extends Spatial

var initOnReady = true

var trueFrameID = 0
var characterData = {}
var constants = {}
var gameState = {}
var instances = {}
var states = {}

var arena

const STARTING_POSITION = 20000
var camera
const ARENA_SIZE = 150000
const CAMERA_SIZE = 55000

var tools = []
const POSITION_SCALE = 0.0001

#-------------------------------------------------------------------------------
# Initialize
func Init(battleInitData):
	Castagne.Log("Init Started")
	
	trueFrameID = 0
	characterData = {}
	constants = {}
	gameState = {}
	instances = {}
	states = {}
	
	# Load maps and music
	var prefabMap = Load(Castagne.data["StagePaths"][battleInitData["map"]])
	var map = prefabMap.instance()
	add_child(map)
	instances["map"] = map
	arena = self
	
	# review this part lol
	for fp in Castagne.functionProviders:
		RegisterTool(fp)
	
	# Load fighters
	var fighter1 = InitPlayerAndInput("p1", battleInitData)
	var fighter2 = InitPlayerAndInput("p2", battleInitData)
	
	# Init
	InitGameStatePlayer("p1", fighter1)
	InitGameStatePlayer("p2", fighter2)
	InitGameStateGlobal()
	
	# Load tools
	
	var toolsList = Castagne.data["Tools"]["Common"] + Castagne.data["Tools"][battleInitData["mode"]]
	for tPath in toolsList:
		var t = Load(tPath).instance()
		add_child(t)
		RegisterTool(t)
	
	for t in tools:
		if(t.has_method("InitTool")):
			t.InitTool(self, battleInitData)
	
	UpdateGraphics(gameState)
	
	Castagne.Log("Init Ended\n----------------")

func InitPlayerAndInput(player, battleInitData):
	var characterPath = Castagne.data["CharacterPaths"][battleInitData[player]]
	var fighter = Castagne.Parser.CreateFullCharacter(characterPath)
	
	# Load Model
	var playerModelPrefab = Load(fighter["Character"]["Model"])
	var playerModel = playerModelPrefab.instance()
	var playerAnim = playerModel.get_node(fighter["Character"]["AnimPlayerPath"])
	arena.add_child(playerModel)
	#player1.InitFighter(self, p1Path)
	
	# Load Input
	var prefabInputProvider = Load(Castagne.data["InputProviders"][battleInitData[player+"-control-type"]])
	var inputProvider = prefabInputProvider.instance()
	inputProvider.Init(battleInitData[player+"-control-param"])
	add_child(inputProvider)
	
	fighter["Input"] = inputProvider
	fighter["Model"] = playerModel
	fighter["Anim"] = playerAnim
	fighter["Root"] = playerModel
	fighter["Sounds"] = playerModel.get_node("Sounds")
	
	return fighter

func InitGameStateGlobal():
	# Constants
	
	# State
	
	# TODO Temp, refactor
	gameState["p1"]["PositionHor"] = -STARTING_POSITION
	gameState["p2"]["PositionHor"] = STARTING_POSITION
	gameState["p1"]["Facing"] = 1
	gameState["p2"]["Facing"] = -1
	gameState["p1"]["FacingTrue"] = 1
	gameState["p2"]["FacingTrue"] = -1

func InitGameStatePlayer(pid, player):
	characterData[pid] = player["Character"]
	constants[pid] = player["Constants"]
	gameState[pid] = player["Variables"]
	instances[pid] = {
		"Model": player["Model"],
		"Input": player["Input"],
		"Anim": player["Anim"],
		"Root": player["Root"],
		"Sounds": player["Sounds"],
	}
	
	states[pid] = player["States"]
	
	for t in tools:
		t.StateSetup(pid, gameState, self)



