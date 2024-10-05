# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Input", Castagne.MODULE_SLOTS_BASE.INPUT, {
		"Description":"Module handling Input inside of the Castagne Engine. Works closely together with CastagneInput.gd. Please read the Intermediate Guide/Castagne Input page for more details."})
	
	RegisterCategory("Input Definition", {"Description":"Holds the input layout and default bindings."})
	
	RegisterConfig("InputLayout", [
		{"Name":"Movement", "Type":Castagne.PHYSICALINPUT_TYPES.STICK,
			"KeyboardInputs":[[[KEY_A, KEY_Q, KEY_LEFT]], [[KEY_D, KEY_RIGHT]], [[KEY_S, KEY_DOWN]], [[KEY_Z, KEY_W, KEY_SPACE, KEY_UP]]],
			"ControllerInputs":[[[JOY_DPAD_LEFT]], [[JOY_DPAD_RIGHT]], [[JOY_DPAD_DOWN]], [[JOY_DPAD_UP]]],
			"GameInputNames":["Left", "Right", "Down", "Up", "Back", "Forward", "Portside", "Starboard", "NeutralH", "NeutralV"]},
		{"Name":"L", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_H, KEY_KP_4]]], "ControllerInputs":[[[JOY_XBOX_X]]]},
		{"Name":"M", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_J, KEY_KP_5]]], "ControllerInputs":[[[JOY_XBOX_Y]]]},
		{"Name":"H", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_K, KEY_KP_6]]], "ControllerInputs":[[[JOY_XBOX_B]]]},
		{"Name":"S", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_N, KEY_KP_0]]], "ControllerInputs":[[[JOY_XBOX_A]]]},
		{"Name":"E", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_L, KEY_KP_ADD]]], "ControllerInputs":[[[JOY_R]]]},
		{"Name":"Throw", "Type":Castagne.PHYSICALINPUT_TYPES.COMBINATION,
			"KeyboardInputs":[[[KEY_SHIFT]]], "ControllerInputs":[[[JOY_L]]],
			"Combination":[[1, 0], [2, 0]]},
		{"Name":"Jump", "Type":Castagne.PHYSICALINPUT_TYPES.ANY,
			"KeyboardInputs":[[]], "ControllerInputs":[[]],
			"Combination":[[0, 3]]},
		{"Name":"Tech", "Type":Castagne.PHYSICALINPUT_TYPES.ANY,
			"KeyboardInputs":[[]], "ControllerInputs":[[]],
			"Combination":[[1, 0], [2, 0], [3, 0]]},
		{"Name":"Pause", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_ENTER, KEY_ESCAPE]]], "ControllerInputs":[[[JOY_START]]]},
		{"Name":"Reset", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_BACK]]], "ControllerInputs":[[[JOY_SELECT]]]},
		{"Name":"TrainingButton1", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[]]], "ControllerInputs":[[[JOY_L3]]]},
		{"Name":"TrainingButton2", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[]]], "ControllerInputs":[[[JOY_R3]]]},
	], {"Flags":["Hidden"], "Description":"The complete InputLayout to use."})
	
	RegisterConfig("InputLayoutMenu", [
		{"Name":"MenuUp", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_Z, KEY_W, KEY_SPACE, KEY_UP]]], "ControllerInputs":[[[JOY_DPAD_UP]]]},
		{"Name":"MenuDown", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_S, KEY_DOWN]]], "ControllerInputs":[[[JOY_DPAD_DOWN]]]},
		{"Name":"MenuLeft", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_A, KEY_Q, KEY_LEFT]]], "ControllerInputs":[[[JOY_DPAD_LEFT]]]},
		{"Name":"MenuRight", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_D, KEY_RIGHT]]], "ControllerInputs":[[[JOY_DPAD_RIGHT]]]},
		
		{"Name":"MenuConfirm", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_N, KEY_KP_0]]], "ControllerInputs":[[[JOY_XBOX_A]]]},
		{"Name":"MenuBack", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_K, KEY_KP_6]]], "ControllerInputs":[[[JOY_XBOX_B]]]},
		{"Name":"MenuPrevious", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_Y, KEY_KP_1]]], "ControllerInputs":[[[JOY_L]]]},
		{"Name":"MenuNext", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_U, KEY_KP_2]]], "ControllerInputs":[[[JOY_R]]]},
	], {"Flags":["Hidden"], "Description":"The complete input layout for menus."})

	RegisterCustomConfig("Define Input Layout", "InputConfig", {"Flags":["ReloadFull", "LockBack"]})

	RegisterConfig("NumberOfKeyboardPlayers", 2, {"Description":"Number of keyboard devices to setup."})
	RegisterConfig("NumberOfKeyboardLayouts", 2, {"Description":"Number of keyboard default bindings to make available."})
	RegisterConfig("NumberOfControllerPlayers", 4, {"Description":"Number of controller devices to setup."})
	RegisterConfig("NumberOfControllerLayouts", 2, {"Description":"Number of controller default bindings to make available."})

	RegisterVariableGlobal("_InputsRaw", [], null, {"Description":"Hold the raw inputs themselves, set by the engine."})
	RegisterVariableGlobal("_InputsProcessed", [], null, {"Description":"Holds the input data for each player."})
	RegisterVariableGlobal("_InputsProcessedPrevious", [], null, {"Description":"Holds the previous values of _InputsProcessed"})
	RegisterConfig("InputBufferSizePress", 3, {"Flags":["Advanced"], "Description":"Number of frames an input press/release event will be active."})
	RegisterVariableEntity("_Inputs", {}, null, {"Description":"Holds the input data of the entity."})
	RegisterVariableEntity("_InputsPrevious", [], null, {"Description":"Holds the previous values of _Inputs"})

	RegisterCategory("Fake Presses", {"Description":"Functions to simulate fake pressed during the AI phase. Untested."})

	# Untested
	RegisterFunction("InputPress", [1], ["AI"], {
		"Description":"Makes a fake input press. Untested.",
		"Arguments":["Input Name"],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("InputRelease", [1], ["AI"], {
		"Description":"Makes a fake input unpress. Untested.",
		"Arguments":["Input Name"],
		"Flags":["Intermediate"],
		"Types":["str"],
	})

	RegisterCategory("Input Transition", {"Description":"Functions relating to the Input Transition system, which allows a user to setup transitions when a certain input is pressed."})

	RegisterFunction("InputTransition", [1,2,3], ["Action"], {
		"Description":"Sets up an input transition, which will do a transition when the input given is pressed.",
		"Arguments":["The input to watch for, in numpad notation.", "(Optional) The name of the state to transition to. By default, the same as the notation.", "(Optional) The priority for the transition. By default, the value specified in the castagne config."],
		"Flags":["Intermediate"],
		"Types":["str", "str", "int"],
		})
	RegisterFunction("InputFlag", [1,2,3], ["Action"], {
		"Description":"Sets up an input flag, which will raise a flag when the input given is pressed.",
		"Arguments":["The input to watch for, in numpad notation.", "(Optional) The name of the flag to raise. By default, the same as the notation.", "(Optional) The priority for the transition. By default, the value specified in the castagne config."],
		"Flags":["Intermediate"],
		"Types":["str", "str", "int"],
		})
	RegisterFunction("InputFlagNext", [1,2,3], ["Action"], {
		"Description":"Sets up an input flag, which will raise a flag next frame when the input given is pressed.",
		"Arguments":["The input to watch for, in numpad notation.", "(Optional) The name of the flag to raise. By default, the same as the notation.", "(Optional) The priority for the transition. By default, the value specified in the castagne config."],
		"Flags":["Intermediate"],
		"Types":["str", "str", "int"],
		})
	RegisterFunction("InputTransitionFlag", [1,2,3,4], ["Action"], {
		"Description":"Sets up an input transition and an input flag, which will do a transition and raise a flag when the input given is pressed.",
		"Arguments":["The input to watch for, in numpad notation.", "(Optional) The name of the state to transition to. By default, the same as the notation.", "(Optional) The name of the flag to raise. By default, the same as the notation.", "(Optional) The priority for the transition. By default, the value specified in the castagne config."],
		"Flags":["Intermediate"],
		"Types":["str", "str", "str", "int"],
		})
	RegisterFunction("InputTransitionFlagNext", [1,2,3,4], ["Action"], {
		"Description":"Sets up an input transition and an input flag, which will do a transition and raise a flag when the input given is pressed.",
		"Arguments":["The input to watch for, in numpad notation.", "(Optional) The name of the state to transition to. By default, the same as the notation.", "(Optional) The name of the flag to raise. By default, the same as the notation.", "(Optional) The priority for the transition. By default, the value specified in the castagne config."],
		"Flags":["Intermediate"],
		"Types":["str", "str", "str", "int"],
		})
	RegisterVariableEntity("_InputTransitionList", [], ["ResetEachFrame"], {"Description":"List of the input transitions to watch for."})
	RegisterVariableEntity("_FrozenInputTransition", null, {"Description":"Holds the input transition data during the freeze phase."})
	RegisterConfig("InputTransitionDefaultPriority", 1000, {"Description":"The default Transition priority for InputTransition."})

	RegisterCategory("Motion Inputs", {"Description":"System for detecting when motion input has been performed by a player."})

	RegisterConfig("EnableMotionInputs", true, {"Description":"Toggle to disable motion inputs engine-wide.", "Flags":["Basic"]})

	RegisterConfig("DirectionalInputBuffer", 60, {"Description":"Number of frames the module retains the directional inputs from. This value should be greater than the longest motion input times the individual input interval for that motion.", "Flags":["Advanced"]})
	RegisterConfig("ShortMotionInterval", 12, {"Description":"Maximum number of frames between inputs for a motion to remain valid. This value is for motions with three directions or less.", "Flags":["Advanced"]})
	RegisterConfig("LongMotionInterval", 8, {"Description":"Maximum number of frames between inputs for a motion to remain valid. This value is for motions with more than three directions.", "Flags":["Advanced"]})
	RegisterConfig("ButtonInterval", 8, {"Description":"Maximum number of frames between motion input and pressing the button for a motion to remain valid.", "Flags":["Advanced"]})
	RegisterConfig("MinChargeTime", 30, {"Description":"Minimum number of frames for a direction to be held for a valid charge input.", "Flags":["Advanced"]})
	RegisterConfig("StrictDiagonalCharge", false, {"Description":"If enabled, holding a diagonal direction will not count as charing the two diagional inputs.", "Flags":["Advanced"]})
	
	RegisterConfig("MotionAliases", [
		{"Name":"360","Aliases":"2684, 6842, 8426, 4268"},
		{"Name":"41236","Aliases":"4126, 4236"},
		{"Name":"63214","Aliases":"6324, 6214"},
	], {"Description":"List of motion input aliases.", "Flags":["Hidden"]})
	
	RegisterCustomConfig("Define Motion Input Aliases", "InputMotionAliases", {"Flags":["Advanced", "ReloadFull", "LockBack"]})

	RegisterVariableEntity("_DirectionalInputLog", [], null, {"Description":"Array containing just the raw directional inputs for a player on each frame. Inputs are held for a number of frames equal to the buffer config variable."})

var _castagneInputScript = load("res://castagne/engine/CastagneInput.gd")
func OnModuleRegistration(configData):
	var input = Node.new()
	input.set_script(_castagneInputScript)
	add_child(input)
	configData._input = input
	input.InitializeFromConfigData(configData)

func FrameStart(stateHandle):
	var inputsProcessed = []
	var inputsRaw = stateHandle.GlobalGet("_InputsRaw")
	var castagneInput = stateHandle.Input()
	var frozenFrame = stateHandle.GlobalGet("_FrozenFrame")

	for pid in range(stateHandle.GlobalGet("_NbPlayers")):
		var raw = null
		if(inputsRaw.size() > pid):
			raw = inputsRaw[pid]
		else:
			raw = castagneInput.PollDevice(null)

		var inputData = castagneInput.CreateInputDataFromRawInput(raw)
		inputsProcessed.push_back(inputData)



	# :TODO:Panthavma:20230228:This is kind of a shortcut, can be improved in v0.7 with a second buffer. Good enough for now
	var previousProcessed = stateHandle.GlobalGet("_InputsProcessedPrevious")
	if(previousProcessed.size() >= stateHandle.ConfigData().Get("InputBufferSizePress")):
		previousProcessed.pop_back()
	if(!frozenFrame):
		previousProcessed.push_front(stateHandle.GlobalGet("_InputsProcessed"))
	stateHandle.GlobalSet("_InputsProcessedPrevious", previousProcessed)

	stateHandle.GlobalSet("_InputsProcessed", inputsProcessed)

	var activeEIDs = stateHandle.GlobalGet("_ActiveEntities")
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)

		# Why is the input weird when coming from the last frame
		var lastFrameInput = stateHandle.EntityGet("_Inputs")
		var previousInput = stateHandle.EntityGet("_InputsPrevious")
		if(previousInput.size() >= stateHandle.ConfigData().Get("InputBufferSizePress")):
			previousInput.pop_back()
		previousInput.push_front(lastFrameInput)
		stateHandle.EntitySet("_InputsPrevious", previousInput)

		var inputData = inputsProcessed[stateHandle.EntityGet("_Player")].duplicate()
		stateHandle.EntitySet("_Inputs", inputData)

func InitPhaseEndEntity(stateHandle):
	var inputsProcessed = stateHandle.GlobalGet("_InputsProcessed")
	var inputData = inputsProcessed[stateHandle.EntityGet("_Player")].duplicate()
	stateHandle.EntitySet("_Inputs", inputData)

func InputPhase(stateHandle, activeEIDs):
	var castagneInput = stateHandle.Input()
	var inputSchema = castagneInput.GetInputSchema()


	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)

		var inputs = stateHandle.EntityGet("_Inputs")
		var previousInputsList = stateHandle.EntityGet("_InputsPrevious")
		if(previousInputsList.empty() or previousInputsList[0].empty()):
			continue

		for derivedInputName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.DERIVED]:
			var derivedInput = inputSchema[derivedInputName]
			var diType = derivedInput["DerivedType"]
			var diValue = false

			if(diType == Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_PRESS):
				var diTarget = derivedInput["Target"]
				if(inputs[diTarget]):
					for previousInputs in previousInputsList:
						if(previousInputs.has(diTarget) and !previousInputs[diTarget]):
							diValue = true
			elif(diType == Castagne.GAMEINPUT_DERIVED_TYPES.BUTTON_RELEASE):
				var diTarget = derivedInput["Target"]
				if(!inputs[diTarget]):
					for previousInputs in previousInputsList:
						if(previousInputs.has(diTarget) and previousInputs[diTarget]):
							diValue = true
			elif(diType == Castagne.GAMEINPUT_DERIVED_TYPES.DIRECTION_NEUTRAL):
				var diTargets = derivedInput["Targets"]
				diValue = true
				for targetName in diTargets:
					if(inputs[targetName]):
						diValue = false
			else:
				continue
			pass
			inputs[derivedInputName] = diValue
		if(inputs["ForwardRelease"]):
			pass
		stateHandle.EntitySet("_Inputs", inputs)

