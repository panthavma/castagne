extends Node

var lastInput = {}

func Init(_param):
	pass

func Poll():
	#var inputs = EnrichInput(PollRaw())
	#lastInput = inputs # TODO Seems like I forgot this function
	return PollRaw()

func PollRaw():
	return GetEmptyRawInputData()

func EnrichInput(raw, playerState, prev):
	var id = raw.duplicate()
	if(prev == null):
		prev = GetEmptyRawInputData()
	
	id["A"] = id["A"] || id["M1"]
	id["B"] = id["B"] || id["M1"] || id["M2"]
	id["C"] = id["C"] || id["M2"]
	id["L"] = id["L"] || id["M3"]
	id["R"] = id["R"] || id["M3"]
	
	
	if(playerState["Facing"] > 0):
		id["Forward"] = raw["Right"]
		id["Back"] = raw["Left"]
	else:
		id["Forward"] = raw["Left"]
		id["Back"] = raw["Right"]
	
	if(playerState["FacingTrue"] > 0):
		id["TrueForward"] = raw["Right"]
		id["TrueBack"] = raw["Left"]
	else:
		id["TrueForward"] = raw["Left"]
		id["TrueBack"] = raw["Right"]
	
	
	id["Tech"] = id["A"] or id["B"] or id["C"]
	
	id["NeutralH"] = !id["Right"] and !id["Left"]
	id["NeutralV"] = !id["Up"] and !id["Down"]
	
	var buttonList = ["A", "B", "C", "D", "Pause", "Up", "Down", "Right", "Left"]
	for b in buttonList:
		id[b+"Press"] = id[b] and !prev[b]
	
	id["Throw"] = id["APress"] and id["BPress"]
	
	id["MenuConfirm"] = id["DPress"] or id["PausePress"]
	id["MenuBack"] = id["CPress"]
	
	return id

func GetEmptyRawInputData():
	return {
		"A": false,"B": false,"C": false,"D":false,"L":false,"R":false,
		"Left":false,"Right":false,"Up":false,"Down":false,
		"M1":false, "M2":false, "M3":false, "Pause":false,
		"MenuConfirm":false, "MenuBack":false,
	}
