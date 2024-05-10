# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Castagne Input
# Gives access and manages input devices
# Is accessible through config data

extends Node

enum STICK_DIRECTIONS { LEFT, RIGHT, DOWN, UP, BACK, FORWARD, PORTSIDE, STARBOARD, NEUTRALH, NEUTRALV}

var _configData = null
var _devices = {}
var _devicesList = []

var _inputLayout
var _inputSchema

func InitializeFromConfigData(configData):
	_configData = configData
	
	_inputLayout = _configData.Get("InputLayout").duplicate(true)
	_inputSchema = CreateInputSchemaFromInputLayout(_inputLayout)
	
	AddDevice("empty", Castagne.INPUTDEVICE_TYPES.EMPTY)
	
	for i in range(configData.Get("NumberOfKeyboardPlayers")):
		AddDevice("k"+str(i+1), Castagne.INPUTDEVICE_TYPES.KEYBOARD, i)
	for i in range(configData.Get("NumberOfControllerPlayers")):
		AddDevice("c"+str(i+1), Castagne.INPUTDEVICE_TYPES.CONTROLLER, i)


func AddDevice(deviceName, deviceType, deviceParameter = null):
	if(_devices.has(deviceName)):
		Castagne.Error("[CastagneInput.AddDevice] Device already exists: " + str(deviceName))
		return
	
	var deviceData = {
		"Name": deviceName,
		"Type": deviceType,
		"DisplayName": "display name not set",
		"DeviceActionPrefix": "castagne-" + deviceName + "-",
		"BindingsBase": 0,
	}
	
	if(deviceType == Castagne.INPUTDEVICE_TYPES.EMPTY):
		deviceData["DisplayName"] = "No Input Device"
	elif(deviceType == Castagne.INPUTDEVICE_TYPES.KEYBOARD):
		deviceData["DisplayName"] = "Keyboard " + str(deviceParameter+1)
		if(deviceParameter != null):
			deviceData["BindingsBase"] = deviceParameter
	elif(deviceType == Castagne.INPUTDEVICE_TYPES.CONTROLLER):
		deviceData["DisplayName"] = "Controller " + str(deviceParameter+1)
		deviceData["ControllerID"] = deviceParameter
	else:
		Castagne.Error("[CastagneInput.AddDevice] Device type unknown: " + str(deviceType))
		return
	
	var inputMap = CreateInputMapFromInputLayout(_inputLayout)
	
	deviceData["InputLayout"] = _inputLayout
	deviceData["InputMap"] = inputMap
	
	_devicesList.push_back(deviceName)
	_devices[deviceName] = deviceData
	
	CreateGodotInputActionsFromDevice(deviceName)

func GetDevicesList():
	return _devicesList

func GetDevice(deviceName = null):
	if(deviceName == null):
		deviceName = "empty"
	
	if(!_devices.has(deviceName)):
		Castagne.Error("[CastagneInput.GetDevice] Device " + str(deviceName) + " not found!")
		return null
	
	return _devices[deviceName]

func PollDevice(deviceName = null):
	var device = GetDevice(deviceName)
	if(device == null):
		return
	
	var inputMap = device["InputMap"]
	var actionPrefix = device["DeviceActionPrefix"]
	var deviceType = device["Type"]
	
	var inputRawData = {}
	
	for iName in inputMap:
		var im = inputMap[iName]
		var value = false
		if(deviceType != Castagne.INPUTDEVICE_TYPES.EMPTY):
			var actionName = actionPrefix + im["ActionName"]
			value = Input.is_action_pressed(actionName)
		inputRawData[iName] = value
	
	return inputRawData










func PhysicalInputGetGameInputNames(physicalInput):
	var piType = physicalInput["Type"]
	var piName = physicalInput["Name"]
	var defaultGameInputNames = [""]
	
	if(piType == Castagne.PHYSICALINPUT_TYPES.AXIS):
		defaultGameInputNames = ["Negative", "Positive", "Neutral"]
	elif(piType == Castagne.PHYSICALINPUT_TYPES.STICK):
		defaultGameInputNames = ["Left", "Right", "Down", "Up", "Back", "Forward", "Portside", "Starboard", "NeutralH", "NeutralV"]
	
	var piGameInputNames = []
	if(physicalInput.has("GameInputNames")):
		piGameInputNames = physicalInput["GameInputNames"]
	
	var gameInputNames = []
	for i in range(defaultGameInputNames.size()):
		if(piGameInputNames.size() > i):
			gameInputNames += [piGameInputNames[i]]
		else:
			gameInputNames += [piName+defaultGameInputNames[i]]
	return gameInputNames