func InputPhaseEndEntity(stateHandle):
	if(stateHandle.ConfigData().Get("EnableMotionInputs")):
		LogDirectionalInputs(stateHandle)

#checks for inputs during the freeze phase
func FreezePhaseStartEntity(stateHandle):
	var frozenInputTransition = FindCorrectInputTransition(stateHandle)
	if frozenInputTransition != null:
		stateHandle.EntitySet("_FrozenInputTransition", frozenInputTransition)

func ReactionPhaseStartEntity(stateHandle):
	var inputTransition = FindCorrectInputTransition(stateHandle)
	var frozenIT = stateHandle.EntityGet("_FrozenInputTransition")
	
	#checks if there is an input from the freeze phase that is still a valid input and sets it as the input transition
	if frozenIT != null:
		if inputTransition == null:
			var itl = stateHandle.EntityGet("_InputTransitionList")
			for input in itl:
				if input["TargetState"] != frozenIT["TargetState"]:
					continue
				if input["TargetFlag"] != frozenIT["TargetFlag"]:
					continue
				if input["TargetFlagNext"] != frozenIT["TargetFlagNext"]:
					continue
				inputTransition = frozenIT
				break
		stateHandle.EntitySet("_FrozenInputTransition", null)
	
	if(inputTransition != null):
		var coreModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
		if(inputTransition["TargetState"] != null):
			coreModule.Transition([inputTransition["TargetState"], inputTransition["Priority"]], stateHandle)
		if(inputTransition["TargetFlag"] != null):
			coreModule.Flag([inputTransition["TargetFlag"]], stateHandle)
		if(inputTransition["TargetFlagNext"] != null):
			coreModule.FlagNext([inputTransition["TargetFlagNext"]], stateHandle)

