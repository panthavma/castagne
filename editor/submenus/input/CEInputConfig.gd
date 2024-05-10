# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"

var layout
var modifiedLayout
var inputID
onready var keyboardRebindings = $KeyboardRebindings

func Enter():
	layout = editor.configData.Get("InputLayout").duplicate(true)
	modifiedLayout = false
	inputID = 0
	RefreshSidelist()
	ShowSchema()

func RefreshSidelist():
	var physInputList = $InputList/ItemList
	
	physInputList.clear()
	
	for le in layout:
		var piName = str(le["Name"]) + " (" + str(Castagne.PHYSICALINPUT_TYPES.keys()[le["Type"]]) +")"
		physInputList.add_item(piName)

func ShowSchema():
	$InputData.hide()
	$InputSchema.show()
	keyboardRebindings.hide()
	var itemList = $InputSchema/ItemList
	itemList.clear()
	
	var schema = editor.configData.Input().CreateInputSchemaFromInputLayout(layout)
	
	for s in schema["_InputList"]:
		itemList.add_item(str(s))

func ShowConfigPanel():
	$InputData.show()
	$InputSchema.hide()
	keyboardRebindings.hide()
	$InputList/ItemList.select(inputID)
	
	var castagneInput = editor.configData.Input()
	var physicalInput = layout[inputID]
	var piType = physicalInput["Type"]
	
	var dataRoot = $InputData/DataScroll/Data
	
	dataRoot.get_node("Name/NameField").set_text(physicalInput["Name"])
	
	var typeField = dataRoot.get_node("Type/TypeField")
	typeField.clear()
	for t in Castagne.PHYSICALINPUT_TYPES:
		typeField.add_item(str(t))
	typeField.select(piType)
	
	var paramsRoot = dataRoot.get_node("Params")
	for c in paramsRoot.get_children():
		c.queue_free()
	var paramsStretchRatio = dataRoot.get_node("Name/Label").get_stretch_ratio()
	
	var bindingsRoot = $InputData/BindingsScroll/Bindings
	for c in bindingsRoot.get_children():
		c.queue_free()
	
	var labelGameInputs = Label.new()
	labelGameInputs.set_text("Game Input Names")
	paramsRoot.add_child(labelGameInputs)
	
	var gameInputNames = castagneInput.PhysicalInputGetGameInputNames(physicalInput)
	var gameInputNamesLabels = ["Game Input"]
	if(gameInputNames.size() > 1):
		gameInputNamesLabels = []
		
		# Populate with default names
		for i in range(gameInputNames.size()):
			gameInputNamesLabels += ["Action "+str(i)]
		var nbAxis = int(gameInputNames.size()/2)
		for i in range(nbAxis):
			gameInputNamesLabels[2*i]   = "Axis "+str(i)+" (-)"
			gameInputNamesLabels[2*i+1] = "Axis "+str(i)+" (+)"
		
		# Overwrite with relevant label names
		var defaultLabelNames = []
		if(piType == Castagne.PHYSICALINPUT_TYPES.AXIS):
			defaultLabelNames = ["Negative", "Positive"]
		if(piType == Castagne.PHYSICALINPUT_TYPES.STICK):
			defaultLabelNames = ["Left", "Right", "Down", "Up", "Back", "Forward", "Portside", "Starboard", "NeutralH", "NeutralV"]
		for i in range(defaultLabelNames.size()):
			gameInputNamesLabels[i] = defaultLabelNames[i]
	
	var keyboardBindings = castagneInput.PhysicalInputGetKeyboardBindings(physicalInput)
	var controllerBindings = castagneInput.PhysicalInputGetControllerBindings(physicalInput)
	
	for gameInputID in range(gameInputNames.size()):
		var gin = gameInputNames[gameInputID]
		
		var hboxGameInputName = HBoxContainer.new()
		var labelGameInputName = Label.new()
		labelGameInputName.set_text(gameInputNamesLabels[gameInputID]+":")
		labelGameInputName.set_h_size_flags(SIZE_EXPAND_FILL)
		labelGameInputName.set_stretch_ratio(paramsStretchRatio)
		labelGameInputName.set_align(LineEdit.ALIGN_RIGHT)
		hboxGameInputName.add_child(labelGameInputName)
		
		var fieldGameInputName = LineEdit.new()
		fieldGameInputName.set_text(gin)
		fieldGameInputName.set_h_size_flags(SIZE_EXPAND_FILL)
		hboxGameInputName.add_child(fieldGameInputName)
		paramsRoot.add_child(hboxGameInputName)
		
		fieldGameInputName.connect("text_entered", self, "_Callback_ChangeGameInputNames", [gameInputID])
		
		bindingsRoot.add_child(HSeparator.new())
		var labelGIN = Label.new()
		labelGIN.set_text(gin)
		bindingsRoot.add_child(labelGIN)
		
		var nbKeyboardLayouts = editor.configData.Get("NumberOfKeyboardLayouts")
		var nbControllerLayouts = editor.configData.Get("NumberOfControllerLayouts")
		
		for totalLayoutID in range(nbKeyboardLayouts+nbControllerLayouts):
			var isController = (totalLayoutID >= nbKeyboardLayouts)
			var layoutID = (totalLayoutID-nbKeyboardLayouts if isController else totalLayoutID)
			
			var hboxMain = HBoxContainer.new()
			var labelKB = Label.new()
			labelKB.set_text(("Controller" if isController else "Keyboard")+" Layout " + str(layoutID+1)+ ": ")
			labelKB.set_h_size_flags(SIZE_EXPAND_FILL)
			labelKB.set_align(Label.ALIGN_RIGHT)
			labelKB.set_stretch_ratio(0.4)
			hboxMain.add_child(labelKB)
			
			var hboxBindings = HBoxContainer.new()
			hboxBindings.set_h_size_flags(SIZE_EXPAND_FILL)
			hboxMain.add_child(hboxBindings)
			
			var deviceBindings = (controllerBindings if isController else keyboardBindings)
			while(deviceBindings.size() <= gameInputID):
				deviceBindings.push_back([])
			while(deviceBindings[gameInputID].size() <= layoutID):
				deviceBindings[gameInputID].push_back([])
			
			var bindings = deviceBindings[gameInputID][layoutID]
			if(isController):
				var controllerButtonNames = []
				for i in range(0, JOY_BUTTON_MAX):
					controllerButtonNames += [str(i)]
				controllerButtonNames[JOY_XBOX_A] += " (XBOX A)"
				controllerButtonNames[JOY_XBOX_B] += " (XBOX B)"
				controllerButtonNames[JOY_XBOX_X] += " (XBOX X)"
				controllerButtonNames[JOY_XBOX_Y] += " (XBOX Y)"
				controllerButtonNames[JOY_DPAD_LEFT] += " (DPad Left)"
				controllerButtonNames[JOY_DPAD_RIGHT] += " (DPad Right)"
				controllerButtonNames[JOY_DPAD_DOWN] += " (DPad Down)"
				controllerButtonNames[JOY_DPAD_UP] += " (DPad Up)"
				controllerButtonNames[JOY_L] += " (LB)"
				controllerButtonNames[JOY_L2] += " (LT)"
				controllerButtonNames[JOY_L3] += " (LS)"
				controllerButtonNames[JOY_R] += " (RB)"
				controllerButtonNames[JOY_R2] += " (RT)"
				controllerButtonNames[JOY_R3] += " (RS)"
				controllerButtonNames[JOY_START] += " (Start)"
				controllerButtonNames[JOY_SELECT] += " (Select)"
				for bindingID in range(bindings.size()):
					var b = bindings[bindingID]
					var buttonCBinding = OptionButton.new()
					
					for i in range(controllerButtonNames.size()):
						buttonCBinding.add_item(controllerButtonNames[i])
					buttonCBinding.select(b)
					
					buttonCBinding.connect("item_selected", self, "_Callback_ChangeControllerBindings", [gameInputID, layoutID, bindingID])
					
					hboxBindings.add_child(buttonCBinding)
			else:
				for bindingID in range(bindings.size()):
					var b = bindings[bindingID]
					var t = "[Empty]"
					if(b != null):
						t = OS.get_scancode_string(b)
					var keyboardKBindings = Button.new()
					keyboardKBindings.set_text(t)
					keyboardKBindings.connect("pressed", self, "_Callback_StartKeyboardInputRebinding", [gameInputID, layoutID, bindingID])
					hboxBindings.add_child(keyboardKBindings)
			
			var buttonPlus = Button.new()
			buttonPlus.set_text("[+]")
			buttonPlus.connect("pressed", self, "_Callback_NewBindings", [gameInputID, layoutID, isController])
			hboxMain.add_child(buttonPlus)
			
			var buttonClear = Button.new()
			buttonClear.set_text("[Clear All]")
			buttonClear.connect("pressed", self, "_Callback_ClearBindings", [gameInputID, layoutID, isController])
			hboxMain.add_child(buttonClear)
			
			bindingsRoot.add_child(hboxMain)
	
	var gameInputNamesResetButton = Button.new()
	gameInputNamesResetButton.set_text("Reset Game Input Names")
	gameInputNamesResetButton.connect("pressed", self, "_Callback_ResetGameInputNames")
	
	paramsRoot.add_child(gameInputNamesResetButton)
	paramsRoot.add_child(HSeparator.new())
	
	if(piType == Castagne.PHYSICALINPUT_TYPES.COMBINATION or piType == Castagne.PHYSICALINPUT_TYPES.ANY):
		var combiLabel = Label.new()
		combiLabel.set_text("Combination Inputs")
		paramsRoot.add_child(combiLabel)
		
		var combination = []
		if(physicalInput.has("Combination")):
			combination = physicalInput["Combination"]
		
		for combiID in range(combination.size()):
			var c = combination[combiID]
			
			var combiHBox = HBoxContainer.new()
			var combiPI = OptionButton.new()
			combiPI.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			var eligibleInputs = castagneInput.GetPrimaryPhysicalInputs(layout)
			for ei in eligibleInputs:
				combiPI.add_item(ei["Name"])
			combiPI.select(c[0])
			combiPI.connect("item_selected", self, "_Callback_CombiChangePI", [combiID])
			combiHBox.add_child(combiPI)
			
			var chosenInput = eligibleInputs[c[0]]
			var gameInputs = castagneInput.PhysicalInputGetGameInputNames(chosenInput)
			
			var combiGI = OptionButton.new()
			combiGI.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			for gi in gameInputs:
				combiGI.add_item(gi)
			combiGI.select(c[1])
			combiGI.connect("item_selected", self, "_Callback_CombiChangeGI", [combiID])
			combiHBox.add_child(combiGI)
			
			paramsRoot.add_child(combiHBox)
		
		var combiButtonHBox = HBoxContainer.new()
		var combiNewButton = Button.new()
		combiNewButton.set_text("Add New Combination")
		combiNewButton.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		combiNewButton.connect("pressed", self, "_Callback_CombiAddNew")
		combiButtonHBox.add_child(combiNewButton)
		var combiRemove = Button.new()
		combiRemove.set_text("Remove last")
		combiRemove.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		combiRemove.connect("pressed", self, "_Callback_CombiRemoveLast")
		combiButtonHBox.add_child(combiRemove)
		paramsRoot.add_child(combiButtonHBox)
		
		paramsRoot.add_child(HSeparator.new())
	

