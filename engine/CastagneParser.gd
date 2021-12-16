extends Node

# Parses .casp files to make Castagne characters
# CreateFullCharacter will actually parse everything, while GetCharacterMetadata
# will only parse the :Character: block.

# TODO :
# - Better Error reporting
# - Use Constants like #DEFINEs
# - More flexibility
# - Types rework

func GetCharacterMetadata(filePath):
	_StartParsing(filePath)
	_ParseMetadata(0)
	return _EndParsing()["Character"]

func CreateFullCharacter(filePath):
	_StartParsing(filePath)
	_ParseFullFile()
	return _EndParsing()

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

var _metadata
var _constants
var _variables
var _states

var _aborting

func _StartParsing(filePath):
	_currentLines = []
	_lineIDs = []
	_files = []
	_filePaths = []
	
	_aborting = false
	_metadata = {}
	_constants = {}
	_variables = {}
	_states = {}
	
	_OpenFile(filePath)

func _AbortParsing():
	for f in _files:
		f.close()
	_files = null
	_aborting = true
	_Log("Aborting Parsing...")
	return null

func _EndParsing():
	if(_aborting):
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
	if(!file.file_exists(filePath)):
		return _Error("File " + filePath + " does not exist.")
	file.open(filePath, File.READ)
	
	_lineIDs.append(0)
	_filePaths.append(filePath)
	_currentLines.append("")
	_files.append(file)
	return false

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

func _ParseMetadata(fileID):
	_LogD("Parsing Metadata of " + _filePaths[fileID])
	if(_GetNextBlock(fileID) != ":Character:"):
		_Error("Expected a metadata block.")
		return null
	
	var md = _ParseBlockData(fileID)
	md["Filepath"] = _filePaths[fileID]
	Castagne.FuseDataNoOverwrite(_metadata, md)
	_LogD("Found " + str(md.size()) + " entries. " + ("Has a skeleton : " + md["Skeleton"] if md.has("Skeleton") else "No Skeleton"))
	return md

func _ParseConstants(fileID):
	_LogD("Parsing Constants of " + _filePaths[fileID])
	if(_GetNextBlock(fileID) != ":Constants:"):
		_LogD("Didn't find constants.")
		return null
	
	var data = _ParseBlockData(fileID)
	Castagne.FuseDataOverwrite(_constants, data)
	_LogD("Found " + str(data.size()) + " entries.")
	return data

func _ParseVariables(fileID):
	_LogD("Parsing Variables of " + _filePaths[fileID])
	if(_GetNextBlock(fileID) != ":Variables:"):
		_LogD("Didn't find variables.")
		return null
	
	var data = _ParseBlockData(fileID)
	Castagne.FuseDataOverwrite(_variables, data)
	_LogD("Found " + str(data.size()) + " entries.")
	return data

