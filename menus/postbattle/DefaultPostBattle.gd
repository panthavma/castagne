# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "res://castagne/menus/CastagneMenu.gd"

# Big ugly menu I stole from the Kronian Titans demo and changed a bit.
# Will be updated at a later date.

var p1 = {}
var p2 = {}

enum State {
	Choosing, Ready
}

var choices = ["Rematch", "Return to Character Select", "Quit to Main Menu"]

func _ready():
	var pDict = [p1, p2]
	var pStr = ["p1", "p2"]
	var uiRoots = [$L, $R]
	
	for id in range(2):
		var p = pDict[id]
		var pid = pStr[id]
		p["InputCooldown"] = 0.2
		p["State"] = State.Choosing
		p["Choice"] = 0
		var prefabInputProvider = load(Castagne.configData["InputProviders"][Castagne.battleInitData[pid+"-control-type"]])
		var inputProvider = prefabInputProvider.instance()
		inputProvider.Init(Castagne.battleInitData[pid+"-control-param"])
		add_child(inputProvider)
		p["Input"] = inputProvider
		# TODO rename p1Points in p1-points for consistency
		if(Castagne.battleInitData[pStr[id]+"Points"] == 2):
			uiRoots[id].get_node("Menu/Result").set_text("Victory!")
		else:
			uiRoots[id].get_node("Menu/Result").set_text("Defeat...")
	
	if(Castagne.battleInitData["p1-control-type"] == "dummy"):
		p1["State"] = State.Ready
	elif(Castagne.battleInitData["p2-control-type"] == "dummy"):
		p2["State"] = State.Ready

func _process(delta):
	var current = [p1, p2]
	var other = [p2, p1]
	var inputs = [p1["Input"].PollRaw(), p2["Input"].PollRaw()]
	var uiRoots = [$L, $R]
	
	for id in range(2):
		var p = current[id]
		var o = other[id]
		var i = inputs[id]
		
		if(p["InputCooldown"] > 0.0):
			p["InputCooldown"] -= delta
		else:
			HandleInput(p, i, o, id, uiRoots[id])

func HandleInput(p, i, o, _id, r):
	var s = p["State"]
	
	if(s == State.Ready):
		r.get_node("Menu/Options").hide()
		
		if(i["C"]):
			p["State"] = State.Choosing
			p["InputCooldown"] = 0.2
			r.get_node("Menu/Options").show()
			return
	
	else:
		r.get_node("Menu/Options").show()
		
		if(i["D"]):
			p["State"] = State.Ready
			p["InputCooldown"] = 0.2
			r.get_node("Menu/Options").hide()
			
			if(p["Choice"] == 1):
				ReturnToCharacterSelect()
				return
			
			if(p["Choice"] == 2):
				ReturnToMainMenu()
				return
			
			if(o["State"] == State.Ready):
				StartMatch()
				return
			
			return
		
		if(i["Up"]):
			p["InputCooldown"] = 0.2
			p["Choice"] = max(0, p["Choice"]-1)
			UpdateCursorPos(r, p["Choice"])
			return
		if(i["Down"]):
			p["InputCooldown"] = 0.2
			p["Choice"] = min(2, p["Choice"]+1)
			UpdateCursorPos(r, p["Choice"])
			return
		UpdateCursorPos(r, p["Choice"])

func UpdateCursorPos(r, choice):
	var t = ""
	for i in range(choices.size()):
		if(i == choice):
			t += ">> " + choices[i] + " <<\n"
		else:
			t+= choices[i]+"\n"
	r.get_node("Menu/Options").set_text(t)

func ReturnToMainMenu():
	var ps = load(Castagne.configData["MainMenu"])
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()

func ReturnToCharacterSelect():
	var ps = load(Castagne.configData["CharacterSelect"])
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()

func StartMatch():
	Castagne.battleInitData["p1Points"] = 0
	Castagne.battleInitData["p2Points"] = 0
	
	var ps = load("res://castagne/engine/CastagneEngine.tscn")
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()