func _Callback_ChangeGameInputNames(newName, gameInputID):
	var physicalInput = layout[inputID]
	var gameInputNames = editor.configData.Input().PhysicalInputGetGameInputNames(physicalInput)
	gameInputNames[gameInputID] = newName
	layout[inputID]["GameInputNames"] = gameInputNames
	ShowConfigPanel()

func _Callback_ResetGameInputNames():
	layout[inputID].erase("GameInputNames")
	ShowConfigPanel()

func _Callback_ClearBindings(gameInputID, layoutID, isController):
	var castagneInput = editor.configData.Input()
	var physicalInput = layout[inputID]
	var bindings = (castagneInput.PhysicalInputGetControllerBindings(physicalInput)
		if isController else castagneInput.PhysicalInputGetKeyboardBindings(physicalInput))
	var bindingsField = ("ControllerInputs" if isController else "KeyboardInputs")
	
	bindings[gameInputID][layoutID] = []
	layout[inputID][bindingsField] = bindings
	
	ShowConfigPanel()

func _Callback_NewBindings(gameInputID, layoutID, isController):
	var castagneInput = editor.configData.Input()
	var physicalInput = layout[inputID]
	var bindings = (castagneInput.PhysicalInputGetControllerBindings(physicalInput)
		if isController else castagneInput.PhysicalInputGetKeyboardBindings(physicalInput))
	var bindingsField = ("ControllerInputs" if isController else "KeyboardInputs")
	
	bindings[gameInputID][layoutID] += [(0 if isController else null)]
	layout[inputID][bindingsField] = bindings
	
	ShowConfigPanel()

