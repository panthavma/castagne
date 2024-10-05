# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CMenu-CSS-Player.gd"

func Setup():
	pass

func OnCharacterChange():
	var t = "---\n"
	var charName = (selectedCharacter["Character"]["Name"] if selectedCharacter["Character"].has("Name") else selectedCharacter["Character"]["Filepath"])
	t += charName
	t += "\nDevice: "+str(device)
	
	$Label.set_text(t)
