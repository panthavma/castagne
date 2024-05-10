# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Globally accessible class for Castagne
# Is the main interface for the Castagne Engine, and can be used to create engine instances

extends Node

onready var Parser = $Parser
onready var Net = $Net
onready var Loader = $Loader
onready var Menus
# Dict with options

const CONFIG_FILE_PATH = "res://castagne-config.json"
const CONFIG_LOCAL_FILE_PATH = "user://castagne-local-config.json"
const CONFIG_CORE_MODULE_PATH = "res://castagne/modules/core/CMCore.gd"
const INPUT_LOCAL = 0
const INPUT_ONLINE = 1
const INPUT_AI = 2
const INPUT_DUMMY = 3

enum HITCONFIRMED { NONE, BLOCK, HIT, CLASH }

enum STATE_TYPE { Normal, BaseState, Helper, Special, Specblock }
enum VARIABLE_MUTABILITY { Variable, Define, Internal }
enum VARIABLE_TYPE { Int, Str, Var, Vec2, Vec3, Box, Bool }
enum MEMORY_STACKS { Global, Player, Entity }
enum MODULE_SLOTS_BASE { CORE, PHYSICS, ATTACKS, GRAPHICS, FLOW, EDITOR, INPUT, CUSTOM_1, CUSTOM_2, CUSTOM_3 }

enum INPUTDEVICE_TYPES { EMPTY, KEYBOARD, CONTROLLER }
enum PHYSICALINPUT_TYPES { RAW, BUTTON, AXIS, STICK, COMBINATION, ANY }
enum GAMEINPUT_TYPES { DIRECT, MULTIPLE, DERIVED }
enum GAMEINPUT_DERIVED_TYPES { BUTTON_PRESS, BUTTON_RELEASE, DIRECTIONAL, DIRECTION_NEUTRAL }

const PRORATION_SCALE = 1000

var baseConfigData = null
var _baseEnginePrefab
var _baseEditorPrefab

var modulesLoaded

func _ready():
	Log("Castagne Startup")
	
	baseConfigData = LoadModulesAndConfig()
	if(baseConfigData == null):
		Error("Castagne Statup failed!")
		queue_free()
		return
	
	add_child(baseConfigData)
	
	_baseEnginePrefab = Loader.Load(baseConfigData.Get("PathEngine"))
	_baseEditorPrefab = Loader.Load(baseConfigData.Get("PathEditor"))

func InstanceCastagneEngine(battleInitData = null, configData = null):
	var enginePrefab = _baseEnginePrefab
	
	if(configData != null):
		enginePrefab = Loader.Load(configData.Get("PathEngine"))
		Log("Instancing Castagne Engine with special config.")
	else:
		configData = baseConfigData
		Log("Instancing Castagne Engine.")
	
	if(battleInitData == null):
		battleInitData = configData.GetBaseBattleInitData()
	
	var engine = enginePrefab.instance()
	engine.configData = configData
	engine.battleInitData = battleInitData
	
	return engine

func InstanceCastagneEditor(configData = null):
	var editorPrefab = _baseEditorPrefab
	
	if(configData != null):
		editorPrefab = Loader.Load(configData.Get("PathEditor"))
		Log("Instancing Castagne Editor with special config.")
	else:
		configData = baseConfigData
		Log("Instancing Castagne Editor.")
	
	var editor = editorPrefab.instance()
	editor.configData = configData
	
	return editor

# Loads the modules and the config file to give to the engine. If no argument is given, it will
# load the base config file, add it to the tree, and do additional module loading
func LoadModulesAndConfig(configFilePath = null, localConfigFilePath = null):
	var firstLoad = false
	if(configFilePath == null):
		firstLoad = true
		configFilePath = CONFIG_FILE_PATH
		if(localConfigFilePath == null):
			localConfigFilePath = CONFIG_LOCAL_FILE_PATH
		Log("Loading Castagne modules and base config.")
	else:
		configFilePath = str(configFilePath)
		Log("Loading modules and config from file: " + configFilePath)
	
	# 1. Loading base config from file
	var configData = CreateNewEmptyConfigData()
	configData.Set("Modules-core",CONFIG_CORE_MODULE_PATH,true)
	
	if(!configData.LoadFromConfigFile(configFilePath)):
		Error("LoadModulesAndConfig: Config file doesn't exist. Aborting.")
		return null
	
	if(localConfigFilePath != null):
		if(!configData.LoadFromLocalConfigFile(localConfigFilePath)):
			Log("LoadModulesAndConfig: Local Config file "+str(localConfigFilePath)+" doesn't exist. This is normal on first run.")
	
	# 2. Load the core module, which will give the path to other modules
	modulesLoaded = {}
	var coreModule = (LoadModules(configData.Get("Modules-core"), configData))[0]
	if(coreModule == null):
		Error("LoadModulesAndConfig: Core module couldn't be loaded.")
		return null
	
	# 3. Load the config skeleton if it exists and load the base values
	var configSkeleton = null
	var configSkeletonPath = ""
	if(configData.Has("ConfigSkeleton")):
		configSkeletonPath = configData.Get("ConfigSkeleton")
	if(!configSkeletonPath.empty()):
		configSkeleton = CreateNewEmptyConfigData()
		if(!configSkeleton.LoadFromConfigFile(configSkeletonPath)):
			Error("LoadModulesAndConfig: Config skeleton file doesn't exist. Aborting.")
			return null
		configData.SetConfigSkeleton(configSkeleton)
	else:
		configSkeleton = configData
	configSkeleton.LoadDefaultValuesFromModule(coreModule)
	configData.RegisterModule(coreModule)
	
	# 4. Load the castagne core modules, for documentation mostly, the first time through.
	if(firstLoad):
		var coreModules = LoadModules(configData.Get("Modules-castagne-standard"), configData)
		if(coreModules == null):
			Error("LoadModulesAndConfig: Standard modules couldn't be loaded.")
			return null
	
	# 5. Load all the other modules defined by the user and load their default values inside the config skeleton
	var modules = LoadModules(configData.Get("Modules"), configData)
	if(modules == null):
		Error("LoadModulesAndConfig: LoadModules didn't work.")
		return null
	for m in modules:
		configSkeleton.LoadDefaultValuesFromModule(m)
		configData.RegisterModule(m)
	
	return configData

