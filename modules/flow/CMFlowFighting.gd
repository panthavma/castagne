# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "CMFlow.gd"

func ModuleSetup():
	.ModuleSetup()
	RegisterModule("Flow Fighting", Castagne.MODULE_SLOTS_BASE.FLOW, {
		"Description":"Flow module for fighting games, handles match entry and exit, as well as mid-match events.\nThis offers better interfaces for regular fighting game matches.",
		"docname":"flowfighting",
		})
	
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Entity, "palette", 0, {"Description":"The color to use for the character."})
	
	RegisterConfig("AmountOfPlayers", 2, {"Description":"Number of players to handle."})
	RegisterConfig("CharactersPerPlayer", 1, {"Description":"Number of characters to spawn per player. Useful for team fighters."})
	
	RegisterConfig("StartingDistance", 20000, {"Description":"The starting distance between the two players."})

func GetBaseBattleInitData(configData):
	var bid = .GetBaseBattleInitData(configData)
	
	for pid in range(configData.Get("AmountOfPlayers")):
		var p = bid["players"][0].duplicate(true)
		var eBase = p["entities"][0]
		
		eBase["overrides"]["_PhysicsStartPosX"] = (-1 if pid == 0 else 1)*configData.Get("StartingDistance")
		eBase["overrides"]["TRAINING_ResetCornerDistance"] = configData.Get("ArenaSize")
		
		if(pid == 0):
			eBase["overrides"]["_ModelZOrder"] = 100
			# :TODO:20250320:Panthavma:Maybe not the best code, good hacky thing for now
		
		for _eid in range(configData.Get("CharactersPerPlayer")):
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

var localConfigPrefixBase = "LocalConfig-Editor-Flow-"
func _EditorCreateFlowWindow_Player(editor, pid):
	var playerRoot = VBoxContainer.new()
	var cdbn = localConfigPrefixBase+str(pid)+"-"
	
	var playerLabel = Label.new()
	playerLabel.set_text("---- Player " + str(pid+1) + " ----")
	playerLabel.set_align(Label.ALIGN_CENTER)
	playerRoot.add_child(playerLabel)
	
	var playerInputDevice = OptionButton.new()
	playerInputDevice.set_text_align(Button.ALIGN_CENTER)
	for deviceName in editor.configData.Input().GetDevicesList():
		var device = editor.configData.Input().GetDevice(deviceName)
		playerInputDevice.add_item("Input Device: " + device["DisplayName"])
	playerInputDevice.select(editor.configData.Get(cdbn+"inputdevice", pid+1+1))
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
	var cdbn = localConfigPrefixBase+str(pid)+"-"+str(eid)+"-"
	
	var title = Label.new()
	title.set_text("Character "+str(eid+1))
	title.set_align(Label.ALIGN_CENTER)
	characterRoot.add_child(title)
	
	var scriptPath = OptionButton.new()
	scriptPath.set_text_align(Button.ALIGN_CENTER)
	var characterIDNBDigits = str(_editorCharacterEditorData.size()).length()
	for c in _editorCharacterEditorData:
		var cid = str(c["ID"])
		var cName = c["Name"]
		while cid.length() < characterIDNBDigits:
			cid = "0"+cid
		scriptPath.add_item("["+str(cid)+"] " + str(cName))
	characterRoot.add_child(scriptPath)
	scriptPath.select(editor.configData.Get(cdbn+"scriptpath", 0))
	
	var paletteChoice = SpinBox.new()
	paletteChoice.set_prefix("Palette")
	paletteChoice.set_min(1)
	paletteChoice.set_value(editor.configData.Get(cdbn+"palette", 0)+1)
	paletteChoice.set_align(LineEdit.ALIGN_CENTER)
	characterRoot.add_child(paletteChoice)
	
	return characterRoot


