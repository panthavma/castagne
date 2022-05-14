extends "../CastagneModule.gd"

var prefabMenu = preload("res://castagne/menus/pause/PauseMenu.tscn")
var prefabHitboxViewer = preload("res://castagne/modules/gamemodes/assets/HurtboxViewer.tscn")

func ModuleSetup():
	RegisterModule("Fighting Game Flow")
	
	RegisterCategory("Game Mode: Fighting Game")
	RegisterVariableGlobal("WhoHasWon", 0)
	RegisterVariableGlobal("TimeSinceDead", 0)
	RegisterVariableEntity("TimeSinceHitstun", 0)
	
	RegisterVariableEntity("HP", 10000)
	# :TODO:Panthavma:20220131:Set HP from HPMax once the game starts
	RegisterVariableEntity("HPMax", 10000)
	RegisterVariableEntity("Meter", 0)
	
	RegisterVariableGlobal("Timer", 6000)
	RegisterVariableGlobal("CameraHor", 0)
	RegisterVariableGlobal("CameraVer", 0)
	RegisterVariableGlobal("PlayerOnTheLeft", 0)
	
	RegisterBattleInitData("p1",0)
	RegisterBattleInitData("p1-control-type","local")
	RegisterBattleInitData("p1-control-param","k1")
	RegisterBattleInitData("p1-palette",0)
	RegisterBattleInitData("p1-onlinepeer",1)
	RegisterBattleInitData("p2-onlinepeer",1)
	RegisterBattleInitData("p2",0)
	RegisterBattleInitData("p2-control-type","local")
	RegisterBattleInitData("p2-control-param","c1")
	RegisterBattleInitData("p2-palette",1)
	RegisterBattleInitData("p1Points",0)
	RegisterBattleInitData("p2Points",0)
	
	RegisterConfig("HurtboxViewer-Hurtbox", "res://castagne/modules/gamemodes/assets/HurtboxViewer-Hurtbox.tscn")
	RegisterConfig("HurtboxViewer-Hitbox", "res://castagne/modules/gamemodes/assets/HurtboxViewer-Hitbox.tscn")
	RegisterConfig("HurtboxViewer-Colbox", "res://castagne/modules/gamemodes/assets/HurtboxViewer-Colbox.tscn")
	

func BattleInit(state, data, battleInitData):
	
	# Create the entities
	for player in data["InstancedData"]["Players"]:
		# Parse fighter, create entity, then create model. Return error if problem
		var characterPath = battleInitData[player["Name"]]
		if(!str(characterPath).ends_with(".casp")):
			characterPath = Castagne.SplitStringToArray(Castagne.configData["CharacterPaths"])[characterPath]
		var playerID = player["PID"]
		
		var fighterID = engine.ParseFighterScript(characterPath)
		if(fighterID < 0):
			ModuleError("CMFightingGame: Fighter parsing failed for " + str(characterPath) + " !")
			return
		
		engine.AddNewEntity(state, playerID, fighterID, "Init")
	
	
	
	trainingMode = (battleInitData["mode"] == "Training")
	if(trainingMode):
		pauseMenu = prefabMenu.instance()
		pauseOptions = {"Resume":null, "Blocking":["No Blocking", "Block All", "Block Low", "Block High"], "HP Regen":["Yes", "No"], "Quit to title":null}
		dummyPID = (1 if (battleInitData["p1-control-type"] == "local") else 0)
	else:
		pauseMenu = prefabMenu.instance()
		pauseOptions = {"Resume":null, "Quit to title":null}
	
	pauseSuboptions = {}
	for o in pauseOptions:
		pauseSuboptions[o] = 0
	
	engine.add_child(pauseMenu)
	pausedPID = null
	pauseMenu.hide()
	var canvasRID = pauseMenu.get_canvas_item()
	VisualServer.canvas_item_set_draw_index(canvasRID, 100)
	VisualServer.canvas_item_set_z_index(canvasRID, 100)
	pauseMenuLabel = pauseMenu.get_node("Menu/Options")
	
	if(trainingMode):
		hitboxViewer = prefabHitboxViewer.instance()
		engine.add_child(hitboxViewer)

