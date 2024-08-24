# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Menus", null)
	
	
	RegisterCategory("Main Menu")
	
	RegisterCategory("Character Select")
	
	RegisterCategory("Options")
	
	RegisterCategory("Training")
	
	RegisterCategory("Post Battle")
	
	RegisterCategory("Pause")

func ActionPhaseStartEntity(stateHandle):
	var i = stateHandle.EntityGet("_Inputs")
	if(i["PausePress"]):
		Castagne.Menus.TMP_MW_ReturnToCSS = true


func FrameEnd(stateHandle):
	if(Castagne.Menus.TMP_MW_ReturnToCSS):
		Castagne.Menus._currentMenu = stateHandle.Engine()
		Castagne.Menus.MCB_CharacterSelect([])
