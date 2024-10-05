# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Parses .casp files to make Castagne characters
# CreateFullCharacter will actually parse everything, while GetCharacterMetadata
# will only parse the :Character: block.
# Is scheduled for rework in v0.7, until then it's staying as spaghetti


# Useful to get access to functions and implement branches
extends "../modules/CastagneModule.gd"



# Errors the compiler needs to find:
# - endif/else missing or too early
# - Function has not enough arguments
# - file can't open
# - static variable analysis ?

var logsActive = false

func GetCharacterMetadata(filePath, configData):
	_StartParsing(filePath, configData)
	_ParseMetadata(0)
	var r = _EndParsing()
	if(r != null):
		return r["Character"]
	return null

func GetCharacterInfo(filePath, configData):
	_StartParsing(filePath, configData, true)
	_ParseFullFile(true)
	return _EndParsing()

func CreateFullCharacter(filePath, configData, resetErrors = true):
	_StartParsing(filePath, configData, resetErrors)
	_ParseFullFile()
	return _EndParsing()

func GetCharacterForEdition(filePath, configData):
	_StartParsing(filePath, configData)
	var res = _ParseForEdition()
	_EndParsing()
	return res

func ResetErrors():
	_errors = []

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
var _metadataSubentities
var _specblockDefines
var _constants
var _variables
var _states
var _transformedData
var _subentityBaseDefines

var _knownVariables

var _aborting
var _invalidFile
var _errors

var _configData

var PHASES = ["Init", "Action", "Reaction", "Freeze", "Manual", "AI", "Subentity", "Halt"]

var _moduleVariables
var _letters = ["I", "F", "L", "V", "P", "S"]
var _branchFunctions
func _StartParsing(filePath, configData, resetErrors = true):
	_configData = configData
	_currentLines = []
	_lineIDs = []
	_files = []
	_filePaths = []
	_curFile = 0

	_metadata = {}
	_metadataSubentities = {}
	_specblockDefines = {}
	_variables = {}
	_states = {}
	_transformedData = {}
	_subentityBaseDefines = {}

	_aborting = false
	_invalidFile = false
	_currentEntity = null
	if(resetErrors):
		ResetErrors()

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
		"Subentities":_metadataSubentities,
		"Variables":_variables,
		"States":_states,
		"TransformedData":_transformedData,
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

func _ParseFullFile(stopAfterSpecblocks = false):
	if(_aborting):
		return


	# 1. Get the metadata and character skeletons
	var profiling = [OS.get_ticks_usec()]
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

	# 1b. Get the specblocks values
	#profiling.push_back(OS.get_ticks_usec())
	_Log(">>> Parsing the spec blocks")
	_specblockDefines = {}
	fileID = _files.size() - 1
	while(fileID >= 0):
		var newDefines = _ParseSpecblocks(fileID)
		for dName in newDefines:
			var v = {
				"Name": dName,
				"Mutability": Castagne.VARIABLE_MUTABILITY.Define,
				"Type": Castagne.VARIABLE_TYPE.Str,
				"Subtype":"",
				"Value": newDefines[dName],
			}
			if(typeof(v["Value"]) == TYPE_INT):
				v["Type"] = Castagne.VARIABLE_TYPE.Int
			_specblockDefines[dName] = v
		fileID -= 1
		if(_aborting):
			return
	
	var moduleSpecblocksMain = _configData.GetModuleSpecblocksMainEntity()
	for sb in moduleSpecblocksMain.values():
		var sbDefaultDefines = sb.GetDefaultDefines()
		for dName in sbDefaultDefines:
			if dName in _specblockDefines:
				continue
			var v = {
				"Name": dName,
				"Mutability": Castagne.VARIABLE_MUTABILITY.Define,
				"Type": Castagne.VARIABLE_TYPE.Str,
				"Subtype":"",
				"Value": sbDefaultDefines[dName],
			}
			if(typeof(v["Value"]) == TYPE_INT):
				v["Type"] = Castagne.VARIABLE_TYPE.Int
			_specblockDefines[dName] = v
	
	for dName in _specblockDefines:
		if(typeof(_specblockDefines[dName]["Type"]) == TYPE_INT):
			_specblockDefines[dName]["Type"] = Castagne.VARIABLE_TYPE.Int
	
	# --- Transform defined data
	for sbName in moduleSpecblocksMain:
		var sb = moduleSpecblocksMain[sbName]
		var tData = sb.TransformDefinedData(_specblockDefines)
		if(tData != null):
			_transformedData[sbName] = tData
	
	if(stopAfterSpecblocks):
		return
	
	# 2. Parse the variables
	profiling.push_back(OS.get_ticks_usec())
	_Log(">>> Parsing the variables...")
	fileID = _files.size() - 1
	while(fileID >= 0):
		_ParseVariables(fileID)
		fileID -= 1
		if(_aborting):
			return

	# Pass the variables from the metadata and specblockdefines block to the variables block
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
	for entityName in _variables:
		Castagne.FuseDataNoOverwrite(_variables[entityName], _specblockDefines)
	
	
	_subentityBaseDefines = {}
	
	for vName in _variables[null]:
		var v = _variables[null][vName]
		if(v["Mutability"] == Castagne.VARIABLE_MUTABILITY.Define):
			_subentityBaseDefines[vName] = v.duplicate()
	
	
	# 3. Parse the states
	profiling.push_back(OS.get_ticks_usec())
	_Log(">>> Parsing the states...")
	fileID = _files.size() - 1
	while(fileID >= 0):
		_ParseStates(fileID)
		fileID -= 1
		if(_aborting):
			return

	# 4-5. Optimize the code
	profiling.push_back(OS.get_ticks_usec())
	_Log(">>> Optimizing...")
	_optimizedStates = {}
	for p in PHASES:
		_optimizedStates[p] = []
	_optimizedStates_CallAfter = {}
	_optimizeActionList_parentWarnings = []
	_OptimizeActionListPhase0()
	for sName in _states:
		_OptimizeActionListPhase1(sName)
	_OptimizeActionListPhase1_After()
	_optimizedStates2 = []
	profiling.push_back(OS.get_ticks_usec())
	variablesList_OptimPhase2 = {}
	for sName in _states:
		_OptimizeActionListPhase2(sName)
	_OptimizeActionListPhase3()

	# 6. Tag states correctly
	profiling.push_back(OS.get_ticks_usec())
	_Log(">>> State Tagging")
	for sName in _states:
		_RuntimeStateTagging(sName)

	# 7. Adjusting the variables
	profiling.push_back(OS.get_ticks_usec())
	var variables = {}
	for entity in _variables:
		variables[entity] = {}
		for vName in _variables[entity]:
			var v = _variables[entity][vName]
			if(v["Mutability"] != Castagne.VARIABLE_MUTABILITY.Variable):
				continue
			variables[entity][vName] = v["Value"]
	_variables = variables

	profiling.push_back(OS.get_ticks_usec())
	_PrintProfilingData("["+str(_filePaths[0])+"] GameParse", profiling)

