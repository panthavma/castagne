extends "res://castagne/engine/functions/CastagneFunctions.gd"

# Big ugly menu I stole from the Kronian Titans demo and changed a bit.
# Will be updated at a later date.

var dummyPID

var blockingMode = BLOCKING_MODE.None
var hpRegenMode = REGEN_MODE.Full


enum BLOCKING_MODE {
	None, BlockAll, BlockLow, BlockHigh
}

enum REGEN_MODE {
	No, Full
}

# State (crouch, jump, stand), req input
# Tech Options (not needed now)
# HP Regen OK
# Reset to middle (later ?)

func InitTool(engine, battleInitData):
	dummyPID = ("p2" if (battleInitData["p1-control-type"] == "local") else "p1")
	pauseSuboptions = {}
	for o in pauseOptions:
		pauseSuboptions[o] = 0
	pauseMenu = prefabMenu.instance()
	engine.add_child(pauseMenu)
	pauseMenu.hide()
	pauseMenuLabel = pauseMenu.get_node("Menu/Options")

func StateSetup(_pid, state, _engine):
	state["WhoHasWon"] = 0
	state["STARTFRAMES"] = -300
	
var framesSinceHitstun = 0
func PrePhysics(pid, _playerState, _inputs, _previousState, state):
	state[pid]["Fuel"] = 60*100
	state[pid]["Flags"] += ["StartRound"]
	if(pid != dummyPID):
		return
	
	var flags = state[pid]["Flags"]
	
	if(flags.has("Hitstun")):
		framesSinceHitstun = 0
	else:
		framesSinceHitstun += 1
	
	if(hpRegenMode == REGEN_MODE.Full and framesSinceHitstun >= 1):
		state[pid]["HP"] = int(state[pid]["HPMax"])
	
	if(blockingMode != BLOCKING_MODE.None):
		state[pid]["Flags"] += ["AutoBlocking"]
		if(blockingMode != BLOCKING_MODE.BlockHigh):
			state[pid]["Flags"] += ["AutoBlockingLow"]
		if(blockingMode != BLOCKING_MODE.BlockLow):
			state[pid]["Flags"] += ["AutoBlockingOverhead"]











var prefabMenu = preload("res://castagne/menus/training/TrainingMenu.tscn")
var pauseMenu
var pauseMenuLabel
var pausedPID = null
var pauseOptionID = 0
var pauseOptions = {"Resume":null, "Blocking":["No Blocking", "Block All", "Block Low", "Block High"], "HP Regen":["Yes", "No"], "Quit to title":null}
var pauseSuboptions = {}
var pauseInputCooldownFrames = 20

func FrameStart(_previousState, state, engine):
	if(pausedPID != null):
		PausedIdle(pausedPID, state, engine)
		return
	
	for pid in ["p1", "p2"]:
		var i = state[pid]["Input"]
		if(i["PausePress"]):
			Pause(pid)
			return

func Pause(pid):
	pausedPID = pid
	#pauseOptionID = 0
	pauseInputCooldownFrames = 6
	UpdateLabel()
	pauseMenu.show()

func Unpause():
	pausedPID = null
	pauseMenu.hide()

func PausedIdle(pid, state, engine):
	var input = state[pid]["Input"]
	state["SkipFrame"] = true
	
	if(pauseInputCooldownFrames > 0):
		pauseInputCooldownFrames -= 1
		return
	
	if(input["PausePress"]):
		Unpause()
		return
	
	if(input["DownPress"]):
		pauseOptionID += 1
		pauseInputCooldownFrames = 6
	
	if(input["UpPress"]):
		pauseOptionID -= 1
		pauseInputCooldownFrames = 6
	
	pauseOptionID = clamp(pauseOptionID, 0, pauseOptions.size()-1)
	
	var optionName = pauseOptions.keys()[pauseOptionID]
	var suboptions = pauseOptions[optionName]
	var suboptionID = pauseSuboptions[optionName]
	
	if(suboptions != null):
		if(input["RightPress"]):
			suboptionID += 1
			pauseInputCooldownFrames = 6
		if(input["LeftPress"]):
			suboptionID -= 1
			pauseInputCooldownFrames = 6
		
		suboptionID = clamp(suboptionID, 0, suboptions.size()-1)
		pauseSuboptions[optionName] = suboptionID
	
	UpdateLabel()
	
	ApplyOptions(dummyPID, state, engine)
	
	if(input["DPress"]):
		pauseInputCooldownFrames = 6
		ActivateOption(pauseOptionID, engine)

func UpdateLabel():
	var t = ""
	var i = 0
	for o in pauseOptions:
		var suboptions = pauseOptions[o]
		var suboptionID = pauseSuboptions[o]
		
		var l = o
		
		if(suboptions != null):
			var so = suboptions[suboptionID]
			
			if(suboptionID == 0):
				so = "[  " + so
			else:
				so = "[< " + so
			
			if(suboptionID == suboptions.size()-1):
				so = so + "  ]"
			else:
				so = so + " >]"
			
			l = l + " " + so
		
		if(i == pauseOptionID):
			l = "> "+l+" <"
		
		t += l + "\n"
		i += 1
	pauseMenuLabel.set_text(t)

func ActivateOption(id, engine):
	if(id == 0):
		Unpause()
	
	if(id == 3):
		LoadLevel(Castagne.data["MainMenu"])
		engine.queue_free()

func ApplyOptions(pid, state, _engine):
	var blockOptions = [BLOCKING_MODE.None, BLOCKING_MODE.BlockAll, BLOCKING_MODE.BlockLow, BLOCKING_MODE.BlockHigh]
	blockingMode = blockOptions[pauseSuboptions["Blocking"]]
	
	var regenOptions = [REGEN_MODE.Full, REGEN_MODE.No]
	hpRegenMode = regenOptions[pauseSuboptions["HP Regen"]]

func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)


# TODO put elsewhere
#	if(Input.is_key_pressed(KEY_Y) and !_fbfkpress):
#		_framebyframe = !_framebyframe
#	_fbfkpress = Input.is_key_pressed(KEY_Y)
#	# FrameByFrame
#	if(_framebyframe):
#		skipFrame = true
#		if(Input.is_key_pressed(KEY_U) and !_fbfkpressa):
#			skipFrame = false
#	_fbfkpressa = Input.is_key_pressed(KEY_U)
