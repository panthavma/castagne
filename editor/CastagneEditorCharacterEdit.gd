extends Control

var characterPath = null
var characterID = null
onready var codeWindow = $CodePanel/Code
var documentationPath = null
func EnterMenu(cID):
	show()
	
	characterID = cID
	characterPath = Castagne.SplitStringToArray(Castagne.configData["CharacterPaths"])[cID]
	$TopBar/HBoxContainer/Label.set_text("Editing " + characterPath)
	
	$TopBar/HBoxContainer/Save.set_disabled(true)
	
	BigToolPanelSetVisible(false)
	for t in Castagne.SplitStringToArray(Castagne.configData["Editor-Tools"]):
		LoadTool(t)
	ShowTool(0)
	HideToolWindow()
	
	ReloadCodePanel()
	ReloadEngine()

func ExitMenu():
	hide()
	$"..".EnterMenu()
	
	if(engine != null):
		engine.queue_free()
	if(engineErrorScreen != null):
		engineErrorScreen.queue_free()
	engine = null
	engineErrorScreen = null
	inputProvider = null


func _on_Back_pressed():
	ExitMenu()












# --------------------------------------------------------------------------------------------------
# Engine

var engine = null
var engineErrorScreen = null
var inputProvider = null
func ReloadEngine():
	if(engine != null):
		engine.runAutomatically = false
		engine.renderGraphics = false
		engine.queue_free()
	if(engineErrorScreen != null):
		engineErrorScreen.queue_free()
		engineErrorScreen = null
	
	var enginePrefab = load(Castagne.configData["Engine"])
	Castagne.battleInitData["p1"] = characterID
	Castagne.battleInitData["p1-palette"] = 0
	Castagne.battleInitData["p2"] = characterID
	Castagne.battleInitData["p2-palette"] = 1
	
	RestartOptionsBID()
	
	engine = enginePrefab.instance()
	engine.runAutomatically = false
	engine.renderGraphics = false
	inputProvider = null
	
	for t in _tools:
		t["Tool"].OnEngineRestarting(engine, Castagne.battleInitData)
	
	$EngineVP/Viewport.add_child(engine)
	
	if(engine.initError):
		for t in _tools:
			t["Tool"].OnEngineInitError(engine)
		engineErrorScreen = engine._errorScreen
		engine = null
		UnfocusGame()
		return
	
	RestartOptions()
	
	FocusGame()
	
	for t in _tools:
		t["Tool"].OnEngineRestarted(engine)

func _input(event):
	if(event is InputEventMouseButton and event.is_pressed()):
		if($ToolsWindow.is_visible() || $"../Documentation".is_visible()):
			UnfocusGame()
		else:
			var vpRect = $EngineVP.get_global_rect()
			if(vpRect.has_point(event.position)):
				FocusGame()
			else:
				UnfocusGame()
func FocusGame():
	if(engine == null):
		return
	lockInput = false
	
	SetAllUIModulate(Color(0.5,0.5,0.5,1.0))
	var nodes = get_children()
	nodes.erase($Popups)
	while(!nodes.empty()):
		var n = nodes.pop_back()
		if(n.has_method("release_focus")):
			n.release_focus()
		nodes.append_array(n.get_children())
func UnfocusGame():
	if(engine == null):
		return
	lockInput = true
	
	SetAllUIModulate(Color(1.0,1.0,1.0,1.0))

func SetAllUIModulate(color):
	for n in get_children():
		if(n.get_name() == "EngineVP"):
			continue
		n.set_modulate(color)

var lockInput = null
func _process(_delta):
	if(lockInput != null):
		if(inputProvider == null):
			if(engine != null and engine.instancedData != null and engine.instancedData.has("Players")):
				inputProvider = engine.instancedData["Players"][0]["InputProvider"]
		if(inputProvider != null):
			inputProvider.lockInput = lockInput
			lockInput = null












# --------------------------------------------------------------------------------------------------
# Code Panel
var character
var curFile
var curState
func ReloadCodePanel(resetStates = true):
	$CodePanel/Navigation.hide()
	
	var originalNBFiles = 0
	if(character != null):
		originalNBFiles = character["NbFiles"]
	
	character = Castagne.Parser.GetCharacterForEdition(characterPath)
	if(character == null):
		return
	for i in range(character["NbFiles"]):
		character[i]["Modified"] = false
	
	if(originalNBFiles != character["NbFiles"]):
		resetStates = true
	
	if(resetStates):
		ChangeCodePanelState("Character", character["NbFiles"]-1)
	else:
		ChangeCodePanelState(null)



func _on_Reload_pressed():
	SaveFile()
	ReloadEngine()
	ReloadCodePanel(false)


