extends Control

# :TODO:Panthavma:20211230:Detect if running in the actual game or not
# :TODO:Panthavma:20211230:Make a menu for the starter
# :TODO:Panthavma:20211230:Make autostart
# :TODO:Panthavma:20211230:Be able to parameter some autostart features
# :TODO:Panthavma:20211230:Start making an editor
# :TODO:Panthavma:20211230:Editor must include dev functions

func _ready():
	MainMenu()

func MainMenu():
	call_deferred("LoadLevel", Castagne.data["MainMenu"])

func LocalBattle():
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "c1"
	Castagne.battleInitData["mode"] = "Battle"
	call_deferred("LoadLevel", "res://castagne/engine/CastagneEngine.tscn")

func Training():
	Castagne.battleInitData["p1"] = 1
	Castagne.battleInitData["p1-palette"] = 6
	Castagne.battleInitData["p2"] = 1
	Castagne.battleInitData["p2-palette"] = 7
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "dummy"
	Castagne.battleInitData["p2-control-param"] = "k1"
	Castagne.battleInitData["mode"] = "Training"
	call_deferred("LoadLevel", "res://castagne/engine/CastagneEngine.tscn")
func Training2():
	Training()
	Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "c1"

func Editor():
	call_deferred("LoadLevel", "res://castagne/editor/CastagneEditor.tscn")

func ShaderTest():
	call_deferred("LoadLevel", "res://shaders/PiShaderTest.tscn")

func EngineReworkTest():
	Castagne.battleInitData["p1"] = 0
	Castagne.battleInitData["p1-palette"] = 0
	Castagne.battleInitData["p2"] = 0
	Castagne.battleInitData["p2-palette"] = 1
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "dummy"
	#Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "c1"
	Castagne.battleInitData["mode"] = "Training"
	#Castagne.battleInitData["mode"] = "Battle"
	call_deferred("LoadLevel", "res://castagne/engine/CastagneEngine.tscn")

func RollbackTest():
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "k1"
	call_deferred("LoadLevel", "res://dev/rollback-test/RollbackOnlineTest.tscn")
	#call_deferred("LoadLevel", "res://dev/rollback-demo/Main.tscn")

func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()