func FindCorrectInputTransition(stateHandle):
	var inputTransitionList = stateHandle.EntityGet("_InputTransitionList")
	var inputs = stateHandle.EntityGet("_Inputs")
	var inputLayout = stateHandle.ConfigData().Get("InputLayout")

	if(inputs.empty() or inputTransitionList.empty()):
		return null

	var prefix = ""
	#var alwaysAllowNeutralV = (prefix != "") # Prevents cancels to 5x when crouching
	var alwaysAllowNeutralV = stateHandle.EntityHasFlag("Airborne")
	# :TODO:Panthavma:20230606:Temporary for neutralV, need an actual system

	# TODO Make inputs a combination of motion + buttons ; with their own priority

	# Get directions and their priority
	var directions = []
	if(inputs["Up"]):
		if(inputs["Forward"]):
			directions += [["9", 90]]
		elif(inputs["Back"]):
			directions += [["7", 80]]
		directions += [["8", 70]]
	elif(inputs["Down"]):
		if(inputs["Forward"]):
			directions += [["3", 60]]
		elif(inputs["Back"]):
			directions += [["1", 50]]
		directions += [["2", 40]]

	if(directions.empty() or alwaysAllowNeutralV):
		if(inputs["Forward"]):
			directions += [["6", 30]]
		elif(inputs["Back"]):
			directions += [["4", 20]]
		directions += [["5", 10]]
	
	var performedMotions = []
	if(stateHandle.ConfigData().Get("EnableMotionInputs")):
		var validMotions = GetMotionsFromInputList(stateHandle, inputTransitionList)
		performedMotions = GetMotionInputs(stateHandle, validMotions)
	
	#add motion inputs to the list of "directions"
	var motionPriority = 100
	for motion in performedMotions:
		directions += [[motion, motionPriority]]
		motionPriority += 10

	# Add Buttons and their priority
	var attackButtons = []

	# First, get the buttons and combinations
	var inputLayoutButtons = []
	var inputLayoutCombinations = []
	for il in inputLayout:
		if(il["Type"] == Castagne.PHYSICALINPUT_TYPES.BUTTON):
			inputLayoutButtons.push_back(il)
		elif(il["Type"] == Castagne.PHYSICALINPUT_TYPES.COMBINATION):
			inputLayoutCombinations.push_back(il)
		elif(il["Type"] == Castagne.PHYSICALINPUT_TYPES.ANY):
			inputLayoutCombinations.push_back(il)
	inputLayoutButtons.append_array(inputLayoutCombinations)

	var buttonPriority = 0
	for il in inputLayoutButtons:
		var buttonName = il["Name"]
		var pressName = buttonName + "Press"
		var releaseName = buttonName + "Release"
		buttonPriority += 10
		if(inputs[pressName]):
			attackButtons += [[buttonName, buttonPriority]]
		elif(inputs[releaseName]):
			attackButtons += [["]"+buttonName+"[", buttonPriority]]

	# Create all the notations we may find
	var nbAttackButtons = attackButtons.size()
	var nbAttackButtonCombinations = int(pow(2, nbAttackButtons))
	var possibleCancels = {}
	for i in range(nbAttackButtonCombinations):
		var buttonsNotation = ""
		var buttonsUsed = []
		var modulo = 2
		for j in range(nbAttackButtons):
			if(i%modulo):
				i -= modulo/2
				buttonsUsed += [attackButtons[j]]
				buttonsNotation += attackButtons[j][0]
			modulo *= 2

		for d in directions:
			var notation = d[0] + buttonsNotation
			var notationData = {
				"Notation": notation,
				"Direction": d,
				"Buttons": buttonsUsed
			}
			possibleCancels[notation] = notationData
	var possibleCancelsNotations = possibleCancels.keys()


	# Find which we are using
	var inputTransitionMaxPriority = null
	var inputTransitionToSort = []
	for itd in inputTransitionList:
		var notation = itd["InputNotation"]
		var priority = itd["Priority"]
		if(notation in possibleCancelsNotations):
			itd["Notation"] = possibleCancels[notation]
			if(inputTransitionMaxPriority == null or inputTransitionMaxPriority < priority):
				inputTransitionMaxPriority = priority
				inputTransitionToSort = [itd]
			elif(inputTransitionMaxPriority == priority):
				inputTransitionToSort.push_back(itd)

	# Get the highest priority one
	if(inputTransitionMaxPriority != null):
		var it = inputTransitionToSort[0]
		for i in range(1, inputTransitionToSort.size()):
			var itB = inputTransitionToSort[i]
			if(_InputTransitionCompareNotationPriority(it["Notation"], itB["Notation"])):
				it = itB
		return it
	return null

