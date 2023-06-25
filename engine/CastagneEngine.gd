extends Node


# :TODO:Panthavma:20220209:Make SyncManager optional

# :TODO:Panthavma:20220124:Refacto module loading

var initOnReady = true
var configData = null
var battleInitData = null


var _memory
# :TODO:Panthavma:20220125:Change to a struct (?)
var instancedData = {}
var fighterScripts = []

var instancesRoot

var devicesToPoll = []


# TODO: remove them
var modules
var physicsModule
var editorModule
var graphicsModule

var useOnline = false
var initError = false
var runAutomatically = true
var renderGraphics = true

#---------------------------------------------------------------------------------------------------
# Initialize
func Init():
	# 1. Start Init
	Castagne.Log("Init Started")
	
	_memory = CreateMemory()
	
	instancedData = {
		"Players": [],
		"ParsedFighters": [],
		"Entities": {},
	}
	fighterScripts = []
	useOnline = false
	initError = false
	
	if(initError):
		AbortWithError("Initialization failed at the map init stage. Aborting.")
		return
		
	# 3. Prepare the first frame
	
	Castagne.Parser.ResetErrors()
	modules = configData.GetModules()
	var sh = CreateStateHandle(_memory)
	for module in modules:
		module.engine = self
		module.CopyVariablesGlobal(_memory)
		module.BattleInit(sh, battleInitData)
	
	
	if(initError):
		AbortWithError("Initialization failed at the fighter init stage. Aborting.", true)
		return
	
	Castagne.Log("Init Ended\n----------------")











#-------------------------------------------------------------------------------
# Main Loop

func EngineTick(previousMemory, playerInputs):
	if(initError):
		return
	
	_castProfilingTickStart = OS.get_ticks_usec()
	# 1. Frame and input setup
	# 0. Memory Set
	ResetStateHandles()
	var memory = CreateMemory(previousMemory)
	memory.GlobalSet("_TrueFrameID", memory.GlobalGet("_TrueFrameID")+1)
	memory.GlobalSet("_SkipFrame", false)
	
	var gameStateHandle = CreateStateHandle(memory)
	
	gameStateHandle.GlobalSet("_InputsRaw", playerInputs)
	
	# 2. Apply the framestart functions, and check if the frame needs to be skipped
	for m in modules:
		m.FramePreStart(gameStateHandle)
	
	
	# 3b. If skipping, stop here. If frozen, special loop using the Freeze phase
	if(gameStateHandle.GlobalGet("_SkipFrame")):
		return memory
	
	for m in modules:
		m.FrameStart(gameStateHandle)
	
	if(gameStateHandle.GlobalGet("_FrozenFrame")):
		var activeEIDs = gameStateHandle.GlobalGet("_ActiveEntities")
		for module in modules:
			module.ResetVariables(gameStateHandle, activeEIDs)
		#var inputPhaseFunction = funcref(configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.INPUT), "InputPhase")
		#ExecuteInternalPhase("Input", activeEIDs, gameStateHandle, inputPhaseFunction)
		ExecuteScriptPhase("Freeze", activeEIDs, gameStateHandle)
		
		
		for m in modules:
			m.FrameEnd(gameStateHandle)
		return memory
	
	gameStateHandle.GlobalSet("_FrameID", gameStateHandle.GlobalGet("_FrameID")+1)
	
	# 3. Gather the entities needed for the init phase
	# 1. Init Script Phase
	var entitiesToDestroy = memory.GlobalGet("_EntitiesToDestroy")
	if(!entitiesToDestroy.empty()):
		for eid in entitiesToDestroy:
			RemoveEntityImmediate(gameStateHandle, eid)
		gameStateHandle.GlobalSet("_EntitiesToDestroy", [])
	
	var entitiesToInit = memory.GlobalGet("_EntitiesToInit")
	var activeEIDs = memory.GlobalGet("_ActiveEntities")
	if(!entitiesToInit.empty()):
		gameStateHandle.GlobalSet("_EntitiesToInit", [])
		for module in modules:
			for eid in entitiesToInit:
				gameStateHandle.PointToEntity(eid)
				module.CopyVariablesEntity(gameStateHandle, true)
		ExecuteScriptPhase("Init", entitiesToInit, gameStateHandle)
		
	# TODO: Loop types
	
	# 2. AI Script Phase
	ExecuteScriptPhase("AI", activeEIDs, gameStateHandle)
	
	# 3. Input Internal Phase
	var inputPhaseFunction = funcref(configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.INPUT), "InputPhase")
	ExecuteInternalPhase("Input", activeEIDs, gameStateHandle, inputPhaseFunction)
	
	# 4. Action Script Phase
	for module in modules:
		module.ResetVariables(gameStateHandle, activeEIDs)
	ExecuteScriptPhase("Action", activeEIDs, gameStateHandle)
	
	# 5. Physics Internal Phase
	var physicsPhaseFunction = funcref(configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS), "PhysicsPhase")
	ExecuteInternalPhase("Physics", activeEIDs, gameStateHandle, physicsPhaseFunction)
	
	
	# 6. Resolution Script Phase
	ExecuteScriptPhase("Reaction", activeEIDs, gameStateHandle)
	
	# End the frame
	for m in modules:
		m.FrameEnd(gameStateHandle)
	
	return memory
	