func _PrintProfilingData(title, profiling):
	var shortText = false
	var t = title + " Time: " + str((profiling.back() - profiling.front())/1000000.0)
	
	var profilingTitles = [
		"Metadata + Specblocks",
		"            Variables",
		"        State Parsing",
		"        Optim Phase 1",
		"      Optim Phase 2+3",
		"            State Tag",
		"      Variable Adjust",
	]
	
	if(shortText):
		t += " ( "
		for i in range(profiling.size()-1):
			t += str(i+1)+"/"+str((profiling[i+1] - profiling[i])/1000000.0)+" "
		t+= ")"
	else:
		for i in range(profiling.size()-1):
			t += "\n"
			if i < profilingTitles.size():
				t += profilingTitles[i]
			else:
				t += str(i)
			t += ": "+str((profiling[i+1] - profiling[i])/1000000.0)
	print(t)

func _OptimizeActionListPhase0():
	var entities = _metadataSubentities.keys()
	_optimizedEntities_Phase0 = []
	
	var statesPerEntity = {}
	for entity in entities:
		statesPerEntity[entity] = {}
	
	for stateName in _states:
		var entity = _GetEntityNameFromStateName(stateName)
		if(entity != null):
			var pureStateName = _GetPureStateNameFromStateName(stateName)
			var np = _ExtractParentFromPureStateName(pureStateName)
			var noParentStateName = np[0]
			var parentLevel = np[1]
			
			if(!statesPerEntity[entity].has(noParentStateName)):
				statesPerEntity[entity][noParentStateName] = []
			statesPerEntity[entity][noParentStateName] += [parentLevel]
	
	for entity in entities:
		var heritageChain = []
		var curEntityInChain = entity
		while(curEntityInChain != null):
			if(!_metadataSubentities.has(curEntityInChain)):
				_Error("Subentity does not exist: "+str(curEntityInChain)+" (from subentity "+str(entity)+")")
				return null
			var chainMD = _metadataSubentities[curEntityInChain]
			var skeleton = "Base"
			if(chainMD.has("Skeleton")):
				skeleton = chainMD["Skeleton"]
			if(skeleton == "none" or skeleton == "None"):
				skeleton = null
			
			if(heritageChain.has(skeleton)):
				_Error("Subentity heritage chain: Subentity "+str(entity)+" has a cyclic dependancy ! ("+str(curEntityInChain)+" -> "+str(skeleton)+")")
				return
			if(skeleton != null):
				heritageChain.push_back(skeleton)
			curEntityInChain = skeleton
		for i in range(heritageChain.size()-1, -1, -1):
			_OptimizeActionListPhase0_Variables(heritageChain[i])
		_OptimizeActionListPhase0_Variables(entity)
		
		for parentEntity in heritageChain:
			for noParentStateName in statesPerEntity[parentEntity]:
				var parentLevels = statesPerEntity[parentEntity][noParentStateName]
				var parentBaseStateName = parentEntity+"---"+noParentStateName
				var childBaseStateName = entity+"---"+noParentStateName
				while(_states.has(childBaseStateName)):
					childBaseStateName = _GetParentStateName(childBaseStateName)
				
				for pl in parentLevels:
					var parentStateName = _GetParentStateName(parentBaseStateName, pl)
					var childStateName = _GetParentStateName(childBaseStateName, pl)
					
					#print("Copying "+parentStateName+" as "+childStateName)
					
					var newState = _states[parentStateName].duplicate(true)
					newState["Entity"] = entity
					newState["Name"] = childStateName
					
					_states[childStateName] = newState

var _optimizedEntities_Phase0
func _OptimizeActionListPhase0_Variables(entity):
	if(_optimizedEntities_Phase0.has(entity)):
		return
	_optimizedEntities_Phase0.push_back(entity)
	var chainMD = _metadataSubentities[entity]
	var skeleton = "Base"
	if(chainMD.has("Skeleton")):
		skeleton = chainMD["Skeleton"]
	if(skeleton == "none" or skeleton == "None"):
		skeleton = null
	
	if(skeleton != null):
		Castagne.FuseDataNoOverwrite(_variables[entity], _variables[skeleton].duplicate(true))
	else:
		Castagne.FuseDataNoOverwrite(_variables[entity], _subentityBaseDefines.duplicate(true))
	
	
	var moduleSpecblocksSub = _configData.GetModuleSpecblocksSubEntity()
	for sb in moduleSpecblocksSub.values():
		var sbDefaultDefines = sb.GetDefaultDefines()
		for dName in sbDefaultDefines:
			if dName in _variables[entity]:
				continue
			var v = {
				"Name": dName,
				"Mutability": Castagne.VARIABLE_MUTABILITY.Define,
				"Type": Castagne.VARIABLE_TYPE.Str,
				"Subtype":"",
				"Value": sbDefaultDefines[dName],
			}
			if(typeof(v["Value"]) == TYPE_INT):
				v["Type"] = Castagne.VARIABLE_TYPE.Int
			_variables[entity][dName] = v
	
	# --- Transform defined data
	#for sbName in moduleSpecblocksSub:
	#	var sb = moduleSpecblocksSub[sbName]
	#	var tData = sb.TransformDefinedData(_specblockDefines)
	#	if(tData != null):
	#		_transformedData[sbName] = tData

