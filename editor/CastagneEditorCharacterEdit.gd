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
	
	ReloadEngine()
	
	ReloadCodePanel()
	
	$Popups.hide()
	

var engine = null
var inputProvider = null
func ReloadEngine():
	if(engine != null):
		engine.runAutomatically = false
		engine.renderGraphics = false
		engine.queue_free()
	
	var enginePrefab = load(Castagne.configData["Engine"])
	Castagne.battleInitData["p1"] = characterID
	Castagne.battleInitData["p1-palette"] = 0
	Castagne.battleInitData["p2"] = characterID
	Castagne.battleInitData["p2-palette"] = 1
	Castagne.battleInitData["p2-palette"] = 1
	
	RestartOptionsBID()
	
	engine = enginePrefab.instance()
	engine.runAutomatically = false
	engine.renderGraphics = false
	inputProvider = null
	
	$EngineVP/Viewport.add_child(engine)
	
	RestartOptions()
	
	FocusGame()

var character
var curFile
var curState
func ReloadCodePanel(resetStates = true):
	$CodePanel/Navigation.hide()
	
	character = Castagne.Parser.GetCharacterForEdition(characterPath)
	for i in range(character["NbFiles"]):
		character[i]["Modified"] = false
	if(resetStates):
		ChangeCodePanelState("Character", character["NbFiles"]-1)
	else:
		ChangeCodePanelState(null)

enum NAVPANEL_MODE {
	ChooseState, ChooseFile
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
	else:
		for stateName in character[curFile]["States"]:
			list.add_item(stateName)

func ChangeCodePanelState(newState, newFile = -1):
	if(newFile >= 0):
		curFile = newFile
	if(newState != null): 
		curState = newState
	
	var file = character[curFile]
	if(!file["States"].has(curState)):
		curState = "Character"
	var state = file["States"][curState]
	
	$CodePanel/Header/File.set_text(file["Path"])
	$CodePanel/Header/State.set_text(curState)
	$CodePanel/Code.set_text(state["Text"])

func ExitMenu():
	hide()
	$"..".EnterMenu()
	
	engine.queue_free()
	engine = null
	inputProvider = null


func _on_Back_pressed():
	ExitMenu()


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

func On_Header_State_Pressed():
	ShowHideNavPanel(NAVPANEL_MODE.ChooseState)
func _on_Header_File_pressed():
	ShowHideNavPanel(NAVPANEL_MODE.ChooseFile)

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
	else:
		ChangeCodePanelState($CodePanel/Navigation/ChooseState/MoveList.get_item_text(index))
	$CodePanel/Navigation.hide()


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


func _input(event):
	if(event is InputEventMouseButton and event.is_pressed()):
		if($Popups.is_visible() || $"../Documentation".is_visible()):
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


func _on_FuncdocButton_pressed():
	$"../Documentation".OpenDocumentation(documentationPath)
	UnfocusGame()


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
	engine.editorModule.runStop = false
	engine.editorModule.runSlowmo = 0
	engine.LocalStepNoInput()
	UpdateRunStatus()
func UpdateRunStatus():
	var slowmo = $BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowSlowmo.is_pressed()
	var run = $BottomPanel/BMiniPanel/HBox/Middle/TopBar/Flow/FlowPlay.is_pressed()
	engine.editorModule.runStop = !slowmo and !run
	engine.editorModule.runSlowmo = (3 if slowmo else 0)





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


