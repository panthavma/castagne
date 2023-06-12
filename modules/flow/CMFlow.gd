extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Flow", Castagne.MODULE_SLOTS_BASE.FLOW, {
		"Description":"Generic flow module, handles match entry and exit, as well as mid-match events."
		})
	#RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Core.casp", -9000)
	
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Global, "players", [], {
		"Description":"List of player BIDs. The 0th one is the default, which the later ones may override."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Global, "entities", [], {
		"Description":"List of entity BIDs to be spawned without players. The 0th one is the default, which the later ones may override."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Global, "overrides", {}, {
		"Description":"Global variables to override at the begining of the match."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Global, "triggers", [], {
		"Description":"Unsupported at the moment."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Global, "map", 0, {
		"Description":"The stage to load."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Global, "music", null, {
		"Description":"Unsupported"
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Global, "exitcallback", null, {
		"Description":"Unsupported"
		})
	
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Player, "entities", [], {
		"Description":"List of entity BIDs to spawn by the player. The 0th one is the default, which the later ones may override."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Player, "overrides", {}, {
		"Description":"List of player variables to override at the beginning of the match."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Player, "inputdevice", null, {
		"Description":"The name of the input device to associate to this player."
		})
	
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Entity, "overrides", {}, {
		"Description":"List of entity variables to override at the beginning of the match."
		})
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Entity, "scriptpath", 0, {
		"Description":"Path to the casp file of the character."
		})
	
	RegisterConfig("BID-Custom-Global", "", {"Description":"Additional fields for the global BID."})
	RegisterConfig("BID-Custom-Player", "", {"Description":"Additional fields for the player BID."})
	RegisterConfig("BID-Custom-Entity", "", {"Description":"Additional fields for the entity BID."})
	
	# _NbPlayers?

func GetBaseBattleInitData(configData):
	var modules = configData.GetModules()
	
	var entityBase = {}
	var playerBase = {}
	var battleInitData = {}
	
	for key in Castagne.SplitStringToArray(configData.Get("BID-Custom-Global")):
		battleInitData[key] = ""
	for key in Castagne.SplitStringToArray(configData.Get("BID-Custom-Player")):
		playerBase[key] = ""
	for key in Castagne.SplitStringToArray(configData.Get("BID-Custom-Entity")):
		entityBase[key] = ""
	
	for m in modules:
		Castagne.FuseDataOverwrite(entityBase, m._battleInitDataDefault[Castagne.MEMORY_STACKS.Entity].duplicate(true))
		Castagne.FuseDataOverwrite(playerBase, m._battleInitDataDefault[Castagne.MEMORY_STACKS.Player].duplicate(true))
		Castagne.FuseDataOverwrite(battleInitData, m._battleInitDataDefault[Castagne.MEMORY_STACKS.Global].duplicate(true))
	
	playerBase["entities"] = [entityBase.duplicate(true)]
	battleInitData["players"] = [playerBase]
	battleInitData["entities"] = [entityBase.duplicate(true)]
	
	return battleInitData

func BattleInit(stateHandle, battleInitData):
	_BattleInit_CreateEntities(stateHandle, battleInitData["entities"], -1)
	
	var pBase = battleInitData["players"][0]
	for pid in range(battleInitData["players"].size()-1):
		var p = pBase.duplicate(true)
		Castagne.FuseDataOverwrite(p, battleInitData["players"][pid+1].duplicate(true))
		
		var pState = {
			"PID": pid,
			"MainEntity": -1, # TODO need main entity
			"Opponent": (0 if pid==1 else 1),
		}
		var pData = {
			"PID": pid,
			"Name": "p"+str(pid+1),
			"PeerID": -1,
		}
		stateHandle.Memory().AddPlayer()
		for key in pState:
			stateHandle.Memory().PlayerSet(pid, key, pState[key], true)
		
		# :TODO:20230217:Panthavma: Maybe make a special AddPlayer callback ? 
		
		var engine = stateHandle.Engine()
		engine.instancedData["Players"].append(pData)
		engine.SetInputDevice(pid, p["inputdevice"])
		stateHandle.GlobalAdd("_NbPlayers", 1)
		
		_BattleInit_CreateEntities(stateHandle, p["entities"], pid)

func _BattleInit_CreateEntities(stateHandle, entities, playerID):
	var eBase = entities[0]
	for eid in range(entities.size()-1):
		var e = eBase.duplicate(true)
		Castagne.FuseDataOverwrite(e, entities[eid+1])
		
		var characterPath = e["scriptpath"]
		
		if(typeof(characterPath) == TYPE_INT):
			characterPath = Castagne.SplitStringToArray(stateHandle.ConfigData().Get("CharacterPaths"))[characterPath]
		
		characterPath = str(characterPath)
		if(!characterPath.ends_with(".casp")):
			ModuleError("Entity init: Player "+str(playerID)+" Entity "+str(eid)+" doesn't have a valid script path: " +characterPath)
		
		var fighterID = stateHandle.Engine().ParseFighterScript(characterPath)
		if(fighterID < 0):
			ModuleError("Fighter parsing failed for " + str(characterPath) + " !")
			return
		
		var newEID = stateHandle.Engine().AddNewEntity(stateHandle, playerID, fighterID)
		for key in e["overrides"]:
			stateHandle.Memory().EntitySet(newEID, key, e["overrides"][key], true)


func EditorCreateFlowWindow(editor, root):
	# If not overwritten, lock the custom panel
	var trueRoot = root.get_node("../..")
	var button = trueRoot.get_node("FlowAdvanced")
	
	button.set_pressed_no_signal(true)
	button.set_disabled(true)
	trueRoot.get_node("Generic").show()
	trueRoot.get_node("Custom").hide()

func EditorGetCurrentBattleInitData(editor, _root):
	return editor.configData.GetBaseBattleInitData()
