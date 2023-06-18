extends Control

var editor
var functions
var characterPath = null
onready var codeWindow = $CodePanel/Code
var documentationPath = null
var _initDone = false
var safeMode = false
var _baseBID = null

func EnterMenu(bid):
	show()
	_initDone = true
	
	# TEMP TODO kinda jank but hey, make it correct a bit later with v0.9 or something
	var entityData = bid["players"][1]["entities"][0].duplicate(true)
	Castagne.FuseDataOverwrite(entityData, bid["players"][1]["entities"][1].duplicate(true))
	characterPath = entityData["scriptpath"]
	
	_baseBID = bid
	
	if(typeof(characterPath) == TYPE_INT):
		characterPath = Castagne.SplitStringToArray(editor.configData.Get("CharacterPaths"))[characterPath]
	#characterID = cID
	#characterPath = Castagne.SplitStringToArray(editor.configData.Get("CharacterPaths"))[cID]
	$TopBar/HBoxContainer/Label.set_text("Editing " + characterPath)
	
	$TopBar/HBoxContainer/Save.set_disabled(true)
	
	BigToolPanelSetVisible(false)
	for t in Castagne.SplitStringToArray(editor.configData.Get("Editor-Tools")):
		LoadTool(t)
	ShowTool(0)
	HideToolWindow()
	
	$TopBar/HBoxContainer/TutorialWindow.set_visible(editor.tutorialPath != null)
	
	ReloadCodePanel()
	ReloadEngine()
	
	$Popups.hide()

func ExitMenu():
	hide()
	$"..".EnterMenu()
	
	UnloadTools()
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
var editorModule = null
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
	
	HidePopups()
	
	if(safeMode):
		return
	
	var bid = _baseBID.duplicate(true)
	RestartOptionsBID()
	
	# TODO Get restart options back in
	
	
	#engine = enginePrefab.instance()
	engine = Castagne.InstanceCastagneEngine(bid, editor.configData)
	engine.runAutomatically = false
	engine.renderGraphics = false
	inputProvider = null
	editorModule = engine.configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.EDITOR)
	
	editorModule.connect("EngineTick_AIStartEntity", self, "EngineTick_AIStartEntity")
	editorModule.connect("EngineTick_ActionStartEntity", self, "EngineTick_ActionStartEntity")
	
	for t in _tools:
		t["Tool"].OnEngineRestarting(engine, bid)
	
	$EngineVP/EngineVPC/Viewport.add_child(engine)
	
	if(engine.initError):
		for t in _tools:
			t["Tool"].OnEngineInitError(engine)
		engineErrorScreen = engine._errorScreen
		engine = null
		editorModule = null
		UnfocusGame()
		return
	
	RestartOptions()
	
	
	FocusGame()
	
	for t in _tools:
		t["Tool"].OnEngineRestarted(engine)

func _input(event):
	if(event is InputEventMouseButton and event.is_pressed()):
		if($ToolsWindow.is_visible() || $Popups.is_visible() || $"../Documentation".is_visible()):
			UnfocusGame()
		else:
			var vpRect = $EngineVP/FocusEngine.get_global_rect()
			if(vpRect.has_point(event.position)):
				#FocusGame()
				pass
			else:
				UnfocusGame()
func FocusGame():
	if(engine == null):
		return
	lockInput = false
	
	SetAllUIModulate(Color(0.5,0.5,0.5,1.0))
	var nodes = get_children()
	HidePopups()
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
func EngineTick_AIStartEntity(stateHandle):
	if(lockInput):
		var inputs = stateHandle.EntityGet("_Inputs")
		for giName in inputs:
			inputs[giName] = false
		stateHandle.EntitySet("_Inputs", inputs)


