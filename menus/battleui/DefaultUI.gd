# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "res://castagne/modules/CastagneModule.gd"

# Big ugly menu I stole from the Kronian Titans demo and changed a bit.
# Will be updated at a later date.

var hpRedRatio = {"p1":1.0, "p2":1.0}
var hpRedTarget = {"p1":10000, "p2":10000}
var hpRedTargetDelay = {"p1":10000, "p2":10000}

var isTrainingMode = false

func InitTool(battleInitData):
	#isTrainingMode = battleInitData["mode"] == "Training"
	isTrainingMode = true
	
	get_node("L/Rounds/1/Active").hide()
	#get_node("L/Rounds/1/Active").set_visible(battleInitData["p1Points"] > 0)
	get_node("L/Rounds/2/Active").hide()
	get_node("R/Rounds/1/Active").hide()
	#get_node("R/Rounds/1/Active").set_visible(battleInitData["p2Points"] > 0)
	get_node("R/Rounds/2/Active").hide()



func UpdateGraphics(stateHandle):
	stateHandle.PointToPlayerMainEntity(0)
	UpdatePlayer(stateHandle, "p1", "L")
	stateHandle.PointToPlayerMainEntity(1)
	UpdatePlayer(stateHandle, "p2", "R")
	
	var timerRoot = get_node("C/Timer")
	if(isTrainingMode):
		timerRoot.get_node("Label").set_text("Timer\nInfinite")
	else:
		var currentTimer = stateHandle.GlobalGet("Timer")/60
		currentTimer = int(clamp(currentTimer, 0, 99))
		timerRoot.get_node("Label").set_text("Timer\n"+str(currentTimer))
	
	var middleText = get_node("C/Text")
	middleText.hide()
	
	#var whw = state["WhoHasWon"]
	var whw = 0
	
	if(whw != 0):
		if(whw == 2):
			middleText.get_node("Label").set_text("Draw")
		else:
			middleText.get_node("Label").set_text("Down!")
		
		middleText.show()
	
	if(stateHandle.GlobalHas("STARTFRAMES")):
		if(stateHandle.GlobalGet("STARTFRAMES") > 0):
			middleText.get_node("Label").set_text("Ready?")
			middleText.show()
		elif(stateHandle.GlobalGet("STARTFRAMES") > -50):
			middleText.get_node("Label").set_text("Fight!")
			middleText.show()

func UpdatePlayer(stateHandle, playerID, uiSide):
	if(!stateHandle.EntityHas("HPMax")):
		return
	var hpMax = stateHandle.EntityGet("HPMax")
	var hp = stateHandle.EntityGet("HP")
	var hpRatio = float(hp)/float(hpMax)
	hpRatio = clamp(hpRatio, 0.0, 1.0)
	
	if(!stateHandle.EntityHasFlag("Hitstun")):
		hpRedTarget[playerID] = hpRedTargetDelay[playerID]
		hpRedTargetDelay[playerID] = hp
	
	var hpRedRatioTarget = float(hpRedTarget[playerID])/float(hpMax)
	hpRedRatioTarget = clamp(hpRedRatioTarget, 0.0, 1.0)
	hpRedRatio[playerID] = move_toward(hpRedRatio[playerID], hpRedRatioTarget, 0.006)
	
	get_node(uiSide+"/HPBar/Handle").set_scale(Vector2(hpRatio, 1.0))
	get_node(uiSide+"/HPBar/HandleRed").set_scale(Vector2(hpRedRatio[playerID], 1.0))