func ExecuteScriptPhase(phaseName, eids, gameStateHandle):
	# :TODO:Panthavma:20220126:Optimize this by making the funcrefs beforehand
	gameStateHandle.SetPhase(phaseName)
	for m in modules:
		funcref(m, phaseName+"PhaseStart").call_func(gameStateHandle)
		var frEntity = funcref(m, phaseName+"PhaseStartEntity")
		for eid in eids:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
	for eid in eids:
		gameStateHandle.PointToEntity(eid)
		ExecuteCurrentFighterScript(gameStateHandle)
	for m in modules:
		var frEntity = funcref(m, phaseName+"PhaseEndEntity")
		for eid in eids:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
		funcref(m, phaseName+"PhaseEnd").call_func(gameStateHandle)

func ExecuteInternalPhase(phaseName, activeEIDs, gameStateHandle, phaseFunction):
	# :TODO:Panthavma:20220126:Optimize this by making the funcrefs beforehand
	for m in modules:
		funcref(m, phaseName+"PhaseStart").call_func(gameStateHandle)
		var frEntity = funcref(m, phaseName+"PhaseStartEntity")
		for eid in activeEIDs:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
	phaseFunction.call_func(gameStateHandle, activeEIDs)
	for m in modules:
		var frEntity = funcref(m, phaseName+"PhaseEndEntity")
		for eid in activeEIDs:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
		funcref(m, phaseName+"PhaseEnd").call_func(gameStateHandle)


func ExecuteCurrentFighterScript(gameStateHandle):
	# 1. Get the fighter script / state from the entity (done outside maybe ?)
	var fighterScript = GetCurrentFighterScriptOfEntity(gameStateHandle)
	
	if(fighterScript == null):
		return
	
	# 2. Execute each action one by one
	ExecuteFighterScript(fighterScript, gameStateHandle)

func GetCurrentFighterScriptOfEntity(gameStateHandle):
	var fighterID = gameStateHandle.EntityGet("_FighterID")
	var stateName = gameStateHandle.EntityGet("_State")
	
	return GetFighterScript(fighterID, stateName)

func GetFighterScript(fighterID, stateName):
	if(fighterID >= fighterScripts.size()):
		Castagne.Error("GetFighterScript: Fighter ID " + str(fighterID) + " not found!")
		return null
	if(!fighterScripts[fighterID].has(stateName)):
		Castagne.Error("GetFighterScript: State "+str(stateName)+" on Fighter ID " + str(fighterID) + " not found!")
		return null
	
	return fighterScripts[fighterID][stateName]