func EngineTick_ActionStartEntity(stateHandle):
	if(get_node("BottomPanel/BMiniPanel/HBox/Middle/TopBar/Other/Blocking").pressed):
		stateHandle.EntitySetFlag("AutoBlocking")
	if(get_node("BottomPanel/BMiniPanel/HBox/Middle/TopBar/Other/BlockingLow").pressed):
		stateHandle.EntitySetFlag("AutoBlockingLow")
	if(get_node("BottomPanel/BMiniPanel/HBox/Middle/TopBar/Other/BlockingOverhead").pressed):
		stateHandle.EntitySetFlag("AutoBlockingOverhead")
		
		

var _popupFunction = null
func ShowPopup(popupName):
	$Popups.show()
	_popupFunction = null
	UnfocusGame()
	for c in $Popups/Window.get_children():
		c.hide()
	var popup = $Popups/Window.get_node(popupName)
	if(popup.has_method("InitPopup")):
		popup.InitPopup()
	popup.show()
	return popup
func HidePopups():
	$Popups.hide()
	if(_popupFunction != null):
		_popupFunction.call_func()

# Needs a function of form name(confirmed = false)
func ShowConfirmPopup(associatedFunction, text, title = ""):
	var popup = ShowPopup("Confirm")
	_popupFunction = associatedFunction
	popup.get_node("Text").set_text(text)
	popup.get_node("Title").set_text(title)

func _on_ConfirmYes_pressed():
	if(_popupFunction != null):
		_popupFunction.call_func(true)







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
	
	character = Castagne.Parser.GetCharacterForEdition(characterPath, editor.configData)
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
	UpdateGizmos()


func ChangeCodePanelState(newState = null, newFile = -1, newLine = 1):
	var changedState = false
	if(newFile >= 0):
		curFile = newFile
		changedState = true
	if(newState != null): 
		curState = newState
		changedState = true
	
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
	var isVariablesBlock = curState.begins_with("Variables")
	var calledStatesList = BuildCalledStatesList(state)
	
	var filePath = file["Path"]
	var lockedFile = IsFileLocked(filePath)
	var lockedCode = lockedFile
	
	if(editor.configData.Get("Editor-OnlyAllowCustomEditors")):
		lockedCode = true
	
	var editorVariables = state["Variables"]
	var editorInheritedVariables = []
	var useCustomEditor = false
	if($CodePanel/UseCustomEditor.is_pressed()):
		if(isVariablesBlock):
			for pfid in range(curFile-1, -1, -1):
				if(character[pfid]["States"].has(curState)):
					var fName = character[pfid]["Path"]
					var sep = fName.find_last("/")
					if(sep >= 0):
						fName = fName.right(sep+1)
					editorInheritedVariables += [{
						"Name":fName, "Variables":character[pfid]["States"][curState]["Variables"].duplicate()
					}]
		else:
			for csd in calledStatesList:
				if(character[csd[1]]["States"].has(csd[0])):
					var calledState = character[csd[1]]["States"][csd[0]]
					if(!calledState["Variables"].empty()):
						editorInheritedVariables += [{
							"Name":csd[0], "Variables":calledState["Variables"].duplicate()
						}]
		
		if(!editorVariables.empty()):
			useCustomEditor = true
		if(!editorInheritedVariables.empty()):
			useCustomEditor = true
	
	if(!lockedFile and useCustomEditor):
		lockedCode = true
		var customEditorRoot = $CodePanel/CustomEditor/PanelContainer/List
		for c in customEditorRoot.get_children():
			c.queue_free()
		
		_CreateCustomEditorPanel(customEditorRoot, editorVariables, (curState if isVariablesBlock else "State Defines"))
		
		for eiv in editorInheritedVariables:
			_CreateCustomEditorPanel(customEditorRoot, eiv["Variables"], eiv["Name"], editorVariables)
	$CodePanel/CustomEditor.set_visible(useCustomEditor)
	
	
	$CodePanel/Header/File.set_text(filePath + (" [LOCKED]" if lockedFile else ""))
	$CodePanel/Header/State.set_text(curState)
	$CodePanel/Header/CalledScripts.set_text(str(calledStatesList.size())+" Called Scripts")
	var code = $CodePanel/Code
	code.set_text(state["Text"])
	code.cursor_set_line(newLine-1)
	code.cursor_set_column(0)
	code.set_readonly(lockedCode)
	if(changedState):
		code.clear_undo_history()
	
	$CodePanel/Warnings.set_pressed_no_signal(false)
	$CodePanel/WarningsList.hide()
	for w in $CodePanel/WarningsList/List.get_children():
		w.queue_free()
	if(state["Warnings"].empty()):
		$CodePanel/Warnings.set_text("No code warnings")
		$CodePanel/Warnings.set_disabled(true)
	else:
		for w in state["Warnings"]:
			var wn = _prefabCodeWarning.instance()
			wn.get_node("Text").set_text(str(w))
			$CodePanel/WarningsList/List.add_child(wn)
		$CodePanel/Warnings.set_text(str(state["Warnings"].size())+" code warnings")
		$CodePanel/Warnings.set_disabled(false)
