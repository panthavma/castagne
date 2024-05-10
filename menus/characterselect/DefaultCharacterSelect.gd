# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "res://castagne/menus/CastagneMenu.gd"


# Big ugly menu I stole from the Kronian Titans demo and changed a bit.
# Will be updated at a later date.

var p1 = {}
var p2 = {}
var soloPlayer = -1

var characters

enum State {
	SelectingCharacter, SelectColor, Ready
}

func _ready():
	var pDict = [p1, p2]
	var pStr = ["p1", "p2"]
	characters = Castagne.GetAllCharactersMetadata()
	
	if(Castagne.battleInitData["p1-control-type"] == "dummy"):
		soloPlayer = 1
	elif(Castagne.battleInitData["p2-control-type"] == "dummy"):
		soloPlayer = 0
	
	for id in range(2):
		var p = pDict[id]
		var pid = pStr[id]
		p["InputCooldown"] = 0.2
		p["State"] = State.SelectingCharacter
		p["Character"] = 0
		p["Color"] = id
		var prefabInputProvider = load(Castagne.configData["InputProviders"][Castagne.battleInitData[pid+"-control-type"]])
		var inputProvider = prefabInputProvider.instance()
		inputProvider.Init(Castagne.battleInitData[pid+"-control-param"])
		add_child(inputProvider)
		p["Input"] = inputProvider

func _process(delta):
	var current = [p1, p2]
	var other = [p2, p1]
	var inputs = [p1["Input"].PollRaw(), p2["Input"].PollRaw()]
	var uiRoots = [$L, $R]
	
	for id in range(2):
		var p = current[id]
		var o = other[id]
		var i = inputs[id]
		
		if(soloPlayer >= 0):
			if(soloPlayer == id):
				if(p["State"] == State.Ready):
					p["InputCooldown"] = 0.2
			else:
				if(o["State"] != State.Ready):
					p["InputCooldown"] = 0.2
				else:
					i = inputs[soloPlayer]
		
		if(p["InputCooldown"] > 0.0):
			p["InputCooldown"] -= delta
		else:
			HandleInput(p, i, o, id)
		
		var s = p["State"]
		var r = uiRoots[id]
		
		r.get_node("Options").set_text("Selecting Character :\n"+str(characters[p["Character"]]["Name"]))
		
		if(s == State.Ready):
			r.get_node("Ready").show()
		else:
			r.get_node("Ready").hide()
	
	var cl = ""
	for i in range(characters.size()):
		if(i == p1["Character"]):
			cl += ">> "
		cl += str(characters[i]["Name"])
		if(i == p2["Character"]):
			cl += " <<"
		cl += "\n"
	$C/Options.set_text(cl)

func HandleInput(p, i, o, id):
	var s = p["State"]
	
	if(s == State.Ready):
		if(i["C"]):
			p["State"] = State.SelectingCharacter
			p["InputCooldown"] = 0.2
			return
	
	# Unused for now
	elif(s == State.SelectColor):
		if(i["D"]):
			if(o["State"] == State.Ready and o["Color"] == p["Color"]):
				return
			
			UpdateColor(id, p["Color"])
			p["State"] = State.Ready
			p["InputCooldown"] = 0.2
			
			if(soloPlayer >= 0):
				o["InputCooldown"] = 0.2
			
			if(o["State"] == State.Ready):
				StartMatch()
			
			return
		if(i["C"]):
			p["State"] = State.SelectingCharacter
			p["InputCooldown"] = 0.2
			return
		
		if(i["Left"]):
			p["Color"] = max(0, p["Color"]-1)
			p["InputCooldown"] = 0.2
			UpdateColor(id, p["Color"])
			return
		if(i["Right"]):
			p["Color"] = min(5, p["Color"]+1)
			p["InputCooldown"] = 0.2
			UpdateColor(id, p["Color"])
			return
	
	else:
		if(i["D"]):
			p["State"] = State.Ready
			p["InputCooldown"] = 0.2
			
			if(soloPlayer >= 0):
				o["InputCooldown"] = 0.2
			
			if(o["State"] == State.Ready):
				StartMatch()
			return
		if(i["C"]):
			if(soloPlayer >= 0):
				if(o["State"] == State.Ready):
					o["State"] = State.SelectingCharacter
				else:
					ReturnToMainMenu()
			p["InputCooldown"] = 0.2
			return
		
		if(i["Up"]):
			p["Character"] = max(0, p["Character"]-1)
			p["InputCooldown"] = 0.2
			return
		if(i["Down"]):
			p["Character"] = min(characters.size()-1, p["Character"]+1)
			p["InputCooldown"] = 0.2
			return

func UpdateColor(_playerID, _newColorID):
	pass

func ReturnToMainMenu():
	var ps = load(Castagne.configData["MainMenu"])
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()

func StartMatch():
	Castagne.battleInitData["p1"] = p1["Character"]
	Castagne.battleInitData["p1-palette"] = p1["Color"]
	Castagne.battleInitData["p2"] = p2["Character"]
	Castagne.battleInitData["p2-palette"] = p2["Color"]
	
	Castagne.battleInitData["p1Points"] = 0
	Castagne.battleInitData["p2Points"] = 0
	
	var ps = load(Castagne.configData["Engine"])
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()
