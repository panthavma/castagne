# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"

var tutorials = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	AddTutorial("temp/TutorialD1", "D1. Welcome to Castagne!", null,
	"""Welcome to Castagne! In this short tour of the engine, we will get a feel for the interface of Castagne and what is available in it!""")
	
	
	AddTutorial("temp/TutorialD2", "D2. Creating a character", null,
		"""Let's see how to create a new character, and some basics of the engine along the way!""")
	AddTutorial("temp/TutorialD3", "D3. Creating an attack!", null,
		"""Now it's serious! Let's add some attacks to our character!""")
	AddTutorialTemp("temp/TutorialD4", "D4. Managing movement", null,
		"Let's learn about specblocks and how to customize our character!")
	AddTutorialTemp("temp/TutorialD5", "D5. System Mechanics and Skeletons", null,
		"Let's see how to put the common parts of characters in a single file!")
	AddTutorialTemp("temp/TutorialD6", "D6. Importing graphical assets", null,
		"This text-only tutorial will help you make heads of how to add assets!")
	#AddTutorialTemp("temp/TutorialD7", "D7. Input Setup", null, "Here, we will look at how to set up input and bindings.")
	
	var tutorialList = $TutorialsList
	tutorialList.clear()
	for t in tutorials:
		tutorialList.add_item(t["Name"], t["ListIcon"])
	tutorialList.select(0)
	OnSelect(0)
func AddTutorialTemp(_internalName, _displayName, _imagePath, _description):
	pass
func AddTutorial(internalName, displayName, imagePath, description):
	var scriptPath = "res://castagne/editor/tutorials/"+internalName+".gd"
	
	var t = {
		"Name":displayName,
		"ScriptPath":scriptPath,
		"Description":description,
	}
	
	t["Description"] += "\n\n[Dev Tutorial: Temporary, will be replaced in Castagne v0.59]"
	
	if(imagePath == null):
		t["Image"] = Castagne.Loader.Load("res://castagne/assets/icons/CastagneLogo.png")
	else:
		t["Image"] = Castagne.Loader.Load(imagePath)
	
	var configKeyName = "LocalConfig-TutorialDone-"+str(internalName)
	var isTutorialDone = editor.configData.Get(configKeyName, false)
	if(isTutorialDone):
		t["ListIcon"] = Castagne.Loader.Load("res://castagne/assets/editor/misc/tutorialDone.png")
	else:
		t["ListIcon"] = Castagne.Loader.Load("res://castagne/assets/editor/misc/tutorialTodo.png")
	
	tutorials += [t]

func OnSelect(idx):
	var t = tutorials[idx]
	
	$DescPanel/Description.set_text(t["Description"])
	$DescPanel/Picture.set_texture(t["Image"])


func LaunchTutorial(idx):
	var t = tutorials[idx]
	
	$"../TutorialSystem".SetupTutorial(t["ScriptPath"])
	
	editor.queue_free()

func _on_OK_pressed():
	var index = $TutorialsList.get_selected_items()[0]
	LaunchTutorial(index)


func _on_Cancel_pressed():
	callbackFunction.call_func(null)


func _on_GenreList_item_selected(index):
	OnSelect(index)
