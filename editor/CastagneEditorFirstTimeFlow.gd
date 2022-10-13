extends Control

# res://fighters/000-Common/BaseFighter.casp,res://fighters/001-Hero/001-Hero.casp,res://fighters/002-Thief/002-Thief.casp,res://fighters/003-Mage/003-Mage.casp,res://fighters/004-Soldier/004-Soldier.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/G001-Castagneur/G001-Castagneur.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,,res://fighters/G007-MysteryJohnson/G007-MysteryJohnson.casp

func _ready():
	$Restart.hide()



func _on_Button2D_pressed():
	Castagne.configData["Editor-FirstTimeFlowDone"] = true
	Castagne.configData["Modules"] = "default-fg2D"
	Castagne.configData["CharacterPaths"] = "res://castagne/example/fighter/sprites/StickmanAnimFrames.casp"
	Castagne.SaveConfigFile()
	$Restart.show()


func _on_Button25D_pressed():
	Castagne.configData["Editor-FirstTimeFlowDone"] = true
	Castagne.configData["Modules"] = "default-fg25D"
	Castagne.configData["CharacterPaths"] = "res://castagne/example/fighter/Castagneur.casp"
	Castagne.SaveConfigFile()
	$Restart.show()


func _on_ButtonManual_pressed():
	Castagne.configData["Editor-FirstTimeFlowDone"] = true
	Castagne.SaveConfigFile()
	$"..".EnterMenu()


func _on_ButtonRestart_pressed():
	get_tree().quit()