func _on_Code_text_changed():
	$TopBar/HBoxContainer/Save.set_disabled(false)
	character[curFile]["States"][curState]["Text"] = $CodePanel/Code.get_text()
	character[curFile]["Modified"] = true
	CompileGizmos()
	UpdateGizmos()


func ChangeCodePanelState(newState, newFile = -1, newLine = 1):
	if(newFile >= 0):
		curFile = newFile
	if(newState != null): 
		curState = newState
	
	if(character["NbFiles"] <= 0):
		$CodePanel/Header/File.set_text("Invalid File")
		$CodePanel/Header/State.set_text("Invalid State")
		$CodePanel/Header/CalledScripts.set_text("0 Called Scripts")
		$CodePanel/Code.set_text("Error")
		return
	
	if(curFile >= character["NbFiles"]):
		curFile = character["NbFiles"]-1;
	
	var file = character[curFile]
	if(!file["States"].has(curState)):
		curState = "Character"
	var state = file["States"][curState]
	
	$CodePanel/Header/File.set_text(file["Path"])
	$CodePanel/Header/State.set_text(curState)
	$CodePanel/Header/CalledScripts.set_text(str(BuildCalledStatesList(state).size())+" Called Scripts")
	var code = $CodePanel/Code
	code.set_text(state["Text"])
	code.cursor_set_line(newLine-1)
	code.cursor_set_column(0)


func _on_FuncdocButton_pressed():
	$"../Documentation".OpenDocumentation(documentationPath)
	UnfocusGame()



func _on_Save_pressed():
	SaveFile()
func SaveFile():
	$TopBar/HBoxContainer/Save.set_disabled(true)
	for i in range(character["NbFiles"]):
		var fileData = character[i]
		if(!fileData["Modified"]):
			continue
		fileData["Modified"] = false
		var filePath = fileData["Path"]
		print("Editor: Saving to " + filePath)
		
		var statesToSave = fileData["States"].keys()
		if(!statesToSave.has("Character")):
			fileData["States"]["Character"] = {"Text":"\n"}
		if(!statesToSave.has("Variables")):
			fileData["States"]["Variables"] = {"Text":"\n\n"}
		statesToSave.erase("Character")
		statesToSave.erase("Variables")
		
		for s in statesToSave:
			var stext = fileData["States"][s]["Text"].strip_edges()
			if(stext.empty()):
				statesToSave.erase(s)
		
		statesToSave.push_front("Variables")
		statesToSave.push_front("Character")
		
		var fulltext = ""
		for s in statesToSave:
			fulltext += ":" + s + ":\n"
			fulltext += fileData["States"][s]["Text"] + "\n"
		
		var file = File.new()
		file.open(fileData["Path"], File.WRITE)
		file.store_string(fulltext)
		file.close()







# --------------------------------------------------------------------------------------------------
# Navigation Panel
enum NAVPANEL_MODE {
	ChooseState, ChooseFile, CalledStates
}
var navpanelMode = null
func RefreshNavigationPanel(mode):
	navpanelMode = mode
	var modesRoot = $CodePanel/Navigation.get_children()
	modesRoot.pop_front()
	for r in modesRoot:
		r.hide()
	var root = modesRoot[mode]
	root.show()
	var list = root.get_node("MoveList")
	
	list.clear()
	
	if(mode == NAVPANEL_MODE.ChooseFile):
		for i in range(character["NbFiles"]):
			list.add_item(character[i]["Path"])
	elif(mode == NAVPANEL_MODE.CalledStates):
		var state = character[curFile]["States"][curState]
		var calledStates = BuildCalledStatesList(state)
		for cs in calledStates:
			var stateName = cs[0]
			if(cs[1] != curFile):
				var filePath = character[cs[1]]["Path"]
				filePath = filePath.right(filePath.find_last("/")+1)
				stateName = filePath + " - " + stateName
			list.add_item(stateName)
	else:
		var statesPerTag = {}
		var states = character[curFile]["States"]
		for stateName in states:
			if(stateName in ["Character", "Variables"]):
				continue
			var state = states[stateName]
			if(statesPerTag.has(state["Tag"])):
				statesPerTag[state["Tag"]] += [state]
			else:
				statesPerTag[state["Tag"]] = [state]
		
		list.add_item("Character")
		list.add_item("Variables")
		
		var tagList = statesPerTag.keys()
		tagList.sort()
		
		for tag in tagList:
			var tagName = ("Untagged" if tag == null else tag)
			list.add_item("  ", null, false)
			list.add_item("--- "+tagName+" ---", null, false)
			for state in statesPerTag[tag]:
				list.add_item(state["Name"])

