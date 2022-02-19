extends "../../CastagneModule.gd"

# :TODO:Panthavma:20220124:Fuse with training ?

# Big ugly menu I stole from the Kronian Titans demo and changed a bit.
# Will be updated at a later date.
var prefabMenu = preload("res://castagne/menus/pause/PauseMenu.tscn")
var pauseMenu
var pauseMenuLabel

var STARTFRAMES = 120

var pausedPID = null
var pauseOptionID = 0
var pauseOptions = ["Resume", "Quit to title"]
var pauseInputCooldownFrames = 20

var timeSinceDead = 0

var winner = 0
var nbRoundsToWin = 2

func OLDInitTool(engine, _battleInitData):
	pauseMenu = prefabMenu.instance()
	engine.add_child(pauseMenu)
	pauseMenu.hide()
	pauseMenuLabel = pauseMenu.get_node("Menu/Options")


func OLDStateSetup(_pid, state, _engine):
	state["WhoHasWon"] = 0
	state["STARTFRAMES"] = STARTFRAMES

func OLDFrameStart(_previousState, state, engine):
	if(pausedPID != null):
		PausedIdle(pausedPID, state, engine)
		return
	
	for pid in ["p1", "p2"]:
		var i = state[pid]["Input"]
		if(i["PausePress"]):
			Pause(pid)
			return
		
	if(STARTFRAMES > -300):
		#state["SkipFrame"] = true
		STARTFRAMES -= 1
		state["STARTFRAMES"] = STARTFRAMES
	
	var p1Dead = state["p1"]["Flags"].has("Dead")
	var p2Dead = state["p2"]["Flags"].has("Dead")
	var fuelEmpty = state["p1"]["Flags"].has("FuelEmpty") or state["p2"]["Flags"].has("FuelEmpty")
	
	if(p1Dead or p2Dead):
		timeSinceDead += 1
		
		if(timeSinceDead == 20):
			winner = 0
			if(p1Dead):
				winner += 1
			if(p2Dead):
				winner -= 1
			if(winner == 0):
				# TODO Should be over HP Max
				winner = sign(state["p2"]["HP"] - state["p1"]["HP"])
			state["WhoHasWon"] = winner + 2
		
		if(timeSinceDead > 15 and timeSinceDead % 2):
			state["SkipFrame"] = true
		
		if(timeSinceDead == 150):
			# TODO Should refactor the winning code I think
			if(winner == 0): # Tie
				if(Castagne.battleInitData["p1Points"] < nbRoundsToWin-1):
					Castagne.battleInitData["p1Points"] += 1
				if(Castagne.battleInitData["p2Points"] < nbRoundsToWin-1):
					Castagne.battleInitData["p2Points"] += 1
			elif(winner == -1): # P1 Win
				Castagne.battleInitData["p1Points"] += 1
			else: # P2 Win
				Castagne.battleInitData["p2Points"] += 1
			
			var fightFinished = Castagne.battleInitData["p1Points"] >= nbRoundsToWin or Castagne.battleInitData["p2Points"] >= nbRoundsToWin
			
			if(fightFinished):
				LoadLevel(Castagne.data["PostBattle"])
			else:
				LoadLevel("res://castagne/engine/CastagneEngine.tscn")
			state["SkipFrame"] = true
			engine.queue_free()

func OLDPrePhysics(pid, _playerState, _inputs, _previousState, state):
	if(STARTFRAMES <= 0):
		state[pid]["Flags"] += ["StartRound"]

func Pause(pid):
	pausedPID = pid
	pauseOptionID = 0
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
	
	UpdateLabel()
	
	if(input["DPress"]):
		pauseInputCooldownFrames = 6
		ActivateOption(pauseOptionID, engine)

func UpdateLabel():
	var t = ""
	for i in range(pauseOptions.size()):
		var o = pauseOptions[i]
		
		if(i == pauseOptionID):
			t += "> "+o+" <\n"
		else:
			t += o + "\n"
	pauseMenuLabel.set_text(t)

func ActivateOption(id, engine):
	if(id == 0):
		Unpause()
	
	if(id == 1):
		LoadLevel(Castagne.data["MainMenu"])
		engine.queue_free()

func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)
