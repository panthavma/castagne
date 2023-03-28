extends "../modules/CastagneModule.gd"
# Useful for the functions themselves

# Parses .casp files to make Castagne characters
# CreateFullCharacter will actually parse everything, while GetCharacterMetadata
# will only parse the :Character: block.

# :TODO:Panthavma:20211230:Constants like #DEFINEs
# :TODO:Panthavma:20211230:More flexibility
# :TODO:Panthavma:20211230:Actual conditions
# :TODO:Panthavma:20211230:Better error reporting (requires moving stuff)
# :BUG:Panthavma:20220310:Multiple empty blocks seem to have a problem
# :BUG:Panthavma:20220310:V branch didn't work correctly?
# :TODO:Panthavma:20220310:Comments at end of line
# :TODO:Panthavma:20220403:Parse variables as int if possible

# Errors to find:
# - endif/else missing or too early
# - Function has not enough arguments
# - file can't open
# - static variable analysis ?

# TODO why file gets set to null?
# TODO make editor robust to errors

var logsActive = false

func GetCharacterMetadata(filePath, configData):
	_StartParsing(filePath, configData)
	_ParseMetadata(0)
	return _EndParsing()["Character"]

func CreateFullCharacter(filePath, configData):
	_StartParsing(filePath, configData)
	_ParseFullFile()
	return _EndParsing()

func GetCharacterForEdition(filePath, configData):
	_StartParsing(filePath, configData)
	var res = _ParseForEdition()
	_EndParsing()
	return res

# ------------------------------------------------------------------------------
# Internal Helper Functions

# We want to parse :
# 1. All metadata in child to parent order (so we can figure out the skeleton hierarchy)
# 2. All constants in parent to child order (overwrite)
# 3. All variables in parents to child order (overwrite)
# 4. All states in parents to child order (put the parents states with a prefix)

# We open several files at a time and keep the pointers in mind for this,
# and keep the relevant info in arrays

var _currentLines # Current contents of the line
var _lineIDs # Current line number
var _files # File pointers
var _filePaths
var _curFile

var _metadata
var _constants
var _variables
var _states

var _knownVariables

var _aborting
var _invalidFile
var _errors

var _configData

var PHASES = ["Init", "Action", "Reaction", "Freeze", "Manual", "AI"]

var _moduleVariables
var _letters = ["I", "F", "L", "V", "P", "S"]
var _branchFunctions
func _StartParsing(filePath, configData):
	_configData = configData
	_currentLines = []
	_lineIDs = []
	_files = []
	_filePaths = []
	_curFile = 0
	
	_metadata = {}
	_variables = {}
	_states = {}
	
	_aborting = false
	_invalidFile = false
	_errors = []
	
	# Helpers
	_moduleVariables = {}
	for m in _configData.GetModules():
		m.CopyVariablesEntityParsing(_moduleVariables)
	
	_branchFunctions = {}
	for l in _letters:
		_branchFunctions[l] = funcref(self, "Instruction"+l)
	
	_OpenFile(filePath)

func _AbortParsing():
	for f in _files:
		f.close()
	_aborting = true
	_Log("Aborting Parsing...")
	return null

func _EndParsing(_sendDataEvenIfError = false):
	if(_aborting or _invalidFile):
		return null
	
	for f in _files:
		f.close()
	
	return {
		"Character":_metadata,
		"Variables":_variables,
		"States":_states
	}

func _OpenFile(filePath):
	_Log("Opening file " + filePath)
	
	var file = File.new()
	_lineIDs.append(0)
	_filePaths.append(filePath)
	_currentLines.append("")
	_files.append(file)
	
	if(!file.file_exists(filePath)):
		_FatalError("File " + filePath + " does not exist.")
	else:
		file.open(filePath, File.READ)

func _ParseFullFile():
	if(_aborting):
		return
	
	# 1. Get the metadata and character skeletons
	_Log(">>> Starting to parse the full file.")
	var fileID = 0
	while(fileID < _files.size()):
		var md = _ParseMetadata(fileID)
		fileID += 1
		if(_aborting):
			return
		
		if(md.has("Skeleton")):
			_OpenFile(md["Skeleton"])
		if(_aborting):
			return
	
	
	# 3. Parse the variables
	_Log(">>> Parsing the variables...")
	fileID = _files.size() - 1
	while(fileID >= 0):
		_ParseVariables(fileID)
		fileID -= 1
		if(_aborting):
			return
	
	# Pass the variables from the metadata block to the variables block
	var characterVariables = {}
	for mName in _metadata:
		var v = {
			"Name": mName,
			"Mutability": Castagne.VARIABLE_MUTABILITY.Define,
			"Type": Castagne.VARIABLE_TYPE.Str,
			"Subtype":"",
			"Value": _metadata[mName],
		}
		if(typeof(v["Value"]) == TYPE_INT):
			v["Type"] = Castagne.VARIABLE_TYPE.Int
		characterVariables[mName] = v
	for entityName in _variables:
		Castagne.FuseDataNoOverwrite(_variables[entityName], characterVariables)
	
	# 4. Parse the states
	_Log(">>> Parsing the states...")
	fileID = _files.size() - 1
	while(fileID >= 0):
		_ParseStates(fileID)
		fileID -= 1
		if(_aborting):
			return
	
	# 5. Optimize the code
	_Log(">>> Optimizing...")
	_optimizedStates = []
	for sName in _states:
		_OptimizeActionList(sName)
	
	# 6. Adjusting the variables
	var variables = {}
	for entity in _variables:
		variables[entity] = {}
		for vName in _variables[entity]:
			var v = _variables[entity][vName]
			variables[entity][vName] = v["Value"]
	_variables = variables