# Returns true if b > a
func _InputTransitionCompareNotationPriority(a, b):
	# Maybe need to check for motions first ?

	# Check if one has more buttons
	var buttonsDiff = a["Buttons"].size() - b["Buttons"].size()
	if(buttonsDiff != 0):
		return buttonsDiff < 0

	# Find who has the highest priority button
	for i in range(a["Buttons"].size()-1, -1, -1):
		var buttonPrioDiff = a["Buttons"][i][1] - b["Buttons"][i][1]
		if(buttonPrioDiff != 0):
			return buttonPrioDiff < 0

	# Find who has the higher priority direction
	var directionDiff = a["Direction"][1] - b["Direction"][1]
	return directionDiff < 0

# Untested
func InputPress(args, stateHandle):
	_InputSet(args, stateHandle, true)
func InputRelease(args, stateHandle):
	_InputSet(args, stateHandle, false)

func _InputSet(args, stateHandle, press):
	var castagneInput = stateHandle.Input()
	var inputSchema = castagneInput.GetInputSchema()
	var buttonName = ArgStr(args, 0, stateHandle)

	if(buttonName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.DIRECT]):
		var inputs = stateHandle.EntityGet("_Inputs")
		inputs[buttonName] = press

		# Update the combination buttons the button is part of
		var multipleInputs = inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.COMBINATION] + inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.ANY]
		for combiName in multipleInputs:
			var combiButtons = inputSchema[combiName]["Combination"]
			var combiAny = inputSchema[combiName]["CombinationAny"]
			if(!(buttonName in combiButtons)):
				continue
			var shouldPress = (false if combiAny else true)
			for combiButton in combiButtons:
				if(combiAny):
					if(inputs[combiButton]):
						shouldPress = true
				else:
					if(!inputs[combiButton]):
						shouldPress = false
			inputs[combiName] = shouldPress
		stateHandle.EntitySet("_Inputs", inputs)
	elif(buttonName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.COMBINATION] or
		buttonName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.ANY]):
		var combiButtons = inputSchema[buttonName]["Combination"]
		var combiAny = inputSchema[buttonName]["CombinationAny"]
		if(combiAny):
			var isOnePressed = false
			for combiButton in combiButtons:
				if(inputSchema[combiButton]):
					isOnePressed = true
			if(!isOnePressed):
				_InputSet([combiButtons[0]], stateHandle, press)
		else:
			for combiButton in combiButtons:
				_InputSet([combiButton], stateHandle, press)
	elif(buttonName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.DERIVED]):
		ModuleError("InputPress: "+str(buttonName)+" is a derived input, which can't be pressed directly.")
	else:
		ModuleError("InputPress: "+str(buttonName)+" couldn't be found in the input schema.")



