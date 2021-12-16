# Globally accessible class for Castagne
# Is the main interface for the Castagne Engine

extends Node

onready var Parser = $Parser
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
var functionProviders

func _init():
	Log("Castagne Startup")
	data = ReadFromConfigFile(CONFIG_FILE_PATH)
	battleInitData = GetDefaultBattleInitData()
	functions = {}
	functionProviders = []
	
	if(data == null):
		Error("Couldn't read from config file, aborting.")
		return
	
	# Setup Functions
	Log("Loading Functions")
	var funcList = []
	funcList.append_array(data["Functions-Base"])
	funcList.append_array(data["Functions-Custom"])
	for fPath in funcList:
		var f = load(fPath).instance()
		add_child(f)
		Log("Loading Functions : " + f.get_name())
		f.castagne = self
		f.Setup()
		functionProviders += [f]

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

func GetDefaultConfig():
	var file = File.new()
	if(!file.file_exists(CONFIG_DEFAULT_FILE_PATH)):
		Error("File " + CONFIG_DEFAULT_FILE_PATH + " does not exist.")
		return null
	file.open(CONFIG_DEFAULT_FILE_PATH, File.READ)
	var fileText = file.get_as_text()
	file.close()
	
	return parse_json(fileText)

func GetDefaultBattleInitData():
	return {
		"map":0, "music":0, "mode":"Training",
		"p1":0, "p1-control-type":"local", "p1-control-param":"k1", "p1-palette":0,
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