var _optimizedStates
func _OptimizeActionList(stateName):
	if(stateName in _optimizedStates):
		return
	_optimizedStates += [stateName]
	var state = _states[stateName]
	
	var parentLevel = 0
	var subName = stateName
	while(subName.begins_with("Parent:")):
		parentLevel += 1
		subName = subName.right(7)
	var entity = _GetEntityNameFromStateName(subName)
	
	for p in PHASES:
		var actionList = _OptimizeActionList_Sublist(state[p], parentLevel, p, state)
		
		var variablesList = state["Variables"].duplicate()
		if(!_variables.has(entity)):
			_variables[entity] = {}
		Castagne.FuseDataNoOverwrite(variablesList, _variables[entity].duplicate(true))
		
		actionList = _OptimizeActionList_Defines(actionList, variablesList)
		
		state[p] = actionList
		
		# TODO Set function not on defines ?

func _OptimizeActionList_Sublist(actionList, parentLevel, p, state):
	var callFuncref = _configData.GetModuleFunctions()["Call"]["ActionFunc"]
	var callParentFuncref = _configData.GetModuleFunctions()["CallParent"]["ActionFunc"]
	
	var branchFuncrefs = _branchFunctions.values()
	
	var loopAgain = true
	while(loopAgain):
		loopAgain = false
		for i in range(actionList.size()):
			var a = actionList[i]
			var calledState = null
			if(a[0] == callFuncref):
				calledState = a[1][0]
			elif(a[0] == callParentFuncref):
				calledState = "Parent:"+a[1][0]
				for _pl in range(parentLevel):
					calledState = "Parent:"+calledState
			elif(a[0] in branchFuncrefs):
				a[1][0] = _OptimizeActionList_Sublist(a[1][0], parentLevel, p, state)
				a[1][1] = _OptimizeActionList_Sublist(a[1][1], parentLevel, p, state)
			
			if(calledState != null and calledState in _states):
				_OptimizeActionList(calledState)
				var calledActionList = _states[calledState][p]
				actionList.remove(i)
				for j in range(calledActionList.size()):
					actionList.insert(i+j, calledActionList[j])
				loopAgain = true
				
				# Variables
				Castagne.FuseDataNoOverwrite(state["Variables"], _states[calledState]["Variables"].duplicate(true))
				
				break
	return actionList

func _OptimizeActionList_Defines(actionList, variablesList):
	var branchFuncrefs = _branchFunctions.values()
	
	for i in range(actionList.size()):
		var a = actionList[i]
		var arguments = a[1]
		if(a[0] in branchFuncrefs):
			a[1][0] = _OptimizeActionList_Defines(a[1][0], variablesList)
			a[1][1] = _OptimizeActionList_Defines(a[1][1], variablesList)
		
		for j in range(arguments.size()):
			if(arguments[j] in variablesList):
				var v = variablesList[arguments[j]]
				if(v["Mutability"] == Castagne.VARIABLE_MUTABILITY.Define):
					arguments[j] = v["Value"]
	return actionList

func _ParseMetadata(fileID):
	_curFile = fileID
	var filepath = _filePaths[fileID]
	_LogD("Parsing Metadata of " + filepath)
	var md = {"Filepath": filepath, "InvalidFile":true}
	if(_GetNextBlock(fileID) != ":Character:"):
		_FatalError("Expected a :Character: block.")
		return md
	
	md = _ParseBlockData(fileID)
	md["Filepath"] = filepath
	
	for mdVarName in md:
		if(mdVarName in _moduleVariables):
			_Error("Character define " + mdVarName + " shares its name with an internal variable. Please use another one.")
	
	Castagne.FuseDataNoOverwrite(_metadata, md)
	
	var baseFilesList = _configData.GetBaseCaspFilePaths()
	var skeletonsList = Castagne.SplitStringToArray(_configData.Get("Skeletons"))
	var idInBaseFiles = baseFilesList.find(filepath)
	var idInSkeletons = skeletonsList.find(filepath)
	
	# Skeleton management
	# Default behaviour:
	#	If a base file, default to base (will be managed later)
	#	If a skeleton, default to base
	#	Otherwise, default to first skeleton
	if(!md.has("Skeleton")):
		if(idInBaseFiles >= 0 or idInSkeletons >= 0):
			md["Skeleton"] = "base"
		elif(skeletonsList.size() > 0):
			md["Skeleton"] = skeletonsList[0]
		else:
			md["Skeleton"] = "base"
	
	while(md.has("Skeleton") and !md["Skeleton"].ends_with(".casp")):
		var skeletonName = str(md["Skeleton"]).strip_edges()
		if(skeletonName == "none"):
			md.erase("Skeleton")
		elif(skeletonName.is_valid_integer()):
			var skelID = skeletonName.to_int()
			if(skeletonsList.size() <= skelID):
				_FatalError("Skeleton "+skeletonName + " not found")
				md.erase("Skeleton")
			else:
				md["Skeleton"] = skeletonsList[skelID]
		elif(skeletonName == "base"):
			if(baseFilesList.size() == 0):
				md.erase("Skeleton")
			elif(idInBaseFiles == 0):
				md.erase("Skeleton")
			elif(idInBaseFiles > 0):
				md["Skeleton"] = baseFilesList[idInBaseFiles -1]
			else:
				md["Skeleton"] = baseFilesList.back()
		else:
		#elif(!_configData.Has("Skeleton-"+skeletonName)):
			_FatalError("Skeleton "+skeletonName + " not found")
			md.erase("Skeleton")
		#else:
		#	md["Skeleton"] = _configData.Get("Skeleton-"+skeletonName)
	
	if(md.has("Skeleton") and md["Skeleton"] in _filePaths):
		_Error("Skeleton "+md["Skeleton"] + " has already been loaded. Do you have a cyclical dependancy?")
		md.erase("Skeleton")
	
	_LogD("Found " + str(md.size()) + " entries. " + ("Has a skeleton : " + md["Skeleton"] if md.has("Skeleton") else "No Skeleton"))
	return md