func InputTransition(args, stateHandle):
	var inputNotation = ArgStr(args, stateHandle, 0)
	var targetState = ArgStr(args, stateHandle, 1, inputNotation)
	var priority = ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("InputTransitionDefaultPriority"))
	AddInputTransitionFlag(stateHandle, inputNotation, targetState, null, null, {"Priority":priority})

func InputFlag(args, stateHandle):
	var inputNotation = ArgStr(args, stateHandle, 0)
	var targetFlag = ArgStr(args, stateHandle, 1, inputNotation)
	var priority = ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("InputTransitionDefaultPriority"))
	AddInputTransitionFlag(stateHandle, inputNotation, null, targetFlag, {"Priority":priority})

func InputFlagNext(args, stateHandle):
	var inputNotation = ArgStr(args, stateHandle, 0)
	var targetFlag = ArgStr(args, stateHandle, 1, inputNotation)
	var priority = ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("InputTransitionDefaultPriority"))
	AddInputTransitionFlag(stateHandle, inputNotation, null, null, targetFlag, {"Priority":priority})

func InputTransitionFlag(args, stateHandle):
	var inputNotation = ArgStr(args, stateHandle, 0)
	var targetState = ArgStr(args, stateHandle, 1, inputNotation)
	var targetFlag = ArgStr(args, stateHandle, 2, inputNotation)
	var priority = ArgInt(args, stateHandle, 3, stateHandle.ConfigData().Get("InputTransitionDefaultPriority"))
	AddInputTransitionFlag(stateHandle, inputNotation, targetState, targetFlag, null, {"Priority":priority})

