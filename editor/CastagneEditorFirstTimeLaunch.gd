extends "CastagneEditorSubmenu.gd"

# res://fighters/000-Common/BaseFighter.casp,res://fighters/001-Hero/001-Hero.casp,res://fighters/002-Thief/002-Thief.casp,res://fighters/003-Mage/003-Mage.casp,res://fighters/004-Soldier/004-Soldier.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/G001-Castagneur/G001-Castagneur.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,,res://fighters/G007-MysteryJohnson/G007-MysteryJohnson.casp


func _on_ButtonTuto_pressed():
	$"../TutorialSelect".LaunchTutorial(0)


func _on_ButtonNoTuto_pressed():
	editor.configData.Set("LocalConfig-Editor-FirstTimeLaunchDone", true)
	editor.configData.SaveConfigFile()
	$"..".EnterMenu()