func _ParseVariables(fileID):
	_curFile = fileID
	_LogD("Parsing Variables of " + _filePaths[fileID])
	
	var nbBlocks = 0
	var nbVariables = 0
	
	var line = _GetNextBlock(fileID)
	
	var variablesFound = {}
	
	while(line != null and line.begins_with(":Variables")):
		line = line.left(line.length()-1).right(1)
		nbBlocks += 1
		
		var entity = _GetEntityNameFromStateName(line)
		if(!variablesFound.has(entity)):
			variablesFound[entity] = []
		
		line = _GetNextLine(fileID)
		while(line != null and !_IsLineBlock(line)):
			if(!_IsLineVariable(line)):
				_Error("Non variable declaration on a variable block.")
				return null
			var variableData = _ExtractVariable(line)
			if(variableData == null):
				return null
			
			if(!_variables.has(entity)):
				_variables[entity] = {}
			
			var variableName = variableData["Name"]
			
			if(variableName in variablesFound[entity]):
				_Error("Variable " + str(variableName) + " is defined twice in the same file and entity.")
			else:
				variablesFound[entity] += [variableName]
			
			_variables[entity][variableName] = variableData
			nbVariables += 1
			
			line = _GetNextLine(fileID)
	
	if(nbBlocks == 0):
		_LogD("Didn't find variables.")
		return null
	
	_LogD("Found " + str(nbVariables) + " variables over "+str(nbBlocks)+" blocks.")
	return nbVariables

func _ParseStates(fileID):
	_curFile = fileID
	_LogD("Parsing States of " + _filePaths[fileID])
	var states = {}
	while(_GetNextBlock(fileID) != null):
		var s = _ParseBlockState(fileID)
		var fp = _filePaths[fileID]
		if(s == null or _aborting):
			return null
		states[s["Name"]] = s
	
	Castagne.FuseDataMoveWithPrefix(_states, states)
	_LogD("Found " + str(states.size()) + " states.")
	return states