func InputTransitionFlagNext(args, stateHandle):
	var inputNotation = ArgStr(args, stateHandle, 0)
	var targetState = ArgStr(args, stateHandle, 1, inputNotation)
	var targetFlag = ArgStr(args, stateHandle, 2, inputNotation)
	var priority = ArgInt(args, stateHandle, 3, stateHandle.ConfigData().Get("InputTransitionDefaultPriority"))
	AddInputTransitionFlag(stateHandle, inputNotation, targetState, null, targetFlag, {"Priority":priority})

func AddInputTransitionFlag(stateHandle, inputNotation, targetState = null, targetFlag = null, targetFlagNext = null, data = {}):
	var itd = {
		"InputNotation":inputNotation,
		"Priority":stateHandle.ConfigData().Get("InputTransitionDefaultPriority"),
		"Callback":null,
		"TargetState": targetState,
		"TargetFlag": targetFlag,
		"TargetFlagNext": targetFlagNext,
	}
	
	Castagne.FuseDataOverwrite(itd, data)
	
	stateHandle.EntityAdd("_InputTransitionList", [itd])

#creates log of inputs ordered from newest to oldest
func LogDirectionalInputs(stateHandle):
	var inputs = stateHandle.EntityGet("_Inputs")
	var buffer = stateHandle.ConfigData().Get("DirectionalInputBuffer")
	var direction = 5
	var inputLog = stateHandle.EntityGet("_DirectionalInputLog")
	
	if inputLog.empty():
		inputLog.resize(buffer)
		inputLog.fill(5)
	
	if(inputs["Up"]):
		direction += 3
	
	if(inputs["Down"]):
		direction -= 3
	
	if(inputs["Forward"]):
		direction += 1
	
	if(inputs["Back"]):
		direction -= 1
	
	direction = str(direction)
	
	inputLog.push_front(direction)
	inputLog.resize(buffer)
	stateHandle.EntitySet("_DirectionalInputLog", inputLog)