func BuildCalledStatesList(state):
	var list = []
	var calledStates = state["CalledStates"]
	
	for cs in calledStates:
		var fileID = curFile - cs[1]
		var stateName = cs[0]
		while fileID >= 0:
			if(character[fileID]["States"].has(stateName)):
				list += [[cs[0], fileID]]
				fileID = -1
			fileID -= 1
	
	return list



func On_Header_State_Pressed():
	ShowHideNavPanel(NAVPANEL_MODE.ChooseState)
func _on_Header_File_pressed():
	ShowHideNavPanel(NAVPANEL_MODE.ChooseFile)
func _on_Header_CheckParent_pressed():
	ShowHideNavPanel(NAVPANEL_MODE.CalledStates)

func ShowHideNavPanel(mode):
	var n = $CodePanel/Navigation
	if(n.is_visible() and navpanelMode == mode):
		n.hide()
	else:
		RefreshNavigationPanel(mode)
		n.show()

func _on_Navigation_MoveList_item_activated(index):
	if(navpanelMode == NAVPANEL_MODE.ChooseFile):
		ChangeCodePanelState(null, index)
	elif(navpanelMode == NAVPANEL_MODE.CalledStates):
		var calledStates = BuildCalledStatesList(character[curFile]["States"][curState])
		var cs = calledStates[index]
		ChangeCodePanelState(cs[0], cs[1])
	else:
		ChangeCodePanelState($CodePanel/Navigation/ChooseState/MoveList.get_item_text(index))
	$CodePanel/Navigation.hide()




func _on_NewState_pressed():
	var stateName = $CodePanel/Navigation/ChooseState/Bottom/NewStateName.get_text().strip_edges()
	$CodePanel/Navigation/ChooseState/Bottom/NewStateName.set_text("")
	if(stateName.empty()):
		return
	
	if(!character[curFile]["States"].has(stateName)):
		character[curFile]["States"][stateName] = {}
		character[curFile]["States"][stateName]["Text"] = ""
	
	$CodePanel/Navigation.hide()
	ChangeCodePanelState(stateName)














# --------------------------------------------------------------------------------------------------
# Gizmos
func _on_Code_cursor_changed():
	UpdateGizmos()
	UpdateDocumentation()

func CompileGizmos():
	# Temporary, but good enough for now
	var currentGizmos = []
	for i in range(codeWindow.get_line_count()):
		var line = codeWindow.get_line(i).strip_edges()
		if(line.empty() || line.begins_with("#") || !Castagne.Parser._IsLineFunction(line)):
			continue
		var funcParsed = Castagne.Parser._ExtractFunction(line)
		var funcName = funcParsed[0]
		var funcArgs = funcParsed[1]
		if(!Castagne.functions.has(funcName)):
			continue
		var f = Castagne.functions[funcName]
		var gizmoFunc = f["GizmoFunc"]
		if(gizmoFunc == null):
			continue
		var gizmo = {"Line":i, "Func":gizmoFunc, "Args":funcArgs}
		currentGizmos += [gizmo]
	if(engine != null and engine.editorModule != null):
		engine.editorModule.currentGizmos = currentGizmos

func UpdateGizmos():
	CompileGizmos()
	var curLine = codeWindow.cursor_get_line()
	if(engine != null and engine.editorModule != null):
		engine.editorModule.currentLine = curLine

func UpdateDocumentation():
	documentationPath = null
	$CodePanel/Documentation/Title.set_text("")
	$CodePanel/Documentation/Doc.set_text("")
	
	var lineID = codeWindow.cursor_get_line()
	var line = codeWindow.get_line(lineID)
	line = line.strip_edges()
	if(line.empty() || line.begins_with("#") || !Castagne.Parser._IsLineFunction(line)):
		return
	
	var funcName = Castagne.Parser._ExtractFunction(line)[0]
	
	if(!Castagne.functions.has(funcName)):
		return
	
	var f = Castagne.functions[funcName]
	var fDoc = f["Documentation"]
	
	var fSignature = fDoc["Name"] + "("
	var i = 0
	for a in fDoc["Arguments"]:
		fSignature += (", " if i > 0 else "") + a
		i += 1
	fSignature += ")"
	var fDescription = fDoc["Description"]
	
	$CodePanel/Documentation/Title.set_text(fSignature)
	$CodePanel/Documentation/Doc.set_text(fDescription)














# --------------------------------------------------------------------------------------------------
# Flow
func _on_FlowPlay_toggled(button_pressed):
	if(button_pressed):
		$BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowSlowmo.set_pressed_no_signal(false)
	UpdateRunStatus()