var _optimizedStates
var _optimizedStates_CallAfter
func _OptimizeActionListPhase1(stateName, phasesToOptim = null):
	if(phasesToOptim == null):
		phasesToOptim = _OptimizeActionList_GetPhasesToOptimize(stateName)
	
	for p in phasesToOptim:
		if(stateName in _optimizedStates[p]):
			phasesToOptim.erase(p)
		else:
			_optimizedStates[p] += [stateName]
	if(phasesToOptim.size() == 0):
		return
	var state = _states[stateName]

	var subName = _GetPureStateNameFromStateName(stateName)
	var np = _ExtractParentFromPureStateName(subName)
	subName = np[0]
	var parentLevel = np[1]

	for p in phasesToOptim:
		var actionList = _OptimizeActionList_Sublist(state[p], parentLevel, p, state)
		state[p] = actionList

		# TODO Set function not on defines ?
	_states[stateName] = state

var _optimizeActionList_parentWarnings = []
func _OptimizeActionList_Sublist(actionList, baseParentLevel, p, state):
	# Call / CallParent
	# Empty branch out
	var callFuncref = _configData.GetModuleFunctions()["Call"]["ActionFunc"]
	var callFromMainFuncref = _configData.GetModuleFunctions()["CallFromMain"]["ActionFunc"]
	var callParentFuncref = _configData.GetModuleFunctions()["CallParent"]["ActionFunc"]
	var attackRegisterFuncrefs = [
		_configData.GetModuleFunctions()["AttackRegister"]["ActionFunc"],
		_configData.GetModuleFunctions()["AttackRegisterNoNotation"]["ActionFunc"],
	]
	var callAfterFuncref = _configData.GetModuleFunctions()["CallAfter"]["ActionFunc"]

	var branchFuncrefs = _branchFunctions.values()

	var loopAgain = true
	while(loopAgain):
		loopAgain = false
		var parentLevel = baseParentLevel
		for i in range(actionList.size()):
			var a = actionList[i]
			var calledState = null
			if(a[0] == callAfterFuncref):
				if not (state["Name"] in _optimizedStates_CallAfter):
					_optimizedStates_CallAfter[state["Name"]] = []
				var callAfterState = a[1][0]
				var calledStateEntity = _GetEntityNameFromStateName(state["Name"])
				if(calledStateEntity != null):
					callAfterState = calledStateEntity + "---" + callAfterState
				if not (callAfterState in _optimizedStates_CallAfter[state["Name"]]):
					_optimizedStates_CallAfter[state["Name"]].push_back(callAfterState)
			
			if(a[0] == callFuncref):
				calledState = a[1][0]
				var calledStateEntity = _GetEntityNameFromStateName(state["Name"])
				if(calledStateEntity != null):
					calledState = calledStateEntity + "---" + calledState
			elif(a[0] == callFromMainFuncref):
				calledState = a[1][0]
			elif(a[0] == callParentFuncref):
				calledState = _ExtractParentFromPureStateName(_GetPureStateNameFromStateName(state["Name"]))[0]
				var calledStateEntity = _GetEntityNameFromStateName(state["Name"])
				if(calledStateEntity != null):
					calledState = calledStateEntity + "---" + calledState
				
				#calledState = state["Name"]
				parentLevel += 1
				calledState = _GetParentStateName(calledState, parentLevel)
				
				if(!(calledState in _states)):
					if(!(calledState in _optimizeActionList_parentWarnings)):
						_Error("CastagneParser: CallParent function is calling non-existing parent state "+ str(calledState) +" (Parent level "+str(parentLevel)+"). Removing Call.")
						_optimizeActionList_parentWarnings.push_back(calledState)
					actionList.remove(i)
					loopAgain = true
					break
			elif(a[0] in attackRegisterFuncrefs):
				calledState = "AttackType-"+a[1][0]

			elif(a[0] in branchFuncrefs):
				a[1][0] = _OptimizeActionList_Sublist(a[1][0], parentLevel, p, state)
				a[1][1] = _OptimizeActionList_Sublist(a[1][1], parentLevel, p, state)

				if(a[1][0].empty() and a[1][1].empty()):
					actionList.remove(i)
					loopAgain = true
					break

			#if(calledState != null and calledState in _states):
			if(calledState != null):
				if not (calledState in _states):
					_Error("CastagneParser: State " + state["Name"] + " is trying to call unexisting state "+calledState+".")
					continue
				if(calledState == state["Name"]):
					_Warning("CastagneParser: State " + calledState + " is calling itself. Recursion has a fair chance of not going well.")
					continue

				_OptimizeActionListPhase1(calledState, [p])
				var calledActionList = _states[calledState][p]
				actionList.remove(i) # we keep attack register for registering attack properly
				
				if(a[0] in attackRegisterFuncrefs):
					var newA = a.duplicate(true)
					var internalFuncName = ("AttackInternalRegisterNoNotation" if a[0] == attackRegisterFuncrefs[1] else "AttackInternalRegister")
					newA[0] = _configData.GetModuleFunctions()[internalFuncName]["ActionFunc"]
					actionList.insert(i, newA)
					i += 1
				
				for j in range(calledActionList.size()):
					actionList.insert(i+j, calledActionList[j].duplicate(true))
				loopAgain = true

				# Variables
				Castagne.FuseDataNoOverwrite(state["Variables"], _states[calledState]["Variables"].duplicate(true))

				break
	return actionList

func _OptimizeActionListPhase1_After():
	# Ensures call after works properly, as we want to include the non-call aftered version for each
	for stateName in _optimizedStates_CallAfter:
		var callAfters = _optimizedStates_CallAfter[stateName]
		var state = _states[stateName]
		for ca in callAfters:
			for p in _OptimizeActionList_GetPhasesToOptimize(stateName):
				var actionList = state[p]
				var caActionList = _states[ca][p]
				for a in caActionList:
					actionList.push_back(a.duplicate(true))
				state[p] = actionList
		_states[stateName] = state
func _OptimizeActionList_Sublist_After(actionList, p, state):
	var callAfterFuncref = _configData.GetModuleFunctions()["CallAfter"]["ActionFunc"]
	var loopAgain = true
	while(loopAgain):
		loopAgain = false
		for i in range(actionList.size()):
			var a = actionList[i]
			if(a[0] == callAfterFuncref):
				var calledState = a[1][0]
				var calledStateEntity = _GetEntityNameFromStateName(state["Name"])
				if(calledStateEntity != null):
					calledState = calledStateEntity + "---" + calledState
			
				if(calledState != null):
					if not calledState in _states:
						_Error("CastagneParser: State " + state["Name"] + " is trying to call unexisting state "+calledState+".")
						continue
					if(calledState == state["Name"]):
						_Warning("CastagneParser: State " + calledState + " is calling itself. Recursion has a fair chance of not going well.")
						continue

					var calledActionList = _states[calledState][p]
					actionList.remove(i)
					for j in range(calledActionList.size()):
						actionList.push_back(calledActionList[j].duplicate(true))
					loopAgain = true
					break
	return actionList

