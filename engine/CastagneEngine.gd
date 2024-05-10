# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Holds the config for the Castagne engine, and manages it.
# It also holds the modules and functions for convinience.

extends Node

var initOnReady = true
var configData = null
var battleInitData = null


var _memory
var instancedData = {}
var fighterScripts = []

var instancesRoot

var devicesToPoll = []


var modules

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
	
	# 4. Prepare main loop
	
	_inputPhaseFunction = funcref(configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.INPUT), "InputPhase")
	_physicsPhaseFunction = funcref(configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS), "PhysicsPhase")
	_modulePhaseCallbacks = {}
	for phaseName in ["Init", "Action", "Freeze", "Reaction", "Physics", "AI", "Subentity", "Input"]:
		_modulePhaseCallbacks[phaseName] = [[], [], [], [], 0, 0]
		for m in modules:
			if(m.has_method(phaseName+"PhaseStart") or m.has_method(phaseName+"PhaseStartEntity")):
				if(m.has_method(phaseName+"PhaseStart")):
					_modulePhaseCallbacks[phaseName][0].push_back(funcref(m, phaseName+"PhaseStart"))
				else:
					_modulePhaseCallbacks[phaseName][0].push_back(funcref(self, "_EmptyModuleCallback"))
				
				if(m.has_method(phaseName+"PhaseStartEntity")):
					_modulePhaseCallbacks[phaseName][1].push_back(funcref(m, phaseName+"PhaseStartEntity"))
				else:
					_modulePhaseCallbacks[phaseName][1].push_back(funcref(self, "_EmptyModuleCallback"))
				
				_modulePhaseCallbacks[phaseName][4] += 1
			
			if(m.has_method(phaseName+"PhaseEnd") or m.has_method(phaseName+"PhaseEndEntity")):
				if(m.has_method(phaseName+"PhaseEndEntity")):
					_modulePhaseCallbacks[phaseName][2].push_back(funcref(m, phaseName+"PhaseEndEntity"))
				else:
					_modulePhaseCallbacks[phaseName][2].push_back(funcref(self, "_EmptyModuleCallback"))
				
				if(m.has_method(phaseName+"PhaseEnd")):
					_modulePhaseCallbacks[phaseName][3].push_back(funcref(m, phaseName+"PhaseEnd"))
				else:
					_modulePhaseCallbacks[phaseName][3].push_back(funcref(self, "_EmptyModuleCallback"))
				
				_modulePhaseCallbacks[phaseName][5] += 1
	
	Castagne.Log("Init Ended\n----------------")

var _inputPhaseFunction
var _physicsPhaseFunction
var _modulePhaseCallbacks
func _EmptyModuleCallback(_gameStateHandle):
	pass









#-------------------------------------------------------------------------------
# Main Loop

func EngineTick(previousMemory, playerInputs):
	if(initError):
		return

	_castProfilingTickStart = OS.get_ticks_usec()
	# Memory Set
	ResetStateHandles()
	var memory = CreateMemory(previousMemory)
	var gameStateHandle = CreateStateHandle(memory)
	
	# Frame and input setup
	memory.GlobalSet("_TrueFrameID", memory.GlobalGet("_TrueFrameID")+1)
	memory.GlobalSet("_SkipFrame", false)
	gameStateHandle.GlobalSet("_InputsRaw", playerInputs)

	# Apply the framestart functions, and check if the frame needs to be skipped
	for m in modules:
		m.FramePreStart(gameStateHandle)
	
	# If skipping, stop here.
	if(gameStateHandle.GlobalGet("_SkipFrame")):
		return memory
	
	for m in modules:
		m.FrameStart(gameStateHandle)
	
	
	
	# Figure out if we are in a halt phase, and who has control
	var haltingEntity = GetHaltingEntityID(memory)
	var haltingEntityIsMainEntity = true
	if(haltingEntity >= 0):
		gameStateHandle.PointToEntity(haltingEntity)
		haltingEntityIsMainEntity = (gameStateHandle.EntityGet("_Entity") == null)
		gameStateHandle.EntityAdd("_HaltFrames", -1)
	
	# Prepare for the main loop
	gameStateHandle.GlobalSet("_FrameID", gameStateHandle.GlobalGet("_FrameID")+1)
	
	
	# Destroy previous entities
	var entitiesToDestroy = memory.GlobalGet("_EntitiesToDestroy")
	if(!entitiesToDestroy.empty()):
		for eid in entitiesToDestroy:
			RemoveEntityImmediate(gameStateHandle, eid)
		gameStateHandle.GlobalSet("_EntitiesToDestroy", [])
	
	# Create new full entities
	DoEntityInit(gameStateHandle, "_EntitiesToInit")
	
	# Gather the full entities
	var allMEIDs = memory.GlobalGet("_ActiveFullEntities")
	if(haltingEntity >= 0 and haltingEntityIsMainEntity):
		allMEIDs = [haltingEntity]
	var _filteredMEIDs = SeparateFrozenEntities(memory, allMEIDs)
	var activeMEIDs = _filteredMEIDs[0]
	var frozenMEIDs = _filteredMEIDs[1]
	
	# AI Script Phase
	ExecuteScriptPhase("AI", activeMEIDs, gameStateHandle)
	
	# Input Internal Phase
	ExecuteInternalPhase("Input", allMEIDs, gameStateHandle, _inputPhaseFunction)
	
	# Action Script Phase
	for module in modules:
		module.ResetVariables(gameStateHandle, activeMEIDs)
	ExecuteScriptPhase("Action", activeMEIDs, gameStateHandle)
	ExecuteScriptPhase("Freeze", frozenMEIDs, gameStateHandle)
	
	# Initialize new subentities
	DoEntityInit(gameStateHandle, "_SubentitiesToInit")
	
	# Gather the list of subentities to process
	var allSEIDs = memory.GlobalGet("_ActiveSubentities")
	var allEIDs = memory.GlobalGet("_ActiveEntities")
	if(haltingEntity >= 0):
		allEIDs = [haltingEntity]
		if(!haltingEntityIsMainEntity):
			allSEIDs = [haltingEntity]
	var _filteredSEIDs = SeparateFrozenEntities(memory, allSEIDs)
	var activeSEIDs = _filteredSEIDs[0]
	var frozenSEIDs = _filteredSEIDs[1]
	
	# Process subentities
	for module in modules:
		module.ResetVariables(gameStateHandle, activeSEIDs)
	ExecuteScriptPhase("Subentity", activeSEIDs, gameStateHandle)
	ExecuteScriptPhase("Freeze", frozenSEIDs, gameStateHandle)
	
	# Physics Internal Phase
	ExecuteInternalPhase("Physics", allEIDs, gameStateHandle, _physicsPhaseFunction)
	
	# Resolution Script Phase
	ExecuteScriptPhase("Reaction", activeMEIDs, gameStateHandle)
	
	# End the frame
	for m in modules:
		m.FrameEnd(gameStateHandle)
	
	return memory


