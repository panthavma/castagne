# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node


# Function callback signature:
# func FunctionName(args, eState, _data):

# --------------------------------------------------------------------------------------------------
# Callbacks and functions

# Used when the program starts, on loading.
func ModuleSetup():
	pass

# Called when a config data registers this module
func OnModuleRegistration(_configData):
	pass

# :TODO:Panthavma:20220124:Document the exact time it starts
# Used at the beginning of a battle
func BattleInit(_stateHandle, _battleInitData):
	pass
func BattleInitLate(_stateHandle, _battleInitData):
	pass

# Called at the beginning of each frame, before choosing the loop
func FramePreStart(_stateHandle):
	pass
# Called at the beginning of each frame
func FrameStart(_stateHandle):
	pass
# Called at the end of each frame
func FrameEnd(_stateHandle):
	pass


# List of phase callbacks, they will be detected by the engine if present
# AI Phase: Helpful to execute the AI logic for an entity and create fake button presses
#func AIPhaseStart(_gameStateHandle):
#func AIPhaseStartEntity(_gameStateHandle):
#func AIPhaseEndEntity(_gameStateHandle):
#func AIPhaseEnd(_gameStateHandle):

# Input Phase: Applies the input to the entities
#func InputPhaseStart(_gameStateHandle):
#func InputPhaseStartEntity(_gameStateHandle):
#func InputPhaseEndEntity(_gameStateHandle):
#func InputPhaseEnd(_gameStateHandle):

# Init Phase: Prepares the entities themselves
#func InitPhaseStart(_gameStateHandle):
#func InitPhaseStartEntity(_gameStateHandle):
#func InitPhaseEndEntity(_gameStateHandle):
#func InitPhaseEnd(_gameStateHandle):

# Action Phase: Allows the characters to act
func ActionPhaseStart(_gameStateHandle):
	pass
func ActionPhaseStartEntity(_gameStateHandle):
	pass
func ActionPhaseEndEntity(_gameStateHandle):
	pass
func ActionPhaseEnd(_gameStateHandle):
	pass

# Subentity Phase: Lightweight phase for subentities. By default, does the same as action phase.
func SubentityPhaseStart(gameStateHandle):
	ActionPhaseStart(gameStateHandle)
func SubentityPhaseStartEntity(gameStateHandle):
	ActionPhaseStartEntity(gameStateHandle)
func SubentityPhaseEndEntity(gameStateHandle):
	ActionPhaseEndEntity(gameStateHandle)
func SubentityPhaseEnd(gameStateHandle):
	ActionPhaseEnd(gameStateHandle)

# Physics Phase: Allows the characters to move, and computes the hits
#func PhysicsPhaseStart(_gameStateHandle):
#func PhysicsPhaseStartEntity(_gameStateHandle):
#func PhysicsPhaseEndEntity(_gameStateHandle):
#func PhysicsPhaseEnd(_gameStateHandle):

# Reaction Phase: Allows the entities to change their state
#func ReactionPhaseStart(_gameStateHandle):
#func ReactionPhaseStartEntity(_gameStateHandle):
#func ReactionPhaseEndEntity(_gameStateHandle):
#func ReactionPhaseEnd(_gameStateHandle):

# Sent during the ReactionPhaseEndEntity (and other few points) to all entities which have changed state
func OnStateTransitionEntity(_gameStateHandle, _previousStateName, _newStateName):
	pass

# Freeze Phase: Called when skipping frames
#func FreezePhaseStart(_gameStateHandle):
#func FreezePhaseStartEntity(_gameStateHandle):
#func FreezePhaseEndEntity(_gameStateHandle):
#func FreezePhaseEnd(_gameStateHandle):


# Called on each graphical frame to keep the display up to date
func UpdateGraphics(_gameStateHandle):
	pass


func TransformDefinedData(_defines):
	return null






# --------------------------------------------------------------------------------------------------
# Helper functions