#checks the input log to see if a motion was done
func MotionInputCheck(stateHandle, motion):
	var inputLog = stateHandle.EntityGet("_DirectionalInputLog")
	var minChargeTime = stateHandle.ConfigData().Get("MinChargeTime")
	var strictDiag = stateHandle.ConfigData().Get("StrictDiagonalCharge")
	
	var inputFrames = [0]
	
	var directions = []
	
	#convert the notation from str to array and reverse the order so the latest inputs are checked first
	for i in len(motion):
		if motion[i] == "]":
			pass
		elif i > 0 && motion[i-1] == "[" && !strictDiag:
			if motion[i] == "2":
				directions.push_front("123")
			elif motion[i] == "4":
				directions.push_front("147")
			elif motion[i] == "6":
				directions.push_front("369")
			elif motion[i] == "8":
				directions.push_front("789")
			else:
				directions.push_front(motion[i])
		else:
			directions.push_front(motion[i])
		if i > 0 && motion[i] == motion[i-1]:
			directions.insert(1,"5")
	
	var intervals = []
	intervals.resize(len(directions)-1)
	
	if len(directions) <= 3:
		intervals.fill(stateHandle.ConfigData().Get("ShortMotionInterval"))
	else:
		intervals.fill(stateHandle.ConfigData().Get("LongMotionInterval"))
	intervals.append(stateHandle.ConfigData().Get("ButtonInterval"))

	for i in range(0, len(directions)):
		#need "[" to mark charges but it doesn't need to be parsed - this should really only be a factor if the motion has a charge partway through it
		if directions[i] == "[":
			inputFrames.append(inputLog[i-1])
		else:
			var frame = -1
			#if the input is a charge, check if there is a sequence of consective inputs longer than the charge time
			if i < len(directions)-1 && directions[i+1] == "[":
				var count = 0
				var maxCharge = 0
				var firstFrame = 0
				for j in range(inputFrames[i],inputFrames[i]+intervals[i]+minChargeTime):
					if inputLog[j] in directions[i]:
						count += 1
						if count > maxCharge:
							maxCharge = count
							firstFrame = j
					else:
						count = 0
				if maxCharge >= minChargeTime:
					inputFrames.append(firstFrame)
				else:
					return
			#otherwise, just check if the input is present in the log between the previous input and the buffer interval
			else:
				frame = inputLog.find(directions[i],inputFrames[i])
				if frame in range(inputFrames[i],inputFrames[i]+intervals[i]):
					inputFrames.append(frame)
				else:
					return
	return motion