var _prefabCodeWarning = preload("res://castagne/editor/CharacterEditor/CECCodeWarning.tscn")

func _CreateCustomEditorPanel(customEditorRoot, variables, partName, stateVariables = null):
	var isCurrentState = (stateVariables == null)
	
	# Create label heading
	if(partName != null):
		var l = Label.new()
		l.set_align(Label.ALIGN_CENTER)
		l.set_valign(Label.VALIGN_BOTTOM)
		l.set_text(str(partName))
		customEditorRoot.add_child(l)
		customEditorRoot.add_child(HSeparator.new())
		if(!isCurrentState):
			l.set_custom_minimum_size(Vector2(64, 48))
	
	# Create main variables
	for vName in variables:
		if(stateVariables != null and vName in stateVariables):
			continue
		
		var v = variables[vName]
		var vType = v["Type"]
		
		var l = Label.new()
		l.set_text(vName)
		l.set_h_size_flags(SIZE_EXPAND_FILL)
		l.set_custom_minimum_size(Vector2(64,32))
		l.set_valign(Label.VALIGN_CENTER)
		
		var e
		if(!isCurrentState):
			e = Button.new()
			e.set_text(str(v["Value"]) + " [Override]")
			e.connect("pressed", self, "_CustomEditorOverride", [v])
		elif(vType == Castagne.VARIABLE_TYPE.Int):
			e = SpinBox.new()
			e.set_allow_greater(true)
			e.set_allow_lesser(true)
			e.set_value(v["Value"])
			e.connect("value_changed", self, "_CustomEditorSetValue", [vName])
		elif(vType == Castagne.VARIABLE_TYPE.Str):
			e = LineEdit.new()
			e.set_text(v["Value"])
			e.connect("text_changed", self, "_CustomEditorSetValue", [vName])
		elif(vType == Castagne.VARIABLE_TYPE.Bool):
			e = CheckBox.new()
			e.set_pressed_no_signal(int(v["Value"]) > 0)
			e.connect("toggled", self, "_CustomEditorSetValue", [vName])
		else: # Not supported type
			e = Label.new()
			e.set_text("[Type Not Supported]")
			e.set_align(Label.ALIGN_RIGHT)
		
		e.set_h_size_flags(SIZE_EXPAND_FILL)
		var hbc = HBoxContainer.new()
		hbc.add_child(l)
		hbc.add_child(e)
		customEditorRoot.add_child(hbc)