func _ParseForEdition():
	var result = {}
	result["NbFiles"] = 0
	
	if(_aborting):
		return result
	
	_parseForEditionPostProcessed = []
	# 1. Parse the character skeleton
	_Log(">>> Starting to parse the full file.")
	var fileID = 0
	while(fileID < _files.size()):
		_parseForEditionPostProcessed += [[]]
		var md = _ParseMetadata(fileID)
		result["NbFiles"] = _files.size()
		var cName = _filePaths[fileID].right(_filePaths[fileID].find_last("/"))
		
		var defaultStateData = {
			"Text":"",
			"LineStart":0,
			"Name":"Character",
			"LineEnd":0,
			"Tag": null,
			"TagLocal": false,
			"Variables":{},
			"FileID": -1,
			
			"Categories": [],
			"StateFlags":[],
			"StateDoc":"",
			"StateFullDoc":"",
			"Overridable":null,
			"Overriding":false,
			"BaseState":null,
			"BaseStateDistance":-1,
			"StateType":Castagne.STATE_TYPE.Normal,
			"CalledStates": [],
			
			"Warnings": [],
		}
		
		var fileData = {
			"States":{"Character":defaultStateData.duplicate(true)},
			"Name": cName,
			"Path": _filePaths[fileID],
		}
		
		for i in range(fileID-1, -1, -1):
			result[i+1] = result[i]
		result[0] = fileData
		
		if(_aborting):
			return result
		
		# Parse states of the file
		var fileStates = {}
		_files[fileID].seek(0)
		var curState = null
		var lineID = 0
		while(!_files[fileID].eof_reached()):
			var line = _files[fileID].get_line()
			lineID += 1
			var lineStripped = line.strip_edges()
			if(lineStripped.begins_with(":") and lineStripped.ends_with(":")):
				if(curState != null):
					fileStates[curState]["LineEnd"] = lineID
				curState = lineStripped.left(lineStripped.length()-1).right(1)
				var sd = defaultStateData.duplicate(true)
				sd["LineStart"] = lineID
				sd["Name"] = curState
				sd["LineEnd"] = lineID
				fileStates[curState] = sd
			elif(curState != null):
				var fscs = fileStates[curState]
				fscs["Text"] += line + "\n"
				fscs["LineEnd"] = lineID
				# Tag extraction
				line = line.strip_edges()
				
				if(line.begins_with("##")):
					var doccontents = line.right(2).strip_edges()
					fscs["StateFullDoc"] += doccontents + "\n"
					if(doccontents.find("TODO") >= 0):
						fscs["StateFlags"] += ["TODO"]
				elif(line.begins_with("#")):
					pass
				elif(_IsLineFunction(line)):
					var f = _ExtractFunction(line)
					if(f[0] == "Tag" and f[1].size() > 0):
						fscs["Tag"] = f[1][0].strip_edges()
						fscs["TagLocal"] = false
					if(f[0] == "TagLocal" and f[1].size() > 0):
						fscs["Tag"] = f[1][0].strip_edges()
						fscs["TagLocal"] = true
					if(f[0] == "Call" and f[1].size() > 0):
						fscs["CalledStates"] += [[f[1][0].strip_edges(),0]]
					if(f[0] == "CallParent" and f[1].size() > 0):
						fscs["CalledStates"] += [[f[1][0].strip_edges(),1]]
					if(f[0] == "_Category" and f[1].size() > 0):
						fscs["Categories"] += [f[1][0].strip_edges()]
					if(f[0] == "_Overridable"):
						var overridableText = ""
						if(f[1].size() > 0):
							overridableText = f[1][0].strip_edges()
						fscs["Overridable"] = overridableText
						fscs["StateFlags"] += ["Overridable"]
					if(f[0] == "_BaseState"):
						fscs["StateType"] = Castagne.STATE_TYPE.BaseState
					if(f[0] == "_Helper"):
						fscs["StateType"] = Castagne.STATE_TYPE.Helper
					#if(f[0] == "_StateDoc" and f[1].size() > 0):
					#	fscs["StateDoc"] = f[1][0].strip_edges()
					if(f[0] == "_StateFlag" and f[1].size() > 0):
						fscs["StateFlags"] += [f[1][0].strip_edges()]
					
					# Bonus state flags, should get a better way in v0.7
					if(f[0] == "Attack"):
						fscs["StateFlags"] += ["Attack"]
					if(f[0] == "AttackFlag" and f[1].size() > 0):
						var acceptedFlags = ["Low", "Overhead"]
						var flag = f[1][0].strip_edges()
						if(flag in acceptedFlags):
							fscs["StateFlags"] += ["Attack"+flag]
				elif(_IsLineVariable(line)):
					var v = _ExtractVariable(line)
					if(v == null):
						_Error("Invalid variable declaration.")
					else:
						if(v["Mutability"] == Castagne.VARIABLE_MUTABILITY.Define):
							if(!fscs["Variables"].has(v["Name"])):
								fscs["Variables"][v["Name"]] = v
						elif(!curState.begins_with("Variables")):
							fscs["Warnings"] += ["Trying to declare a variable inside a state! You can either use a constant (with def), or declare your variable in a 'Variables' block."]
					
					
		#if(curState != null):
		#	fileStates[curState]["LineEnd"] = _lineIDs[fileID]
		
		result[0]["States"] = fileStates
		
		fileID += 1
		if(md.has("Skeleton")):
			_OpenFile(md["Skeleton"])
		if(_aborting):
			return result
	
	for i in range(_files.size()):
		for stateName in result[i]["States"]:
			ParseForEditionPostProcess(i, stateName, result)
	
	return result

