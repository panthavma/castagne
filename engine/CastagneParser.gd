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

func GetCharacterMetadata(filePath):
	_StartParsing(filePath)
	_ParseMetadata(0)
	return _EndParsing()["Character"]

func CreateFullCharacter(filePath):
	_StartParsing(filePath)
	_ParseFullFile()
	return _EndParsing()

func GetCharacterForEdition(filePath):
	_StartParsing(filePath)
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

var _aborting
var _invalidFile
var _errors

var PHASES = ["Init", "Action", "Transition", "Freeze", "Manual"]

func _StartParsing(filePath):
	_currentLines = []
	_lineIDs = []
	_files = []
	_filePaths = []
	_curFile = 0
	
	_metadata = {}
	_constants = {}
	_variables = {}
	_states = {}
	
	_aborting = false
	_invalidFile = false
	_errors = []
	
	_OpenFile(filePath)

func _AbortParsing():
	for f in _files:
		f.close()
	_aborting = true
	_Log("Aborting Parsing...")
	return null

func _EndParsing(sendDataEvenIfError = false):
	if(_aborting or _invalidFile):
		return null
	
	for f in _files:
		f.close()
	
	return {
		"Character":_metadata,
		"Constants":_constants,
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
	
	# 2. Parse the constants
	_Log(">>> Parsing the constants...")
	fileID = _files.size() - 1
	while(fileID >= 0):
		_ParseConstants(fileID)
		fileID -= 1
		
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
	
	var callFuncref = Castagne.functions["Call"]["ActionFunc"]
	var callParentFuncref = Castagne.functions["CallParent"]["ActionFunc"]
	for p in PHASES:
		var loopAgain = true
		while(loopAgain):
			loopAgain = false
			var actionList = state[p]
			for i in range(actionList.size()):
				var a = actionList[i]
				var calledState = null
				if(a[0] == callFuncref):
					calledState = a[1][0]
				elif(a[0] == callParentFuncref):
					calledState = "Parent:"+a[1][0]
					for pl in range(parentLevel):
						calledState = "Parent:"+calledState
				
				if(calledState != null and calledState in _states):
					_OptimizeActionList(calledState)
					var calledActionList = _states[calledState][p]
					actionList.remove(i)
					for j in range(calledActionList.size()):
						actionList.insert(i+j, calledActionList[j])
					loopAgain = true
					
					# Tag Transfer
					if(state["Tag"] == null and !_states[calledState]["TagLocal"]):
						state["Tag"] = _states[calledState]["Tag"]
					
					break


func _ParseMetadata(fileID):
	_curFile = fileID
	_LogD("Parsing Metadata of " + _filePaths[fileID])
	if(_GetNextBlock(fileID) != ":Character:"):
		_FatalError("Expected a :Character: block.")
		return null
	
	var md = _ParseBlockData(fileID)
	md["Filepath"] = _filePaths[fileID]
	Castagne.FuseDataNoOverwrite(_metadata, md)
	
	# Skeleton management
	if(!md.has("Skeleton")):
		md["Skeleton"] = Castagne.configData["Skeleton-default"]
	
	while(md.has("Skeleton") and !md["Skeleton"].ends_with(".casp")):
		var skeletonName = str(md["Skeleton"]).strip_edges()
		if(skeletonName == "none"):
			md.erase("Skeleton")
		elif(!Castagne.configData.has("Skeleton-"+skeletonName)):
			_FatalError("Skeleton "+skeletonName + " not found")
			md.erase("Skeleton")
		else:
			md["Skeleton"] = Castagne.configData["Skeleton-"+skeletonName]
	
	_LogD("Found " + str(md.size()) + " entries. " + ("Has a skeleton : " + md["Skeleton"] if md.has("Skeleton") else "No Skeleton"))
	return md

func _ParseConstants(fileID):
	_curFile = fileID
	_LogD("Parsing Constants of " + _filePaths[fileID])
	if(_GetNextBlock(fileID) != ":Constants:"):
		_LogD("Didn't find constants.")
		return null
	
	var data = _ParseBlockData(fileID)
	Castagne.FuseDataOverwrite(_constants, data)
	_LogD("Found " + str(data.size()) + " entries.")
	return data

func _ParseVariables(fileID):
	_curFile = fileID
	_LogD("Parsing Variables of " + _filePaths[fileID])
	if(_GetNextBlock(fileID) != ":Variables:"):
		_LogD("Didn't find variables.")
		return null
	
	var data = _ParseBlockData(fileID)
	Castagne.FuseDataOverwrite(_variables, data)
	_LogD("Found " + str(data.size()) + " entries.")
	return data

func _ParseStates(fileID):
	_curFile = fileID
	_LogD("Parsing States of " + _filePaths[fileID])
	var states = {}
	while(_GetNextBlock(fileID) != null):
		var s = _ParseBlockState(fileID)
		if(s == null):
			break
		if(_aborting):
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
		if(_aborting):
			return result
		
		# Parse states of the file
		var fileStates = {}
		_files[fileID].seek(0)
		var cName = _filePaths[fileID]
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
				fileStates[curState] = {
					"Text":"",
					"LineStart":lineID,
					"Name":curState,
					"LineEnd":lineID,
					"Tag": null,
					"TagLocal": false,
					"CalledStates": [],
				}
			elif(curState != null):
				fileStates[curState]["Text"] += line + "\n"
				
				# Tag extraction
				line = line.strip_edges()
				
				if(_IsLineFunction(line)):
					var f = _ExtractFunction(line)
					if(f[0] == "Tag" and f[1].size() > 0):
						fileStates[curState]["Tag"] = f[1][0].strip_edges()
						fileStates[curState]["TagLocal"] = false
					if(f[0] == "TagLocal" and f[1].size() > 0):
						fileStates[curState]["Tag"] = f[1][0].strip_edges()
						fileStates[curState]["TagLocal"] = true
					if(f[0] == "Call" and f[1].size() > 0):
						fileStates[curState]["CalledStates"] += [[f[1][0].strip_edges(),0]]
					if(f[0] == "CallParent" and f[1].size() > 0):
						fileStates[curState]["CalledStates"] += [[f[1][0].strip_edges(),1]]
		if(curState != null):
			fileStates[curState]["LineEnd"] = _lineIDs[fileID]
		
		var fileData = {
			"States":fileStates,
			"Name": cName,
			"Path": _filePaths[fileID],
		}
		
		for i in range(fileID-1, -1, -1):
			result[i+1] = result[i]
		result[0] = fileData
		
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
	if(stateName in ["Character", "Variables"]):
		return false
	if(!stateName in result[fileID]["States"]):
		return false
	if(stateName in _parseForEditionPostProcessed[fileID]):
		return true
	_parseForEditionPostProcessed[fileID] += [stateName]
	var state = result[fileID]["States"][stateName]
	
	var calledStates = state["CalledStates"]
	var forceInheritParentTag = true
	
	# :TODO:Panthavma:20220514:Add option to not inherit states automatically
	if(forceInheritParentTag and fileID > 0):
		calledStates += [[stateName, fileID - 1]]
	
	# Check called states
	for calledStateData in calledStates:
		var calledStateName = calledStateData[0]
		for calledStateFileID in range(fileID-calledStateData[1], -1, -1):
			if(ParseForEditionPostProcess(calledStateFileID, calledStateName, result)):
				var inheritTag = !result[calledStateFileID]["States"][calledStateName]["TagLocal"]
				if(forceInheritParentTag and calledStateName == stateName):
					inheritTag = true
				if(state["Tag"] == null and inheritTag):
					state["Tag"] = result[calledStateFileID]["States"][calledStateName]["Tag"]
				break

# ------------------------------------------------------------------------------
# Internal Helper functions



func _GetNextLine(fileID):
	if(_aborting):
		return null
	
	while(true):
		if(_files[fileID].eof_reached()):
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
	Castagne.Log("Parser Log : " + str(text))
func _LogD(_text):
	return
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
	var line = _GetNextLine(fileID)
	
	if(line == null):
		return null
	
	_currentState = {
		"Name": stateName,
		"Type": null,
		"Tag": null, "TagLocal":false,
	}
	
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
			if(f[0] in Castagne.functions):
				var fData = Castagne.functions[f[0]]
				if(f[1].size() in fData["NbArgs"]):
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
		
		else:
			var letter = line.left(1)
			var letterArgs = line.left(line.length()-1).right(1)
			var letters = ["I", "F", "L", "V", "P", "S"]
			
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
			elif(letter in letters): # Inputs
				reserveSubblocks.push_back(currentSubblock)
				reserveSubblocksList.push_back(currentSubblockList)
				currentSubblockList = "True"
				
				currentSubblock = {
					"Func": funcref(self, "Instruction"+letter),
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



# ------------------------------------------------------------------------------
# Standard State functions

func StandardParseFunction(functionName, args):
	var fData = Castagne.functions[functionName]
	return {
		"Func":fData["ActionFunc"],
		"FuncName":functionName,
		"Args":args,
		"Flags":fData["Flags"],
	}

func InstructionI(args, eState, data):
	var state = data["State"]
	var inputName = ArgStr(args, eState, 2)
	var inputs = state["Players"][eState["Player"]]["Inputs"]
	
	if(!inputName in inputs):
		Castagne.Error("I"+inputName+" : Input not found !")
		return
	
	InstructionBranch(args, eState, data, inputs[inputName])

func InstructionF(args, eState, data):
	var letterArgs = args[2]
	var state = data["State"]
	
	var frameID = state["FrameID"] - eState["StateStartFrame"]
	var validFrames = []
	
	var rangeSepID = letterArgs.find("-")
	var plusSepID = letterArgs.find("+")
	if(rangeSepID > 0): # A-B
		var start = ArgInt([letterArgs.left(rangeSepID)], eState, 0)
		var end = ArgInt([letterArgs.right(rangeSepID+1)], eState, 0)
		for i in range(start, end+1):
			validFrames += [i]
	elif(plusSepID > 0): # A+
		var minFrame = ArgInt([letterArgs.left(plusSepID)], eState, 0)
		if(frameID >= minFrame):
			validFrames += [frameID]
	else: # A
		validFrames += [ArgInt([letterArgs], eState, 0)]
	
	letterArgs = validFrames
	
	InstructionBranch(args, eState, data, frameID in validFrames)
func InstructionS(args, eState, data):
	InstructionF(args, eState, data)

func InstructionL(args, eState, data):
	var flagName = args[2]
	InstructionBranch(args, eState, data, flagName in eState["Flags"])

func InstructionV(args, eState, data):
	var varName = args[2]
	var cond = ParseCondition(varName, eState)
	InstructionBranch(args, eState, data, cond)

func InstructionP(args, eState, data):
	var phaseName = ArgStr(args, eState, 2)
	var initPhaseName = data["Phase"]
	var cond = (initPhaseName == phaseName)
	data["Phase"] = "Manual"
	InstructionBranch(args, eState, data, cond)
	data["Phase"] = initPhaseName

func InstructionBranch(args, eState, moduleCallbackData, condition):
	var actionListTrue = args[0]
	var actionListFalse = args[1]
	
	var actionList = actionListFalse
	if(condition):
		actionList = actionListTrue
	
	var phase = moduleCallbackData["Phase"]
	
	moduleCallbackData["Engine"].ExecuteFighterScript({"Name":"Branch", phase:actionList}, eState["EID"], moduleCallbackData)
	

func ParseCondition(s, eState):
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
		ModuleError("ParseCondition: Found both < and > in the same condition", eState)
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
	
	firstPart = ArgInt([firstPart], eState, 0, 0)
	secondPart = ArgInt([secondPart], eState, 0, 0)
	var diff = firstPart - secondPart
	
	if(diff == 0):
		return (abs(condition) <= 1)
	return (sign(condition) == sign(diff))