func _CustomEditorSetValue(value, varName):
	var file = character[curFile]
	var state = file["States"][curState]
	var v = state["Variables"][varName]
	var type = v["Type"]
	if(type == Castagne.VARIABLE_TYPE.Bool):
		value = (1 if value else 0)
	v["Value"] = value
	
	var lines = state["Text"].split("\n")
	var text = ""
	for l in lines:
		var lStrip = l.strip_edges()
		if(Castagne.Parser._IsLineVariable(lStrip)):
			var lv = Castagne.Parser._ExtractVariable(lStrip)
			if(lv["Name"] == v["Name"]):
				var sep = l.find("=")
				if(sep >= 0):
					l = l.left(sep)
				l += "= " + str(v["Value"]) + "\n"
		text += l + "\n"
	state["Text"] = text
	file["Modified"] = true

func _CustomEditorOverride(vData):
	var file = character[curFile]
	var state = file["States"][curState]
	
	var vLine = "def " + vData["Name"]
	
	for vt in Castagne.Parser.KnownVariableTypes:
		if(vData["Type"] == Castagne.Parser.KnownVariableTypes[vt]):
			vLine += " " + vt + "()"
			break
	
	vLine += " = " + str(vData["Value"]) + "\n"
	
	state["Text"] = vLine + state["Text"]
	file["Modified"] = true
	SaveFile()
	ReloadCodePanel(false)


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
		if(IsFileLocked(filePath)):
			continue
		
		print("Editor: Saving to " + filePath)
		
		var statesToSave = fileData["States"].keys()
		statesToSave.sort()
		
		if(!statesToSave.has("Character")):
			fileData["States"]["Character"] = {"Text":"\n"}
		statesToSave.erase("Character")
		
		var variablesBlocksList = []
		for sName in statesToSave:
			if(sName.begins_with("Variables")):
				variablesBlocksList += [sName]
		for sName in variablesBlocksList:
			statesToSave.erase(sName)
			statesToSave.push_front(sName)
		
		statesToSave.push_front("Character")
		
		# Remove Trailing Whitespace
		for s in statesToSave:
			if(fileData["States"][s]["Text"] == null):
				fileData["States"][s]["Text"] = ""
			var stext = fileData["States"][s]["Text"].strip_edges()
			fileData["States"][s]["Text"] = stext
		
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
func IsFileLocked(fileName):
	if(fileName.begins_with("res://castagne/") and editor.configData.Get("Editor-LockCastagneFiles")):
		return true
	var skeletons = Castagne.SplitStringToArray(editor.configData.Get("Skeletons"))
	if(!skeletons.empty() and fileName in skeletons and editor.configData.Get("Editor-LockBaseSkeleton")):
		return true
	return false

