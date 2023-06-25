extends Node


# :TODO:Panthavma:20220124:Allow only some modules to be called for slight perf boost ?


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

# Called at the beginning of each frame, before choosing the loop
func FramePreStart(_stateHandle):
	pass
# Called at the beginning of each frame
func FrameStart(_stateHandle):
	pass
# Called at the end of each frame
func FrameEnd(_stateHandle):
	pass


# AI Phase: Helpful to execute the AI logic for an entity and create fake button presses
func AIPhaseStart(_gameStateHandle):
	pass
func AIPhaseStartEntity(_gameStateHandle):
	pass
func AIPhaseEndEntity(_gameStateHandle):
	pass
func AIPhaseEnd(_gameStateHandle):
	pass

# Input Phase: Applies the input to the entities
func InputPhaseStart(_gameStateHandle):
	pass
func InputPhaseStartEntity(_gameStateHandle):
	pass
func InputPhaseEndEntity(_gameStateHandle):
	pass
func InputPhaseEnd(_gameStateHandle):
	pass

# Init Phase: Prepares the entities themselves
func InitPhaseStart(_gameStateHandle):
	pass
func InitPhaseStartEntity(_gameStateHandle):
	pass
func InitPhaseEndEntity(_gameStateHandle):
	pass
func InitPhaseEnd(_gameStateHandle):
	pass

# Action Phase: Allows the characters to act
func ActionPhaseStart(_gameStateHandle):
	pass
func ActionPhaseStartEntity(_gameStateHandle):
	pass
func ActionPhaseEndEntity(_gameStateHandle):
	pass
func ActionPhaseEnd(_gameStateHandle):
	pass

# Physics Phase: Allows the characters to move, and computes the hits
func PhysicsPhaseStart(_gameStateHandle):
	pass
func PhysicsPhaseStartEntity(_gameStateHandle):
	pass
func PhysicsPhaseEndEntity(_gameStateHandle):
	pass
func PhysicsPhaseEnd(_gameStateHandle):
	pass
# :TODO:Panthavma:20220124:Allow a more flexible physics phase through modules

# Reaction Phase: Allows the entities to change their state
func ReactionPhaseStart(_gameStateHandle):
	pass
func ReactionPhaseStartEntity(_gameStateHandle):
	pass
func ReactionPhaseEndEntity(_gameStateHandle):
	pass
func ReactionPhaseEnd(_gameStateHandle):
	pass

# Freeze Phase: Called when skipping frames
func FreezePhaseStart(_gameStateHandle):
	pass
func FreezePhaseStartEntity(_gameStateHandle):
	pass
func FreezePhaseEndEntity(_gameStateHandle):
	pass
func FreezePhaseEnd(_gameStateHandle):
	pass


# Called on each graphical frame to keep the display up to date
func UpdateGraphics(_gameStateHandle):
	pass









# --------------------------------------------------------------------------------------------------
# Helper functions

var moduleName = "Unnamed Module"
var moduleSlot = null
var moduleDocumentation = {"Description":""}

var moduleDocumentationCategories = {null:{"Name":"Uncategorized", "Description":"", "Variables":[], "Functions":[], "Flags":[], "Config":[], "BattleInitData":[]}}

func RegisterModule(_moduleName, _moduleSlot=null, _moduleDocumentation = null):
	if(moduleName != "Unnamed Module"):
		return
	moduleName = _moduleName
	moduleSlot = _moduleSlot
	if(_moduleDocumentation == null):
		_moduleDocumentation = moduleDocumentation
	moduleDocumentation = _moduleDocumentation
	
	if(!moduleDocumentation.has("docname")):
		moduleDocumentation["docname"] = moduleName.to_lower()
	
	if(_battleInitDataDefault.size() == 0):
		_battleInitDataDefault = {Castagne.MEMORY_STACKS.Global:{}, Castagne.MEMORY_STACKS.Entity:{}, Castagne.MEMORY_STACKS.Player:{}}


# Call before declaring functions or variables to group them in a category
func RegisterCategory(categoryName, categoryDocumentation = null):
	# TODO
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

func RegisterVariableEntity(variableName, defaultValue, flags = null, documentation = null):
	variablesEntity[variableName] = _RegisterVariableCommon(variableName, defaultValue, flags, documentation, true)

func RegisterConstant(constantName, value, documentation = null):
	RegisterVariableEntity(constantName, value, null, documentation)

func RegisterVariableGlobal(variableName, defaultValue, flags = null, documentation = null):
	variablesGlobal[variableName] = _RegisterVariableCommon(variableName, defaultValue, flags, documentation, false)

func _RegisterVariableCommon(variableName, defaultValue, flags, documentation, entityVariable):
	if(flags == null):
		flags = []
	
	if("ResetEachFrame" in flags):
		if(entityVariable):
			_variablesResetEntity[variableName] = defaultValue
		else:
			_variablesResetGlobal[variableName] = defaultValue
	
	# :TODO:Panthavma:20220203:Add a "temporary/volatile" flag for variables that won't get stored
	
	if(!"NoInit" in flags):
		if(entityVariable):
			_variablesInitEntity[variableName] = defaultValue
		else:
			_variablesInitGlobal[variableName] = defaultValue
	
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

# :TODO:Panthavma:20220124:Document the flags and how to document
# :TODO:Panthavma:20220124:Document how the functions are found
# Registers a function in the parser. 
func RegisterFunction(functionName, nbArguments, flags = null, documentation = null):
	var parseFunc = null
	var actionFunc = null
	var gizmoFunc = null
	
	if(flags == null):
		flags = []
	
	# :TODO:Panthavma:20220124:Look at making it parallel through the ThreadSafe flag
	# :TODO:Panthavma:20220124:Rework the flags
	
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



# :TODO:Panthavma:20220420:Make them actual flags instead of strings, with a more global system
func HasFlag(eState, flagName):
	if(eState.has("Flags")):
		return eState["Flags"].has(flagName)
	return false
func SetFlag(eState, flagName, flagVarName = "Flags"):
	if(!eState[flagVarName].has(flagName)):
		eState[flagVarName] += [flagName]
func UnsetFlag(eState, flagName, flagVarName = "Flags"):
	eState[flagVarName].erase(flagName)

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
		return default
	var value = args[argID]
	if(stateHandle == null):
		return default
	if(stateHandle.EntityHas(value)):
		return str(stateHandle.EntityGet(value))
	return value

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
		return int(v)
	# :TODO:Panthavma:20220126:Make the message more precise
	Castagne.Error("ArgInt ("+str(argID)+"): Couldn't find variable " + value)
	if(default == null):
		return 1
	return default


# :TODO:Panthavma:20220203:Replace by True/False constants
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
	# :TODO:Panthavma:20220126:Make the message more precise
	Castagne.Error("ArgBool ("+argID+"): Couldn't find variable " + value)
	return default



func SetVariableInTarget(stateHandle, varTargetEntity, value):
	# TODO check if already in?
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
var variablesEntity = {}
var _variablesInitGlobal = {}
var _variablesInitEntity = {}
var _variablesResetGlobal = {}
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
	
	#Castagne.FuseDataOverwrite(state, _variablesInitGlobal.duplicate(true))

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
	#Castagne.FuseDataOverwrite(state, _variablesResetGlobal.duplicate(true))
	var vrg = (_variablesResetGlobal.duplicate(true))
	for k in vrg:
		stateHandle.GlobalSet(k, vrg[k])
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)
		var vre = _variablesResetEntity.duplicate(true)
		for k in vre:
			stateHandle.EntitySet(k, vre[k])
		#Castagne.FuseDataOverwrite(state[eid], )
