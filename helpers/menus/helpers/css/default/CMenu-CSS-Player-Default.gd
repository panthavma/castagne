# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CMenu-CSS-Player.gd"

func Setup():
	pass

func UpdateDisplay():
	var t = "---\n"
	t += "\nDevice: "+str(device)
	var charData = selectedCharacter["TransformedData"]["MenuData"]["Defines"]
	#var charName = (selectedCharacter["Character"]["Name"] if selectedCharacter["Character"].has("Name") else selectedCharacter["Character"]["Filepath"])
	var charName = charData["MENU_Name"]
	t += "\n"+charName
	if(menuState != MENUSTATE.CHARACTER):
		var palette = "Palette: "+str(selectedPalette+1)
		if(menuState == MENUSTATE.PALETTE):
			palette = "< "+palette+" >"
		t += "\n"+palette
	if(css.stageSelectPlayer == self):
		var stage = "Stage: "+str(css.stageSelected+1)
		if(menuState == MENUSTATE.STAGE):
			stage = "< "+stage+" >"
		t += "\n"+stage
	
	$Label.set_text(t)
