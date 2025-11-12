# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CMenu-PostBattle-Player.gd"


func UpdateDisplay():
	var t = "You win!" if _isWinner else "You lose..."
	t += "\n\n"
	
	if(wantsRematch):
		t += "[Rematch]"
	elif(chosenOption == 0):
		t += "> [Rematch] <"
	else:
		t += "Rematch"
	
	t += "\n"
	
	t += "> [Return to Menu] <" if chosenOption == 1 else "Return to Menu"
	
	$Text.set_text(t)