func PhysicalInputGetBindableGameInputNames(physicalInput):
	var piType = physicalInput["Type"]
	var giNames = PhysicalInputGetGameInputNames(physicalInput)
	
	if(piType == Castagne.PHYSICALINPUT_TYPES.AXIS):
		for i in range(2, giNames.size()):
			giNames.pop_back()
	if(piType == Castagne.PHYSICALINPUT_TYPES.STICK):
		for i in range(4, giNames.size()):
			giNames.pop_back()
	
	return giNames

func PhysicalInputGetNumberOfGameInputs(physicalInput):
	var piType = physicalInput["Type"]
	var nbGameInputs = 1
	if(piType == Castagne.PHYSICALINPUT_TYPES.AXIS):
		nbGameInputs = 2
	elif(piType == Castagne.PHYSICALINPUT_TYPES.STICK):
		nbGameInputs = 4
	return nbGameInputs

func PhysicalInputGetKeyboardBindings(physicalInput):
	return _PhysicalInputGetBindings(physicalInput, false)
func PhysicalInputGetControllerBindings(physicalInput):
	return _PhysicalInputGetBindings(physicalInput, true)
func _PhysicalInputGetBindings(physicalInput, isController):
	var nbGameInputs = PhysicalInputGetNumberOfGameInputs(physicalInput)
	var nbLayouts = (_configData.Get("NumberOfControllerLayouts") if isController else _configData.Get("NumberOfKeyboardLayouts"))
	var bindingsField = ("ControllerInputs" if isController else "KeyboardInputs")
	
	var bindingsBase = []
	if(physicalInput.has(bindingsField)):
		bindingsBase = physicalInput[bindingsField]
	
	var bindings = []
	for giID in range(nbGameInputs):
		var giBindings = []
		for lID in range(nbLayouts):
			var lBindings = []
			if(bindingsBase.size() > giID and bindingsBase[giID].size() > lID):
				lBindings = bindingsBase[giID][lID].duplicate(true)
			giBindings += [lBindings]
		bindings += [giBindings]
	return bindings

func GetPhysicalInputs():
	return _inputLayout

func GetPrimaryPhysicalInputs(layout = null):
	if(layout == null):
		layout = _inputLayout
	var inputs = []
	for pi in layout:
		var piType = pi["Type"]
		if(piType == Castagne.PHYSICALINPUT_TYPES.COMBINATION or piType == Castagne.PHYSICALINPUT_TYPES.ANY):
			continue
		inputs += [pi]
	return inputs

func GetPhysicalCombinationInputGameInputNames(physicalInput, layout):
	var eligibleInputs = GetPrimaryPhysicalInputs(layout)
	var combination = []
	if(physicalInput.has("Combination")):
		combination = physicalInput["Combination"]
	else:
		Castagne.Error("[CastagneInput] PhysicalInput " + str(physicalInput["Name"]) + " doesn't have Combination property.")
	
	var combinedGameInputs = []
	
	for combiID in range(combination.size()):
		var c = combination[combiID]
		if(c[0] >= eligibleInputs.size()):
			Castagne.Error("[CastagneInput] " + str(physicalInput["Name"]) + " Combination is looking for an inexistant physical input.")
			continue
		var chosenInput = eligibleInputs[c[0]]
		
		var gameInputs = PhysicalInputGetGameInputNames(chosenInput)
		if(c[1] >= gameInputs.size()):
			Castagne.Error("[CastagneInput] " + str(physicalInput["Name"]) + " Combination is looking for an inexistant game input.")
			continue
		combinedGameInputs.push_back(gameInputs[c[1]])
	
	return combinedGameInputs






func CreateInputMapFromInputLayout(inputLayout):
	var inputMap = {}
	
	for physicalInput in inputLayout:
		var gameInputNames = PhysicalInputGetBindableGameInputNames(physicalInput)
		var keyboardBindings = PhysicalInputGetKeyboardBindings(physicalInput)
		var controllerBindings = PhysicalInputGetControllerBindings(physicalInput)
		
		for giID in range(gameInputNames.size()):
			var giName = gameInputNames[giID]
			var im = {
				"GameInputName": giName,
				"ActionName": giName,
				"BindingsKeyboard": keyboardBindings[giID],
				"BindingsController": controllerBindings[giID],
			}
			
			if(inputMap.has(giName)):
				Castagne.Error("[CastagneInput] Game Input present twice in the input map: " + str(giName))
			inputMap[giName] = im
	
	return inputMap




