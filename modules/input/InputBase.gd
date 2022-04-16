extends Node

func _ready():
	onlineLastInput = GetEmptyRawInputData()

func Init(_param):
	pass

func Poll():
	#var inputs = EnrichInput(PollRaw())
	#lastInput = inputs # TODO Seems like I forgot this function
	return PollRaw()

func PollRaw():
	return GetEmptyRawInputData()

# :TODO:Panthavma:20220126:Need to rework this
func EnrichInput(raw, richPrevious, state, pid):
	if(raw.size() == 0): # When missing input online
		raw = GetEmptyRawInputData()
	if(richPrevious == null or richPrevious.size() == 0): # First frame
		richPrevious = GetEmptyEnrichedInputData() # :TODO:Panthavma:20220203:Actually enrich it
	
	var buttonList = ["Pause", "Up", "Down", "Right", "Left"]
	var bufferedButtonList = ["A", "B", "C", "D", ]
	var PRESS_BUFFER = 3
	var id = raw.duplicate()
	var curFrame = state["FrameID"]
	
	id["A"] = id["A"] || id["M1"]
	id["B"] = id["B"] || id["M1"] || id["M2"]
	id["C"] = id["C"] || id["M2"]
	id["L"] = id["L"] || id["M3"]
	id["R"] = id["R"] || id["M3"]
	
	# :TODO:Panthavma:20220203:Make it a module function and move Facing related stuff to 2D physics
	var eState = state[state["Players"][pid]["MainEntity"]]
	
	var facing = 1
	var facingTrue = 1
	
	# Kinda hacky way to wait for init
	if(eState.has("Facing")):
		facing = eState["Facing"]
		facingTrue = eState["FacingTrue"]
	
	if(facing > 0):
		id["Forward"] = raw["Right"]
		id["Back"] = raw["Left"]
	else:
		id["Forward"] = raw["Left"]
		id["Back"] = raw["Right"]
	
	if(facingTrue > 0):
		id["TrueForward"] = raw["Right"]
		id["TrueBack"] = raw["Left"]
	else:
		id["TrueForward"] = raw["Left"]
		id["TrueBack"] = raw["Right"]
	
	id["Tech"] = id["A"] or id["B"] or id["C"]
	
	id["NeutralH"] = !id["Right"] and !id["Left"]
	id["NeutralV"] = !id["Up"] and !id["Down"]
	
	for b in bufferedButtonList:
		var bFrame = richPrevious[b+"Frame"]
		if(!id[b]):
			bFrame = -1
		elif(bFrame < 0):
			bFrame = curFrame
		
		id[b+"Frame"] = bFrame
		id[b+"Press"] = (bFrame >= 0) and (curFrame - bFrame < PRESS_BUFFER)
	for b in buttonList:
		id[b+"Press"] = id[b] and !richPrevious[b]
	
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

func GetEmptyEnrichedInputData():
	return {
		"AFrame":-1,"BFrame":-1,"CFrame":-1,"DFrame":-1,
		"UpFrame":-1,"DownFrame":-1,"RightFrame":-1,"LeftFrame":-1,
		"PauseFrame":-1,
		
		"A": false,"B": false,"C": false,"D":false,"L":false,"R":false,
		"Left":false,"Right":false,"Up":false,"Down":false,
		"M1":false, "M2":false, "M3":false, "Pause":false,
		"MenuConfirm":false, "MenuBack":false,
	}




# ------------
# Network


var onlineLastInput = {}


func _get_local_input() -> Dictionary:
	var rawInput = PollRaw()
	
	return rawInput
func _predict_remote_input(previous_input: Dictionary, _ticks_since_real_input: int) -> Dictionary:
	return previous_input.duplicate()

func _network_process(rawInput: Dictionary) -> void:
	onlineLastInput = rawInput


func _save_state() -> Dictionary:
	return onlineLastInput

func _load_state(state: Dictionary) -> void:
	onlineLastInput = state