func _on_FlowSlowmo_toggled(button_pressed):
	if(button_pressed):
		$BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowPlay.set_pressed_no_signal(false)
	UpdateRunStatus()
func _on_FlowNextFrame_pressed():
	$BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowSlowmo.set_pressed_no_signal(false)
	$BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowPlay.set_pressed_no_signal(false)
	if(engine == null):
		return
	engine.editorModule.runStop = false
	engine.editorModule.runSlowmo = 0
	engine.LocalStepNoInput()
	UpdateRunStatus()
func UpdateRunStatus():
	if(engine == null):
		return
	var slowmo = $BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowSlowmo.is_pressed()
	var run = $BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowPlay.is_pressed()
	engine.editorModule.runStop = !slowmo and !run
	if(!engine.editorModule.runStop):
		FocusGame()
	engine.editorModule.runSlowmo = (3 if slowmo else 0)

















# --------------------------------------------------------------------------------------------------
# Restart Options
enum RESTART_RESET {
	Normal, Air, Corner, RCorner
}
var restartResetMode = RESTART_RESET.Normal
var restartState = null
var restartStateFrames = 0
var restartBIDMode = "training"
func RestartOptionsBID():
	pass
func RestartOptions():
	engine.editorModule.runStop = false
	engine.editorModule.runSlowmo = 0
	engine.LocalStepNoInput()
	engine.LocalStepNoInput()
	var mainEID = engine._gameState["Players"][0]["MainEntity"]
	
	if(restartResetMode != RESTART_RESET.Normal):
		var opponentEID = engine._gameState["Players"][1]["MainEntity"]
		
		if(restartResetMode == RESTART_RESET.Air):
			engine._gameState[mainEID]["PositionY"] = 35000
		if(restartResetMode == RESTART_RESET.Corner):
			engine._gameState[mainEID]["PositionX"] = Castagne.configData["ArenaSize"] - 30000
			engine._gameState[opponentEID]["PositionX"] = Castagne.configData["ArenaSize"]
			engine._gameState["CameraX"] = Castagne.configData["ArenaSize"]
		if(restartResetMode == RESTART_RESET.RCorner):
			engine._gameState[mainEID]["PositionX"] = -Castagne.configData["ArenaSize"] 
			engine._gameState[opponentEID]["PositionX"] = -Castagne.configData["ArenaSize"] + 30000
			engine._gameState["CameraX"] = -Castagne.configData["ArenaSize"]
	
	if(restartState != null):
		var fs = engine.GetCurrentFighterScriptOfEntity(mainEID, engine._gameState)
		if(fs == null or restartState == "Character" or restartState == "Variables"):
			restartState = null
	
	if(restartState != null):
		engine._gameState[mainEID]["State"] = restartState
		engine._gameState[mainEID]["StateStartFrame"] = engine._gameState["FrameID"]
		for i in range(restartStateFrames-1):
			if(restartResetMode == RESTART_RESET.Air):
				engine._gameState[mainEID]["PositionY"] = 35000
			engine.LocalStepNoInput()
	else:
		engine.LocalStepNoInput()
	
	engine.LocalStepNoInput()
	engine.renderGraphics = true
	engine.runAutomatically = true
	UpdateRunStatus()




func _on_ResetAir_pressed():
	restartResetMode = RESTART_RESET.Air
	restartState = null
	ReloadEngine()
func _on_ResetGround_pressed():
	restartResetMode = RESTART_RESET.Normal
	restartState = null
	ReloadEngine()
func _on_ResetCorner_pressed():
	restartResetMode = RESTART_RESET.Corner
	restartState = null
	ReloadEngine()
func _on_ResetCornerReverse_pressed():
	restartResetMode = RESTART_RESET.RCorner
	restartState = null
	ReloadEngine()


func _on_ResetExecuteMove_pressed():
	restartState = $BottomPanel/BMiniPanel/HBox/Match/ExecuteMoveData/MoveToExec.get_text()
	restartStateFrames = $BottomPanel/BMiniPanel/HBox/Match/ExecuteMoveData/Frame.get_value()
	if(restartState.empty()):
		restartState = curState
	ReloadEngine()
func _on_ResetMatchTraining_pressed():
	restartBIDMode = "training"
	restartResetMode = RESTART_RESET.Normal
	restartState = null
	ReloadEngine()
func _on_ResetMatchNormal_pressed():
	restartBIDMode = "battle"
	restartResetMode = RESTART_RESET.Normal
	restartState = null
	ReloadEngine()














