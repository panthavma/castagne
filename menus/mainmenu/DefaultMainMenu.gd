# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "res://castagne/menus/CastagneMenu.gd"

# Big ugly menu I stole from the Kronian Titans demo and changed a bit.
# Will be updated at a later date.

var optionSelected = 0
var optionList = ["LocalBattle", "Training", "QuitGame"]
var optionText = ["Local Battle", "Training", "Quit"]

var inputCooldown = 0
var returnedToNeutral = {}

var choosingController = false
var controllerChosenL = null
var controllerChosenR = null

func _ready():
	for i in $Inputs.get_children():
		i.Init(i.get_name())
		returnedToNeutral[i] = true
	inputCooldown = 0.2
	$GameTitle.set_text(Castagne.baseConfigData.Get("GameTitle"))
	$Version.set_text(Castagne.baseConfigData.Get("GameVersion"))
	$ChooseController.hide()

func _process(delta):
	if(inputCooldown > 0):
		inputCooldown -= delta
	else:
		HandleInput()
	MenuGraphics(delta)

func HandleInput():
	for iN in $Inputs.get_children():
		var i = iN.PollRaw()
		
		if(choosingController):
			if(i["Left"]):
				if(returnedToNeutral[iN]):
					if(controllerChosenR == iN.get_name()):
						controllerChosenR = null
					elif(controllerChosenL == null):
						controllerChosenL = iN.get_name()
					inputCooldown = 0.1
					returnedToNeutral[iN] = false
			elif(i["Right"]):
				if(returnedToNeutral[iN]):
					if(controllerChosenL == iN.get_name()):
						controllerChosenL = null
					elif(controllerChosenR == null):
						controllerChosenR = iN.get_name()
					inputCooldown = 0.1
					returnedToNeutral[iN] = false
			else:
				returnedToNeutral[iN] = true
			
			if((i["D"] or i["Pause"]) and (controllerChosenL == iN.get_name() or controllerChosenR == iN.get_name())):
				StartMatch()
				inputCooldown = 0.2
				return
			
			if(i["C"]):
				choosingController = false
				controllerChosenL = null
				controllerChosenR = null
				inputCooldown = 0.2
				return
		else:
			if(i["Down"]):
				if(returnedToNeutral[iN]):
					optionSelected += 1
					inputCooldown = 0.1
					returnedToNeutral[iN] = false
			elif(i["Up"]):
				if(returnedToNeutral[iN]):
					optionSelected -= 1
					inputCooldown = 0.1
					returnedToNeutral[iN] = false
			else:
				returnedToNeutral[iN] = true
			
			if(optionSelected < 0):
				optionSelected = 0
			if(optionSelected >= optionList.size()):
				optionSelected = optionList.size() -1
			
			if((i["D"] or i["Pause"])):
				inputCooldown = 0.2
				funcref(self, optionList[optionSelected]).call_func()
				return

func LocalBattle():
	Castagne.battleInitData["mode"] = "Battle"
	Castagne.battleInitData["p1-control-type"] = "dummy"
	Castagne.battleInitData["p2-control-type"] = "dummy"
	choosingController = true

func Training():
	Castagne.battleInitData["mode"] = "Training"
	Castagne.battleInitData["p1-control-type"] = "dummy"
	Castagne.battleInitData["p2-control-type"] = "dummy"
	choosingController = true

func Options():
	pass

func QuitGame():
	get_tree().quit()

func StartMatch():
	if(controllerChosenL != null):
		Castagne.battleInitData["p1-control-type"] = "local"
		Castagne.battleInitData["p1-control-param"] = controllerChosenL
	if(controllerChosenR != null):
		Castagne.battleInitData["p2-control-type"] = "local"
		Castagne.battleInitData["p2-control-param"] = controllerChosenR
	
	var ps = load(Castagne.baseConfigData.Get("CharacterSelect"))
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()

func MenuGraphics(_delta):
	var t = ""
	for i in range(optionText.size()):
		if(i == optionSelected):
			t += ">> "+optionText[i]+" << \n"
		else:
			t += optionText[i]+"\n"
	$Options.set_text(t)
	
	var tL = "Left Player :\n"
	var tC = "Choose your controller :\n"
	var tR = "Right Player :\n"
	
	for i in $Inputs.get_children():
		var n = i.get_name()
		if(controllerChosenL == n):
			tL += n + " >"
			tC += ".\n"
		elif(controllerChosenR == n):
			tR += "< " + n
			tC += ".\n"
		else:
			tC += "< " + n + " >\n"
	$ChooseController/Left.set_text(tL)
	$ChooseController/Center.set_text(tC)
	$ChooseController/Right.set_text(tR)
	
	if(choosingController):
		$Options.hide()
		$ChooseController.show()
	else:
		$Options.show()
		$ChooseController.hide()
