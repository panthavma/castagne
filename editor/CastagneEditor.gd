extends Control

# :TODO:Panthavma:20220408:Add a way to have automatic tests to see if combos still work (or work with different positions)


func _ready():
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
				t += "### Functions\n"
				for f in funcs:
					t += f["Name"] + ": " + f["Documentation"]["Description"] + " ("+str(f["Documentation"]["Arguments"])+")\n"
			
			if(!vars.empty()):
				t += "### Variables\n"
				for v in vars:
					t += v["Name"] + ": " + v["Description"] + "\n"
			if(!flags.empty()):
				t += "### Flags\n"
				for f in flags:
					t += f["Name"] + ": " + f["Description"] + "\n"
			
			t += "\n"
		t += "----\n"
	
	return t