func LoadModulesAndConfigAdditive(configFilePath, baseConfig = null):
	if(baseConfig == null):
		if(baseConfigData == null):
			baseConfigData = LoadModulesAndConfig()
		baseConfig = baseConfigData
	
	var configData = CreateNewEmptyConfigData()
	if(!configData.LoadFromConfigFile(configFilePath)):
		Error("LoadModulesAndConfigAdditive: Config file doesn't exist. Aborting.")
		return null
	
	configData.SetConfigSkeleton(baseConfig)
	LoadModules(configData.Get("Modules"), configData)
	
	return configData

var prefabConfigData = preload("res://castagne/engine/CastagneConfig.gd")
func CreateNewEmptyConfigData():
	var configData = Node.new()
	configData.set_script(prefabConfigData)
	return configData

# Loads all modules from a config key, returns the modules or null if therer is an error.
func LoadModules(basePath, configData = null):
	var modulesPaths = ParseFullModulesList(basePath, configData)
	if(modulesPaths == null):
		Error("LoadModules: List is invalid. Aborted.")
		return null
	return LoadModulesFromList(modulesPaths)

# Loads all modules from a list, returns the modules or null if therer is an error.
func LoadModulesFromList(modulesPaths):
	var modules = []
	for modulePath in modulesPaths:
		var module = LoadSingleModule(modulePath)
		if(module == null):
			Error("LoadModulesFromList: Module is invalid, loading aborted: " + str(modulePath))
			return null
		modules.append(module)
	return modules

# Transforms one module list into all the modules' paths. Returns null on error.
func ParseFullModulesList(basePath, configData = null):
	if(configData == null):
		configData = baseConfigData
	var modulesPaths = []
	for modulePath in SplitStringToArray(basePath):
		if(modulePath.ends_with(".tscn") or modulePath.ends_with(".gd")):
			modulesPaths.append(modulePath)
		else:
			if(!configData.Has("Modules-"+modulePath)):
				Error("Can't find module list to load: "+modulePath)
				return null
			var sublist = ParseFullModulesList(configData.Get("Modules-"+modulePath), configData)
			if(sublist == null):
				return null
			modulesPaths += sublist
	return modulesPaths

# Loads one single module, or returns a reference to it if already loaded once
func LoadSingleModule(modulePath):
	var module = null
	if(modulesLoaded.has(modulePath)):
		return modulesLoaded[modulePath]
	
	if(modulePath.ends_with(".tscn")):
		var modulePrefab = load(modulePath)
		if(modulePrefab == null):
			Error("Can't find module to load: "+str(modulePath))
			return
		module = modulePrefab.instance()
	elif(modulePath.ends_with(".gd")):
		var scriptPrefab = load(modulePath)
		if(scriptPrefab == null):
			Error("Can't find script to load: "+str(modulePath))
			return
		module = Node.new()
		module.set_script(scriptPrefab)
		var moduleName = modulePath.right(modulePath.find_last("/"))
		module.set_name(moduleName.left(moduleName.length()-2))
	else:
		Error("LoadSingleModule: Not a valid module: " + str(modulePath))
		return null
	
	if(module == null):
		Error("Module couldn't be loaded: "+str(modulePath))
		return null
	Log("Loading Module: " + module.get_name() + " ("+str(modulePath)+")")
	
	add_child(module)
	module.ModuleSetup()
	
	modulesLoaded[modulePath] = module
	return module

func GetLoadedModules():
	return modulesLoaded

signal castagne_log(message)
func Log(text):
	emit_signal("castagne_log", text)
	print("[Castagne] " + str(text))

