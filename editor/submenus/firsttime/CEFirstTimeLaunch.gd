# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"

func _on_ButtonTuto_pressed():
	$"../TutorialSelect".LaunchTutorial(0)


func _on_ButtonNoTuto_pressed():
	editor.configData.Set("LocalConfig-Editor-FirstTimeLaunchDone", true)
	editor.configData.SaveConfigFile()
	$"..".EnterMenu()
	#$"../TutorialSelect".Enter()
