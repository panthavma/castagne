extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Input", Castagne.MODULE_SLOTS_BASE.INPUT, {
		"Description":"Module handling Input inside of the Castagne Engine. Works closely together with CastagneInput.gd. Please read the Intermediate Guide/Castagne Input page for more details."})
	#RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Core.casp", -9000)

	RegisterCategory("Input Definition", {"Description":"Holds the input layout and default bindings."})

	RegisterConfig("InputLayout", [
		{"Name":"Movement", "Type":Castagne.PHYSICALINPUT_TYPES.STICK,
			"KeyboardInputs":[[[KEY_A, KEY_Q, KEY_LEFT]], [[KEY_D, KEY_RIGHT]], [[KEY_S, KEY_DOWN]], [[KEY_Z, KEY_W, KEY_SPACE, KEY_UP]]],
			"ControllerInputs":[[[JOY_DPAD_LEFT]], [[JOY_DPAD_RIGHT]], [[JOY_DPAD_DOWN]], [[JOY_DPAD_UP]]],
			"GameInputNames":["Left", "Right", "Down", "Up", "Back", "Forward", "Portside", "Starboard", "NeutralH", "NeutralV"]},
		{"Name":"L", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_H, KEY_KP_4]]], "ControllerInputs":[[[JOY_XBOX_X]]]},
		{"Name":"M", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_J, KEY_KP_5]]], "ControllerInputs":[[[JOY_XBOX_Y]]]},
		{"Name":"H", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_K, KEY_KP_6]]], "ControllerInputs":[[[JOY_XBOX_B]]]},
		{"Name":"S", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_L, KEY_KP_0]]], "ControllerInputs":[[[JOY_XBOX_A]]]},
		{"Name":"Throw", "Type":Castagne.PHYSICALINPUT_TYPES.COMBINATION,
			"KeyboardInputs":[[[KEY_KP_ADD]]], "ControllerInputs":[[[JOY_L]]],
			"Combination":[[1, 0], [2, 0]], "CombinationAny":false},
		{"Name":"Jump", "Type":Castagne.PHYSICALINPUT_TYPES.COMBINATION,
			"KeyboardInputs":[[]], "ControllerInputs":[[]],
			"Combination":[[0, 3]], "CombinationAny":true},
		{"Name":"Tech", "Type":Castagne.PHYSICALINPUT_TYPES.COMBINATION,
			"KeyboardInputs":[[]], "ControllerInputs":[[]],
			"Combination":[[1, 0], [2, 0], [3, 0]], "CombinationAny":true},
		{"Name":"Pause", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_ENTER, KEY_ESCAPE]]], "ControllerInputs":[[[JOY_START]]]},
		{"Name":"Reset", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_BACK]]], "ControllerInputs":[[[JOY_SELECT]]]},
		{"Name":"TrainingButton1", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[]]], "ControllerInputs":[[[JOY_L3]]]},
		{"Name":"TrainingButton2", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[]]], "ControllerInputs":[[[JOY_R3]]]},
	], {"Flags":["Hidden"], "Description":"The complete InputLayout to use."})

	RegisterCustomConfig("Define Input Layout", "InputConfig", {"Flags":["LockBack"]})

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
	RegisterVariableEntity("_InputTransitionList", [], ["ResetEachFrame"], {"Description":"List of the input transitions to watch for."})
	RegisterConfig("InputTransitionDefaultPriority", 1000, {"Description":"The default Transition priority for InputTransition."})

	RegisterModule("Motion Inputs", null, {"Description":"Module handling motion inputs, allowing them to used as part of the input and attack cancel systems."})


	RegisterCategory("Motion Inputs", {"Description":"System for detecting when motion input has been performed by a player."})

	RegisterConfig("DirectionalInputBuffer", 60, {"Description":"Number of frames the module retains the directional inputs from. This value should be greater than the longest motion input times the individual input interval for that motion."})
	RegisterConfig("ShortMotionInterval", 12, {"Description":"Maximum number of frames between inputs for a motion to remain valid. This value is for motions with three directions or less."})
	RegisterConfig("LongMotionInterval", 8, {"Description":"Maximum number of frames between inputs for a motion to remain valid. This value is for motions with more than three directions."})
	RegisterConfig("ButtonInterval", 8, {"Description":"Maximum number of frames between motion input and pressing the button for a motion to remain valid."})
	#crosseyed: the above three values determine the number of frames between inputs in a motion. By default, shorter motions have more leniency.

	RegisterConfig("ValidMotionInputs","236, 214, 623, 421, 41236, 63214, 252",{"Description":"Motion inputs in numpad notation that the system will check for."})

	RegisterVariableEntity("DirectionalInputLog", [], {"Description":"Array containing just the raw directional inputs for a player. Inputs are held for a number of frames equal to the buffer config variable."})
	RegisterVariableEntity("PerformedMotions",[],{"Description":"Array containing the motions that have been performed by the player."})

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