var navpanelMode = null
onready var prefabNavPanelCategory = preload("res://castagne/editor/CharacterEditor/CECNavigationCategory.tscn")
onready var prefabNavPanelState = preload("res://castagne/editor/CharacterEditor/CECNavigationState.tscn")
var _navigationSelected = null
var categoriesStatus = {}
var categoriesStatusDefault = true
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
			var path = character[i]["Path"]
			list.add_item(path + (" [LOCKED]" if IsFileLocked(path) else ""))
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
		_navigationSelected = null
		var stateListRoot = $CodePanel/Navigation/ChooseState/StateList/Scroll/List
		for c in stateListRoot.get_children():
			c.queue_free()
		
		var stateChar = prefabNavPanelState.instance()
		stateChar.charEditor = self
		stateChar.InitFromState(character[curFile]["States"]["Character"])
		stateListRoot.add_child(stateChar)
		
		# Get Flags and clean panel
		var flagsPanel = $CodePanel/Navigation/ChooseState/Menu/Flags
		var activeFlags = []
		for f in flagsPanel.get_children():
			if(f.is_pressed()):
				activeFlags += [f.get_tooltip()]
			f.queue_free()
		
		# Gather all categories at first
		var categoriesRaw = {}
		var showAllStates = $CodePanel/Navigation/ChooseState/Menu/ToggleAllStates.is_pressed()
		var showVariables = $CodePanel/Navigation/ChooseState/Menu/ToggleShowVariables.is_pressed()
		var showOverridableStates = $CodePanel/Navigation/ChooseState/Menu/ToggleOverridableStates.is_pressed()
		var checkFromPreviousFiles = (showAllStates or showVariables or showOverridableStates)
		var statesFound = []
		var flagsFound = []
		
		if($CodePanel/Navigation/ChooseState/Menu/ToggleShowAllFlags.is_pressed()):
			flagsFound = editor.configData.GetModuleStateFlags()
		var nbStatesTotal = 0
		var nbStatesChosen = 0
		for fileID in range(curFile, -1, -1):
			var states = character[fileID]["States"]
			for stateName in states:
				if(stateName in ["Character"] or stateName in statesFound):
					continue
				var state = states[stateName]
				
				# Get all the flags in the files
				for f in state["StateFlags"]:
					if(!f in flagsFound):
						flagsFound += [f]
				
				# Filter some states from previous files out
				if(fileID != curFile and !checkFromPreviousFiles):
					continue
				if(fileID != curFile and !showAllStates):
					var skip = true
					if(showOverridableStates and "Overridable" in state["StateFlags"]):
						skip = false
					if(showVariables and stateName.begins_with("Variables")):
						skip = false
					if(skip):
						continue;
				
				statesFound += [stateName]
				nbStatesTotal += 1
				
				# Filter depending on flags
				if(!activeFlags.empty()):
					var skip = false
					for f in activeFlags:
						if(!(f in state["StateFlags"])):
							skip = true
					if(skip):
						continue
				
				nbStatesChosen += 1
				
				var stateCategories = state["Categories"]
				
				if(stateCategories.empty()):
					stateCategories = [null]
				for stateCategory in stateCategories:
					if(categoriesRaw.has(stateCategory)):
						categoriesRaw[stateCategory]["States"] += [state]
					else:
						categoriesRaw[stateCategory] = {"States":[state], "CategoryNode":null}
		
		# Parse the categories to make a tree
		var categoriesTree = {}
		for category in categoriesRaw:
			_NavigationParseCategoryTree(categoriesRaw, categoriesTree, category)
		
		# Sort and create the category tree
		_NavigationCreateCategoryTree(categoriesTree, stateListRoot)
		
		# Recreate flags panel
		flagsFound.sort()
		for f in flagsFound:
			var b = Button.new()
			b.set_name(f)
			b.set_tooltip(f)
			var icon = Castagne.Loader.LoadCastagneAsset("icons/editor/stateflags/EF"+f+".png")
			if(icon != null):
				b.set_button_icon(icon)
				b.set_expand_icon(true)
			b.set_text(f)
			b.set_clip_text(true)
			b.set_custom_minimum_size(Vector2(36,36)) # 32x32 pixel icons +4px button margin
			b.set_h_size_flags(SIZE_EXPAND_FILL)
			b.set_toggle_mode(true)
			if(f in activeFlags):
				b.set_pressed_no_signal(true)
			b.connect("pressed", self, "OnNavigationPanelParamsChanged")
			flagsPanel.add_child(b)
		
		# Panel
		$CodePanel/Navigation/ChooseState/Menu/CatFiler.set_text("--- Filtering ("+str(nbStatesChosen)+" / "+str(nbStatesTotal)+") ---")
		$CodePanel/Navigation/ChooseState/StateInfo/StateName.set_text("")
		$CodePanel/Navigation/ChooseState/StateInfo/StateDocs.set_text("")
		$CodePanel/Navigation/ChooseState/Menu/OverrideState.set_disabled(true)
		$CodePanel/Navigation/ChooseState/Menu/DeleteState.set_disabled(true)
		$CodePanel/Navigation/ChooseState/Menu/RenameState.set_disabled(true)