var _parseForEditionPostProcessed
func ParseForEditionPostProcess(fileID, stateName, result):
	if(!stateName in result[fileID]["States"]):
		return false
	if(stateName in _parseForEditionPostProcessed[fileID]):
		return true
	_parseForEditionPostProcessed[fileID] += [stateName]
	var state = result[fileID]["States"][stateName]
	state["FileID"] = fileID
	
	var calledStates = state["CalledStates"]
	var forceInheritParentTag = true
	var inheritFromCalledStates = !(stateName in ["Character"])
	var inheritDocFromParent = !(stateName in ["Character"])
	
	# Check if overriding a state
	var _pFID = fileID - 1
	var parentState = null
	while(_pFID >= 0):
		if(result[_pFID]["States"].has(stateName)):
			parentState = result[_pFID]["States"][stateName]
			state["Overriding"] = true
			state["StateFlags"] += ["Overriding"]
			if(state["StateType"] == Castagne.STATE_TYPE.Normal and parentState["StateType"] == Castagne.STATE_TYPE.Helper):
				state["StateType"] = parentState["StateType"]
			
			if(forceInheritParentTag):
				# :TODO:Panthavma:20220514:Add option to not inherit states automatically
				calledStates += [[stateName, _pFID]]
			break
		_pFID -= 1
	
	
	# Inherit data from called states
	var baseStateRef = null
	if(inheritFromCalledStates):
		for calledStateData in calledStates:
			var calledStateName = calledStateData[0]
			for calledStateFileID in range(fileID-calledStateData[1], -1, -1):
				if(ParseForEditionPostProcess(calledStateFileID, calledStateName, result)):
					var calledState = result[calledStateFileID]["States"][calledStateName]
					#var inheritTag = !result[calledStateFileID]["States"][calledStateName]["TagLocal"]
					#if(forceInheritParentTag and calledStateName == stateName):
					#	inheritTag = true
					#if(state["Tag"] == null and inheritTag):
					#	state["Tag"] = result[calledStateFileID]["States"][calledStateName]["Tag"]
					#break
					var inheritedFlags = calledState["StateFlags"].duplicate()
					for flagToErase in ["Overridable", "Overriding"]:
						inheritedFlags.erase(flagToErase)
					
					state["StateFlags"].append_array(inheritedFlags)
					
					if(calledState["StateType"] == Castagne.STATE_TYPE.BaseState and 
						(state["BaseStateDistance"] == -1 or state["BaseStateDistance"] > calledState["BaseStateDistance"]+1)):
						state["BaseStateDistance"] = calledState["BaseStateDistance"]
						state["BaseState"] = calledState["BaseState"]
						baseStateRef = calledState
	
	# Additional checks and inheritance
	if(state["Categories"].empty()):
		if(state["StateType"] in [Castagne.STATE_TYPE.Helper, Castagne.STATE_TYPE.Special]):
			if(parentState != null):
				state["Categories"] = parentState["Categories"]
		elif(baseStateRef != null):
			state["Categories"] = baseStateRef["Categories"]
	
	if(parentState != null and inheritDocFromParent):
		if(state["StateFullDoc"] == ""):
			state["StateFullDoc"] = parentState["StateFullDoc"]
		if(state["StateDoc"] == ""):
			state["StateDoc"] = parentState["StateDoc"]
	
	var entityName = _GetEntityNameFromStateName(stateName)
	if(entityName != "Main" and state["Categories"].empty()):
		state["Categories"] = ["Entities/"+entityName]
	
	if(stateName == "Character"):
		state["StateType"] = Castagne.STATE_TYPE.Special
		state["StateFlags"].erase("Overriding")
	
	if(stateName.begins_with("Variables")):
		state["StateType"] = Castagne.STATE_TYPE.Special
		if(state["Categories"].empty()):
			state["Categories"] = ["Variables"]
	if(stateName.begins_with("Init-")):
		state["StateType"] = Castagne.STATE_TYPE.Special
		
	
	if(state["StateType"] == Castagne.STATE_TYPE.BaseState):
		state["BaseStateDistance"] = 0
		state["BaseState"] = state["Name"]
	
	if(stateName.begins_with("StateTemplate-")):
		state["Categories"] = ["Templates/State Templates"]
	if(stateName.begins_with("EntityTemplate-")):
		state["Categories"] = ["Templates/Entity Templates"]
		if(stateName.ends_with("-Init") or stateName.ends_with("-Variables")):
			state["StateType"] = Castagne.STATE_TYPE.Special
	
	state["StateDoc"] = state["StateFullDoc"]
	var fdFirstLine = state["StateFullDoc"].find("\n")
	if(fdFirstLine >= 0):
		state["StateDoc"] = state["StateFullDoc"].left(fdFirstLine)
	
	if(!state["Variables"].empty() or stateName.begins_with("Variables")):
		state["StateFlags"] += ["CustomEditor"]
	
	# Code Quality Checks
	if(state["StateType"] == Castagne.STATE_TYPE.Normal and state["BaseStateDistance"] == -1):
		state["Warnings"] += ["State doesn't lead back to a base state, and isn't itself a base state or helper."]
	
	if(!state["Warnings"].empty()):
		state["StateFlags"] += ["Warning"]
	
	
	# Remove double flags
	state["StateFlags"].sort()
	var flags = []
	for f in state["StateFlags"]:
		if(flags.empty() or flags.back() != f):
			flags += [f]
	state["StateFlags"] = flags
	
	return true

# ------------------------------------------------------------------------------
# Internal Helper functions



func _GetNextLine(fileID):
	if(_aborting):
		return null
	
	while(true):
		if(_files[fileID].eof_reached()):
			_currentLines[fileID] = null
			return null
		
		var l = _files[fileID].get_line()
		l = l.strip_edges()
		_lineIDs[fileID] += 1
		
		if(_IsValidLine(l)):
			_currentLines[fileID] = l
			return l

func _GetCurrentLine(fileID):
	return _currentLines[fileID]

func _GetNextBlock(fileID):
	var l = _GetCurrentLine(fileID)
	if(l == null):
		return null
	while(!_IsLineBlock(l)):
		l = _GetNextLine(fileID)
		if(l == null):
			return null
	return l

func _Log(text):
	if(!logsActive):
		return
	Castagne.Log("Parser Log : " + str(text))
func _LogD(_text):
	_Log(_text)
func _Warning(text):
	_ErrorCommon("Warning", text, false, false)
func _Error(text):
	_ErrorCommon("Error", text, true, false)
func _FatalError(text):
	_ErrorCommon("Fatal Error", text, true, true)
