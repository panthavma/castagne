extends Control

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
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "dummy"
	Castagne.battleInitData["p2-control-param"] = "k1"
	Castagne.battleInitData["mode"] = "Training"
	call_deferred("LoadLevel", "res://castagne/engine/CastagneEngine.tscn")
func Training2():
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "c1"
	Castagne.battleInitData["mode"] = "Training"
	call_deferred("LoadLevel", "res://castagne/engine/CastagneEngine.tscn")

func Editor():
	call_deferred("LoadLevel", "res://castagne/editor/CastagneEditor.tscn")

func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()