func _Callback_ChangeControllerBindings(newValue, gameInputID, layoutID, bindingID):
	var castagneInput = editor.configData.Input()
	var physicalInput = layout[inputID]
	var bindings = castagneInput.PhysicalInputGetControllerBindings(physicalInput)
	
	bindings[gameInputID][layoutID][bindingID] = newValue
	layout[inputID]["ControllerInputs"] = bindings
	
	ShowConfigPanel()

func _Callback_StartKeyboardInputRebinding(gameInputID, layoutID, bindingID):
	keyboardRebindings.KeyboardRebindStart(gameInputID, layoutID, bindingID)


func _Callback_CombiAddNew():
	var physicalInput = layout[inputID]
	var combination = []
	if(physicalInput.has("Combination")):
		combination = physicalInput["Combination"]
	combination += [[0,0]]
	physicalInput["Combination"] = combination
	ShowConfigPanel()
func _Callback_CombiRemoveLast():
	var physicalInput = layout[inputID]
	var combination = []
	if(physicalInput.has("Combination")):
		combination = physicalInput["Combination"]
	combination.pop_back()
	physicalInput["Combination"] = combination
	ShowConfigPanel()
func _Callback_CombiChangePI(newValue, combiID):
	var physicalInput = layout[inputID]
	var combination = []
	if(physicalInput.has("Combination")):
		combination = physicalInput["Combination"]
	combination[combiID] = [newValue, 0]
	physicalInput["Combination"] = combination
	ShowConfigPanel()