func _ErrorCommon(type, text, invalidFile, abortParsing):
	var e = {
		"Type":type, "Text":str(text),
		"LineID":_lineIDs[_curFile], "FilePath":_filePaths[_curFile],
		"LineText":_currentLines[_curFile],
	}
	_errors += [e]
	Castagne.Log("Parser "+e["Type"]+" (l."+str(e["LineID"])+" in "+e["FilePath"]+"): " + str(text))
	if(invalidFile or abortParsing):
		_invalidFile = true
	if(abortParsing):
		_AbortParsing()


func _IsLineBlock(line):
	return line.begins_with(":") and line.ends_with(":")
func _IsLineInstruction(line):
	return (!line.begins_with(":")) and line.ends_with(":")
func _IsLineFunction(line):
	return (line.find("(") > 0) and line.ends_with(")") 
func _IsLineVariable(line):
	return (line.begins_with("var ") or line.begins_with("def ") or line.begins_with("internal "))


func _IsValidLine(line):
	return !(line.begins_with("#") or line.empty())





func _ParseBlockData(fileID):
	# TODO translate to int if necessary (?)
	var line = _GetNextLine(fileID)
	var variables = {}
	while(line != null and !_IsLineBlock(line)):
		var splitIndex = line.find(":")
		var left = line.left(splitIndex)
		var right = line.right(splitIndex+1)
		right = right.strip_edges()
		variables[left] = right
		line = _GetNextLine(fileID)
	return variables

var _currentState = {}
func _ParseBlockState(fileID):
	var stateName = _GetCurrentLine(fileID)
	stateName = stateName.left(stateName.length()-1).right(1)
	
	if(stateName.begins_with("Variables")):
		_Error("Found a variables block after variables are handled.")
		return null
	
	var entity = _GetEntityNameFromStateName(stateName)
	if(!_variables.has(entity)):
		_variables[entity] = {}
	
	_currentState = {
		"Name": stateName,
		"Type": null,
		"Tag": null, "TagLocal":false,
		"Entity":entity,
		"Variables":{},
	}
	
	
	var line = _GetNextLine(fileID)
	
	var stateActions = {}
	for p in PHASES:
		stateActions[p] = []
	var reserveSubblocks = []
	var reserveSubblocksList = []
	var currentSubblock = null
	var currentSubblockList = ""
	while(line != null and !_IsLineBlock(line)):
		if(_IsLineFunction(line)):
			var f = _ExtractFunction(line)
			if(f[0] in _configData.GetModuleFunctions()):
				var fData = _configData.GetModuleFunctions()[f[0]]
				if(f[1].size() in fData["NbArgs"]):
					# type check
					var types = fData["Types"]
					var typeCheck = true
					for i in range(f[1].size()):
						var a = str(f[1][i])
						var isKnownVariable = ((a in _variables[entity]) or (a in _currentState["Variables"]))
						var t = types[i]
						if(t == "int"):
							if(!a.is_valid_integer() and !isKnownVariable):
								_Error("Function " + f[0] + " argument " + str(i) + " ("+a+") is not an integer.")
								typeCheck = false
						elif(t == "var"):
							if(!isKnownVariable):
								_Error("Function " + f[0] + " argument " + str(i) + " ("+a+") is not a registered variable.")
								typeCheck = false
					if(typeCheck):
						var action = null
						var parseData = {
							"CurrentState": _currentState,
						}
						if(fData["ParseFunc"] == null):
							action = StandardParseFunction(f[0], f[1])
						else:
							action = fData["ParseFunc"].call_func(self, f[1], parseData)
						
						if(action != null):
							var d = [action["Func"], action["Args"]]
							for p in PHASES:
								if(p in action["Flags"]):
									if(currentSubblock == null):
										stateActions[p] += [d]
									else:
										currentSubblock[currentSubblockList][p] += [d]
				else:
					_Error(f[0] + " : Expected " + str(fData["NbArgs"]) + " arguments, got " + str(f[1].size()) + "("+str(f[1])+")")
			else:
				_Error("Function " + f[0] + " doesn't exist or isn't registered properly.")
		elif(_IsLineVariable(line)):
			var v = _ExtractVariable(line)
			if(v == null):
				_Error("Invalid Variable declaration.")
			else:
				if(v["Mutability"] == Castagne.VARIABLE_MUTABILITY.Define):
					if(_currentState["Variables"].has(v["Name"])):
						_Error("Trying to declare define " + v["Name"] + " several times in the same state!")
					elif(_variables[entity].has(v["Name"]) and _variables[entity][v["Name"]]["Mutability"] != Castagne.VARIABLE_MUTABILITY.Define):
						_Error("Trying to define " + v["Name"]+", but it already is a variable.")
					else:
						_currentState["Variables"][v["Name"]] = v
				else:
					_Error("Trying to declare a variable inside a state! You can either use a constant (with def), or declare your variable in a 'Variables' block.")
		else:
			var letter = line.left(1)
			var letterArgs = line.left(line.length()-1).right(1)
			
			if(line == "endif"):
				var branch = currentSubblock
				if(currentSubblock == null):
					_Error("Endif found without a branch!")
					line = _GetNextLine(fileID)
					continue
				
				if(branch["Letter"] == "S"):
					pass
				
				currentSubblock = reserveSubblocks.pop_back()
				currentSubblockList = reserveSubblocksList.pop_back()
				for p in PHASES:
					var phaseToGet = p
					if(branch["Letter"] == "P"):
						phaseToGet = "Manual"
					
					var args = [branch["True"][phaseToGet], branch["False"][phaseToGet], branch["LetterArgs"]]
					var d = [branch["Func"], args]
					
					if(args[0].empty() and args[1].empty()):
						continue
					
					if(currentSubblock == null):
						stateActions[p] += [d]
					else:
						currentSubblock[currentSubblockList][p] += [d]
			elif(line == "else"):
				if(currentSubblock == null):
					_Error("Else found without a branch!")
					line = _GetNextLine(fileID)
					continue
				if(currentSubblockList == "False"):
					_Error("Else found while already in an else block!")
					line = _GetNextLine(fileID)
					continue
				currentSubblockList = "False"
			elif(letter in _branchFunctions): # Inputs
				reserveSubblocks.push_back(currentSubblock)
				reserveSubblocksList.push_back(currentSubblockList)
				currentSubblockList = "True"
				
				currentSubblock = {
					"Func": _branchFunctions[letter],
					"FuncName":"Instruction " + letter,
					"LetterArgs":letterArgs,
					"Letter": letter,
					"True": {}, "False":{},
					"Flags":["Init", "Action", "Transition", "Freeze", "Manual"],
				}
				for p in PHASES:
					currentSubblock["True"][p] = []
					currentSubblock["False"][p] = []
				
			else:
				_Error("Branch type not recognized: " + letter)
		
		line = _GetNextLine(fileID)
		
		if(_aborting):
			return null
	for p in PHASES:
		_currentState[p] = stateActions[p]
	return _currentState