func _EditorCreateFlowWindow_Global(editor, root):
	var cdbn = localConfigPrefixBase+"Global-"
	
	var stageChoice = OptionButton.new()
	stageChoice.set_text_align(Button.ALIGN_CENTER)
	var stages = Castagne.SplitStringToArray(editor.configData.Get("StagePaths"))
	for sid in range(stages.size()):
		var sPath = stages[sid]
		stageChoice.add_item("Stage "+str(sid)+": " + str(sPath))
	root.add_child(stageChoice)
	stageChoice.select(editor.configData.Get(cdbn+"map", 0))
	
	var musicChoice = OptionButton.new()
	musicChoice.set_text_align(Button.ALIGN_CENTER)
	musicChoice.add_item("[0] No Music")
	var i = 1
	for m in editor.configData.Get("MusicData"):
		musicChoice.add_item("["+str(i)+"] "+m["Name"])
		i += 1
	
	root.add_child(musicChoice)
	musicChoice.select(editor.configData.Get(cdbn+"music", 0))
	
	var mirrorMatch = CheckButton.new()
	mirrorMatch.set_text_align(Button.ALIGN_CENTER)
	mirrorMatch.set_text("Mirror Match")
	mirrorMatch.set_pressed_no_signal(editor.configData.Get(cdbn+"mirror", false))
	mirrorMatch.connect("toggled", self, "_EditorFlowWindow_MirrorMatchToggle", [root, editor.configData.Get("AmountOfPlayers")])
	_EditorFlowWindow_MirrorMatchToggle(mirrorMatch.is_pressed(), root, editor.configData.Get("AmountOfPlayers"))
	root.add_child(mirrorMatch)

func _EditorFlowWindow_MirrorMatchToggle(isMirrorMatch, root, nbPlayers):
	for pid in range(1, nbPlayers):
		var pRoot = root.get_child(pid*2)
		_EditorFlowWindow_MirrorMatchToggle_RecursiveDisable(pRoot, isMirrorMatch)
		pRoot.get_child(1).set_disabled(false)

func _EditorFlowWindow_MirrorMatchToggle_RecursiveDisable(node, isDisabled):
	if(node.has_method("set_disabled")):
		node.set_disabled(isDisabled)
	if(node.has_method("set_editable")):
		node.set_editable(!isDisabled)
	for c in node.get_children():
		_EditorFlowWindow_MirrorMatchToggle_RecursiveDisable(c, isDisabled)


func EditorGetCurrentBattleInitData(editor, root):
	var bid = .EditorGetCurrentBattleInitData(editor, root)
	var nbPlayers = editor.configData.Get("AmountOfPlayers")
	var cdbng = localConfigPrefixBase+"Global-"
	var globalStart = nbPlayers*2
	
	var isMirrorMatch = root.get_child(globalStart+2).is_pressed()
	editor.configData.Set(cdbng+"mirror", isMirrorMatch, true)
	
	var checkPalettes = true
	var usedPalettes = {}
	
	var configDataBaseName = localConfigPrefixBase
	
	for pid in range(nbPlayers):
		var p = bid["players"][pid+1]
		var pRoot = root.get_child(pid*2)
		var pRootNoMirror = pRoot
		if(isMirrorMatch):
			pRoot = root.get_child(0)
		var cdbn = configDataBaseName + str(pid) + "-"
		
		var inputDeviceID = pRootNoMirror.get_child(1).get_selected_id()
		editor.configData.Set(cdbn+"inputdevice", inputDeviceID, true)
		var inputDevice = editor.configData.Input().GetDevicesList()[inputDeviceID]
		p["inputdevice"] = inputDevice
		
		var rememberCdbn = cdbn

		for eid in range(editor.configData.Get("CharactersPerPlayer")):
			var e = p["entities"][eid+1]
			var eRoot = pRoot.get_child(pRoot.get_child_count()-1).get_child(eid*2)
			cdbn = rememberCdbn + str(eid) + "-"
			var scriptpathEditorID = eRoot.get_child(1).get_selected_id()
			var scriptpath = _editorCharacterEditorData[scriptpathEditorID]["ID"]
			
			var paletteID = eRoot.get_child(2).get_value()-1
			editor.configData.Set(cdbn+"scriptpath", scriptpathEditorID, true)
			editor.configData.Set(cdbn+"palette", paletteID, true)
			
			# Palette duplication check, can make it more generic
			if not scriptpath in usedPalettes:
				# Probably misses if using both IDs and paths but shouldn't happen here
				usedPalettes[scriptpath] = []
			if checkPalettes and paletteID in usedPalettes[scriptpath]:
				paletteID = 0
				while paletteID in usedPalettes[scriptpath]:
					paletteID += 1
				
			usedPalettes[scriptpath] += [paletteID]
			
			e["scriptpath"] = scriptpath
			e["overrides"] = {}
			e["overrides"]["_PaletteID"] = paletteID
	
	bid["map"] = root.get_child(globalStart).get_selected_id()
	bid["music"] = root.get_child(globalStart+1).get_selected_id()
	editor.configData.Set(cdbng+"map", bid["map"], true)
	editor.configData.Set(cdbng+"music", bid["music"], true)
	
	editor.configData.SaveConfigFile()
	
	return bid