func CreateGodotInputActionsFromDevice(deviceName):
	var device = GetDevice(deviceName)
	if(device == null):
		return
	
	var deviceType = device["Type"]
	if(deviceType == Castagne.INPUTDEVICE_TYPES.EMPTY):
		return
	
	var actionNamePrefix = device["DeviceActionPrefix"]
	
	
	var inputMap = device["InputMap"]
	for iName in inputMap:
		var im = inputMap[iName]
		var actionName = actionNamePrefix + im["ActionName"]
		InputMap.add_action(actionName)
		
		InputMap.action_erase_events(actionName)
		var bindingsBaseID = device["BindingsBase"]
		
		if(deviceType == Castagne.INPUTDEVICE_TYPES.KEYBOARD):
			var keyboardInputs = im["BindingsKeyboard"]
			if(keyboardInputs.size() <= bindingsBaseID):
				keyboardInputs = []
			else:
				keyboardInputs = keyboardInputs[bindingsBaseID]
			
			for ki in keyboardInputs:
				var ie = InputEventKey.new()
				ie.set_scancode(ki)
				InputMap.action_add_event(actionName, ie)
		elif(deviceType == Castagne.INPUTDEVICE_TYPES.CONTROLLER):
			var controllerInputs = im["BindingsController"]
			if(controllerInputs.size() <= bindingsBaseID):
				controllerInputs = []
			else:
				controllerInputs = controllerInputs[bindingsBaseID]
			
			var controllerID = device["ControllerID"]
			for ci in controllerInputs:
				var ie = InputEventJoypadButton.new()
				ie.set_button_index(ci)
				ie.set_device(controllerID)
				InputMap.action_add_event(actionName, ie)






func CreateInputSchemaFromInputLayout(inputLayout):
	var inputSchema = {
		"_InputListByType":{
			Castagne.GAMEINPUT_TYPES.DIRECT:[],
			Castagne.GAMEINPUT_TYPES.MULTIPLE:[],
			Castagne.GAMEINPUT_TYPES.DERIVED:[],
		},
		"_InputList":[],
	}
	for physicalInput in inputLayout:
		var piName = physicalInput["Name"]
		var piType = physicalInput["Type"]
		var inputData = null
		var gameInputNames = PhysicalInputGetGameInputNames(physicalInput)
		
		
		if(piType == Castagne.PHYSICALINPUT_TYPES.COMBINATION or piType == Castagne.PHYSICALINPUT_TYPES.ANY):
			inputData = {
				"Combination": GetPhysicalCombinationInputGameInputNames(physicalInput, inputLayout)
			}
			
		
		_AddPhysicalInputToInputSchema(inputSchema, piName, piType, gameInputNames, inputData)
	return inputSchema