func _ExtractFunction(line):
	var splitID = line.find("(")
	var functionName = line.left(splitID)
	var splitVars = line.left(line.length()-1).right(splitID+1).split(",")
	
	var args = []
	for v in splitVars:
		args += [v.strip_edges()]
	
	if(args.size() == 1 and args[0] == ""):
		args = []
	
	return [functionName, args]

func _GetEntityNameFromStateName(stateName):
	var entity = "Main"
	var sep = stateName.find("--")
	if(sep >= 0):
		if(stateName.begins_with("Variables") or stateName.begins_with("Init")):
			stateName = stateName.right(sep+2)
			sep = stateName.find("-")
			if(sep >= 0):
				stateName = stateName.left(sep)
			entity = stateName
		else:
			entity = stateName.left(sep)
	return entity

onready var KnownVariableTypes = {"int":Castagne.VARIABLE_TYPE.Int, "str":Castagne.VARIABLE_TYPE.Str}
func _ExtractVariable(line):
	# Structure: var NAME int() = 5
	var variableMutability = null
	var variableValue = null
	var variableName = null
	var variableType = null
	var variableSubtype = null
	
	if(line.begins_with("var ")):
		line = line.right(4)
		variableMutability = Castagne.VARIABLE_MUTABILITY.Variable
	elif(line.begins_with("def ")):
		line = line.right(4)
		variableMutability = Castagne.VARIABLE_MUTABILITY.Define
	elif(line.begins_with("internal ")):
		line = line.right(9)
		variableMutability = Castagne.VARIABLE_MUTABILITY.Internal
	else:
		_Error("Couldn't find variable mutability.")
		return null
	
	line = line.strip_edges()
	var sep = line.find("=")
	if(variableMutability == Castagne.VARIABLE_MUTABILITY.Internal):
		if(sep >= 0):
			_Error("Can't assign an internal variable.")
			return null
	elif(sep >= 0):
		variableValue = line.right(sep+1).strip_edges()
		line = line.left(sep).strip_edges()
		if(variableValue.empty()):
			_Error("Variable declaration has an '=' sign but no assignation.")
			return null
	
	
	var splits = line.split(" ", false)
	var nbSplits = splits.size()
	if(nbSplits != 1 and nbSplits != 2):
		_Error("Too many words in variable declaration. Please keep your variable names as one word.")
		return null
	variableName = splits[0]
	
	# Internal var check
	var hasInternalName = (variableName in _moduleVariables)
	if(hasInternalName and variableMutability != Castagne.VARIABLE_MUTABILITY.Internal):
		_Error("Variable " + str(variableName) + " has the same name as an internal variable. If this is intentional and you know what you're doing, use 'internal'.")
		return null
	if(!hasInternalName and variableMutability == Castagne.VARIABLE_MUTABILITY.Internal):
		if(hasInternalName):
			variableType = _moduleVariables[variableName]["Type"]
			variableValue = _moduleVariables[variableName]["Value"]
		else:
			_Error("Variable " + str(variableName) + " is marked as internal but no internal variable of the name exists.")
			return null
	
	
	# Type check
	if(variableMutability == Castagne.VARIABLE_MUTABILITY.Internal):
		if(nbSplits == 2):
			_Error("Can't choose the type of an internal variable.")
			return null
	elif(nbSplits == 2):
		var lineType = splits[1]
		sep = lineType.find("(")
		if(sep == -1 or !lineType.ends_with(")")):
			_Error("Missing parenthesis on variable type.")
			return null
		variableSubtype = lineType.left(lineType.length()-1).right(sep+1)
		lineType = lineType.left(sep)
		# TODO parse / use the subtype
		
		
		if(!lineType in KnownVariableTypes):
			_Error("Unknown variable type: "+lineType+".")
			return null
		variableType = KnownVariableTypes[lineType]
	
	
	# Default behaviors
	if(variableType == null):
		if(variableValue != null and !variableValue.is_valid_integer()):
			variableType = Castagne.VARIABLE_TYPE.Str
		else:
			variableType = Castagne.VARIABLE_TYPE.Int
	
	if(variableValue == null):
		if(variableType == Castagne.VARIABLE_TYPE.Int):
			variableValue = "0"
		else:
			variableValue = ""
	
	if(variableType == Castagne.VARIABLE_TYPE.Int):
		if(variableValue.is_valid_integer()):
			variableValue = variableValue.to_int()
		else:
			variableValue = 0
			_Error("Int variable but the value isn't a valid integer.")
	
	return {
		"Name": variableName,
		"Mutability": variableMutability,
		"Type": variableType,
		"Subtype":variableSubtype,
		"Value": variableValue,
	}