var moduleName = "Unnamed Module"
var moduleSlot = null
var moduleDocumentation = {"Description":""}
var moduleSpecblocks = {}

var moduleDocumentationCategories = {null:{"Name":"Uncategorized", "Description":"", "Variables":[], "Functions":[], "Flags":[], "Config":[], "BattleInitData":[]}}

func RegisterModule(_moduleName, _moduleSlot=null, _moduleDocumentation = null):
	if(moduleName != "Unnamed Module"):
		return
	moduleName = _moduleName
	moduleSlot = _moduleSlot
	if(_moduleDocumentation == null):
		_moduleDocumentation = moduleDocumentation
	moduleDocumentation = _moduleDocumentation
	moduleSpecblocks = {}
	
	if(!moduleDocumentation.has("docname")):
		moduleDocumentation["docname"] = moduleName.to_lower()
	
	if(_battleInitDataDefault.size() == 0):
		_battleInitDataDefault = {Castagne.MEMORY_STACKS.Global:{}, Castagne.MEMORY_STACKS.Entity:{}, Castagne.MEMORY_STACKS.Player:{}}


# Call before declaring functions or variables to group them in a category
func RegisterCategory(categoryName, categoryDocumentation = null):
	currentCategory = categoryName
	if(categoryDocumentation == null):
		categoryDocumentation = {}
	Castagne.FuseDataNoOverwrite(categoryDocumentation, {
			"Description":"",
		})
	categoryDocumentation["Name"] = categoryName
	categoryDocumentation["Variables"] = []
	categoryDocumentation["Functions"] = []
	categoryDocumentation["Flags"] = []
	categoryDocumentation["Config"] = []
	categoryDocumentation["BattleInitData"] = []
	moduleDocumentationCategories[categoryName] = categoryDocumentation

func RegisterSpecblock(specblockName, specblockGDPath, argument = null):
	if(!specblockGDPath.ends_with(".gd")):
		ModuleError("RegisterModuleSpecblock: Path doesn't end in .gd! Aborting. ("+str(specblockGDPath)+")")
		return
	var sbScript = load(specblockGDPath)
	if(sbScript == null):
		ModuleError("RegisterModuleSpecblock: Can't find script to load: "+str(specblockGDPath))
		return
	var sbNode = Node.new()
	sbNode.set_script(sbScript)
	sbNode.set_name(specblockName)
	add_child(sbNode)
	sbNode.module = self
	sbNode._specblockName = specblockName
	sbNode.SetupSpecblock(argument)
	moduleSpecblocks[specblockName] = sbNode

func RegisterVariablePlayer(variableName, defaultValue, flags = null, documentation = null):
	variablesPlayer[variableName] = _RegisterVariableCommon(variableName, defaultValue, flags, documentation, false, true)

func RegisterVariableEntity(variableName, defaultValue, flags = null, documentation = null):
	variablesEntity[variableName] = _RegisterVariableCommon(variableName, defaultValue, flags, documentation, true)

func RegisterConstant(constantName, value, documentation = null):
	RegisterVariableEntity(constantName, value, null, documentation)

func RegisterVariableGlobal(variableName, defaultValue, flags = null, documentation = null):
	variablesGlobal[variableName] = _RegisterVariableCommon(variableName, defaultValue, flags, documentation, false)