func ExecuteScriptPhase(phaseName, eids, gameStateHandle):
	gameStateHandle.SetPhase(phaseName)
	for mID in range(_modulePhaseCallbacks[phaseName][4]):
		_modulePhaseCallbacks[phaseName][0][mID].call_func(gameStateHandle)
		var frEntity = _modulePhaseCallbacks[phaseName][1][mID]
		for eid in eids:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
	for eid in eids:
		gameStateHandle.PointToEntity(eid)
		ExecuteCurrentFighterScript(gameStateHandle)
	for mID in range(_modulePhaseCallbacks[phaseName][5]):
		var frEntity = _modulePhaseCallbacks[phaseName][2][mID]
		for eid in eids:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
		_modulePhaseCallbacks[phaseName][3][mID].call_func(gameStateHandle)

func ExecuteInternalPhase(phaseName, activeEIDs, gameStateHandle, phaseFunction):
	for mID in range(_modulePhaseCallbacks[phaseName][4]):
		_modulePhaseCallbacks[phaseName][0][mID].call_func(gameStateHandle)
		var frEntity = _modulePhaseCallbacks[phaseName][1][mID]
		for eid in activeEIDs:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
	phaseFunction.call_func(gameStateHandle, activeEIDs)
	for mID in range(_modulePhaseCallbacks[phaseName][5]):
		var frEntity = _modulePhaseCallbacks[phaseName][2][mID]
		for eid in activeEIDs:
			gameStateHandle.PointToEntity(eid)
			frEntity.call_func(gameStateHandle)
		_modulePhaseCallbacks[phaseName][3][mID].call_func(gameStateHandle)

func GetHaltingEntityID(memory):
	var eids = memory.GlobalGet("_ActiveEntities")
	for eid in eids:
		if(memory.EntityGet(eid, "_HaltFrames") > 0):
			return eid
	return -1

func SeparateFrozenEntities(memory, eids):
	var unfrozen = []
	var frozen = []
	for eid in eids:
		if(memory.EntityGet(eid, "_FreezeFrames") > 0):
			frozen.push_back(eid)
		else:
			unfrozen.push_back(eid)
	return [unfrozen, frozen]

func DoEntityInit(gameStateHandle, listName):
	var entitiesToInit = gameStateHandle.GlobalGet(listName)
	if(!entitiesToInit.empty()):
		gameStateHandle.GlobalSet(listName, [])
		for module in modules:
			for eid in entitiesToInit:
				gameStateHandle.PointToEntity(eid)
				module.CopyVariablesEntity(gameStateHandle, true)
		ExecuteScriptPhase("Init", entitiesToInit, gameStateHandle)

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
	var entityName = gameStateHandle.EntityGet("_Entity")
	if(entityName != null):
		stateName = entityName+"---"+stateName

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