func InputPhase(stateHandle, _previousStateHandle, activeEIDs):
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

			if(derivedInputName == "ForwardPress"):
				pass
			if(derivedInputName == "ForwardRelease"):
				pass
			if(derivedInputName == "APress"):
				pass

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
	LogDirectionalInputs(stateHandle)

	var validMotions = Castagne.SplitStringToArray(stateHandle.ConfigData().Get("ValidMotionInputs"))
	var motions = []

	for m in validMotions:
		if MotionInputCheck(stateHandle, m):
			motions += [m]
	stateHandle.EntitySet("PerformedMotions", motions)

	#print performed motions to the log for testing
#	if motions.size() > 0:
#		print(motions)

func ReactionPhaseStartEntity(stateHandle):
	var inputTransition = FindCorrectInputTransition(stateHandle)
	if(inputTransition != null):
		var coreModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
		coreModule.Transition([inputTransition["TargetState"], inputTransition["Priority"]], stateHandle)

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

	#add motion inputs to the list of "directions"
	var motionPriority = 100
	for motion in stateHandle.EntityGet("PerformedMotions"):
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
	inputLayoutButtons.append_array(inputLayoutCombinations)

	var buttonPriority = 0
	for il in inputLayoutButtons:
		var buttonName = il["Name"]
		var pressName = buttonName + "Press"
		buttonPriority += 10
		if(inputs[pressName]):
			attackButtons += [[buttonName, buttonPriority]]

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
		for combiName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.COMBINATION]:
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
	elif(buttonName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.COMBINATION]):
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
	AddInputTransition(stateHandle, inputNotation, targetState, {"Priority":priority})

func AddInputTransition(stateHandle, inputNotation, targetState, data = {}):
	var itd = {
		"InputNotation":inputNotation,
		"TargetState":targetState,
		"Priority":stateHandle.ConfigData().Get("InputTransitionDefaultPriority"),
		"Callback":null,
	}

	Castagne.FuseDataOverwrite(itd, data)

	stateHandle.EntityAdd("_InputTransitionList", [itd])

#motion input stuff:
func LogDirectionalInputs(stateHandle):
	var inputs = stateHandle.EntityGet("_Inputs")
	var buffer = stateHandle.ConfigData().Get("DirectionalInputBuffer")
	var direction = "5"
	var inputLog = stateHandle.EntityGet("DirectionalInputLog")

	if(inputs["Up"]):
		if(inputs["Forward"]):
			direction = "9"
		elif(inputs["Back"]):
			direction = "7"
		else:
			direction = "8"
	elif(inputs["Down"]):
		if(inputs["Forward"]):
			direction = "3"
		elif(inputs["Back"]):
			direction = "1"
		else:
			direction = "2"
	else:
		if(inputs["Forward"]):
			direction = "6"
		elif(inputs["Back"]):
			direction = "4"

	inputLog.push_front(direction)
	inputLog.resize(buffer)
	stateHandle.EntitySet("DirectionalInputLog", inputLog)

func MotionInputCheck(stateHandle, motion):
	var inputLog = stateHandle.EntityGet("DirectionalInputLog")
	var inputFrames = [0]

	var directions = []

	for i in motion:
		directions.push_front(i)

	var intervals = []
	intervals.resize(len(directions)-1)

	if len(directions) <= 3:
		intervals.fill(stateHandle.ConfigData().Get("ShortMotionInterval"))
	else:
		intervals.fill(stateHandle.ConfigData().Get("LongMotionInterval"))
	intervals.append(stateHandle.ConfigData().Get("ButtonInterval"))

	for i in range(0, len(directions)):
		var frame = inputLog.find(directions[i],inputFrames[i])
		inputFrames.append(frame)
		if !frame in range(inputFrames[i],inputFrames[i]+intervals[i]):
			return
	return motion