func _RegisterVariableCommon(variableName, defaultValue, flags, documentation, entityVariable, entityPlayer = false):
	if(flags == null):
		flags = []
	
	if("ResetEachFrame" in flags):
		if(entityPlayer):
			_variablesResetPlayer[variableName] = defaultValue
		elif(entityVariable):
			_variablesResetEntity[variableName] = defaultValue
		else:
			_variablesResetGlobal[variableName] = defaultValue
	
	if(!"NoInit" in flags):
		if(entityPlayer):
			_variablesInitPlayer[variableName] = defaultValue
		elif(entityVariable):
			_variablesInitEntity[variableName] = defaultValue
		else:
			_variablesInitGlobal[variableName] = defaultValue
	
	if("InheritToSubentity" in flags and entityVariable):
		_variablesEntityInheritToSubentity += [variableName]
	
	if(documentation == null):
		documentation = {}
	
	var defaultDocumentation = {
		"Description": ""
	}
	
	Castagne.FuseDataNoOverwrite(documentation, defaultDocumentation)
	
	documentation["Name"] = variableName
	documentation["Default"] = defaultValue
	documentation["Flags"] = flags
	
	moduleDocumentationCategories[currentCategory]["Variables"].append(documentation)
	return documentation

# Registers a function in the parser. 
func RegisterFunction(functionName, nbArguments, flags = null, documentation = null):
	var parseFunc = null
	var actionFunc = null
	var gizmoFunc = null
	
	if(flags == null):
		flags = []
	
	if(flags.has("Transition")):
		print("CHANGE TO REACTION: "+functionName)
	
	if(flags.has("EditorOnly")):
		flags += ["NoFunc"]
	
	if(flags.has("AllPhases")):
		flags += ["Init", "Action", "Reaction"]
	
	if(!flags.has("Reaction") and !flags.has("Action") and !flags.has("Init") and !flags.has("NoFunc")):
		flags += ["Init", "Action"]
	if(!flags.has("NoManual")):
		flags += ["Manual"]
	
	if(flags.has("Action") and !flags.has("NoSubentity")):
		flags += ["Subentity"]
	
	if(has_method("Parse"+functionName)):
		parseFunc = funcref(self, "Parse"+functionName)
	
	if(has_method(functionName)):
		actionFunc = funcref(self, functionName)
	
	if(has_method("Gizmo"+functionName)):
		gizmoFunc = funcref(self, "Gizmo"+functionName)
	
	if(parseFunc == null and flags.has("NoFunc")):
		parseFunc = funcref(self, "ParseFunc_NoFunc")
	
	if(parseFunc == null and actionFunc == null):
		Castagne.Error(functionName+" : Parse function or Action func couldn't be found.")
		return
	
	var docs = GetDefaultDocumentation(functionName, nbArguments, flags)
	if(documentation != null):
		Castagne.FuseDataOverwrite(docs, documentation)
	
	var argTypes = docs["Types"]
	if(argTypes == null):
		argTypes = []
	
	var maxArgs = 0
	for i in nbArguments:
		maxArgs = max(maxArgs, i)
	
	for _i in range(maxArgs - argTypes.size()):
		argTypes += ["any"]
	docs["Types"] = argTypes
	
	var funcData = {
		"Name": functionName,
		"NbArgs": nbArguments,
		"ParseFunc": parseFunc,
		"ActionFunc": actionFunc,
		"GizmoFunc": gizmoFunc,
		"Flags": flags,
		"Documentation":docs,
		"Category":currentCategory,
		"Types":argTypes,
	}
	
	moduleDocumentationCategories[currentCategory]["Functions"].append(funcData)
	_moduleFunctions[functionName] = funcData

func ParseFunc_NoFunc(_parser, _args, _parseData):
	return null

# Registers a flag for the documentation
func RegisterFlag(flagName, documentation = null):
	if(documentation == null):
		documentation = {
			"Description": ""
		}
	documentation["Name"] = flagName
	moduleDocumentationCategories[currentCategory]["Flags"].append(documentation)

# Registers a configuration option
func RegisterConfig(keyName, defaultValue, documentation=null):
	var docs = {
		"Description": "",
		"Flags":[],
		"Name":keyName,
	}
	if(documentation != null):
		Castagne.FuseDataOverwrite(docs, documentation)
	docs["Key"]=keyName
	docs["Default"]=defaultValue
	moduleDocumentationCategories[currentCategory]["Config"].append(docs)
	
	configDefault[keyName] = defaultValue