# --------------------------------------------------------------------------------------------------
# Tools
var bigToolPanelVisible = false
func BigToolPanelSetVisible(v):
	bigToolPanelVisible = v
	var bigToolPanel = $BottomPanel/BBigPanel
	if(v):
		bigToolPanel.set_anchor_and_margin(MARGIN_TOP, -0.8, 32)
		bigToolPanel.set_anchor_and_margin(MARGIN_BOTTOM, 0, 0)
		$BottomPanel/BMiniPanel/HBox/Reload/BigToolExpand.set_text("vv")
	else:
		bigToolPanel.set_anchor_and_margin(MARGIN_TOP, 0.2, 0)
		bigToolPanel.set_anchor_and_margin(MARGIN_BOTTOM, 1.0, 32)
		$BottomPanel/BMiniPanel/HBox/Reload/BigToolExpand.set_text("^^")
		



func _on_BigToolExpand_pressed():
	BigToolPanelSetVisible(!bigToolPanelVisible)

onready var bigToolRoot = $BottomPanel/BBigPanel/BigTool
onready var smallToolRoot = $BottomPanel/BMiniPanel/HBox/Middle/MiniTool
var _tools = []
var _currentTool = 0
func LoadTool(path):
	var packedScene = Castagne.Loader.Load(path)
	var t = packedScene.instance()
	var eV = Control.new()
	var sV = Control.new()
	
	t.editor = self
	t.toolFocused = false
	t.SetupTool()
	
	eV.set_anchors_preset(Control.PRESET_WIDE)
	sV.set_anchors_preset(Control.PRESET_WIDE)
	
	bigToolRoot.add_child(eV)
	smallToolRoot.add_child(sV)
	
	t.AddTool(sV, eV)
	
	eV.hide()
	sV.hide()
	
	var toolData = {
		"Path":path,
		"SmallView":sV,
		"ExpandedView":eV,
		"Tool":t,
	}
	_tools += [toolData]
func UnloadTools():
	for t in _tools:
		t["SmallView"].queue_free()
		t["ExpandedView"].queue_free()
	_tools = []
func ShowTool(toolID):
	if(toolID < 0 or toolID >= _tools.size()):
		Castagne.Error("Editor: Show a tool outside of what's possible! " + str(toolID))
	var i = 0
	for t in _tools:
		if(i == toolID):
			t["ExpandedView"].show()
			t["SmallView"].show()
			t["Tool"].toolFocused = true
		else:
			t["ExpandedView"].hide()
			t["SmallView"].hide()
			t["Tool"].toolFocused = false
		i += 1
	_currentTool = toolID




func ShowToolWindow():
	var itemList = $ToolsWindow/Window/ToolList
	itemList.clear()
	
	for t in _tools:
		itemList.add_item(t["Tool"].toolName)
		if(t["Tool"].toolFocused):
			itemList.select(itemList.get_item_count() - 1)
	UpdateToolWindow()
	
	UnfocusGame()
	$ToolsWindow.show()
func HideToolWindow():
	$ToolsWindow.hide()
func _on_ToolCancel_pressed():
	HideToolWindow()


func _on_ToolSelect_pressed():
	var itemList = $ToolsWindow/Window/ToolList
	if(itemList.get_selected_items().size() == 0):
		return
	var toolID = itemList.get_selected_items()[0]
	ShowTool(toolID)
	HideToolWindow()


func _on_ToolDocumentation_pressed():
	var itemList = $ToolsWindow/Window/ToolList
	var docPage = "/Editor"
	if(itemList.get_selected_items().size() > 0):
		var toolID = itemList.get_selected_items()[0]
		docPage = _tools[toolID]["Tool"].toolDocumentationPage
	$"../Documentation".OpenDocumentation(docPage)
	UnfocusGame()

func UpdateToolWindow():
	var itemList = $ToolsWindow/Window/ToolList
	
	var toolTitle = ""
	var toolDescription = ""
	var canSelect = false
	
	if(itemList.get_selected_items().size() > 0):
		var t = _tools[itemList.get_selected_items()[0]]["Tool"]
		toolTitle = t.toolName
		toolDescription = t.toolDescription
		canSelect = true
	$ToolsWindow/Window/Info/Title.set_text(toolTitle)
	$ToolsWindow/Window/Info/Description.set_text(toolDescription)
	$ToolsWindow/Window/Info/ToolSelect.disabled = !canSelect
	$ToolsWindow/Window/Info/ToolDocumentation.disabled = !canSelect

func _on_ChangeTool_pressed():
	ShowToolWindow()


func _on_ToolList_item_selected(_index):
	UpdateToolWindow()


func _on_ToolList_nothing_selected():
	UpdateToolWindow()


func _on_ToolList_item_activated(_index):
	_on_ToolSelect_pressed()


