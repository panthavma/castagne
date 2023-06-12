extends "CastagneEditorSubmenu.gd"

var tutorials = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	AddTutorial("TutorialD1", "D1. Welcome to Castagne!", null,
	"""Welcome to Castagne! In this short tour of the engine, we will get a feel for the interface of Castagne and what is available in it!""")
	
	AddTutorialTemp("", "D3. Input Setup", null, "Here, we will look at how to set up input and bindings.")
	
	AddTutorial("TutorialD2", "D2. Creating a character", null,
		"""Let's see how to create a new character, and some basics of the engine along the way!""")
	AddTutorial("TutorialD3", "D3. Creating an attack!", null,
		"""Now it's serious! Let's add some attacks to our character!""")
	AddTutorialTemp("", "D4. Importing graphical assets", null, "")
	AddTutorialTemp("", "D5. Genre Features", null, "")
	AddTutorialTemp("", "D6. Advanced Attacks", null, "")
	
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
		t["ListIcon"] = Castagne.Loader.Load("res://castagne/assets/icons/editor/misc/tutorialDone.png")
	else:
		t["ListIcon"] = Castagne.Loader.Load("res://castagne/assets/icons/editor/misc/tutorialTodo.png")
	
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