var _optimizedStates2 = []
var variablesList_OptimPhase2 = {}
func _OptimizeActionListPhase2(stateName):
	# Defines replace
	# V branch compile time conditions
	if(stateName in _optimizedStates2):
		return
	_optimizedStates2 += [stateName]
	var state = _states[stateName]

	
	var entity = _GetEntityNameFromStateName(stateName)

	#if(!variablesList_OptimPhase2.has(entity)):
	#var variablesList = state["Variables"].duplicate()
	if(!_variables.has(entity)):
		_variables[entity] = _subentityBaseDefines.duplicate()
	#Castagne.FuseDataNoOverwrite(variablesList, _variables[entity].duplicate(true))
	#variablesList_OptimPhase2[entity] = newVariablesList
	#var variablesList = variablesList_OptimPhase2[entity]

	for p in _OptimizeActionList_GetPhasesToOptimize(stateName):
		var actionList = state[p]

		actionList = _OptimizeActionList_Defines(actionList, state["Variables"], _variables[entity])
		actionList = _OptimizeActionList_StaticBranches(actionList)

		state[p] = actionList
	_states[stateName] = state

func _OptimizeActionListPhase3():
	# Erase all parent states.
	var statesExisting = _states.keys()
	
	for stateName in statesExisting:
		var pureStateName = _GetPureStateNameFromStateName(stateName)
		if(pureStateName.begins_with("Parent:")):
			_states.erase(stateName)

func _OptimizeActionList_Defines(actionList, variablesList, entityVariablesList):
	var branchFuncrefs = _branchFunctions.values()

	for i in range(actionList.size()):
		var a = actionList[i]
		var arguments = a[1]
		if(a[0] in branchFuncrefs):
			a[1][0] = _OptimizeActionList_Defines(a[1][0], variablesList, entityVariablesList)
			a[1][1] = _OptimizeActionList_Defines(a[1][1], variablesList, entityVariablesList)
			a[1][2] = _OptimizeActionList_Defines_BranchArgs(a[0], a[1][2], variablesList, entityVariablesList)

		for j in range(arguments.size()):
			arguments[j] = _OptimizeActionList_Defines_ReplaceSymbol(arguments[j], variablesList, entityVariablesList)
	return actionList

func _OptimizeActionList_Defines_ReplaceSymbol(symbol, variablesList, entityVariablesList):
	var v = null
	if(symbol in variablesList):
		v = variablesList[symbol]
	elif(symbol in entityVariablesList):
		v = entityVariablesList[symbol]

	if(v != null):
		if(v["Mutability"] == Castagne.VARIABLE_MUTABILITY.Define):
			return v["Value"]
	return symbol

func _OptimizeActionList_Defines_BranchArgs(branchFuncref, letterArgs, variablesList, entityVariablesList):
	letterArgs = str(letterArgs)

	if(branchFuncref == _branchFunctions["F"]):
		var frameRange = _Instruction_GetRange(letterArgs)
		var sameStartEnd = (frameRange[0] == frameRange[1])
		frameRange[0] = _OptimizeActionList_Defines_ReplaceSymbol(frameRange[0], variablesList, entityVariablesList)
		if(frameRange[1] == "+"):
			letterArgs = str(frameRange[0]) + "+"
		elif(!sameStartEnd):
			frameRange[1] = _OptimizeActionList_Defines_ReplaceSymbol(frameRange[1], variablesList, entityVariablesList)
			letterArgs = str(frameRange[0]) + "-" + str(frameRange[1])
		else:
			letterArgs = str(frameRange[0])
		if(frameRange.size() == 3):
			frameRange[2] = _OptimizeActionList_Defines_ReplaceSymbol(frameRange[2], variablesList, entityVariablesList)
			letterArgs += "%"+str(frameRange[2])
	elif(branchFuncref == _branchFunctions["V"]):
		var parsedCondition = _Instruction_ParseCondition(letterArgs)
		var comparaisonSymbols = { 0:"==", 1:">=", 2:">", -1:"<=", -2:"<", null:"<>"}
		parsedCondition[0] = _OptimizeActionList_Defines_ReplaceSymbol(parsedCondition[0], variablesList, entityVariablesList)
		parsedCondition[2] = _OptimizeActionList_Defines_ReplaceSymbol(parsedCondition[2], variablesList, entityVariablesList)
		letterArgs = str(parsedCondition[0]) + comparaisonSymbols[parsedCondition[1]] + str(parsedCondition[2])
	else:
		letterArgs = _OptimizeActionList_Defines_ReplaceSymbol(letterArgs, variablesList, entityVariablesList)

	if(letterArgs.is_valid_integer()):
		letterArgs = int(letterArgs)
	return letterArgs

func _OptimizeActionList_StaticBranches(actionListToParse):
	var vbranch = _branchFunctions["V"]
	var branchFuncrefs = _branchFunctions.values()
	var newActionList = []

	for a in actionListToParse:
		if(a[0] == vbranch):
			var parsedCondition = _Instruction_ParseCondition(a[1][2])
			if(parsedCondition[0].is_valid_integer() and parsedCondition[2].is_valid_integer()):
				var result = _Instruction_ComputeCondition_Internal(int(parsedCondition[0]), parsedCondition[1], int(parsedCondition[2]))
				var chosenBranch = (a[1][0] if result else a[1][1])
				newActionList.append_array(_OptimizeActionList_StaticBranches(chosenBranch))
			else:
				newActionList.push_back(a)
		elif a[0] in branchFuncrefs:
			a[1][0] = _OptimizeActionList_StaticBranches(a[1][0])
			a[1][1] = _OptimizeActionList_StaticBranches(a[1][1])
			newActionList.push_back(a)
		else:
			newActionList.push_back(a)
	
	return newActionList