#-------------------------------------------------------------------------------
# Main Loop
var _framebyframe =false
var _fbfkpress = false
var _fbfkpressa = false
func FrameAdvance(previousState, inputsP1, inputsP2):
	var currentState = previousState.duplicate(true)
	currentState["TrueFrameID"] += 1
	trueFrameID = currentState["TrueFrameID"]
	
	var p1State = states["p1"][currentState["p1"]["State"]]
	var p2State = states["p2"][currentState["p2"]["State"]]
	
	inputsP1 = instances["p1"]["Input"].EnrichInput(inputsP1, currentState["p1"], previousState["p1"]["Input"])
	inputsP2 = instances["p2"]["Input"].EnrichInput(inputsP2, currentState["p2"], previousState["p2"]["Input"])
	
	currentState["SkipFrame"] = false
	currentState["p1"]["Input"] = inputsP1
	currentState["p2"]["Input"] = inputsP2
	
	for t in tools:
		t.FrameStart(previousState, currentState, self)
	
	var skipFrame = currentState["SkipFrame"]
	
	if(!skipFrame):
		currentState["FrameID"] += 1
		
		for t in tools:
			t.PreFrame("p1", p1State, inputsP1, previousState, currentState)
			t.PreFrame("p2", p2State, inputsP2, previousState, currentState)
		FrameAdvancePlayerPlayActionsTypes("p1", p1State, currentState, "FrameFunc")
		FrameAdvancePlayerPlayActionsTypes("p2", p2State, currentState, "FrameFunc")
		for t in tools:
			t.PostFrame("p1", p1State, inputsP1, previousState, currentState)
			t.PostFrame("p2", p2State, inputsP2, previousState, currentState)
		
		for t in tools:
			t.PrePhysics("p1", p1State, inputsP1, previousState, currentState)
			t.PrePhysics("p2", p2State, inputsP2, previousState, currentState)
		FrameAdvanceCollisions(previousState, currentState)
		FrameAdvancePhysicsHitboxes("p1", "p2", currentState)
		FrameAdvancePhysicsHitboxes("p2", "p1", currentState)
		FrameAdvanceCommon(inputsP1, inputsP2, previousState, currentState)
		for t in tools:
			t.PostPhysics("p1", p1State, inputsP1, previousState, currentState)
			t.PostPhysics("p2", p2State, inputsP2, previousState, currentState)
		
		FrameAdvancePlayerPlayActionsTypes("p1", p1State, currentState, "TransitionFunc")
		FrameAdvancePlayerPlayActionsTypes("p2", p2State, currentState, "TransitionFunc")
		for t in tools:
			t.PostTransition("p1", p1State, inputsP1, previousState, currentState)
			t.PostTransition("p2", p2State, inputsP2, previousState, currentState)
	
	
	return currentState

func ExecuteAction(action, pid, currentState, neededFlag):
	if(!neededFlag in action["Flags"]):
		return
	if("FullData" in action["Flags"]):
		action["Func"].call_func(action["Args"], pid, currentState, self, neededFlag)
	else:
		action["Func"].call_func(action["Args"], pid, currentState)

func FrameAdvancePlayerPlayActions(pid, playerState, currentState, neededFlag):
	for action in playerState["Actions"]:
		ExecuteAction(action, pid, currentState, neededFlag)

func FrameAdvancePlayerPlayActionsTypes(pid, playerState, currentState, neededFlag):
	var typeStates = [playerState]
	var curType = playerState["Type"]
	while(curType != null):
		var newState = states[pid][curType]
		typeStates.push_front(newState)
		
		if(curType+"Post" in states[pid]):
			var newStatePost = states[pid][curType+"Post"]
			typeStates.push_back(newStatePost)
		
		curType = newState["Type"]
	
	for pState in typeStates:
		FrameAdvancePlayerPlayActions(pid, pState, currentState, neededFlag)

func FrameAdvancePlayer(pid, playerState, inputs, previousState, currentState):
	currentState[pid]["Input"] = inputs
	
	for t in tools:
		t.PreFrame(pid, playerState, inputs, previousState, currentState)
	
	FrameAdvancePlayerPlayActionsTypes(pid, playerState, currentState, "FrameFunc")
	
	for t in tools:
		t.PostFrame(pid, playerState, inputs, previousState, currentState)