# ------------------------------------------------------------------------------
# Standard State functions

func StandardParseFunction(functionName, args):
	var fData = _configData.GetModuleFunctions()[functionName]
	return {
		"Func":fData["ActionFunc"],
		"FuncName":functionName,
		"Args":args,
		"Flags":fData["Flags"],
	}

func InstructionI(args, stateHandle):
	var inputName = ArgStr(args, stateHandle, 2)
	var inputs = stateHandle.EntityGet("_Inputs")
	
	if(!inputName in inputs):
		Castagne.Error("I"+inputName+" : Input not found !")
		return
	
	InstructionBranch(args, stateHandle, inputs[inputName])

func InstructionF(args, stateHandle):
	var letterArgs = str(args[2])
	
	var frameID = stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame")
	var validFrames = []
	
	var rangeSepID = letterArgs.find("-")
	var plusSepID = letterArgs.find("+")
	if(rangeSepID > 0): # A-B
		var start = ArgInt([letterArgs.left(rangeSepID)], stateHandle, 0)
		var end = ArgInt([letterArgs.right(rangeSepID+1)], stateHandle, 0)
		for i in range(start, end+1):
			validFrames += [i]
	elif(plusSepID > 0): # A+
		var minFrame = ArgInt([letterArgs.left(plusSepID)], stateHandle, 0)
		if(frameID >= minFrame):
			validFrames += [frameID]
	else: # A
		validFrames += [ArgInt([letterArgs], stateHandle, 0)]
	
	letterArgs = validFrames
	
	InstructionBranch(args, stateHandle, frameID in validFrames)
func InstructionS(args, stateHandle):
	InstructionF(args, stateHandle)

func InstructionL(args, stateHandle):
	var flagName = args[2]
	InstructionBranch(args, stateHandle, flagName in stateHandle.EntityGet("_Flags"))

func InstructionV(args, stateHandle):
	var varName = args[2]
	var cond = ParseCondition(varName, stateHandle)
	InstructionBranch(args, stateHandle, cond)

func InstructionP(args, stateHandle):
	var phaseName = ArgStr(args, stateHandle, 2)
	var initPhaseName = stateHandle.GetPhase()
	var cond = (initPhaseName == phaseName)
	stateHandle.SetPhase("Manual")
	InstructionBranch(args, stateHandle, cond)
	stateHandle.SetPhase(initPhaseName)

func InstructionBranch(args, stateHandle, condition):
	var actionListTrue = args[0]
	var actionListFalse = args[1]
	
	var actionList = actionListFalse
	if(condition):
		actionList = actionListTrue
	
	var phase = stateHandle.GetPhase()
	
	stateHandle.Engine().ExecuteFighterScript({"Name":"Branch", phase:actionList}, stateHandle)
	

func ParseCondition(s, stateHandle):
	var inferiorPos = s.find("<")
	var superiorPos = s.find(">")
	var equalPos = s.find("=")
	var firstPart = s
	var secondPart = 0
	var condition = 2
	var splitPos = max(inferiorPos, superiorPos)
	if(splitPos < 0):
		splitPos = equalPos
	
	if(inferiorPos >= 0 and superiorPos >= 0):
		ModuleError("ParseCondition: Found both < and > in the same condition", stateHandle)
		return false
	if(splitPos >= 0):
		firstPart = s.left(splitPos)
		secondPart = s.right(splitPos+1)
		condition = 0
		condition += (2 if superiorPos>=0 else 0)
		condition -= (2 if inferiorPos>=0 else 0)
		
		if(secondPart.begins_with("=")):
			secondPart = secondPart.right(1)
			condition -= sign(condition)
	
	firstPart = ArgInt([firstPart], stateHandle, 0, 0)
	secondPart = ArgInt([secondPart], stateHandle, 0, 0)
	var diff = firstPart - secondPart
	
	if(diff == 0):
		return (abs(condition) <= 1)
	return (sign(condition) == sign(diff))