func _Callback_CombiChangeGI(newValue, combiID):
	var physicalInput = layout[inputID]
	var combination = []
	if(physicalInput.has("Combination")):
		combination = physicalInput["Combination"]
	combination[combiID][1] = newValue
	physicalInput["Combination"] = combination
	ShowConfigPanel()



func _on_SeeInputSchema_pressed():
	ShowSchema()
func _on_Confirm_pressed():
	editor.configData.Set("InputLayout", layout)
	Exit(1)
func _on_Cancel_pressed():
	Exit()

func _on_ItemList_item_activated(index):
	inputID = index
	ShowConfigPanel()


func _on_NameField_text_changed(new_text):
	layout[inputID]["Name"] = new_text
	RefreshSidelist()
	$InputList/ItemList.select(inputID)


func _on_TypeField_item_selected(index):
	layout[inputID]["Type"] = index
	RefreshSidelist()
	ShowConfigPanel()




func _on_AddNew_pressed():
	layout += [{"Name":"NewInput", "Type":Castagne.PHYSICALINPUT_TYPES.RAW}]
	inputID = layout.size() -1
	RefreshSidelist()
	ShowConfigPanel()
func _on_DeleteInput_pressed():
	var castagneInput = editor.configData.Input()
	var list = $InputList/ItemList
	if(!list.is_anything_selected()):
		return
	
	var toDeleteID = list.get_selected_items()[0]
	var primaryInputsBefore = castagneInput.GetPrimaryPhysicalInputs(layout)
	layout.remove(toDeleteID)
	var primaryInputsAfter = castagneInput.GetPrimaryPhysicalInputs(layout)
	
	for piID in range(layout.size()):
		var pi = layout[piID]
		var piType = pi["Type"]
		if(piType == Castagne.PHYSICALINPUT_TYPES.COMBINATION or piType == Castagne.PHYSICALINPUT_TYPES.ANY):
			var combinations = []
			if(pi.has("Combination")):
				combinations = pi["Combination"]
			
			for combiID in range(combinations.size()):
				var combiInputID = combinations[combiID][0]
				if(primaryInputsBefore[combiInputID] != primaryInputsAfter[combiInputID]):
					if(combiInputID > 0):
						combiInputID -= 1
					combinations[combiID] = [combiInputID, combinations[combiID][1]]
			layout[piID]["Combination"] = combinations
	
	RefreshSidelist()
	ShowSchema()