#parses possible motions and aliases from the input transition list 
func GetMotionsFromInputList(stateHandle, itl):
	var validChars = ["0","1","2","3","4","5","6","7","8","9","[","]"]
	var motionList = []
	for i in range(0, len(itl)):
		var motion = ""
		var input = itl[i]["InputNotation"]
		#for each input, pulls only the valid characters
		for c in range(0, len(input)):
			if validChars.has(input[c]):
				motion += input[c]
		#if the input has 2 or more valid characters, it is counted as a motion
		if len(motion) > 1 and !motionList.has(motion):
			motionList += [motion]
			var aliases = GetMotionAliases(stateHandle, motion)
			for a in range(0, len(aliases)):
				if len(aliases[a]) > 1 and !motionList.has(aliases[a]):
					motionList += [aliases[a]]
	return motionList

#pulls the aliases of a motion input from the config
func GetMotionAliases(stateHandle, motion):
	var motionAliases = stateHandle.ConfigData().Get("MotionAliases")
	for dict in motionAliases:
		if dict["Name"] == motion:
			return Castagne.SplitStringToArray(dict["Aliases"])
	return []

#checks the list of possible motions to determine which ones, if any, were performed
func GetMotionInputs(stateHandle, validMotions):
	var motions = []
	
	for m in validMotions:
		if MotionInputCheck(stateHandle, m):
			motions += [m]
			var mainMotion = GetMainMotion(stateHandle, m)
			if len(mainMotion) > 1:
				motions += [mainMotion]
	return motions

#finds the main motion given an alias
func GetMainMotion(stateHandle, alias):
	var motionAliases = stateHandle.ConfigData().Get("MotionAliases")
	for dict in motionAliases:
		var aliases = Castagne.SplitStringToArray(dict["Aliases"])
		for a in aliases:
			if a == alias:
				return dict["Name"]
	return ""