func _OptimizeActionList_GetPhasesToOptimize(stateName):
	#return ["Init", "Action", "Reaction", "Freeze", "Manual", "AI", "Subentity", "Halt"]
	var subName = _ExtractParentFromPureStateName(_GetPureStateNameFromStateName(stateName))[0]
	var entity = _GetEntityNameFromStateName(stateName)
	
	if(entity != null):
		return ["Init", "Subentity", "Freeze", "AI", "Halt"]
	if(subName == "Init" or subName.begins_with("Init-")):
		return ["Init", "AI"]
	if(subName.begins_with("CCB_")):
		return ["Manual"]
	return ["Action", "Reaction", "Freeze", "AI", "Halt"]
	#return PHASES

func _RuntimeStateTagging(stateName):
	var state = _states[stateName]
	var subName = _GetPureStateNameFromStateName(stateName)
	var np = _ExtractParentFromPureStateName(subName)
	subName = np[0]
	var parentLevel = np[1]
	var entity = _GetEntityNameFromStateName(stateName)

	var metadata = {
		"ParentLevel":parentLevel, "Entity":entity,
		"NameShort":subName,
		"AttackNotations":[], "AttackType":null,
	}
	var flags = []

	for p in PHASES:
		var actionList = state[p]
		var newFlags = _ExtractFlagsFromActionList(actionList, metadata)
		for f in newFlags:
			if(!flags.has(f)):
				flags.push_back(f)

	metadata["Flags"] = flags
	state["Metadata"] = metadata

func _ExtractFlagsFromActionList(actionList, metadata, level = 0):
	var f = []
	var branchFuncrefs = _branchFunctions.values()
	var attackRegisterFuncrefs = [
		_configData.GetModuleFunctions()["AttackRegister"]["ActionFunc"],
		_configData.GetModuleFunctions()["AttackRegisterNoNotation"]["ActionFunc"],
		_configData.GetModuleFunctions()["AttackAddNotation"]["ActionFunc"],
		_configData.GetModuleFunctions()["AttackInternalRegister"]["ActionFunc"],
		_configData.GetModuleFunctions()["AttackInternalRegisterNoNotation"]["ActionFunc"],
		]

	for i in range(actionList.size()):
		var a = actionList[i]
		var arguments = a[1]
		if(a[0] in branchFuncrefs):
			var nft = _ExtractFlagsFromActionList(arguments[0], metadata, level+1)
			for flag in nft:
				f.push_back(flag)
			var nff = _ExtractFlagsFromActionList(arguments[1], metadata, level+1)
			for flag in nff:
				f.push_back(flag)

		elif(a[0] in attackRegisterFuncrefs and level == 0):
			var atkType = null
			var atkNotation = null

			if(a[0] == attackRegisterFuncrefs[0] or a[0] == attackRegisterFuncrefs[3]):
				atkType = arguments[0]
				atkNotation = metadata["NameShort"]
				if(arguments.size() >= 2):
					atkNotation = arguments[1]
			elif(a[0] == attackRegisterFuncrefs[1] or a[0] == attackRegisterFuncrefs[4]):
				atkType = arguments[0]
			else:
				atkNotation = arguments[0]

			if(atkType != null):
				f.push_back("Attack")
				f.push_back("AttackType-"+arguments[0])
				if(!(metadata["AttackNotations"].empty()) and metadata["AttackType"] != atkType):
					_Error("Found several AttackRegister calls in one state ! "+metadata["NameShort"] + "(Parent level "+str(metadata["ParentLevel"])+", entity "+metadata["Entity"]+")")
				metadata["AttackType"] = atkType

			if(atkNotation != null):
				metadata["AttackNotations"] += [atkNotation]

	return f

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

	while(md.has("Skeleton") and (typeof(md["Skeleton"]) == TYPE_INT or !md["Skeleton"].ends_with(".casp"))):
		var skeletonName = str(md["Skeleton"]).strip_edges()
		if(skeletonName == "none" or skeletonName == "None"):
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

func _ParseSpecblocks(fileID):
	_curFile = fileID
	_LogD("Parsing Specblocks of " + _filePaths[fileID])

	var definesFound = {}
	var line = _GetNextBlock(fileID)
	
	while(line != null):
		line = line.left(line.length()-1).right(1)
		line = _GetPureStateNameFromStateName(line)
		
		if(!line.begins_with("Specs-")):
			break
		
		line = _GetNextLine(fileID)
		while(line != null and !_IsLineBlock(line)):
			if(!_IsLineVariable(line)):
				_FatalError("Non variable declaration in a specblock.")
				continue
			var defineData = _ExtractVariable(line)
			if(defineData == null):
				return null
			var defineName = defineData["Name"]
			if(defineName in definesFound):
				_FatalError("Specblock: " + str(defineName) + " found in two specblocks of the same file! (This error is more on the module author)")
			else:
				definesFound[defineName] = defineData["Value"]
			line = _GetNextLine(fileID)

	return definesFound

func _ParseVariables(fileID):
	_curFile = fileID
	_LogD("Parsing Variables of " + _filePaths[fileID])

	var nbBlocks = 0
	var nbVariables = 0

	var line = _GetNextBlock(fileID)

	var variablesFound = {}
	
	while(line != null):
		line = line.left(line.length()-1).right(1)
		var stateNamePure = _GetPureStateNameFromStateName(line)
		if(!stateNamePure.begins_with("Variables")):
			break
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
	_currentEntity = null
	_LogD("Parsing States of " + _filePaths[fileID])
	var states = {}
	while(_GetNextBlock(fileID) != null):
		var s = _ParseBlockState(fileID)
		if(s == null or _aborting):
			return null
		states[s["Name"]] = s

	_ParseStates_OverwriteStates(states)
	_LogD("Found " + str(states.size()) + " states.")
	return states

func _ParseStates_OverwriteStates(newStates):
	#Castagne.FuseDataMoveWithPrefix(_states, states)
	for stateName in newStates:
		_ParseStates_OverwriteStates_MoveToParentIfExists(stateName)
		_states[stateName] = newStates[stateName]

func _GetParentStateName(stateName, levels = 1):
	var parentText = ""
	for _i in range(levels):
		parentText += "Parent:"
	
	var parentStateName = parentText+stateName
	var entity = _GetEntityNameFromStateName(stateName)
	if(entity != null):
		parentStateName = entity+"---"+parentText+_GetPureStateNameFromStateName(stateName)
	return parentStateName

func _ExtractParentFromPureStateName(stateName):
	var parentLevel = 0
	while(stateName.begins_with("Parent:")):
		parentLevel += 1
		stateName = stateName.right(7)
	return [stateName, parentLevel]