func FrameAdvancePlayerTransition(pid, playerState, inputs, previousState, currentState):
	FrameAdvancePlayerPlayActionsTypes(pid, playerState, currentState, "TransitionFunc")
	
	for t in tools:
		t.PostTransition(pid, playerState, inputs, previousState, currentState)

func FrameAdvanceCollisions(previousState, state):
	var pids = ["p1", "p2"]
	var nbPids = pids.size()
	
	var arenaSize = ARENA_SIZE
	var cameraSize = CAMERA_SIZE
	
	# Find out who is one the left and who is on the right
	var posDiff = previousState["p2"]["PositionHor"] - previousState["p1"]["PositionHor"]
	var playerOnTheLeft = (0 if posDiff > 0 else 1)
	# Use the previous frame's result if there is doubt (stored because of jumps)
	if(posDiff == 0):
		playerOnTheLeft = previousState["PlayerOnTheLeft"]
	state["PlayerOnTheLeft"] = playerOnTheLeft
	
	# Find out collisions and camera postion for better placement
	var camCenter = previousState["CameraHor"] # TODO Recompute ?
	var p1Colbox = GetBoxPosition(state["p1"], state["p1"]["Colbox"])
	var p2Colbox = GetBoxPosition(state["p2"], state["p2"]["Colbox"])
	var areBoxesOverlapping = AreBoxesOverlapping(p1Colbox, p2Colbox)
	var overlapAmount = 0
	if(areBoxesOverlapping):
		if(playerOnTheLeft == 0):
			overlapAmount = p1Colbox["Right"] - p2Colbox["Left"]
		else:
			overlapAmount = p2Colbox["Right"] - p1Colbox["Left"]
	
	
	for i in range(nbPids):
		var pid = pids[i]
		var minX = max(-arenaSize, camCenter - cameraSize)
		var maxX = min(arenaSize, camCenter + cameraSize)
		
		# Prevent corner steal and push the boxes if in the corner
		if(i == playerOnTheLeft):
			maxX -= 1 + overlapAmount
		else:
			minX += 1 + overlapAmount
		
		# Check Collisions
		var positionX = state[pid]["PositionHor"]
		if(i == playerOnTheLeft):
			positionX -= overlapAmount/2
		else:
			positionX += overlapAmount/2
		positionX = clamp(positionX, minX, maxX)
		state[pid]["PositionHor"] = positionX 
		
		var events = {}
		var newFacing = (1 if i == playerOnTheLeft else -1)
		if(state[pid]["FacingTrue"] != newFacing):
			events["SwitchFacing"] = newFacing
			state[pid]["FacingTrue"] = newFacing
		
		if(state[pid]["PositionVer"] <= 0):
			state[pid]["PositionVer"] = 0
			events["Grounded"] = true
		else:
			events["Airborne"] = true
		
		state[pid]["Events"] = events