func _NavigationParseCategoryTree(categoriesRaw, categoriesTree, categoryNameFull):
	# Create intermediary categories if they don't exist
	if(!categoriesRaw.has(categoryNameFull)):
		categoriesRaw[categoryNameFull] = {"States":[], "CategoryNode":null}
	
	# Check if we already processed it
	var catRaw = categoriesRaw[categoryNameFull]
	if(catRaw["CategoryNode"] != null):
		return catRaw["CategoryNode"]
	
	# Check for parents based on category name
	var catNodeName = categoryNameFull
	var parentCategory = null
	
	if(categoryNameFull != null):
		var separationIndex = categoryNameFull.find_last("/")
		if(separationIndex > 0): # Ignore Slash on first character
			catNodeName = categoryNameFull.right(separationIndex+1)
			parentCategory = _NavigationParseCategoryTree(categoriesRaw, categoriesTree, categoryNameFull.left(separationIndex))
	
	# Create the category node
	var catNode = {
		"Name": catNodeName, "States":catRaw["States"], "Categories":{},
		"FullName": categoryNameFull,
	}
	
	# Add the node to the tree
	categoriesRaw[categoryNameFull]["CategoryNode"] = catNode
	if(parentCategory == null): # At the root
		categoriesTree[catNodeName] = catNode
	else: # Child of another category
		parentCategory["Categories"][catNodeName] = catNode
	return catNode

func _NavigationCreateCategoryTree(parentCategory, stateListRoot = null):
	var categories
	var states = []
	var isRootLevel = (stateListRoot != null)
	var fullNameBase = ""
	if(isRootLevel):
		categories = parentCategory
	else:
		categories = parentCategory["Categories"]
		states = parentCategory["States"]
	
	var categoriesNames = categories.keys()
	categoriesNames.sort_custom(self, "_NavigationCreateCategoryTree_SortCategories")
	
	# Create the categories first
	for cName in categoriesNames:
		var cNode = categories[cName]
		if(cName == null):
			if(isRootLevel):
				cNode["Name"] = "Uncategorized"
			else:
				continue
		if(!categoriesStatus.has(cNode["FullName"])):
			categoriesStatus[cNode["FullName"]] = categoriesStatusDefault
		cNode["Open"] = categoriesStatus[cNode["FullName"]]
		cNode["Editor"] = self
		var category = prefabNavPanelCategory.instance()
		category.InitFromCategory(cNode)
		cNode["GodotNode"] = category
		if(isRootLevel):
			stateListRoot.add_child(category)
		else:
			parentCategory["GodotNode"].AddItem(category)
		
		_NavigationCreateCategoryTree(cNode)
	
	# Create the states for this category
	if(isRootLevel):
		return
	states.sort_custom(self, "_NavigationCreateCategoryTree_SortStates")
	
	var includeHelpers = $CodePanel/Navigation/ChooseState/Menu/ToggleHelpers.is_pressed()
	
	for state in states:
		var s = prefabNavPanelState.instance()
		s.charEditor = self
		s.InitFromState(state)
		parentCategory["GodotNode"].AddItem(s)
		
		if(includeHelpers):
			var calledStates = BuildCalledStatesList(state)
			for csd in calledStates:
				if(csd[0] == state["Name"]):
					continue
				#if(csd[1] != curFile):
				#	continue
				var cstate = character[csd[1]]["States"][csd[0]]
				if(cstate["StateType"] != Castagne.STATE_TYPE.Helper):
					continue
				var cs = prefabNavPanelState.instance()
				cs.charEditor = self
				cs.padState = 1
				cs.InitFromState(cstate)
				parentCategory["GodotNode"].AddItem(cs)

func _NavigationCreateCategoryTree_SortCategories(a, b):
	var priority = [0, 0]
	for i in range(2):
		var c = [a, b][i]
		if(c == null):
			priority[i] = -9000
		elif(c == "Variables"):
			priority[i] = 1000
	if(priority[0] != priority[1]):
		return priority[0] > priority[1]
	return a < b
func _NavigationCreateCategoryTree_SortStates(a, b):
	return a["Name"] < b["Name"]