func _ParseStates_OverwriteStates_MoveToParentIfExists(stateName):
	if(!_states.has(stateName)):
		return
	var parentStateName = _GetParentStateName(stateName)
	_ParseStates_OverwriteStates_MoveToParentIfExists(parentStateName)
	_states[parentStateName] = _states[stateName]

func _ParseForEdition():
	var result = {}
	result["NbFiles"] = 0

	if(_aborting):
		return result

	_parseForEditionPostProcessed = []
	# 1. Parse the character skeleton
	var profiling = [OS.get_ticks_usec()]
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
			"ParseFlags": [],
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
					var fscs = fileStates[curState]
					fileStates[curState]["LineEnd"] = lineID
					if(fscs["ParseFlags"].has("AttackFunctionUsed")):
						if(!fscs["StateFlags"].has("Attack") and fscs["StateType"] != Castagne.STATE_TYPE.Helper):
							fscs["Warnings"] += ["Attack function used, but the state is not a registered attack or a helper!"]
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
						var todoFlags = ["DESIGN", "MOMENTUM", "FRAMEDATA", "ANIM", "VFX", "SOUND", "BUG"]
						var todoFlag = "TODO"
						for tf in todoFlags:
							if(doccontents.find("TODO"+tf) >= 0):
								todoFlag = "TODO"+tf
						fscs["StateFlags"] += [todoFlag]
					if(doccontents.find("CASTDO") >= 0):
						fscs["StateFlags"] += ["CASTTODO"]
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
					if(f[0] == "AttackRegister" or f[0] == "AttackRegisterNoNotation"):
						fscs["StateFlags"] += ["Attack"]
						if(f[1].size() >= 1):
							fscs["StateFlags"] += ["AttackType-"+str(f[1][0])]
					if(f[0] == "AttackFlag" and f[1].size() > 0):
						var acceptedFlags = ["Throw"]
						var flag = f[1][0].strip_edges()
						if(flag in acceptedFlags):
							fscs["StateFlags"] += ["AttackFlag"+flag]
					if(f[0] == "AttackMustBlock" and f[1].size() > 0):
						var flag = f[1][0].strip_edges()
						fscs["StateFlags"] += ["AttackMB"+flag]
					if(f[0].begins_with("Attack")):
						fscs["ParseFlags"] += ["AttackFunctionUsed"]
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

	profiling.push_back(OS.get_ticks_usec())
	for i in range(_files.size()):
		for stateName in result[i]["States"]:
			ParseForEditionPostProcess(i, stateName, result)

	profiling.push_back(OS.get_ticks_usec())
	_PrintProfilingData("["+str(_filePaths[0])+"] EditParse", profiling)
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

	var UNHERITED_FLAGS = ["Overridable", "Overriding", "TODO", "CASTTODO", "Warning", "Error", "Attack"]

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
					for flagToErase in UNHERITED_FLAGS:
						inheritedFlags.erase(flagToErase)
					for f in inheritedFlags:
						if(f.begins_with("AttackType-")):
							inheritedFlags.erase(f)

					state["StateFlags"].append_array(inheritedFlags)

					if(calledState["StateType"] == Castagne.STATE_TYPE.BaseState and
						(state["BaseStateDistance"] == -1 or state["BaseStateDistance"] > calledState["BaseStateDistance"]+1)):
						state["BaseStateDistance"] = calledState["BaseStateDistance"]
						state["BaseState"] = calledState["BaseState"]
						baseStateRef = calledState

	# Additional checks and inheritance
	if(state["Categories"].empty()):
		var attackType = null
		for sf in state["StateFlags"]:
			if(sf.begins_with("AttackType-")):
				attackType = sf.right(11)
				break
		if(attackType != null):
			state["Categories"] = ["Attacks/"+attackType]
		elif(state["StateType"] in [Castagne.STATE_TYPE.Helper, Castagne.STATE_TYPE.Special]):
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
	if(entityName != null and state["Categories"].empty()):
		state["Categories"] = ["Entities/"+entityName]

	if(stateName == "Character"):
		state["StateType"] = Castagne.STATE_TYPE.Special
		state["StateFlags"].erase("Overriding")

	if(stateName.begins_with("Variables")):
		state["StateType"] = Castagne.STATE_TYPE.Special
		if(state["Categories"].empty()):
			state["Categories"] = ["Variables"]
	if(stateName.begins_with("Init-") or stateName == "Init"):
		state["StateType"] = Castagne.STATE_TYPE.Special
	if(stateName.begins_with("Specs-")):
		state["StateType"] = Castagne.STATE_TYPE.Specblock
		state["Categories"] = ["Specblocks"]


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
	if(state["StateType"] == Castagne.STATE_TYPE.Normal and state["BaseStateDistance"] == -1 and !state["StateFlags"].has("Attack")):
		state["Warnings"] += ["State doesn't lead back to a base state, and isn't itself a base state, helper, or registered attack."]

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
		if(right.is_valid_integer()):
			right = int(right)
		variables[left] = right
		line = _GetNextLine(fileID)
	return variables

