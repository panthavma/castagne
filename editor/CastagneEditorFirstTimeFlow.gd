extends "CastagneEditorSubmenu.gd"

# res://fighters/000-Common/BaseFighter.casp,res://fighters/001-Hero/001-Hero.casp,res://fighters/002-Thief/002-Thief.casp,res://fighters/003-Mage/003-Mage.casp,res://fighters/004-Soldier/004-Soldier.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/G001-Castagneur/G001-Castagneur.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,res://fighters/000-Common/BaseFighter.casp,,res://fighters/G007-MysteryJohnson/G007-MysteryJohnson.casp


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