signal castagne_error(message)
func Error(text):
	emit_signal("castagne_error", text)
	print("[Castagne] ! " + str(text))

func GetAllCharactersMetadata():
	var characters = []
	for cpath in baseConfigData.Get("CharacterPaths"):
		characters.append(Parser.GetCharacterMetadata(cpath))
	return characters











# ------------------------------------------------------------------------------
# Helper functions

func HasFlag(flagname, pid, state):
	return flagname in state[pid]["Flags"]

func SetFlag(flagname, pid, state):
	if(!HasFlag(flagname, pid, state)):
		state[pid]["Flags"] += [flagname]

func UnsetFlag(flagname, pid, state):
	if(HasFlag(flagname, pid, state)):
		state[pid]["Flags"].erase(flagname)

func GetInt(value, pid, state):
	value = str(value)
	if(value.is_valid_integer()):
		return int(value)
	else:
		if(value in state[pid]):
			return int(state[pid][value])
		Castagne.Error("GetInt : not a correct value : " + value)
		return 0

func GetStr(value, _pid, _state):
	return str(value)
func GetStrVar(value, pid, state):
	if(value in state[pid]):
		return str(state[pid][value])
	return str(value)
func GetBool(value, pid, state):
	return GetInt(value, pid, state) > 0


func FuseDataOverwrite(baseDict, additionalDict):
	for key in additionalDict:
		baseDict[key] = additionalDict[key]
func FuseDataNoOverwrite(baseDict, additionalDict):
	for key in additionalDict:
		if(!baseDict.has(key)):
			baseDict[key] = additionalDict[key]
func FuseDataMoveWithPrefix(baseDict, additionalDict, prefix="Parent:"):
	for key in additionalDict:
		var keyName = key
		var keysToMove = []
		while(baseDict.has(keyName)):
			keysToMove.append(keyName)
			keyName = prefix+keyName
		for i in range(keysToMove.size()-1, -1, -1):
			var k = keysToMove[i]
			baseDict[prefix+k] = baseDict[k]
			
		baseDict[key] = additionalDict[key]
func AreDictionariesEqual(a, b):
	if(a == b):
		return true
	if(a.size() != b.size()):
		return false
	for k in a:
		if(!b.has(k)):
			return false
		if(a[k] == b[k]):
			continue
		
		var typeA = typeof(a[k])
		var typeB = typeof(b[k])
		if(typeA != typeB):
			return false
		
		if(typeA == TYPE_DICTIONARY):
			if(!AreDictionariesEqual(a[k], b[k])):
				return false
		elif(typeA == TYPE_ARRAY):
			if(!AreArraysEqual(a[k], b[k])):
				return false
		else:
			return false
	return true
func AreArraysEqual(a, b):
	if(a == b):
		return true
	if(a.size() != b.size()):
		return false
	for i in range(a.size()):
		if(a[i] == b[i]):
			continue
		
		var typeA = typeof(a[i])
		var typeB = typeof(b[i])
		if(typeA != typeB):
			return false
		
		if(typeA == TYPE_DICTIONARY):
			if(!AreDictionariesEqual(a[i], b[i])):
				return false
		elif(typeA == TYPE_ARRAY):
			if(!AreArraysEqual(a[i], b[i])):
				return false
		else:
			return false
	return true

func SplitStringToArray(stringToSeparate, separator=","):
	if(stringToSeparate == null or stringToSeparate.empty()):
		return []
	var a = []
	var strings = stringToSeparate.split(separator)
	for s in strings:
		s = s.strip_edges()
		if(!s.empty()):
			a.push_back(s)
	return a

func VariableTypeToCastagneType(variableType):
	if(variableType == TYPE_INT):
		return Castagne.VARIABLE_TYPE.Int
	if(variableType == TYPE_STRING):
		return Castagne.VARIABLE_TYPE.Str
	if(variableType == TYPE_BOOL):
		return Castagne.VARIABLE_TYPE.Bool
	Error("Castagne.VariableTypeToCastagneType: Can't convert type "+str(variableType))
	return null

func BattleInitData_GetPlayer(battleInitData, pid):
	if(battleInitData["players"].size() <= pid+1):
		Error("[BattleInitData_GetPlayer] BID not big enough for PID "+str(pid))
		return null
	
	var p = battleInitData["players"][0].duplicate(true)
	Castagne.FuseDataOverwrite(p, battleInitData["players"][pid+1].duplicate(true))
	return p

func BattleInitData_GetEntity(battleInitData, pid, eid):
	var p = BattleInitData_GetPlayer(battleInitData, pid)
	if(p == null):
		return null
	
	if(p["entities"].size() <= eid+1):
		Error("[BattleInitData_GetEntity] BID not big enough for EID "+str(eid))
		return null
	
	var e = p["entities"][0].duplicate(true)
	Castagne.FuseDataOverwrite(e, p["entities"][eid+1].duplicate(true))
	return e