func OnNavigationPanelParamsChanged():
	RefreshNavigationPanel(NAVPANEL_MODE.ChooseState)

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



func _on_OpenState_pressed():
	Navigation_OpenState()

func Navigation_OpenState():
	if(_navigationSelected == null):
		Castagne.Error("Editor: Navigation_OpenState with no selected state")
		return
	var state = _navigationSelected.GetStateData()
	var fileID = _navigationSelected.GetFileID()
	ChangeCodePanelState(state["Name"], fileID)
	$CodePanel/Navigation.hide()

func Navigation_SelectState(state):
	if(_navigationSelected == state):
		return
	
	if(_navigationSelected != null):
		_navigationSelected.Deselect()
	_navigationSelected = state
	state.Select()
	
	var sd = state.GetStateData()
	
	$CodePanel/Navigation/ChooseState/StateInfo/StateName.set_text(sd["Name"])
	$CodePanel/Navigation/ChooseState/StateInfo/StateDocs.set_text(sd["StateFullDoc"])
	
	var isFromCurrentFile = (state.GetFileID() == curFile)
	$CodePanel/Navigation/ChooseState/Menu/OverrideState.set_disabled(isFromCurrentFile)
	$CodePanel/Navigation/ChooseState/Menu/DeleteState.set_disabled(!isFromCurrentFile)
	$CodePanel/Navigation/ChooseState/Menu/RenameState.set_disabled(!isFromCurrentFile)

func _on_NewState_pressed():
	ShowPopup("NewState")
	return
	# TODO Unreachable
	var stateName = $CodePanel/Navigation/ChooseState/Bottom/NewStateName.get_text().strip_edges()
	$CodePanel/Navigation/ChooseState/Bottom/NewStateName.set_text("")
	if(stateName.empty()):
		return
	
	if(!character[curFile]["States"].has(stateName)):
		character[curFile]["States"][stateName] = {}
		character[curFile]["States"][stateName]["Text"] = ""
	
	$CodePanel/Navigation.hide()
	ChangeCodePanelState(stateName)

func _on_RenameState_pressed():
	ShowPopup("RenameState")

func _on_NewEntity_pressed():
	ShowPopup("NewEntity")

func _on_OverrideState_pressed():
	if(_navigationSelected == null):
		return
	
	var stateName = _navigationSelected.GetStateData()["Name"]
	var fileID = curFile
	
	if(!character[fileID]["States"].has(stateName)):
		var defaultText = "CallParent("+str(stateName)+")\n"
		if(stateName.begins_with("Variables")):
			defaultText = "# Overriden\n"
		character[fileID]["States"][stateName] = {"Text":defaultText}
		character[fileID]["Modified"] = true
		SaveFile()
		ReloadCodePanel()
	
	ChangeCodePanelState(stateName, fileID)

func _on_DeleteState_pressed():
	if(_navigationSelected == null or _navigationSelected.GetStateData()["Name"] == "Character"):
		return
	
	ShowConfirmPopup(funcref(self, "DeleteStateCallback"), "Delete state "+str(_navigationSelected.GetStateData()["Name"])+" ?")

func DeleteStateCallback(confirmed = false):
	if(_navigationSelected != null and confirmed):
		var fileID = _navigationSelected.GetFileID()
		character[fileID]["States"].erase(_navigationSelected.GetStateData()["Name"])
		character[fileID]["Modified"] = true
		var cf = curFile
		SaveFile()
		ReloadCodePanel()
		ReloadEngine()
		ChangeCodePanelState("Character", cf)












# --------------------------------------------------------------------------------------------------
# Gizmos
func _on_Code_cursor_changed():
	if(!_initDone):
		return
	UpdateGizmos()
	UpdateDocumentation()

