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

func EnrichInput(raw, playerState, prev):
	if(raw.size() == 0):
		raw = GetEmptyRawInputData()
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




# ------------
# Network


var onlineLastInput = {}


func _get_local_input() -> Dictionary:
	#onlineLastInput = PollRaw()
	#onlineLastInput = GetEmptyRawInputData()
	#return onlineLastInput
	#return GetEmptyRawInputData()
	var rawInput = PollRaw()
	
	var inputNames = ["A", "B", "C", "D", "Left", "Right", "Up", "Down"]
	
	var packedInput = {}
	for i in range(inputNames.size()):
		packedInput[i] = rawInput[inputNames[i]]
	
	return rawInput
	return packedInput
func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	#var input = previous_input.duplicate()
	#onlinePredictedInput = input
	#return input
	return previous_input.duplicate()

func _network_process(packedInput: Dictionary) -> void:
	#var input = GetEmptyRawInputData()
	
	#if(packedInput.size() > 0):
	#	var inputNames = ["A", "B", "C", "D", "Left", "Right", "Up", "Down"]
	#	
	#	for i in range(inputNames.size()):
	#		input[inputNames[i]] = packedInput[i]
	
	#input["A"] = packedInput[0]
	#input["B"] = packedInput[1]
	#input["C"] = packedInput[2]
	
	#onlineLastInput = input
	onlineLastInput = packedInput
	#if(_onlineAllReady):
	#return
#	if(useOnline and _onlineStart):
#		gameState = FrameAdvance(gameState, instances["p1"]["Input"].onlineLastInput, instances["p2"]["Input"].onlineLastInput)
	#gameState = FrameAdvance(gameState, instances["p1"]["Input"].PollRaw(), instances["p2"]["Input"].PollRaw())

func _save_state() -> Dictionary:
	#return {"nostate":true}
	return onlineLastInput

func _load_state(state: Dictionary) -> void:
	onlineLastInput = state

#func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
#	var input = previous_input.duplicate()
#	return input