# Helper for executing a single function as part of another module
func ExecuteCASPCallback(callbackName, gameStateHandle, customTarget = null, customPhase = null):
	var entityName = gameStateHandle.EntityGet("_Entity")
	if(entityName != null):
		callbackName = entityName+"---"+callbackName
	
	var fighterScript = GetFighterScript(gameStateHandle.EntityGet("_FighterID"), callbackName)
	if(fighterScript == null):
		Castagne.Error("ExecuteCASPCallback: Calling undefined state " + str(callbackName))
		return
	
	var previousTarget = gameStateHandle.GetTargetEntity() if customTarget != null else null
	var previousPhase = gameStateHandle.GetPhase() if customPhase != null else null
	
	if(customTarget != null):
		gameStateHandle.SetTargetEntity(customTarget)
	if(customPhase != null):
		gameStateHandle.SetPhase(customPhase)
	
	ExecuteFighterScript(fighterScript, gameStateHandle)
	
	if(customTarget != null):
		gameStateHandle.SetTargetEntity(previousTarget)
	if(customPhase != null):
		gameStateHandle.SetPhase(previousPhase)



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

var SyncManager = null # temp
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
		"TransformedData":fighter["TransformedData"],
	}

	instancedData["ParsedFighters"].append(parsedFighterData)
	fighterScripts.append(fighter["States"])
	return id

# Adds the data needed for a new entity, and returns its ID. It will be initialized on the next frame
func AddNewEntity(gameStateHandle, playerID, fighterID, entityName = null):
	var initStateName = "Init"

	var memory = gameStateHandle._memory
	var newEID = memory.AddEntity()
	var entityState = {
		"_Player": playerID,
		"_FighterID": fighterID,
		"_EID": newEID,
		"_State": initStateName,
		"_Entity": entityName,
	}

	var entityInstanceData = {
		"Root": null, "Model":null, "AnimPlayer":null,
		"Sprite":null,
	}

	gameStateHandle.GlobalSet("_CurrentEntityID", newEID)
	var parsedFighter = instancedData["ParsedFighters"][fighterID]
	var variablesEntity = {}
	var parsedFighterVariables = parsedFighter["Variables"]
	if(parsedFighterVariables.has(entityName)):
		for vName in parsedFighterVariables[entityName]:
			memory.EntitySet(newEID, vName, parsedFighterVariables[entityName][vName], true)
	else:
		Castagne.Error("Entity "+entityName+" has no variables attached.")
	for k in entityState:
		memory.EntitySet(newEID, k, entityState[k], true)
	
	for tdName in parsedFighter["TransformedData"]:
		entityInstanceData["TD_"+tdName] = parsedFighter["TransformedData"][tdName].duplicate(true)
	
	if(entityName == null):
		gameStateHandle.GlobalGet("_EntitiesToInit").append(newEID)
	else:
		gameStateHandle.GlobalGet("_SubentitiesToInit").append(newEID)
	gameStateHandle.IDGlobalGet("Entities")[newEID] = entityInstanceData

	if(gameStateHandle.PlayerGet("MainEntity") == -1):
		gameStateHandle.PlayerSet("MainEntity", newEID)

	return newEID

func RemoveEntityImmediate(gameStateHandle, eid):
	var memory = gameStateHandle.Memory()
	gameStateHandle.PointToEntity(eid)
	var playerID = gameStateHandle.EntityGet("_Player")
	if(gameStateHandle.IDEntityHas("Root")):
		var r = gameStateHandle.IDEntityGet("Root")
		if(r != null):
			r.queue_free()
	gameStateHandle.IDGlobalGet("Entities").erase(eid)
	gameStateHandle.GlobalGet("_ActiveEntities").erase(eid)
	gameStateHandle.GlobalGet("_ActiveFullEntities").erase(eid)
	gameStateHandle.GlobalGet("_ActiveSubentities").erase(eid)
	memory.RemoveEntity(eid)

	if(gameStateHandle.PlayerGet("MainEntity") == eid):
		var newMainEntity = -1
		var activeFullEntities = gameStateHandle.GlobalGet("_ActiveFullEntities")
		for eid in activeFullEntities:
			if(memory.EntityGet(eid, "_Player") == playerID):
				newMainEntity = eid
				break
		gameStateHandle.PlayerSet("MainEntity", newMainEntity)

func InstanceModel(eid, modelPath, animPlayerPath=null):
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
	# Temporary route around because we are too slow
	#if(_memories.size() < MAX_MEMORIES_IN_MEMORY):
	#	var newMemory = Node.new()
	#	newMemory.set_script(_prefabMemory)
	#	newMemory.InitMemory()
	#	add_child(newMemory)
	#	_memories.push_back(newMemory)
	#else:
	#	pass
	#var memory = _memories[_nextMemoryID]
	#_nextMemoryID = (_nextMemoryID + 1) % MAX_MEMORIES_IN_MEMORY
	#if(copyFrom != null):
	#	memory.CopyFrom(copyFrom)
	#return memory

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