func GetFighterAllScripts(fighterID):
	if(fighterID >= fighterScripts.size()):
		Castagne.Error("GetFighterScript: Fighter ID " + str(fighterID) + " not found!")
		return null
	return fighterScripts[fighterID]

func ExecuteFighterScript(fighterScript, gameStateHandle):
	var phaseName = gameStateHandle.GetPhase()
	var actionList = fighterScript[phaseName]
	
	for action in actionList:
		action[0].call_func(action[1], gameStateHandle)

func ExecuteAction(action, phaseName, entityState, moduleCallbackData):
	# :TODO:Panthavma:20221120:Seems unneeded now
	if(phaseName in action["Flags"]):
		action["Func"].call_func(action["Args"], entityState, moduleCallbackData)



func UpdateGraphics(memory):
	_castProfilingGraphicsStart = OS.get_ticks_usec()
	var gameStateHandle = CreateStateHandle(memory)
	for m in modules:
		m.UpdateGraphics(gameStateHandle)
	_castProfilingGraphicsEnd = OS.get_ticks_usec()





# ------------------------------------------------------------------------------
# Networking
var _onlineStart = false
var _onlineNbReady = 0

# :TODO:Panthavma:20220124:Make entity spawning work online

func _save_state() -> Dictionary:
	return _memory

func _load_state(state: Dictionary) -> void:
	_memory = state
	_lastGraphicsFrameUpdate = -1

func _network_process(_input: Dictionary) -> void:
	if(_onlineStart):
		var playerInputs = []
		for player in instancedData["Players"]:
			playerInputs.append(player["InputProvider"].onlineLastInput)
		_memory = EngineTick(_memory, playerInputs)


remotesync func _OnlineReady():
	if(!get_tree().is_network_server()):
		return
	_onlineNbReady += 1
	Castagne.Net.Log("Engine : Online Ready " + str(_onlineNbReady))
	if(_onlineNbReady == 2):
		#get_tree().paused = false
		Castagne.Net.Log("Engine : Online All Ready, starting...")
		Castagne.Net.StartSync()
#		rpc("_NetStartMatch")

#remotesync func _NetStartMatch():
#	get_tree().paused = false


func _on_SyncManager_sync_started() -> void:
	Castagne.Net.Log("Engine : SyncManager Sync Started")
	_onlineStart = true

func _OnlineInit():
	#SyncManager.connect("scene_spawned", self, "_on_SyncManager_scene_spawned")
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	#get_tree().paused = true
	set_network_master(1)
	Castagne.Net.StartLogging()
	
	Init()
	
	rpc("_OnlineReady")



remotesync func OnlineEndMatch():
	Castagne.Net.StopSync()
	queue_free()


# --------------------------------------------------------------------------------------------------
# Helpers

#func _BuildModuleCallbackData(currentState):
#	# :TODO:Panthavma:20220124:Rework that a bit?
#	var data = {
#		"State": currentState,
#		"InstancedData": instancedData,
#		"Engine": self,
#		
#		"Phase": "NotSpecified",
#		"FighterScripts": fighterScripts,
#		
#		"OriginalEID": -1,
#		"SelectedEID": -1,
#		"RefEID": -1,
#		"rState": null,
#	}
#	return data

# Parses a script file and adds it to the relevant lists. Returns the ID if okay, or -1 if not.
func ParseFighterScript(characterPath):
	var fighter = Castagne.Parser.CreateFullCharacter(characterPath, configData, false)
	
	if(fighter == null):
		Castagne.Error("Character "+characterPath+" isn't initialized properly.")
		initError = true
		return -1
	
	var id = instancedData["ParsedFighters"].size()
	
	var parsedFighterData = {
		"ID": id,
		"File":characterPath,
		"Character":fighter["Character"],
		"Variables":fighter["Variables"],
	}
	
	instancedData["ParsedFighters"].append(parsedFighterData)
	fighterScripts.append(fighter["States"])
	return id