var _tmpSkipFirstFrame = true
func FrameStart(state, data):
	# Pause Management
	if(pausedPID != null):
		state["SkipFrame"] = true
		PausedIdle(pausedPID, state, data)
		return
		
	var slowmo = false
	var slowmoFast = false
	var slowmoFactor = 8
	if(slowmo and state["TrueFrameID"] % slowmoFactor != 0):
		state["SkipFrame"] = true
	
	var mainEIDs = []
	for player in state["Players"]:
		var i = player["Inputs"]
		mainEIDs.append(player["MainEntity"])
		if(i["PausePress"]):
			Pause(player["PID"])
			return
	
	
	# :TODO:Panthavma:20220207:Remove this hack
	if(_tmpSkipFirstFrame):
		_tmpSkipFirstFrame = false
		return
	
	
	# Game Management
	#if(STARTFRAMES > -300):
		#state["SkipFrame"] = true
	#	STARTFRAMES -= 1
	#	state["STARTFRAMES"] = STARTFRAMES
	
	# :TODO:Panthavma:20220207:Manage several rounds from one instance, both local and online
	
	# :TODO:Panthavma:20220207:Put this in a separate function
	var p1Dead = HasFlag(state[mainEIDs[0]], "Dead")
	var p2Dead = HasFlag(state[mainEIDs[1]], "Dead")
	# :TODO:Panthavma:20220207:This is Kronian Titans specific, remove it cleanly
	#var fuelEmpty = HasFlag(state[mainEIDs[0]], "FuelEmpty") or HasFlag(state[mainEIDs[1]], "FuelEmpty")
	
	if(p1Dead or p2Dead):
		state["TimeSinceDead"] += 1
		var timeSinceDead = state["TimeSinceDead"]
		
		if(timeSinceDead == 20):
			winner = 0
			if(p1Dead):
				winner += 1
			if(p2Dead):
				winner -= 1
			if(winner == 0):
				# :TODO:Panthavma:20220207:Should be ratio over HP Max
				var p1HP = float(state[mainEIDs[0]]["HP"]) / float(state[mainEIDs[0]]["HPMax"])
				var p2HP = float(state[mainEIDs[1]]["HP"]) / float(state[mainEIDs[1]]["HPMax"])
				winner = sign(p2HP - p1HP)
			state["WhoHasWon"] = winner + 2
		
		# Slowdown
		if(timeSinceDead > 15 and timeSinceDead % 2):
			state["SkipFrame"] = true
		
		if(timeSinceDead == 150):
			# :TODO:Panthavma:20220207:Should refactor the winning code I think
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
			
			if(engine.useOnline):
				engine.rpc("OnlineEndMatch")
			
			fightFinished = true
			
			if(fightFinished):
				if(engine.useOnline):
					LoadLevel("res://dev/rollback-test/RollbackOnlineTest.tscn")
				else:
					LoadLevel(Castagne.configData["PostBattle"])
			else:
				if(engine.useOnline):
					Castagne.Net.StartNetworkMatch()
				else:
					LoadLevel("res://castagne/engine/CastagneEngine.tscn")
			engine.queue_free()
			state["SkipFrame"] = true

func InitPhaseEndEntity(eState, _data):
	if(eState["EID"] == 0):
		eState["PositionX"] = -20000
	if(eState["EID"] == 1):
		eState["PositionX"] = 20000

func ActionPhaseStartEntity(eState, _data):
	if(eState["HP"] <= 0 and !trainingMode):
		SetFlag(eState, "Die")

func UpdateGraphics(state, data):
	if(trainingMode):
		hitboxViewer.UpdateGraphics(state, data)



func PhysicsPhaseStartEntity(eState, data):
	if(trainingMode):
		TrainingApplyOptions(eState, data)
	if(data["State"]["FrameID"] == STARTFRAMES):
		SetFlag(eState,"StartRound")

var STARTFRAMES = 120
var winner = 0
var nbRoundsToWin = 2
var trainingMode = false
var hitboxViewer









# --------------------------------------------------------------------------------------------------
# Pause Menu

# :TODO:Panthavma:20220207:Move menu options with the other menus
var pauseMenu
var pauseMenuLabel
var pausedPID = null
var pauseOptionID = 0
var pauseOptions = null
var pauseSuboptions = {}
var pauseInputCooldownFrames = 20

func Pause(pid):
	pausedPID = pid
	if(!trainingMode):
		pauseOptionID = 0
	pauseInputCooldownFrames = 6
	PauseMenuUpdateLabel()
	pauseMenu.show()

func Unpause():
	pausedPID = null
	pauseMenu.hide()

func PausedIdle(pid, state, _data):
	var input = state["Players"][pid]["Inputs"]
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
	
	PauseMenuUpdateLabel()
	
	PauseMenuApplyOptions()
	
	if(input["DPress"]):
		pauseInputCooldownFrames = 6
		PauseMenuActivateOption(pauseOptionID, engine)

func PauseMenuUpdateLabel():
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

func PauseMenuActivateOption(id, engine):
	if(id == 0):
		Unpause()
	
	if((!trainingMode and id == 1) or (trainingMode and id == 3)):
		LoadLevel(Castagne.configData["MainMenu"])
		engine.queue_free()

func PauseMenuApplyOptions():
	if(!trainingMode):
		return
	
	var blockOptions = [BLOCKING_MODE.None, BLOCKING_MODE.BlockAll, BLOCKING_MODE.BlockLow, BLOCKING_MODE.BlockHigh]
	blockingMode = blockOptions[pauseSuboptions["Blocking"]]
	
	var regenOptions = [REGEN_MODE.Full, REGEN_MODE.No]
	hpRegenMode = regenOptions[pauseSuboptions["HP Regen"]]

func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)







# --------------------------------------------------------------------------------------------------
# Training Mode

var dummyPID

var blockingMode = BLOCKING_MODE.None
var hpRegenMode = REGEN_MODE.Full


enum BLOCKING_MODE {
	None, BlockAll, BlockLow, BlockHigh
}

enum REGEN_MODE {
	No, Full
}

func TrainingApplyOptions(eState, data):
	eState["TotalFuel"] = 60*100
	eState["Flags"] += ["StartRound"]
	if(eState["EID"] != data["State"]["Players"][dummyPID]["MainEntity"]):
		return
	
	
	if(HasFlag(eState, "Hitstun")):
		eState["TimeSinceHitstun"] = 0
	else:
		eState["TimeSinceHitstun"] += 1
	
	if(hpRegenMode == REGEN_MODE.Full and eState["TimeSinceHitstun"] >= 3):
		eState["HP"] = int(eState["HPMax"])
	
	if(blockingMode != BLOCKING_MODE.None):
		SetFlag(eState, "AutoBlocking")
		if(blockingMode != BLOCKING_MODE.BlockHigh):
			SetFlag(eState, "AutoBlockingLow")
		if(blockingMode != BLOCKING_MODE.BlockLow):
			SetFlag(eState, "AutoBlockingOverhead")


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







