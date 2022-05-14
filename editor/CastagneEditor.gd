extends Control

# :TODO:Panthavma:20220408:Add a way to have automatic tests to see if combos still work (or work with different positions)

var documentation

func _ready():
	EnterMenu()

func EnterMenu():
	$Background.show()
	$MainMenu.show()
	$Config.hide()
	$CharacterEdit.hide()
	$Documentation.hide()
	
	$Documentation.SetupDocumentation()
	
	# Write title
	var title = "--- Castagne Editor ---\n"
	title += Castagne.configData["CastagneVersion"] + "\n"
	title += Castagne.configData["GameTitle"]+"\n"
	title += Castagne.configData["GameVersion"]
	$MainMenu/Title.set_text(title)
	
	# Write character list
	var list = $MainMenu/Characters
	list.clear()
	for c in Castagne.SplitStringToArray(Castagne.configData["CharacterPaths"]):
		list.add_item(c)
	var charToSelect = Castagne.configData["Starter-P1"]#Castagne.configData["Editor-SelectedCharacter"]
	if(charToSelect >= Castagne.SplitStringToArray(Castagne.configData["CharacterPaths"]).size()):
		charToSelect = 0
	list.select(charToSelect)


func OpenDocumentation(page = null):
	$Documentation.show()
	$Documentation.OpenDocumentation(page)















func _tools_ready():
	$TextEdit.set_text(PrintDocumentation())
	
	return
	
	
	print(Castagne.data["CharacterPaths"])
	var metadata = Castagne.Parser.GetCharacterMetadata(Castagne.data["CharacterPaths"][0])
	print("---------------------------")
	print(metadata)
	
	print("--------------------------")
	var cdata = Castagne.Parser.CreateFullCharacter(Castagne.data["CharacterPaths"][0])
	
	#print("--------------------------")
	#var stateName = "HitstunAir"
	#print(stateName)
	#var state = cdata["States"][stateName]
	#PrintStateActions(state["Actions"])
	
	
	print("--------------------------")
	PrintCharacterOverview(cdata)
	
	get_tree().quit()

func PrintStateActions(actions, indentLevel = 1):
	for action in actions:
		var indent = ""
		for i in range(indentLevel):
			indent += "    "
		var t = indent + action["FuncName"]
		print(t)
		if(action["FuncName"].begins_with("Instruction ")):
			PrintStateActions(action["True"], indentLevel+1)
			print(indent+"else")
			PrintStateActions(action["False"], indentLevel+1)

func PrintCharacterOverview(cdata):
	var t = "--- [Character Overview] "+cdata["Character"]["Name"]+" ---"
	
	t += "\n>>> [METADATA] : "+str(cdata["Character"].size())
	#t += "\n"+str(cdata["Character"].keys())
	t += "\n>>> [CONSTANTS] : "+str(cdata["Constants"].size())
	#t += "\n"+str(cdata["Constants"].keys())
	t += "\n>>> [VARIABLES] : "+str(cdata["Variables"].size())
	#t += "\n"+str(cdata["Variables"].keys())
	t += "\n>>> [STATES] : "+str(cdata["States"].size())
	t += "\n"+str(cdata["States"].keys())
	
	print(t)

func PrintDocumentation():
	var t = "----\n"
	
	for m in Castagne.modules:
		t += "# " + m.moduleName + "\n"
		t += m.moduleDocumentation["Description"] + "\n\n"
		for categoryName in m.moduleDocumentationCategories:
			var c = m.moduleDocumentationCategories[categoryName]
			var vars = c["Variables"]
			var funcs = c["Functions"]
			var flags = c["Flags"]
			if(vars.empty() and funcs.empty() and flags.empty()):
				continue
			t += "## " + categoryName + "\n"
			t += c["Description"] + "\n"
			
			
			if(!funcs.empty()):
				t += "\n### Functions\n"
				for f in funcs:
					t += "--- " + f["Name"] + ":  ("+str(f["Documentation"]["Arguments"])+")\n"
					t += f["Documentation"]["Description"] + "\n\n"
			
			if(!vars.empty()):
				t += "\n### Variables\n"
				for v in vars:
					t += v["Name"] + ": " + v["Description"] + "\n"
			if(!flags.empty()):
				t += "\n### Flags\n"
				for f in flags:
					t += f["Name"] + ": " + f["Description"] + "\n"
			
			t += "\n"
		t += "----\n"
	
	return t


func _on_Config_pressed(advanced=false):
	$MainMenu.hide()
	$Config.EnterMenu(advanced)


func _on_CharacterEdit_pressed():
	$MainMenu.hide()
	$CharacterEdit.EnterMenu($MainMenu/Characters.get_selected_items()[0])


func _on_CharacterEditNew_pressed():
	var fileEdit = $MainMenu/NewCharDialog
	fileEdit.popup_centered()


func _on_NewCharDialog_file_selected(path):
	Castagne.configData["CharacterPaths"] += ","+path
	var f = File.new()
	
	if(!f.file_exists(path)):
		f.open(path, File.WRITE)
		f.store_string(":Character:\n\n:Variables:\n\n")
		f.close()
	
	Castagne.SaveConfigFile()
	$MainMenu.hide()
	$CharacterEdit.EnterMenu($MainMenu/Characters.get_item_count())


func _on_MainMenuDocumentation_pressed():
	OpenDocumentation($Documentation.defaultPage)



func _on_Characters_item_activated(_index):
	_on_CharacterEdit_pressed()
