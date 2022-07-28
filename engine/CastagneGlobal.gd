# Globally accessible class for Castagne
# Is the main interface for the Castagne Engine

# :TODO:Panthavma:20211230:Start working on castagne menus
# :TODO:Panthavma:20211230:Move debug code to the dev folder (or editor/dev)
# :TODO:Panthavma:20211230:Rework input to be more modular
# :TODO:Panthavma:20211230:More flexible tool loading (have short names for the default ones)

# :TODO:Panthavma:20211230:General code documentation
# :TODO:Panthavma:20211230:Site documentation
# :TODO:Panthavma:20211230:Automatic documentation of modules

extends Node

onready var Parser = $Parser
onready var Net = $Net
onready var Loader = $Loader
onready var Menus
# Dict with options

const CONFIG_FILE_PATH = "res://castagne-config.json"
const CONFIG_CORE_MODULE_PATH = "res://castagne/modules/functions/CFCore.gd"
const INPUT_LOCAL = 0
const INPUT_ONLINE = 1
const INPUT_AI = 2
const INPUT_DUMMY = 3

enum HITCONFIRMED {
	NONE, BLOCK, HIT
}

const PRORATION_SCALE = 1000

var configData
var battleInitData

var functions

var modules

func _ready():
	Log("Castagne Startup")
	functions = {}
	
	# 1. Loading Config
	configData = {"Modules-core":CONFIG_CORE_MODULE_PATH}
	var customConfigData = ReadFromConfigFile()
	
	if(customConfigData == null):
		Error("Couldn't find a Castagne config file at " + str(CONFIG_FILE_PATH))
	else:
		FuseDataOverwrite(configData, customConfigData)
	
	
	# 2. Load modules and set functions
	Log("Loading Modules")
	modules = []
	
	# 2.1 Load the core module, which will give the path to other modules
	LoadModule(configData["Modules-core"])
	
	# 2.2 Load all the other modules
	for modulePath in SplitStringToArray(configData["Modules"]):
		LoadModule(modulePath)
	
	# 3. Set BattleInitData
	battleInitData = GetDefaultBattleInitData()

func ReadFromConfigFile(configFilePath=null):
	if(configFilePath == null):
		configFilePath = CONFIG_FILE_PATH
	var file = File.new()
	if(!file.file_exists(configFilePath)):
		Error("File " + configFilePath + " does not exist.")
		return null
	file.open(configFilePath, File.READ)
	var fileText = file.get_as_text()
	file.close()
	
	return parse_json(fileText)

func SaveConfigFile(configFilePath=null):
	if(configFilePath == null):
		configFilePath = CONFIG_FILE_PATH
	
	var file = File.new()
	if(!file.file_exists(configFilePath)):
		Error("File " + configFilePath + " does not exist.")
		return ERR_FILE_NOT_FOUND
	
	var defaultConfig = {"Modules-core":CONFIG_CORE_MODULE_PATH}
	for module in modules:
		FuseDataOverwrite(defaultConfig, module.configDefault.duplicate(true))
	
	var savedData = {}
	for key in configData:
		var save = false
		if(!defaultConfig.has(key)):
			save = true
		elif(configData[key] != defaultConfig[key]):
			if(typeof(configData[key]) == TYPE_DICTIONARY):
				save = !AreDictionariesEqual(configData[key], defaultConfig[key])
			else:
				save = true
		
		if(save):
			savedData[key] = configData[key]
	
	var jsonData = to_json(savedData)
	file.open(configFilePath, File.WRITE)
	file.store_string(jsonData)
	file.close()
	
	return OK

func LoadModule(modulePath):
	var module = null
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
		if(!configData.has("Modules-"+modulePath)):
			Error("Can't find module list to load: "+modulePath)
			return
		for mPath in SplitStringToArray(configData["Modules-"+modulePath]):
			LoadModule(mPath)
		return
	
	if(module == null):
		Error("Module couldn't be loaded: "+str(modulePath))
		return
	Log("Loading Module: " + module.get_name())
	
	add_child(module)
	module.ModuleSetup()
	
	modules += [module]
	FuseDataNoOverwrite(configData, module.configDefault.duplicate(true))

func GetDefaultBattleInitData():
	var bid = {}
	for m in modules:
		FuseDataOverwrite(bid, m.battleInitDataDefault.duplicate(true))
	return bid

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
	for cpath in SplitStringToArray(configData["CharacterPaths"]):
		var cdata = Parser.GetCharacterMetadata(cpath)
		if(cdata != null):
			characters.append(cdata)
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
		if(!b.has(k) or a[k] != b[k]):
			return false
	return true

func SplitStringToArray(stringToSeparate, separator=","):
	var a = []
	var strings = stringToSeparate.split(separator)
	for s in strings:
		s = s.strip_edges()
		if(!s.empty()):
			a.push_back(s)
	return a
