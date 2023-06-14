extends Node

var system
var editor
var charEditor

func Setup():
	charEditor = editor.get_node("CharacterEdit")
	return system.TutorialSetupBasic("res://castagne/editor/tutorials/assets/ConfigSimple.json")

func TutorialScript():
	
	system.ShowDialogue("Overwrite TutorialScript(), end with system.EndTutorial().")
	
	yield()
	
	system.EndTutorial()