# Adds the data needed for a new entity, and returns its ID. It will be initialized on the next frame
func AddNewEntity(gameStateHandle, playerID, fighterID, entityName = "Main"):
	# :TODO:Panthavma:20220310:Probably needs special attention for rollback or we're gonna get problems
	# Add the entity
	# :TODO:Panthavma:20220125:Move entity setup elsewhere
	# :TODO:Panthavma:20221120:Definitely needs a second pass
	
	var initStateName = "Init-Main"
	if(entityName != "Main"):
		initStateName = "Init--"+entityName
	
	var memory = gameStateHandle._memory
	var newEID = memory.AddEntity()
	var entityState = {
		"_Player": playerID,
		"_FighterID": fighterID,
		"_EID": newEID,
		"_State": initStateName,
	}
	
	# :TODO:Panthavma:20220125:Need main entity id
	
	var entityInstanceData = {
		"Root": null, "Model":null, "AnimPlayer":null,
		"Sprite":null,
	}
	
	gameStateHandle.GlobalSet("_CurrentEntityID", newEID)
	var variablesEntity = {}
	var parsedFighterVariables = instancedData["ParsedFighters"][fighterID]["Variables"]
	if(parsedFighterVariables.has(entityName)):
		for vName in parsedFighterVariables[entityName]:
			memory.EntitySet(newEID, vName, parsedFighterVariables[entityName][vName], true)
	else:
		Castagne.Error("Entity "+entityName+" has no variables attached.")
	for k in entityState:
		memory.EntitySet(newEID, k, entityState[k], true)
	gameStateHandle.GlobalGet("_EntitiesToInit").append(newEID)
	
	gameStateHandle.IDGlobalGet("Entities")[newEID] = entityInstanceData
	
	if(gameStateHandle.PlayerGet("MainEntity") == -1):
		gameStateHandle.PlayerSet("MainEntity", newEID)
	
	return newEID

func RemoveEntityImmediate(gameStateHandle, eid):
	gameStateHandle.PointToEntity(eid)
	if(gameStateHandle.IDEntityHas("Root")):
		gameStateHandle.IDEntityGet("Root").queue_free()
	gameStateHandle.IDGlobalGet("Entities").erase(eid)
	gameStateHandle.GlobalGet("_ActiveEntities").erase(eid)
	gameStateHandle._memory.RemoveEntity(eid)
	
	if(gameStateHandle.PlayerGet("MainEntity") == eid):
		gameStateHandle.PlayerSet("MainEntity", -1)
		# :TODO:Panthavma:20230318:Find new main entity

func InstanceModel(eid, modelPath, animPlayerPath=null):
	# :TODO:Panthavma:20220310:Probably needs special attention for rollback or we're gonna get problems
	var playerModelPrefab = Castagne.Loader.Load(modelPath)
	if(playerModelPrefab == null):
		Castagne.Error("InstanceModel: Scene not found for " + str(modelPath))
		return
	
	var playerModel = playerModelPrefab.instance()
	
	instancedData["Entities"][eid]["Model"] = playerModel
	var modelRoot = instancedData["Entities"][eid]["Root"]
	
	if(animPlayerPath != null):
		var playerAnim = playerModel.get_node(animPlayerPath)
		if(playerAnim != null):
			if(playerAnim.has_method("play")):
				instancedData["Entities"][eid]["AnimPlayer"] = playerAnim
			else:
				print("InstanceModel: AnimPlayer Path invalid, found " +str(playerAnim) +" instead")
		else:
			print("InstanceModel: AnimPlayer Path invalid, didn't find anything at path " +str(animPlayerPath))
	
	modelRoot.add_child(playerModel)


func GetInputDevice(pid):
	if(devicesToPoll.size() <= pid):
		return null
	return devicesToPoll[pid]
func SetInputDevice(pid, deviceName):
	while(devicesToPoll.size() <= pid):
		devicesToPoll.push_back(null)
	devicesToPoll[pid] = deviceName



