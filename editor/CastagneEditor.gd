extends Control


func _ready():
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