var _currentState = {}
var _currentEntity = null
func _ParseBlockState(fileID):
	var stateName = _GetCurrentLine(fileID)
	stateName = stateName.left(stateName.length()-1).right(1)

	if(stateName.begins_with("Variables")):
		_Error("Found a variables block after variables are handled.")
		return null

	var entity = _GetEntityNameFromStateName(stateName)
	var stateNamePure = _GetPureStateNameFromStateName(stateName)
	
	# New subentity
	if(_currentEntity != entity):
		if(entity == null):
			_Error("Found a main entity state after subentities started.")
			return null
		#if(entity in _metadataSubentities):
		#	_Error("Subentity "+str(entity)+" has already been defined before, please pack your subentities in order.")
		#	return null
		if(stateNamePure != "Subentity"):
			_Error("Subentity "+str(entity)+" doesn't start with special state 'Subentity'.")
			return null
		_currentEntity = entity
		if(!_metadataSubentities.has(entity)):
			_metadataSubentities[entity] = {}
			#for i in range(_filePaths.length()):
			#	_metadataSubentities[entity][i] = {}
			
			_variables[entity] = {}
			#_variables[entity] = _subentityBaseDefines.duplicate()
		
		# Parse subentity block
		Castagne.FuseDataOverwrite(_metadataSubentities[entity], _ParseBlockData(fileID))
		
		var newDefines = _ParseSpecblocks(fileID)
		for dName in newDefines:
			var v = {
				"Name": dName,
				"Mutability": Castagne.VARIABLE_MUTABILITY.Define,
				"Type": Castagne.VARIABLE_TYPE.Str,
				"Subtype":"",
				"Value": newDefines[dName],
			}
			if(typeof(v["Value"]) == TYPE_INT):
				v["Type"] = Castagne.VARIABLE_TYPE.Int
			#_specblockDefines[dName] = v
			_variables[entity][dName] = v
		
		# Parse variables
		_ParseVariables(fileID)
		
		stateName = _GetCurrentLine(fileID)
		if(stateName == null):
			return null
		stateName = stateName.left(stateName.length()-1).right(1)
		entity = _GetEntityNameFromStateName(stateName)
		stateNamePure = _GetPureStateNameFromStateName(stateName)
	
	

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
						# TODO: This is a hack because we don't really know the variables. Won't fix before compiler rewrite because it's annoying
						isKnownVariable = isKnownVariable or entity != null
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
				
				currentSubblock = reserveSubblocks.pop_back()
				currentSubblockList = reserveSubblocksList.pop_back()
				
				if(branch["Letter"] == "S"):
					# Translate the S blocks to F branches
					var nbSBlocks = len(branch["S_Blocks_Start"])
					for sbID in range(nbSBlocks):
						var start = branch["S_Blocks_Start"][sbID]
						var end = branch["S_Blocks_End"][sbID]
						var regularActions = branch["S_"+str(sbID)]
						var starActions = branch["S_"+str(sbID)+"*"]
						
						var fLetterArgsRegular = str(start)
						var fLetterArgsStar = str(start)
						if(typeof(end) == TYPE_STRING): # it's "+"
							fLetterArgsRegular += "+"
						else:
							fLetterArgsRegular += "-"+str(end)
						if(branch["S_Modulo"] > 0):
							fLetterArgsRegular += "%"+str(branch["S_Modulo"])
							fLetterArgsStar += "%"+str(branch["S_Modulo"])
						
						for p in PHASES:
							# Star before regular
							if(!starActions[p].empty()):
								var argsStar = [starActions[p], [], fLetterArgsStar]
								var dStar = [_branchFunctions["F"], argsStar]
								
								if(currentSubblock == null):
									stateActions[p] += [dStar]
								else:
									currentSubblock[currentSubblockList][p] += [dStar]
							if(!regularActions[p].empty()):
								var argsReg = [regularActions[p], [], fLetterArgsRegular]
								var dReg = [_branchFunctions["F"], argsReg]
								
								if(currentSubblock == null):
									stateActions[p] += [dReg]
								else:
									currentSubblock[currentSubblockList][p] += [dReg]
				else:
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
				if(currentSubblock["Letter"] == "S"):
					_Error("Else found in an S branch!")
					line = _GetNextLine(fileID)
					continue
				if(currentSubblockList == "False"):
					_Error("Else found while already in an else block!")
					line = _GetNextLine(fileID)
					continue
				currentSubblockList = "False"
			elif(line == "then"):
				if(currentSubblock == null or currentSubblock["Letter"] != "S"):
					_Error("'then' found without an S branch!")
					line = _GetNextLine(fileID)
					continue
				if(!currentSubblockList.ends_with("*")):
					_Error("'then' found in a non-'*' S branch!")
					line = _GetNextLine(fileID)
					continue
				currentSubblockList = currentSubblockList.left(currentSubblockList.length() - 1)
			elif(line.begins_with("S") and !line.ends_with(":")):
				if(currentSubblock == null or currentSubblock["Letter"] != "S"):
					_Error("S followup found without an S branch!")
					line = _GetNextLine(fileID)
					continue
				if(currentSubblock["S_Sum"] == -1):
					_Error("S followup found after an S+ branch!")
					line = _GetNextLine(fileID)
					continue
				
				letterArgs = line.left(line.length()).right(1)
				currentSubblockList = "S_"+str(len(currentSubblock["S_Blocks_Start"]))
				currentSubblock[currentSubblockList] = {}
				currentSubblock[currentSubblockList+"*"] = {}
				for p in PHASES:
					currentSubblock[currentSubblockList][p] = []
					currentSubblock[currentSubblockList+"*"][p] = []
				
				if(letterArgs.ends_with("*")):
					letterArgs = letterArgs.left(letterArgs.length()-1)
					currentSubblockList += "*"
				
				currentSubblock["S_Blocks_Start"] += [currentSubblock["S_Sum"] + 1]
				if(letterArgs == "+"):
					currentSubblock["S_Sum"] = -1
					currentSubblock["S_Blocks_End"] += ["+"]
				else:
					if(!letterArgs.is_valid_integer()):
						_Error("S followup with a non-static duration: "+letterArgs)
						line = _GetNextLine(fileID)
						continue
					
					var duration = int(letterArgs)
					currentSubblock["S_Sum"] += duration
					currentSubblock["S_Blocks_End"] += [currentSubblock["S_Sum"]]
					
					if(currentSubblock["S_Modulo"] > 0 and currentSubblock["S_Sum"] > currentSubblock["S_Modulo"]):
						_Error("S Branch sum total ("+str(currentSubblock["S_Sum"])+") is superior to the modulo ("+str(currentSubblock["S_Modulo"])+")!")
						line = _GetNextLine(fileID)
						continue
					
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
					"Flags":["Init", "Action", "Reaction", "Freeze", "Manual"],
				}
				for p in PHASES:
					currentSubblock["True"][p] = []
					currentSubblock["False"][p] = []
				
				if(letter == "S"):
					# S Branch is static only, and can't exist from another branch
					if(reserveSubblocks.size() > 1):
						_Error("S Branches can't exist from within another branch.")
					
					currentSubblock["S_Modulo"] = 0
					currentSubblock["S_Blocks_Start"] = [1]
					currentSubblock["S_Blocks_End"] = []
					currentSubblockList = "S_0"
					currentSubblock["S_0"] = {}
					currentSubblock["S_0*"] = {}
					currentSubblock["S_Sum"] = 0
					for p in PHASES:
						currentSubblock["S_0"][p] = []
						currentSubblock["S_0*"][p] = []
					var moduloSepID = letterArgs.find("%")
					if(moduloSepID > 0):
						var modulo = letterArgs.right(moduloSepID+1)
						letterArgs = letterArgs.left(moduloSepID)
						if(modulo.is_valid_integer()):
							currentSubblock["S_Modulo"] = int(modulo)
						else:
							_Error("S Branch modulo is not a static number: " + modulo)
					if(letterArgs.ends_with("*")):
						letterArgs = letterArgs.left(letterArgs.length()-1)
						currentSubblockList += "*"
					if(letterArgs == "+"):
						currentSubblock["S_Blocks_End"] += ["+"]
						currentSubblock["S_Sum"] = -1
					elif(letterArgs.is_valid_integer()):
						var la = int(letterArgs)
						currentSubblock["S_Blocks_End"] += [la]
						currentSubblock["S_Sum"] = la
					else:
						_Error("S Branch is not a static number: " + letterArgs)

			else:
				if(line.ends_with(":")):
					_Error("Branch type not recognized: " + letter)
				else:
					_Error("Line is invalid: " + line)

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
	var entity = null
	var sep = stateName.find("---")
	if(sep >= 0):
		#if(stateName.begins_with("Variables") or stateName.begins_with("Init")):
		#	stateName = stateName.right(sep+2)
		#	sep = stateName.find("-")
		#	if(sep >= 0):
		#		stateName = stateName.left(sep)
		#	entity = stateName
		#else:
		entity = stateName.left(sep)
	return entity
	