# --------------------------------------------------------------------------------------------------
# System

var _castProfilingTickStart = -1
var _castProfilingGraphicsStart = -1
var _castProfilingGraphicsEnd = -1

func _ready():
	#useOnline = battleInitData["online"]
	useOnline = false
	if(useOnline):
		_OnlineInit()
	elif(initOnReady):
		Init()

func _physics_process(_delta):
	# Physics process is fixed at 60 FPS
	if(!useOnline and runAutomatically):
		LocalStep()

func LocalStep():
	var castagneInputs = configData.Input()
	var playerInputs = []
	for deviceName in devicesToPoll:
		playerInputs.push_back(castagneInputs.PollDevice(deviceName))
	_memory = EngineTick(_memory, playerInputs)

func LocalStepNoInput():
	_memory = EngineTick(_memory, [])

var _lastGraphicsFrameUpdate = -1
func _process(_delta):
	if(!renderGraphics):
		return
	var trueFrameID = _memory.GlobalGet("_TrueFrameID")
	if(_lastGraphicsFrameUpdate < trueFrameID):
		_lastGraphicsFrameUpdate = trueFrameID
		UpdateGraphics(_memory)


var _prefabMemory = preload("res://castagne/engine/CastagneMemory.gd")
var _memories = []
var MAX_MEMORIES_IN_MEMORY = 16
var _nextMemoryID = 0
func CreateMemory(copyFrom = null):
	if(_memories.empty()):
		var newMemory = Node.new()
		newMemory.set_script(_prefabMemory)
		newMemory.InitMemory()
		add_child(newMemory)
		_memories.push_back(newMemory)
	return _memories[0]
	
	
	# :TODO:Panthavma:20230617:Put back actual memory management back in when we go faster for rollback
	if(_memories.size() < MAX_MEMORIES_IN_MEMORY):
		var newMemory = Node.new()
		newMemory.set_script(_prefabMemory)
		newMemory.InitMemory()
		add_child(newMemory)
		_memories.push_back(newMemory)
	else:
		pass
	var memory = _memories[_nextMemoryID]
	_nextMemoryID = (_nextMemoryID + 1) % MAX_MEMORIES_IN_MEMORY
	if(copyFrom != null):
		memory.CopyFrom(copyFrom)
	return memory

var _prefabStateHandle = preload("res://castagne/engine/CastagneStateHandle.gd")
var _stateHandles = []
var _currentStateHandle = 0
func CreateStateHandle(memory, eid = -1):
	var stateHandle = null
	if(_currentStateHandle >= _stateHandles.size()):
		stateHandle = Node.new()
		stateHandle.set_script(_prefabStateHandle)
		_stateHandles.push_back(stateHandle)
		add_child(stateHandle)
	else:
		stateHandle = _stateHandles[_currentStateHandle]
	_currentStateHandle += 1
	stateHandle.InitHandle(memory, self)
	stateHandle.PointToEntity(eid)
	return stateHandle

func ResetStateHandles():
	_currentStateHandle = 0

var _errorScreen = null
func AbortWithError(error, showParserErrors = false):
	queue_free()
	Castagne.Error(error)
	
	var l = Label.new()
	var t = ""
	
	if(showParserErrors):
		var nbErrors = {"Warning":0, "Error":0, "Fatal Error":0}
		for e in Castagne.Parser._errors:
			nbErrors[e["Type"]] += 1
			t += "["+str(e["Type"])+"] " + e["FilePath"] +" l." + str(e["LineID"]) + ": " + e["Text"] +"\n"
		t = "\n\n---- "+str(nbErrors["Warning"])+" Warnings / "+str(nbErrors["Error"])+" Errors / "+str(nbErrors["Fatal Error"])+" Fatal Errors ----\n" + t
	
	l.set_text(error + t)
	get_node("..").add_child(l)
	l.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	l.set_align(Label.ALIGN_CENTER)
	l.set_valign(Label.VALIGN_CENTER)
	_errorScreen = l
