# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

# Temporary module until menus get refactored

var ui
var isTrainingMode = false
func ModuleSetup():
	RegisterModule("Fighting UI (temporary module)", null)
	
	RegisterConfig("ShowFightingUI_Temp", true)
	RegisterConfig("FightingUIPath_Temp", "res://castagne/menus/battleui/DefaultUI.tscn")
	
func BattleInit(stateHandle, battleInitData):
	if(!stateHandle.ConfigData().Get("ShowFightingUI_Temp")):
		return
	ui = load(stateHandle.ConfigData().Get("FightingUIPath_Temp")).instance()
	stateHandle.Engine().add_child(ui)
	ui.InitTool(battleInitData)

func UpdateGraphics(stateHandle):
	if(!stateHandle.ConfigData().Get("ShowFightingUI_Temp")):
		return
	ui.UpdateGraphics(stateHandle)