func _GetPureStateNameFromStateName(stateName):
	var entity = _GetEntityNameFromStateName(stateName)
	if(entity == null):
		return stateName
	return stateName.right(entity.length()+3)

onready var KnownVariableTypes = {"int":Castagne.VARIABLE_TYPE.Int, "str":Castagne.VARIABLE_TYPE.Str, "bool":Castagne.VARIABLE_TYPE.Bool}
func _ExtractVariable(line, returnIncompleteType = false):
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
			variableValue = null
		#	_Error("Variable declaration has an '=' sign but no assignation.")
		#	return null


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
	
	if(variableType == Castagne.VARIABLE_TYPE.Bool):
		if(variableValue.is_valid_integer()):
			variableValue = (1 if variableValue.to_int() > 0 else 0)
		else:
			variableValue = 0
			_Error("Bool variable but the value isn't stored properly.")

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

	var frameID = stateHandle.EntityGet("_StateFrameID")#stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame")
	var validFrames = []

	var frameRange = _Instruction_GetRange(letterArgs)
	
	if(frameRange.size() >= 3):
		var modulo = ArgInt(frameRange, stateHandle, 2)
		frameID = frameID % modulo
		if(frameID == 0):
			frameID = modulo # More logical since F0 is special
		
	#if(frameRange.size() == 1):
	#	validFrames += [ArgInt([frameRange[0]], stateHandle, 0)]
	if(frameRange[1] == "+"):
		var minFrame = ArgInt(frameRange, stateHandle, 0)
		if(frameID >= minFrame):
			validFrames += [frameID]
	else:
		var start = ArgInt(frameRange, stateHandle, 0)
		var end = ArgInt(frameRange, stateHandle, 1)
		for i in range(start, end+1):
			validFrames += [i]
	
	letterArgs = validFrames
	InstructionBranch(args, stateHandle, frameID in validFrames)
func InstructionS(_args, stateHandle):
	ModuleError("S Instructions shouldn't ever be executed.", stateHandle)

func _Instruction_GetRange(letterArgs):
	var rangeSepID = letterArgs.find("-")
	var plusSepID = letterArgs.find("+")
	var moduloSepID = letterArgs.find("%")
	var modulo
	if(moduloSepID > 0): # %C
		modulo = letterArgs.right(moduloSepID+1)
		letterArgs = letterArgs.left(moduloSepID)
	
	var r
	if(rangeSepID > 0): # A-B
		r = [letterArgs.left(rangeSepID), letterArgs.right(rangeSepID+1)]
	elif(plusSepID > 0): # A+
		r = [letterArgs.left(plusSepID), "+"]
	else: # A
		r = [letterArgs, letterArgs]
	
	if(moduloSepID > 0): # %C
		r += [modulo]
	return r

func InstructionL(args, stateHandle):
	var flagName = args[2]
	InstructionBranch(args, stateHandle, flagName in stateHandle.EntityGet("_Flags"))

func InstructionV(args, stateHandle):
	var cond = _Instruction_ComputeCondition(args[2], stateHandle)
	InstructionBranch(args, stateHandle, cond)

func InstructionP(args, stateHandle):
	var phaseNameString = ArgStr(args, stateHandle, 2)
	var phaseNames = phaseNameString.split(",")
	var initPhaseName = stateHandle.GetPhase()
	var cond = (initPhaseName in phaseNames)
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


func _Instruction_ParseCondition(s):
	var firstPart = s
	var secondPart = 0
	var condition = 2

	var inferiorPos = s.find("<")
	var superiorPos = s.find(">")
	var equalPos = s.find("=")
	var splitPos = max(inferiorPos, superiorPos)
	if(splitPos < 0):
		splitPos = equalPos

	if(inferiorPos >= 0 and superiorPos >= 0):
		condition = null
	elif(splitPos >= 0):
		firstPart = s.left(splitPos)
		secondPart = s.right(splitPos+1)
		condition = 0
		condition += (2 if superiorPos>=0 else 0)
		condition -= (2 if inferiorPos>=0 else 0)

		if(secondPart.begins_with("=")):
			secondPart = secondPart.right(1)
			condition -= sign(condition)

	return [firstPart, condition, secondPart]

func _Instruction_ComputeCondition(letterArgs, stateHandle):
	var parsedCondition = _Instruction_ParseCondition(letterArgs)

	if(parsedCondition[1] == null):
		ModuleError("_Instruction_ComputeCondition: Found both < and > in the same condition", stateHandle)
		return false

	var firstPart = ArgInt([parsedCondition[0]], stateHandle, 0, 0)
	var secondPart = ArgInt([parsedCondition[2]], stateHandle, 0, 0)
	return _Instruction_ComputeCondition_Internal(firstPart, parsedCondition[1], secondPart)

func _Instruction_ComputeCondition_Internal(firstPart, condition, secondPart):
	var diff = firstPart - secondPart
	if(diff == 0):
		return (abs(condition) <= 1)
	return (sign(condition) == sign(diff))