func _AddPhysicalInputToInputSchema(inputSchema, piName, piType, gameInputNames, inputData = null):
	if(piType == Castagne.PHYSICALINPUT_TYPES.RAW):
		_AddGameInputToInputSchema(inputSchema, gameInputNames[0], Castagne.GAMEINPUT_TYPES.DIRECT)
	elif(piType == Castagne.PHYSICALINPUT_TYPES.BUTTON):
		_AddPhysicalInputToInputSchema(inputSchema, piName, Castagne.PHYSICALINPUT_TYPES.RAW, gameInputNames)
		_AddGameInputToInputSchema(inputSchema, gameInputNames[0]+"Press", Castagne.GAMEINPUT_TYPES.DERIVED,
			{"DerivedType": Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_PRESS, "Target": gameInputNames[0]})
		_AddGameInputToInputSchema(inputSchema, gameInputNames[0]+"Release", Castagne.GAMEINPUT_TYPES.DERIVED,
			{"DerivedType": Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_RELEASE, "Target": gameInputNames[0]})
	elif(piType == Castagne.PHYSICALINPUT_TYPES.AXIS):
		_AddPhysicalInputToInputSchema(inputSchema, piName, Castagne.PHYSICALINPUT_TYPES.BUTTON, [gameInputNames[0]])
		_AddPhysicalInputToInputSchema(inputSchema, piName, Castagne.PHYSICALINPUT_TYPES.BUTTON, [gameInputNames[1]])
	elif(piType == Castagne.PHYSICALINPUT_TYPES.STICK):
		_AddPhysicalInputToInputSchema(inputSchema, piName, Castagne.PHYSICALINPUT_TYPES.AXIS, [gameInputNames[0], gameInputNames[1]])
		_AddPhysicalInputToInputSchema(inputSchema, piName, Castagne.PHYSICALINPUT_TYPES.AXIS, [gameInputNames[2], gameInputNames[3]])
		for i in range(4, gameInputNames.size()):
			if(i >= 8):
				var giBase = (0 if i == 8 else 2)
				_AddGameInputToInputSchema(inputSchema, gameInputNames[i], Castagne.GAMEINPUT_TYPES.DERIVED,
					{"DerivedType":Castagne.GAMEINPUT_DERIVED_TYPES.DIRECTION_NEUTRAL,
					"Targets":[gameInputNames[giBase], gameInputNames[giBase+1]]})
			else:
				_AddGameInputToInputSchema(inputSchema, gameInputNames[i], Castagne.GAMEINPUT_TYPES.DERIVED,
					{"DerivedType":Castagne.GAMEINPUT_DERIVED_TYPES.DIRECTIONAL, "GINames":gameInputNames, "DirID":i})
			_AddGameInputToInputSchema(inputSchema, gameInputNames[i]+"Press", Castagne.GAMEINPUT_TYPES.DERIVED,
				{"DerivedType":Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_PRESS, "Target":gameInputNames[i]})
			_AddGameInputToInputSchema(inputSchema, gameInputNames[i]+"Release", Castagne.GAMEINPUT_TYPES.DERIVED,
				{"DerivedType":Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_RELEASE, "Target":gameInputNames[i]})
	elif(piType == Castagne.PHYSICALINPUT_TYPES.COMBINATION or piType == Castagne.PHYSICALINPUT_TYPES.ANY):
		if(!inputData):
			inputData = {}
		inputData["CombinationAny"] = (piType == Castagne.PHYSICALINPUT_TYPES.ANY)
		_AddGameInputToInputSchema(inputSchema, gameInputNames[0], Castagne.GAMEINPUT_TYPES.MULTIPLE, inputData)
		_AddGameInputToInputSchema(inputSchema, gameInputNames[0]+"Press", Castagne.GAMEINPUT_TYPES.DERIVED,
			{"DerivedType": Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_PRESS, "Target": gameInputNames[0]})
		_AddGameInputToInputSchema(inputSchema, gameInputNames[0]+"Release", Castagne.GAMEINPUT_TYPES.DERIVED,
			{"DerivedType": Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_RELEASE, "Target": gameInputNames[0]})
	else:
		Castagne.Error("[CastagneInput] Physical Input " + str(piName) + " has an unrecognized type: " + str(piType))

func _AddGameInputToInputSchema(inputSchema, inputName, inputType, inputData = {}):
	if(inputSchema.has(inputName)):
		Castagne.Error("[CastagneInput] Input name " + str(inputName) + " already exists in the Input Schema!")
		return
	if(inputType == Castagne.GAMEINPUT_TYPES.MULTIPLE and !inputData.has("Combination")):
		Castagne.Error("[CastagneInput] Input name " + str(inputName) + " has no Combination for the Input Schema!")
		return
	inputData["Name"] = inputName
	inputData["Type"] = inputType
	inputSchema[inputName] = inputData
	inputSchema["_InputListByType"][inputType].push_back(inputName)
	inputSchema["_InputList"].push_back(inputName)

func GetInputSchema():
	return _inputSchema



func CreateInputDataFromRawInput(rawInput, schema = null):
	if(schema == null):
		schema = _inputSchema
	
	var inputData = {}
	for inputName in schema["_InputList"]:
		inputData[inputName] = false
	
	# Start with the direct inputs
	for directInputName in schema["_InputListByType"][Castagne.GAMEINPUT_TYPES.DIRECT]:
		inputData[directInputName] = rawInput[directInputName]
	
	# Press the associated buttons for pressed combination buttons
	for combinationInputName in schema["_InputListByType"][Castagne.GAMEINPUT_TYPES.MULTIPLE]:
		var combination = schema[combinationInputName]["Combination"]
		var combinationAny = schema[combinationInputName]["CombinationAny"]
		if(rawInput[combinationInputName]):
			if(combinationAny):
				var hasOne = false
				for c in combination:
					if(inputData[c]):
						hasOne = true
				if(!hasOne):
					inputData[combination[0]] = true
			else:
				for c in combination:
					inputData[c] = true
			inputData[combinationInputName] = true
	
	# Press the combination button if the conditions are there
	for combinationInputName in schema["_InputListByType"][Castagne.GAMEINPUT_TYPES.MULTIPLE]:
		var combination = schema[combinationInputName]["Combination"]
		var combinationAny = schema[combinationInputName]["CombinationAny"]
		if(!rawInput[combinationInputName]):
			if(combinationAny):
				var value = false
				for c in combination:
					if(inputData[c]):
						value = true
						break
				inputData[combinationInputName] = value
			else:
				var value = true
				for c in combination:
					if(!inputData[c]):
						value = false
						break
				inputData[combinationInputName] = value
	
	return inputData