func RegisterCustomConfig(buttonName, submenuName, documentation=null):
	var docs = {
		"Description": "",
		"Flags":[],
		"Name":buttonName,
	}
	if(documentation != null):
		Castagne.FuseDataOverwrite(docs, documentation)
	docs["Flags"] += ["Custom"]
	docs["SubmenuName"] = submenuName
	moduleDocumentationCategories[currentCategory]["Config"].append(docs)

# Register a battle init data value, used by castagne at initialization.
func RegisterBattleInitData(memoryStack, keyName, defaultValue, documentation=null):
	if(documentation == null):
		documentation = {
			"Description": ""
		}
	documentation["Name"]=keyName
	moduleDocumentationCategories[currentCategory]["BattleInitData"].append(documentation)
	
	_battleInitDataDefault[memoryStack][keyName] = defaultValue


func RegisterStateFlag(flagName, documentation=null):
	if(documentation == null):
		documentation = {}
	_moduleStateFlags[flagName] = documentation


var baseCaspFilePath = null
func RegisterBaseCaspFile(filePaths = null, order=0):
	if(filePaths == null):
		baseCaspFilePath = null
	if(typeof(filePaths) != TYPE_ARRAY):
		filePaths = [filePaths]
	baseCaspFilePath = [filePaths, order, 0]



func EntityHasFlag(stateHandle, flagName):
	return stateHandle.EntityGet("_Flags").has(flagName)
func EntitySetFlag(stateHandle, flagName):
	if(!EntityHasFlag(stateHandle, flagName)):
		stateHandle.EntityGet("_Flags").push_back(flagName)
func EntityUnsetFlag(stateHandle, flagName):
	stateHandle.EntityGet("_Flags").erase(flagName)

func CallFunction(functionName, args, stateHandle):
	stateHandle.ConfigData().GetModuleFunctions()[functionName]["ActionFunc"].call_func(args, stateHandle)

func ModuleLog(text, stateHandle = null):
	var eidName = ("Entity ["+str(stateHandle.EntityGet("_EID"))+"]" if stateHandle != null else "")
	Castagne.Log("Module "+moduleName+" Log "+eidName+" : " + text)
func ModuleError(text, stateHandle = null):
	var eidName = (" Entity ["+str(stateHandle.EntityGet("_EID"))+"]" if stateHandle != null else "")
	Castagne.Error("Module "+moduleName+" Error"+eidName+": " + text)

func ArgStr(args, stateHandle, argID, default = null):
	if(args.size() <= argID):
		if(default == null):
			Castagne.Error("ArgStr ("+argID+"): This argument needs a default but doesn't have one")
		return str(default)
	var value = args[argID]
	if(stateHandle == null):
		return str(default)
	if(stateHandle.EntityHas(value)):
		return str(stateHandle.EntityGet(value))
	return str(value)

func ArgVar(args, _stateHandle, argID, default = null):
	if(args.size() <= argID):
		if(default == null):
			Castagne.Error("ArgVar ("+argID+"): This argument needs a default but doesn't have one")
		return default
	return args[argID]

func ArgInt(args, stateHandle, argID, default = null):
	if(args.size() <= argID):
		if(default == null):
			Castagne.Error("ArgInt ("+str(argID)+"): This argument needs a default but doesn't have one")
			return 1
		return default
	var value = str(args[argID])
	if(value.is_valid_integer()):
		return int(value)
	if(stateHandle == null):
		return default
	if(stateHandle.EntityHas(value)):
		var v = stateHandle.EntityGet(value)
		if(v == null):
			Castagne.Error("ArgInt ("+str(argID)+"): Variable " + value + " is null")
		else:
			return int(v)
	# :TODO:Panthavma:20220126:Make the message more precise
	Castagne.Error("ArgInt ("+str(argID)+"): Couldn't find variable " + value)
	if(default == null):
		return 1
	return default