func _ParseStates(fileID):
	_LogD("Parsing States of " + _filePaths[fileID])
	var states = {}
	while(_GetNextBlock(fileID) != null):
		var s = _ParseBlockState(fileID)
		if(_aborting):
			return null
		states[s["Name"]] = s
	
	Castagne.FuseDataMoveWithPrefix(_states, states)
	_LogD("Found " + str(states.size()) + " states.")
	return states

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
func _Error(error, fatal=true):
	# TODO add line IDs again
	Castagne.Error("Parser Error"+(" (Fatal)" if fatal else "")+" : " + str(error))
	#Castagne.Error("Parser Error"+(" (Fatal)" if fatal else "")+" (l."+str(_lineID)+") : " + str(error) + " / " + GetCurrentLine())
	if(fatal):
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
	
	_currentState = {
		"Name": stateName,
		"Type": null,
	}
	
	var stateActions = []
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
					if(fData["ParseFunc"] == null):
						action = StandardParseFunction(f[0], f[1])
					else:
						action = fData["ParseFunc"].call_func(self, f[1])
						
					if(action != null):
						if(currentSubblock == null):
							stateActions += [action]
						else:
							currentSubblock[currentSubblockList] += [action]
				else:
					_Error(f[0] + " : Expected " + str(fData["NbArgs"]) + " arguments, got " + str(f[1].size()) + "("+str(f[1])+")")
			else:
				_Error("Function " + f[0] + " doesn't exist or isn't registered properly.")
		
		else:
			var letter = line.left(1)
			var letterArgs = line.left(line.length()-1).right(1)
			var letters = ["I", "F", "L", "E", "V"]
			if(line == "endif"):
				var args = [currentSubblock["True"], currentSubblock["False"], currentSubblock["LetterArgs"]]
				currentSubblock["Args"] = args
				
				var action = currentSubblock
				currentSubblock = reserveSubblocks.pop_back()
				currentSubblockList = reserveSubblocksList.pop_back()
				
				if(currentSubblock == null):
					stateActions += [action]
				else:
					currentSubblock[currentSubblockList] += [action]
			elif(line == "else"):
				currentSubblockList = "False"
			elif(letter in letters): # Inputs
				reserveSubblocks.push_back(currentSubblock)
				reserveSubblocksList.push_back(currentSubblockList)
				currentSubblockList = "True"
				
				currentSubblock = {
					"Func": funcref(self, "Instruction"+letter),
					"FuncName":"Instruction " + letter,
					"LetterArgs":letterArgs,
					"True": [], "False":[],
					"Flags":["FrameFunc", "TransitionFunc", "FullData"],
				}
			else:
				_Error("Instruction not recognized : " + letter)
		
		line = _GetNextLine(fileID)
		
		if(_aborting):
			return null
	_currentState["Actions"] = stateActions
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

func InstructionI(args, pid, currentState, engine, neededFlag):
	var inputName = args[2]
	var inputs = currentState[pid]["Input"]
	
	if(!inputName in inputs):
		Castagne.Error("I"+inputName+" : Input not found !")
		return
	
	InstructionBranch(args, pid, currentState, engine, neededFlag, inputs[inputName])

func InstructionF(args, pid, currentState, engine, neededFlag):
	var letterArgs = args[2]
	
	var frameID = currentState["FrameID"] - currentState[pid]["StateStartFrame"]
	var validFrames = []
	
	var rangeSepID = letterArgs.find("-")
	var plusSepID = letterArgs.find("+")
	if(rangeSepID > 0):
		var start = Castagne.GetInt(letterArgs.left(rangeSepID), pid, currentState)
		var end = Castagne.GetInt(letterArgs.right(rangeSepID+1), pid, currentState)
		for i in range(start, end+1):
			validFrames += [i]
	elif(plusSepID > 0):
		var minFrame = Castagne.GetInt(letterArgs.left(plusSepID), pid, currentState)
		if(frameID >= minFrame):
			validFrames += [frameID]
	else:
		validFrames += [Castagne.GetInt(letterArgs, pid, currentState)]
	
	letterArgs = validFrames
	
	InstructionBranch(args, pid, currentState, engine, neededFlag, frameID in validFrames)

func InstructionL(args, pid, currentState, engine, neededFlag):
	var flagName = args[2]
	InstructionBranch(args, pid, currentState, engine, neededFlag, flagName in currentState[pid]["Flags"])
	
func InstructionE(args, pid, currentState, engine, neededFlag):
	var eventName = args[2]
	InstructionBranch(args, pid, currentState, engine, neededFlag, eventName in currentState[pid]["Events"])

func InstructionV(args, pid, currentState, engine, neededFlag):
	var varName = args[2]
	var cond = varName in currentState[pid]
	if(cond):
		cond = Castagne.GetBool(varName, pid, currentState)
	InstructionBranch(args, pid, currentState, engine, neededFlag, cond)

func InstructionBranch(args, pid, currentState, engine, neededFlag, condition):
	var actionListTrue = args[0]
	var actionListFalse = args[1]
	
	var actionList = actionListFalse
	if(condition):
		actionList = actionListTrue
	
	for action in actionList:
		engine.ExecuteAction(action, pid, currentState, neededFlag)

	
