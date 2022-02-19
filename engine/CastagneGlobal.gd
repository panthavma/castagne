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
onready var Menus
# Dict with options

const CONFIG_FILE_PATH = "res://castagne-config.json"
const CONFIG_DEFAULT_FILE_PATH = "res://castagne/castagne-config-default.json"
const INPUT_LOCAL = 0
const INPUT_ONLINE = 1
const INPUT_AI = 2
const INPUT_DUMMY = 3

enum HITCONFIRMED {
	NONE, BLOCK, HIT
}

const PRORATION_SCALE = 1000

var data
var battleInitData

var functions

var modules

func _ready():
	Log("Castagne Startup")
	data = ReadFromConfigFile(CONFIG_FILE_PATH)
	battleInitData = GetDefaultBattleInitData()
	functions = {}
	
	if(data == null):
		Error("Couldn't read from config file, aborting.")
		return
	
	# Setup Functions
	Log("Loading Modules")
	var modulesList = []
	# :TODO:Panthavma:20220125:Make the loading more flexible, alongside params
	#modulesList.append_array(data["Functions-Base"])
	#modulesList.append_array(data["Functions-Base"])
	modulesList.append_array(data["Modules"])
	modules = []
	for modulePath in modulesList:
		# :TODO:Panthavma:20220201:Check for errors
		var module = load(modulePath).instance()
		add_child(module)
		Log("Loading Module : " + module.get_name())
		module.ModuleSetup()
		modules += [module]

func ReadFromConfigFile(configFilePath):
	var d = GetDefaultConfig()
	if(d == null):
		return null
	
	var file = File.new()
	if(!file.file_exists(configFilePath)):
		Error("File " + configFilePath + " does not exist.")
		return null
	file.open(configFilePath, File.READ)
	var fileText = file.get_as_text()
	file.close()
	
	var newConfig = parse_json(fileText)
	FuseDataOverwrite(d, newConfig)
	return d

# :TODO:Panthavma:20211230:Make it more modular through modules instead of a file
func GetDefaultConfig():
	var file = File.new()
	if(!file.file_exists(CONFIG_DEFAULT_FILE_PATH)):
		Error("File " + CONFIG_DEFAULT_FILE_PATH + " does not exist.")
		return null
	file.open(CONFIG_DEFAULT_FILE_PATH, File.READ)
	var fileText = file.get_as_text()
	file.close()
	
	return parse_json(fileText)

# :TODO:Panthavma:20211230:Make it more modular through modules
func GetDefaultBattleInitData():
	return {
		"map":0, "music":0, "mode":"Training", "online":false,
		"p1":0, "p1-control-type":"local", "p1-control-param":"k1", "p1-palette":0,
		"p1-onlinepeer":1, "p2-onlinepeer":1,
		#"p2":0, "p2-control-type":"dummy", "p2-control-param":"",
		"p2":0, "p2-control-type":"local", "p2-control-param":"c1", "p2-palette":1,
		"p1Points":0, "p2Points":0,
	}

func Log(text):
	print("[Castagne] " + str(text))

func Error(text):
	print("[Castagne] ! " + str(text))

func GetAllCharactersMetadata():
	var characters = []
	for cpath in data["CharacterPaths"]:
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
