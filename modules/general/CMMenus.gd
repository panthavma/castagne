# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Menus", null)
	RegisterBaseCaspFile("res://castagne/modules/general/Base-Training.casp", 9000)
	RegisterSpecblock("MenuData", "res://castagne/modules/general/CMMenusSBMenuData.gd")
	
	RegisterCategory("General")
	
	
	RegisterCategory("Main Menu")
	RegisterConfig("MenuScene-MainMenu", "res://castagne/helpers/menus/menus/default/CMenu-Main.tscn")
	RegisterConfig("MenuData-MainMenu", {
		"Options":[
			{
			#	"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Local Versus",
			#	"Action":"MMLocalBattle", "ActionParams":null,
			#},{
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Training",
				"Action":"MMTraining", "ActionParams":null,
			#},{
			#	"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Options",
			#	"Action":null, "ActionParams":null,
			},{
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Quit",
				"Action":"MCB_QuitGame", "ActionParams":null,
			},
		],
	})
	
	RegisterCategory("Character Select")
	RegisterConfig("MenuScene-CSS", "res://castagne/helpers/menus/menus/default/CMenu-CSS.tscn")
	RegisterConfig("MenuData-CSS", {
		"Options":[],
	})
	
	
	RegisterCategory("Options")
	
	
	
	RegisterCategory("Pause")
	RegisterConfig("MenuScene-Pause", "res://castagne/helpers/menus/menus/default/CMenu-Pause.tscn")
	RegisterConfig("MenuData-Pause", {
		"Options":[
			{
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Resume",
				"Action":"Resume", "ActionParams":null,
			},{
			#	"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Character Select",
			#	"Action":"ReturnToCSS", "ActionParams":null,
			#},{
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Return to Main Menu",
				"Action":"ReturnToMM", "ActionParams":null,
			},
		],
	})
	RegisterConfig("PauseMenu-HoldFrames", 15)
	RegisterConfig("PauseMenu-ResumeTimer", 8)
	RegisterVariablePlayer("PauseHeldFrames", 0)
	RegisterVariableGlobal("PausedGame", false)
	RegisterVariableGlobal("PausedGameResumeTimer", 0)
	
	
	
	
	RegisterCategory("Training")
	RegisterConfig("MenuScene-Training", "res://castagne/helpers/menus/menus/default/CMenu-Training.tscn")
	RegisterConfig("MenuData-Training", {
		"Options":[
			{
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Resume",
				"Action":"Resume", "ActionParams":null,
			},{
				"Type":Castagne.MENUS_ELEMENT_TYPES.LIST, "ScenePath":null, "DisplayName":"HP Regen",
				"Action":null, "ActionParams":null, "List": ["No Regen", "Regen"], "ListDefaultOption": 1,
				"TrainingAction":"TrainingFlagBroadcast", "TrainingParams":[null, ["TF_HPRegen"]],
			},{
				"Type":Castagne.MENUS_ELEMENT_TYPES.LIST, "ScenePath":null, "DisplayName":"Blocking",
				"Action":null, "ActionParams":null, "List": ["No Blocking", "All Block", "Block High", "Block Low"], "ListDefaultOption": 0,
				"TrainingAction":"TrainingFlagBroadcast", "TrainingParams":[null, ["Blocking", "Blocking-All"], ["Blocking", "Blocking-Overhead"], ["Blocking", "Blocking-Low"]],
			},{
			#	"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Character Select",
			#	"Action":"ReturnToCSS", "ActionParams":null,
			#},{
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Return to Main Menu",
				"Action":"ReturnToMM", "ActionParams":null,
			},
		],
	})
	
	RegisterVariableEntity("_TrainingMode", 0)
	RegisterVariableEntity("_TrainingMode_RegenHP", 0)
	RegisterVariableEntity("_TrainingMode_BlockingMode", 0)
	RegisterConfig("TrainingMenu-HoldFrames", 3)
	RegisterConfig("TrainingMenu-ResumeTimer", 8)
	
	
	RegisterCategory("Post Battle")
	
	
	

func BattleInitLate(stateHandle, battleInitData):
	var uiRoot = stateHandle.IDGlobalGet("UIRoot")
	if(uiRoot == null):
		return
	
	var pauseMenuParams = {
		"BattleInitData": battleInitData,
		"Engine": stateHandle.Engine(),
	}
	
	var menuType = "Pause"
	if(battleInitData["mode"] == Castagne.GAMEMODES.MODE_TRAINING or battleInitData["mode"] == Castagne.GAMEMODES.MODE_EDITOR):
		menuType = "Training"
	
	var pauseMenu = Castagne.Menus.InstanceMenu(menuType, pauseMenuParams, stateHandle.ConfigData())
	stateHandle.IDGlobalSet("Menu-Pause", pauseMenu)
	stateHandle.IDGlobalSet("Pause-HoldFrames", stateHandle.ConfigData().Get(menuType+"Menu-HoldFrames"))
	stateHandle.IDGlobalSet("Pause-ResumeTimer", stateHandle.ConfigData().Get(menuType+"Menu-ResumeTimer"))
	uiRoot.add_child(pauseMenu)

func FramePreStart(stateHandle):
	var menu = stateHandle.IDGlobalGet("Menu-Pause")
	if(menu != null):
		menu.SyncWithEngine(stateHandle, self)
	
	if(stateHandle.GlobalGet("PausedGame")):
		stateHandle.GlobalSet("_SkipFrame", true)
	elif(stateHandle.GlobalGet("PausedGameResumeTimer") > 0):
		stateHandle.GlobalAdd("PausedGameResumeTimer", -1)
		stateHandle.GlobalSet("_SkipFrame", true)

func FrameEnd(stateHandle):
	var globalInputsProcessed = stateHandle.GlobalGet("_InputsProcessed")
	
	for pid in range(stateHandle.GlobalGet("_NbPlayers")):
		stateHandle.PointToPlayer(pid)
		var inputs = globalInputsProcessed[pid]
		if(inputs["Pause"]):
			stateHandle.PlayerAdd("PauseHeldFrames", 1)
		else:
			stateHandle.PlayerSet("PauseHeldFrames", 0)
		
		if(stateHandle.PlayerGet("PauseHeldFrames") >= stateHandle.IDGlobalGet("Pause-HoldFrames")):
			stateHandle.PlayerSet("PauseHeldFrames", 0)
			OpenPauseMenu(stateHandle, null)
			return

func OpenPauseMenu(stateHandle, device):
	stateHandle.GlobalSet("PausedGame", true)
	var menu = stateHandle.IDGlobalGet("Menu-Pause")
	if(menu == null):
		return
	menu.OpenMenu(device)

func ClosePauseMenu(stateHandle):
	stateHandle.GlobalSet("PausedGame", false)
	stateHandle.GlobalSet("PausedGameResumeTimer", stateHandle.IDGlobalGet("Pause-ResumeTimer"))
	var menu = stateHandle.IDGlobalGet("Menu-Pause")
	if(menu == null):
		return
	menu.CloseMenu()