func FrameAdvancePhysicsHitboxes(defenderPID, attackerPID, state):
	var defenderState = state[defenderPID]
	var attackerState = state[attackerPID]
	var defenderEvents = defenderState["Events"]
	
	# Hitbox/Hurtbox collisions. Own Hurtboxes vs foe hitboxes
	var hurtboxes = []
	var hitboxes = []
	
	var nbHurtboxes = defenderState["NbHurtboxes"]
	var nbHitboxes = attackerState["NbHitboxes"]
	
	for i in range(nbHurtboxes):
		hurtboxes += [defenderState["Hurtbox"+str(i)]]
	for i in range(nbHitboxes):
		hitboxes += [attackerState["Hitbox"+str(i)]]
	
	if(!attackerState["AttackHasHit"]):
		for hitbox in hitboxes:
			var hitboxPos = GetBoxPosition(attackerState, hitbox)
			
			var hit = Castagne.HITCONFIRMED.NONE
			for hurtbox in hurtboxes:
				var hurtboxPos = GetBoxPosition(defenderState, hurtbox)
				
				if(AreBoxesOverlapping(hurtboxPos, hitboxPos)):
					hit = Castagne.HITCONFIRMED.HIT
					break
			
			# First hitbox has priority
			if(hit != Castagne.HITCONFIRMED.NONE):
				var attackData = hitbox["AttackData"]
				for t in tools:
					hit = t.IsHitConfirmed(hit, attackData, defenderPID, attackerPID, state)
				
				if(hit == Castagne.HITCONFIRMED.NONE):
					continue
				
				
				if(hit == Castagne.HITCONFIRMED.HIT):
					defenderEvents["Hit"] = attackData
					for t in tools:
						t.OnHit(attackData, defenderPID, attackerPID, state, defenderEvents)
				
				else:
					defenderEvents["Block"] = attackData
					for t in tools:
						t.OnBlock(attackData, defenderPID, attackerPID, state, defenderEvents)
					
				break 
	
	defenderState["Events"] = defenderEvents

func FrameAdvanceCommon(_inputsP1, _inputsP2, _previousState, currentState):
	currentState["CameraHor"] = (currentState["p1"]["PositionHor"]+currentState["p2"]["PositionHor"])/2
	currentState["CameraVer"] = (currentState["p1"]["PositionVer"]+currentState["p2"]["PositionVer"])/2
	
	var signCam = sign(currentState["CameraHor"])
	if(signCam != 0 and abs(currentState["CameraHor"]) > (ARENA_SIZE - CAMERA_SIZE)):
		currentState["CameraHor"] = signCam * (ARENA_SIZE - CAMERA_SIZE)




func GetBoxPosition(fighterState, box):
	var boxLeft = fighterState["PositionHor"]
	var boxRight = fighterState["PositionHor"]
	
	if(fighterState["Facing"] > 0):
		boxLeft += box["Left"]
		boxRight += box["Right"]
	else:
		boxLeft -= box["Right"]
		boxRight -= box["Left"]
	
	var boxDown = fighterState["PositionVer"] + box["Down"]
	var boxUp = fighterState["PositionVer"] + box["Up"]
	
	return {"Left":boxLeft, "Right":boxRight,"Down":boxDown,"Up":boxUp}

func AreBoxesOverlapping(boxA, boxB):
	return (boxA["Right"] > boxB["Left"]
		and boxA["Left"] < boxB["Right"]
		and boxA["Up"] > boxB["Down"]
		and boxA["Down"] < boxB["Up"])

func Load(path):
	return load(path)





func UpdateGraphics(currentState):
	for t in tools:
		t.UpdateGraphics(currentState, self)
	UpdatePlayerGraphics("p1", currentState)
	UpdatePlayerGraphics("p2", currentState)
	
	
	Render()

func UpdatePlayerGraphics(pid, globalState):
	var charState = globalState[pid]
	var animPlayer = instances[pid]["Anim"]
	
	var frameID = globalState[pid]["StateFrameID"]
	
	
	if(animPlayer != null):
		animPlayer.play(charState["Anim"], 0.0, 0.0)
		animPlayer.seek(float(frameID + globalState[pid]["AnimOffset"])/60.0, true)
	
	for t in tools:
		t.UpdatePlayerGraphics(pid, globalState, self)

func Render():
	pass








func _ready():
	if(initOnReady):
		Init(Castagne.battleInitData)

func _physics_process(_delta):
	# Physics process is fixed at 60 FPS
	gameState = FrameAdvance(gameState, instances["p1"]["Input"].PollRaw(), instances["p2"]["Input"].PollRaw())

var _lastGraphicsFrameUpdate = -1
func _process(_delta):
	if(_lastGraphicsFrameUpdate < trueFrameID):
		_lastGraphicsFrameUpdate = trueFrameID
		UpdateGraphics(gameState)

func RegisterTool(toolNode):
	tools += [toolNode]