func ArgBool(args, stateHandle, argID, default = null):
	if(args.size() <= argID):
		if(default == null):
			Castagne.Error("ArgBool ("+argID+"): This argument needs a default but doesn't have one")
		return default
	var value = str(args[argID])
	if(value.is_valid_integer()):
		return int(value) > 0
	if(stateHandle.EntityHas(value)):
		return int(stateHandle.EntityGet(value)) > 0
	Castagne.Error("ArgBool ("+argID+"): Couldn't find variable " + value)
	return default



func SetVariableInTarget(stateHandle, varTargetEntity, value):
	var copyData = {
		"OriginEID": stateHandle.GetEntityID(), "TargetEID": stateHandle.GetTargetEntity(),
		"Variable":varTargetEntity, "Value": value,
	}
	stateHandle.GlobalAdd("_CopyToBuffer", [copyData])
func SetFlagInTarget(stateHandle, flagName, value = true):
	var flagData = {
		"OriginEID": stateHandle.GetEntityID(), "TargetEID": stateHandle.GetTargetEntity(),
		"Flag":flagName, "Value": value,
	}
	stateHandle.GlobalAdd("_FlagTargetBuffer", [flagData])




# --------------------------------------------------------------------------------------------------
# Internals
var engine
var currentCategory = null
var variablesGlobal = {}
var variablesPlayer = {}
var variablesEntity = {}
var _variablesInitGlobal = {}
var _variablesInitPlayer = {}
var _variablesInitEntity = {}
var _variablesEntityInheritToSubentity = []
var _variablesResetGlobal = {}
var _variablesResetPlayer = {}
var _variablesResetEntity = {}
var configDefault = {}
var _battleInitDataDefault = {}
var _moduleFunctions = {}
var _moduleStateFlags = {}

func ArgRaw(args, argID, default = null):
	if(args.size() <= argID):
		if(default == null):
			Castagne.Error("ArgRaw ("+argID+"): This argument needs a default but doesn't have one")
		return default
	return args[argID]

func ArgRawIfExists(args, argID):
	if(args.size() <= argID):
		return null
	return args[argID]




func GetDefaultDocumentation(functionName, nbArguments, _flags):
	var d = {
		"Name":functionName,
		"NbArgs": nbArguments,
		"ArgsDesc":[],
		"Description":"Unspecified.",
		"Arguments":[],
		"Types":null,
	}
	
	for _i in range(nbArguments.size()):
		d["ArgsDesc"].append("Unspecified.")
	
	return d

func CopyVariablesGlobal(memory):
	var vars = _variablesInitGlobal.duplicate(true)
	for key in vars:
		memory.GlobalSet(key, vars[key], true)
func CopyVariablesPlayer(memory, pid):
	var vars = _variablesInitPlayer.duplicate(true)
	for key in vars:
		memory.PlayerSet(pid, key, vars[key], true)

func CopyVariablesEntityParsing(data):
	Castagne.FuseDataNoOverwrite(data, _variablesInitEntity.duplicate(true))

func CopyVariablesEntity(stateHandle, newValue = false):
	var vars = _variablesInitEntity.duplicate(true)
	for key in vars:
		if(newValue):
			if(!stateHandle.Memory().EntityHas(stateHandle._eid, key)):
				stateHandle.Memory().EntitySet(stateHandle._eid, key, vars[key], true)
		else:
			stateHandle.EntitySet(key, vars[key])

func ResetVariables(stateHandle, activeEIDs):
	var vrg = (_variablesResetGlobal.duplicate(true))
	for k in vrg:
		stateHandle.GlobalSet(k, vrg[k])
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)
		# Inefficient for players but okay for now
		var vrp = (_variablesResetPlayer.duplicate(true))
		for k in vrp:
			stateHandle.PlayerSet(k, vrp[k])
		var vre = _variablesResetEntity.duplicate(true)
		for k in vre:
			stateHandle.EntitySet(k, vre[k])