func CompileGizmos():
	if(get_node("BottomPanel/BMiniPanel/HBox/Middle/TopBar/Other/HideGizmos").pressed):
		if(engine != null):
			engine.editorModule.currentGizmos = []
		return
	
	# Temporary, but good enough for now
	var currentGizmos = []
	#return #TODO
	var functions = editor.configData.GetModuleFunctions()
	for i in range(codeWindow.get_line_count()):
		var line = codeWindow.get_line(i).strip_edges()
		if(line.empty() || line.begins_with("#") || !Castagne.Parser._IsLineFunction(line)):
			continue
		var funcParsed = Castagne.Parser._ExtractFunction(line)
		var funcName = funcParsed[0]
		var funcArgs = funcParsed[1]
		if(!functions.has(funcName)):
			continue
		var f = functions[funcName]
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
	var functions = editor.configData.GetModuleFunctions()
	
	if(!functions.has(funcName)):
		return
	
	var f = functions[funcName]
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
	
	# TODO
	#var mainEID = engine._gameState["Players"][0]["MainEntity"]
	#
	#if(restartResetMode != RESTART_RESET.Normal):
	#	var opponentEID = engine._gameState["Players"][1]["MainEntity"]
	#	
	#	if(restartResetMode == RESTART_RESET.Air):
	#		engine._gameState[mainEID]["PositionY"] = 35000
	#	if(restartResetMode == RESTART_RESET.Corner):
	#		engine._gameState[mainEID]["PositionX"] = editor.configData.Get("ArenaSize") - 30000
	#		engine._gameState[opponentEID]["PositionX"] = editor.configData.Get("ArenaSize")
	#		engine._gameState["CameraX"] = editor.configData.Get("ArenaSize")
	#	if(restartResetMode == RESTART_RESET.RCorner):
	#		engine._gameState[mainEID]["PositionX"] = -editor.configData.Get("ArenaSize") 
	#		engine._gameState[opponentEID]["PositionX"] = -editor.configData.Get("ArenaSize") + 30000
	#		engine._gameState["CameraX"] = -editor.configData.Get("ArenaSize")
	#
	#if(restartState != null):
	#	var fs = engine.GetCurrentFighterScriptOfEntity(mainEID, engine._gameState)
	#	if(fs == null or restartState == "Character" or restartState == "Variables"):
	#		restartState = null
	#
	#if(restartState != null):
	#	engine._gameState[mainEID]["State"] = restartState
	#	engine._gameState[mainEID]["StateStartFrame"] = engine._gameState["FrameID"]
	#	for i in range(restartStateFrames-1):
	#		if(restartResetMode == RESTART_RESET.Air):
	#			engine._gameState[mainEID]["PositionY"] = 35000
	#		engine.LocalStepNoInput()
	#else:
	#	engine.LocalStepNoInput()
	
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

#:TODO:Panthavma:20220715:Oops I added popup system and forgot this exists, will have to convert I guess

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









func _on_CodePanel_WarningsToggled(button_pressed):
	$CodePanel/WarningsList.set_visible(button_pressed)






func _on_NavOpenCategories_pressed():
	_Nav_OpenCloseCategories(true)
func _on_NavCloseCategories_pressed():
	_Nav_OpenCloseCategories(false)
func _Nav_OpenCloseCategories(v):
	for c in categoriesStatus:
		categoriesStatus[c] = v
	categoriesStatusDefault = v
	RefreshNavigationPanel(NAVPANEL_MODE.ChooseState)




func _on_HideGizmos_toggled(_button_pressed):
	UpdateGizmos()



func _on_TutorialContinue_pressed():
	HidePopups()
	get_node("../TutorialSystem").StopCoding()

func _on_TutorialReset_pressed():
	HidePopups()
	get_node("../TutorialSystem").ResetCode()


func _on_TutorialQuit_pressed():
	get_node("../TutorialSystem").EndTutorial()


func _on_TutorialWindow_pressed():
	ShowPopup("Tutorial")
