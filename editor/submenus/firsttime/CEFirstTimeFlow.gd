# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"

var requireRestart = false

func _ready():
	$Restart.hide()

func StartSetup(submenuName, button):
	editor.EnterSubmenu(submenuName, funcref(self, "SetupCallback"))
	_buttonForCallback = button

var _buttonForCallback
func SetupCallback(index):
	editor.EnterSubmenu("FirstTimeFlow")
	if(index != null):
		var t = _buttonForCallback.get_text()
		if(!t.ends_with(" (Done!)")):
			_buttonForCallback.set_text(t + " (Done!)")
		requireRestart = true


func _on_ButtonRestart_pressed():
	get_tree().quit()


func _on_ButtonGenre_pressed():
	StartSetup("GenreSelector", $VBoxContainer/ButtonGenre)


func _on_ButtonDone_pressed():
	editor.configData.Set("Editor-FirstTimeFlowDone", true)
	editor.configData.SaveConfigFile()
	if(requireRestart):
		$Restart.show()
	else:
		hide()
		$"..".EnterMenu()


func _on_ButtonInput_pressed():
	StartSetup("InputConfig", $VBoxContainer/ButtonInput)
