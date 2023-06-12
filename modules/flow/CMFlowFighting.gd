extends "CMFlow.gd"

func ModuleSetup():
	.ModuleSetup()
	RegisterModule("Flow Fighting", Castagne.MODULE_SLOTS_BASE.FLOW, {
		"Description":"Flow module for fighting games, handles match entry and exit, as well as mid-match events.\nThis offers better interfaces for regular fighting game matches.",
		"docname":"flowfighting",
		})
	#RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Core.casp", -9000)
	
	#RegisterConfig()
	
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Entity, "palette", 0, {"Description":"The color to use for the character."})
	
	RegisterConfig("AmountOfPlayers", 2, {"Description":"Number of players to handle."})
	RegisterConfig("CharactersPerPlayer", 1, {"Description":"Number of characters to spawn per player. Useful for team fighters."})
	
	RegisterConfig("StartingDistance", 20000, {"Description":"The starting distance between the two players."})

func GetBaseBattleInitData(configData):
	var bid = .GetBaseBattleInitData(configData)
	
	for pid in range(configData.Get("AmountOfPlayers")):
		#var p = {"entities":bid["players"][0]["entities"].duplicate(true)}
		var p = bid["players"][0].duplicate(true)
		var eBase = p["entities"][0]
		
		eBase["overrides"]["_PositionX"] = (-1 if pid == 0 else 1)*configData.Get("StartingDistance")
		
		for eid in range(configData.Get("CharactersPerPlayer")):
			var e = {}
			p["entities"] += [e]
		bid["players"] += [p]
	
	return bid

func ActionPhaseStartEntity(stateHandle):
	.ActionPhaseStartEntity(stateHandle)
	if(stateHandle.GlobalGet("_NbPlayers") == 2):
		var playerPID = stateHandle.EntityGet("_Player")
		var otherPID = (1 if playerPID == 0 else 0)
		var otherMainEntity = stateHandle.Memory().PlayerGet(otherPID, "MainEntity")
		stateHandle.SetTargetEntity(otherMainEntity)

func EditorCreateFlowWindow(editor, root):
	_EditorGetCharacterEditorData(editor.configData)
	for pid in range(editor.configData.Get("AmountOfPlayers")):
		var playerRoot = _EditorCreateFlowWindow_Player(editor, pid)
		root.add_child(playerRoot)
		root.add_child(HSeparator.new())
	_EditorCreateFlowWindow_Global(editor, root)

var _editorCharacterEditorData
func _EditorGetCharacterEditorData(configData):
	_editorCharacterEditorData = configData.GetEditorCharacterList(true)

func _EditorCreateFlowWindow_Player(editor, pid):
	var playerRoot = VBoxContainer.new()
	var cdbn = "LocalConfig-Editor-Flow-"+str(pid)+"-"
	
	var playerLabel = Label.new()
	playerLabel.set_text("---- Player " + str(pid+1) + " ----")
	playerLabel.set_align(Label.ALIGN_CENTER)
	playerRoot.add_child(playerLabel)
	
	var playerInputDevice = OptionButton.new()
	playerInputDevice.set_text_align(Button.ALIGN_CENTER)
	for deviceName in editor.configData.Input().GetDevicesList():
		var device = editor.configData.Input().GetDevice(deviceName)
		playerInputDevice.add_item("Input Device: " + device["DisplayName"])
	playerInputDevice.select(editor.configData.Get(cdbn+"inputdevice", pid+1))
	playerRoot.add_child(playerInputDevice)
	
	var characterList = HBoxContainer.new()
	characterList.set_name("List")
	playerRoot.add_child(characterList)
	for eid in range(editor.configData.Get("CharactersPerPlayer")):
		if(eid != 0):
			characterList.add_child(VSeparator.new())
		var characterRoot = _EditorCreateFlowWindow_Character(editor, pid, eid)
		characterList.add_child(characterRoot)
	
	return playerRoot


func _EditorCreateFlowWindow_Character(editor, pid, eid):
	var characterRoot = VBoxContainer.new()
	characterRoot.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	var cdbn = "LocalConfig-Editor-Flow-"+str(pid)+"-"+str(eid)+"-"
	
	var title = Label.new()
	title.set_text("Character "+str(eid+1))
	title.set_align(Label.ALIGN_CENTER)
	characterRoot.add_child(title)
	
	var scriptPath = OptionButton.new()
	scriptPath.set_text_align(Button.ALIGN_CENTER)
	for c in _editorCharacterEditorData:
		var cid = c["ID"]
		var cName = c["Name"]
		scriptPath.add_item("["+str(cid)+"] " + str(cName))
	characterRoot.add_child(scriptPath)
	scriptPath.select(editor.configData.Get(cdbn+"scriptpath", 0))
	
	var paletteChoice = SpinBox.new()
	paletteChoice.set_prefix("Palette")
	paletteChoice.set_value(1)
	paletteChoice.set_align(LineEdit.ALIGN_CENTER)
	characterRoot.add_child(paletteChoice)
	
	return characterRoot


func _EditorCreateFlowWindow_Global(editor, root):
	var stageChoice = OptionButton.new()
	stageChoice.set_text_align(Button.ALIGN_CENTER)
	var stages = Castagne.SplitStringToArray(editor.configData.Get("StagePaths"))
	for sid in range(stages.size()):
		var sPath = stages[sid]
		stageChoice.add_item("Stage "+str(sid)+": " + str(sPath))
	root.add_child(stageChoice)
	
	var musicChoice = OptionButton.new()
	musicChoice.set_text_align(Button.ALIGN_CENTER)
	musicChoice.add_item("No Music")
	root.add_child(musicChoice)
	


func EditorGetCurrentBattleInitData(editor, root):
	var bid = editor.configData.GetBaseBattleInitData()
	var nbPlayers = editor.configData.Get("AmountOfPlayers")
	
	var configDataBaseName = "LocalConfig-Editor-Flow-"
	
	for pid in range(nbPlayers):
		var p = bid["players"][pid+1]
		var pRoot = root.get_child(pid*2)
		var cdbn = configDataBaseName + str(pid) + "-"
		
		var inputDeviceID = pRoot.get_child(1).get_selected_id()
		editor.configData.Set(cdbn+"inputdevice", inputDeviceID, true)
		var inputDevice = editor.configData.Input().GetDevicesList()[inputDeviceID]
		p["inputdevice"] = inputDevice
		
		for eid in range(editor.configData.Get("CharactersPerPlayer")):
			var e = p["entities"][eid+1]
			var eRoot = pRoot.get_child(pRoot.get_child_count()-1).get_child(eid*2)
			cdbn += str(eid) + "-"
			e["scriptpath"] = eRoot.get_child(1).get_selected_id()
			editor.configData.Set(cdbn+"scriptpath", e["scriptpath"], true)
	
	var globalStart = nbPlayers*2
	bid["map"] = root.get_child(globalStart).get_selected_id()
	
	editor.configData.SaveConfigFile()
	
	return bid
