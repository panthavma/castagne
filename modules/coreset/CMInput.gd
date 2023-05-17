extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Input", Castagne.MODULE_SLOTS_BASE.INPUT, {"Description":"Module handling Input inside of the Castagne Engine. Works closely together with CastagneInput.gd. Please read the Intermediate Guide/Castagne Input page for more details."})
	#RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Core.casp", -9000)
	
	RegisterCategory("Input Definition", {"Description":"Holds the input layout and default bindings."})
	
	RegisterConfig("InputLayout", [
		{"Name":"Movement", "Type":Castagne.PHYSICALINPUT_TYPES.STICK,
			"KeyboardInputs":[[[KEY_A, KEY_Q]], [[KEY_D]], [[KEY_S]], [[KEY_Z, KEY_W, KEY_SPACE]]],
			"ControllerInputs":[[[JOY_DPAD_LEFT]], [[JOY_DPAD_RIGHT]], [[JOY_DPAD_DOWN]], [[JOY_DPAD_UP]]],
			"GameInputNames":["Left", "Right", "Down", "Up", "Back", "Forward", "Portside", "Starboard", "NeutralH", "NeutralV"]},
		{"Name":"A", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_H, KEY_KP_4]]], "ControllerInputs":[[[JOY_XBOX_X]]]},
		{"Name":"B", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_J, KEY_KP_5]]], "ControllerInputs":[[[JOY_XBOX_Y]]]},
		{"Name":"C", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_K, KEY_KP_6]]], "ControllerInputs":[[[JOY_XBOX_B]]]},
		{"Name":"D", "Type":Castagne.PHYSICALINPUT_TYPES.BUTTON, "KeyboardInputs":[[[KEY_L, KEY_KP_0]]], "ControllerInputs":[[[JOY_XBOX_A]]]},
		{"Name":"Throw", "Type":Castagne.PHYSICALINPUT_TYPES.COMBINATION,
			"KeyboardInputs":[[[KEY_KP_ADD]]], "ControllerInputs":[[[JOY_L]]],
			"Combination":[[1, 0], [2, 0]]},
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
	RegisterFunction("InputPress", [1], ["AI"])
	RegisterFunction("InputRelease", [1], ["AI"])
	
	RegisterCategory("Input Transition", {"Description":"Functions relating to the Input Transition system, which allows a user to setup transitions when a certain input is pressed."})
	
	RegisterFunction("InputTransition", [1,2,3], ["Action"], {"Description":"Sets up an input transition, which will do a transition when the input given is pressed.", "Arguments":["The input to watch for, in numpad notation.", "(Optional) The name of the state to transition to. By default, the same as the notation.", "(Optional) The priority for the transition. By default, the value specified in the castagne config."]})
	RegisterVariableEntity("_InputTransitionList", [], ["ResetEachFrame"], {"Description":"List of the input transitions to watch for."})
	RegisterConfig("_InputTransitionDefaultPriority", 1000, {"Description":"The default Transition priority for InputTransition."})
	
	RegisterModule("Motion Inputs", null, {"Description":"Module handling motion inputs, allowing them to used as part of the input and attack cancel systems."})
	
	
	RegisterCategory("Motion Inputs", {"Description":"System for detecting when motion input has been performed by a player."})
	
	RegisterConfig("DirectionalInputBuffer", 60, {"Description":"Number of frames the module retains the directional inputs from. This value should be greater than the longest motion input times the individual input interval for that motion."})
	RegisterConfig("ShortMotionInterval", 12, {"Description":"Maximum number of frames between inputs for a motion to remain valid. This value is for motions with three directions or less."})
	RegisterConfig("LongMotionInterval", 8, {"Description":"Maximum number of frames between inputs for a motion to remain valid. This value is for motions with more than three directions."})
	RegisterConfig("ButtonInterval", 8, {"Description":"Maximum number of frames between motion input and pressing the button for a motion to remain valid."})
	RegisterConfig("MinChargeTime", 30, {"Description":"Minimum number of frames for a direction to be held for a valid charge input."})
	#the above three values determine the number of frames between inputs in a motion. By default, shorter motions have more leniency.
	
	RegisterConfig("ValidMotionInputs","236, 214, 623, 421, 41236, 63214, C46, C28, 22",{"Description":"Motion inputs in numpad notation that the system will check for."})
	
	RegisterVariableEntity("_DirectionalInputLog", [], {"Description":"Array containing just the raw directional inputs for a player on each frame. Inputs are held for a number of frames equal to the buffer config variable."})
	RegisterVariableEntity("_ChargeInputLog", [], {"Description":"Array containing the inputs that have been held long enough to charge on each frame. Diagonal inputs also add the cardinal direction inputs. Inputs are held for a number of frames equal to the buffer config variable."})
	RegisterVariableEntity("_ChargeTime", {"Up":0,"Down":0,"Forward":0,"Back":0},{"Description":"Dict containing the number of frames each direction has been held."})
	RegisterVariableEntity("_PerformedMotions", [], {"Description":"Array containing the motions that have been performed by the player."})

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
	stateHandle.EntitySet("_PerformedMotions", motions)
	
	#print performed motions to the log for testing
#	if motions.size() > 0:
#		print(motions)

func ReactionPhaseStartEntity(stateHandle):
	var inputTransitionList = stateHandle.EntityGet("_InputTransitionList")
	var inputs = stateHandle.EntityGet("_Inputs")
	
	if(inputs.empty() or inputTransitionList.empty()):
		return
	
	# TODO do this
	
	#var prefix = ArgStr(args, stateHandle, 0, "")
	var prefix = ""
	
	#var listToUse = "Neutral"
	#if(stateHandle.EntityHasFlag("Attacking")):
	#	listToUse = stateHandle.EntityGet("_AttackHitconfirm_State")
	#	if(listToUse == null):
	#		return
	
	var alwaysAllowNeutralV = (prefix != "") # Prevents cancels to 5x when crouching
	
	# TODO Refactor ?
	#var input = stateHandle.PlayerGet("Inputs")
	var directions = []
	
	if(inputs["Up"]):
		if(inputs["Forward"]):
			directions += ["9"]
		elif(inputs["Back"]):
			directions += ["7"]
		directions += ["8"]
	elif(inputs["Down"]):
		if(inputs["Forward"]):
			directions += ["3"]
		elif(inputs["Back"]):
			directions += ["1"]
		directions += ["2"]
	
	if(directions.empty() or alwaysAllowNeutralV):
		if(inputs["Forward"]):
			directions += ["6"]
		elif(inputs["Back"]):
			directions += ["4"]
		directions += ["5"]
		
	#add motion inputs to the list of "directions"
	directions += stateHandle.EntityGet("_PerformedMotions")
	
	var attackButtons = []
	
	if(inputs["DPress"]):
		attackButtons += ["D"]
	if(inputs["CPress"]):
		attackButtons += ["C"]
	if(inputs["BPress"]):
		attackButtons += ["B"]
	if(inputs["APress"]):
		attackButtons += ["A"]
	
	var combinedAttackButtons = []
	var nbAttackButtons = attackButtons.size()
	var nbAttackButtonCombinations = int(pow(2, nbAttackButtons))
	# :TODO:Panthavma:20220310:There's certainly a smarter way to do it as this is litterally combinatory algebra but today I want to see man do punch and not formulas. Revisit when doing input.
	# List all possibilities. Order should be from strongest combinations to least.
	# This is not exactly true, as not all three letter combinations are first, but I can live with that for now.
	
	for i in range(nbAttackButtonCombinations-1,-1,-1):
		var buttonName = ""
		var modulo = 2
		var nbActive = 0
		for j in range(nbAttackButtons-1, -1, -1):
			if(i % modulo):
				i -= modulo/2
				buttonName += attackButtons[j]
				nbActive += 1
			modulo *= 2
		if(nbActive > 1):
			combinedAttackButtons += [buttonName]
	
	attackButtons = combinedAttackButtons + attackButtons
	
	var possibleCancels = []
	for b in attackButtons:
		for d in directions:
			var notation = prefix + d + b
			possibleCancels += [notation]
	#		# Check if the input is in the current cancel list
	#		if(stateHandle.EntityGet("_AttackPossibleCancels" + listToUse).has(notation)):
	#			var attackName = stateHandle.EntityGet("_AttackPossibleCancels"+listToUse)[notation]
	#			
	#			# We ignore if the attack has already used and that it exists
	#			if(stateHandle.EntityGet("_AttackDoneCancels").has(attackName)
	#				or !stateHandle.FighterScripts()[stateHandle.EntityGet("_FighterID")].has(attackName)):
	#				continue
	#			
	#			stateHandle.EntityAdd("AttackDoneCancels", [attackName])
	#			CallFunction("Transition", [attackName, 100], stateHandle)
	#			return
	
	var coreModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
	for itd in inputTransitionList:
		var notation = itd["InputNotation"]
		if(notation in possibleCancels):
			coreModule.Transition([itd["TargetState"], itd["Priority"]], stateHandle)


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
			if(!(buttonName in combiButtons)):
				continue
			var shouldPress = true
			for combiButton in combiButtons:
				if(!inputs[combiButton]):
					shouldPress = false
			inputs[combiName] = shouldPress
		stateHandle.EntitySet("_Inputs", inputs)
	elif(buttonName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.COMBINATION]):
		var combiButtons = inputSchema[buttonName]["Combination"]
		for combiButton in combiButtons:
			_InputSet([combiButton], stateHandle, press)
			_InputSet([combiButton], stateHandle, press)
	elif(buttonName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.DERIVED]):
		ModuleError("InputPress: "+str(buttonName)+" is a derived input, which can't be pressed directly.")
	else:
		ModuleError("InputPress: "+str(buttonName)+" couldn't be found in the input schema.")
		


func InputTransition(args, stateHandle):
	var inputNotation = ArgStr(args, stateHandle, 0)
	var targetState = ArgStr(args, stateHandle, 1, inputNotation)
	var priority = ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("_InputTransitionDefaultPriority"))
	AddInputTransition(stateHandle, inputNotation, targetState, {"Priority":priority})

func AddInputTransition(stateHandle, inputNotation, targetState, data = {}):
	var itd = {
		"InputNotation":inputNotation,
		"TargetState":targetState,
		"Priority":stateHandle.ConfigData().Get("_InputTransitionDefaultPriority"),
		"Callback":null,
	}
	
	Castagne.FuseDataOverwrite(itd, data)
	
	stateHandle.EntityAdd("_InputTransitionList", [itd])

#motion input stuff:
func LogDirectionalInputs(stateHandle):
	var inputs = stateHandle.EntityGet("_Inputs")
	var buffer = stateHandle.ConfigData().Get("DirectionalInputBuffer")
	var direction = 5
	var inputLog = stateHandle.EntityGet("_DirectionalInputLog")
	var minChargeTime = stateHandle.ConfigData().Get("MinChargeTime")
	var chargeTime = stateHandle.EntityGet("_ChargeTime")
	var chargeLog = stateHandle.EntityGet("_ChargeInputLog")
	var currentCharge = ""
	
	
	if(inputs["Up"]):
		chargeTime["Up"] += 1
		direction += 3
	else:
		chargeTime["Up"] = 0
		
	if(inputs["Down"]):
		chargeTime["Down"] += 1
		direction -= 3
	else:
		chargeTime["Down"] = 0
		
	if(inputs["Forward"]):
		chargeTime["Forward"] += 1
		direction += 1
	else:
		chargeTime["Forward"] = 0
		
	if(inputs["Back"]):
		chargeTime["Back"] += 1
		direction -= 1
	else:
		chargeTime["Back"] = 0
		
	direction = str(direction)
	
	if chargeTime["Down"] >= minChargeTime:
		if chargeTime["Back"] >= minChargeTime:
			currentCharge += "1"
		currentCharge += "2"
		if chargeTime["Forward"] >= minChargeTime:
			currentCharge += "3"
		
	if chargeTime["Back"] >= minChargeTime:
		currentCharge += "4"
	
	if chargeTime["Forward"] >= minChargeTime:
		currentCharge += "6"
	
	if chargeTime["Up"] >= minChargeTime:
		if chargeTime["Back"] >= minChargeTime:
			currentCharge += "7"
		currentCharge += "8"
		if chargeTime["Forward"] >= minChargeTime:
			currentCharge += "9"
	
	inputLog.push_front(direction)
	inputLog.resize(buffer)
	stateHandle.EntitySet("_DirectionalInputLog", inputLog)
	
	chargeLog.push_front(currentCharge)
	chargeLog.resize(buffer)
	stateHandle.EntitySet("_ChargeInputLog", chargeLog)
	
	stateHandle.EntitySet("_ChargeTime", chargeTime)

func MotionInputCheck(stateHandle, motion):
	var inputLog = stateHandle.EntityGet("_DirectionalInputLog")
	var chargeLog = stateHandle.EntityGet("_ChargeInputLog")
	var inputFrames = [0]
	
	var directions = []
	
	for i in len(motion):
		if motion[i] == "]":
			pass
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
		if directions[i] == "[":
			pass
			var chargeDir = directions[i-1]
			if !chargeDir in chargeLog[inputFrames[i]]:
				return
		else:
			var frame = inputLog.find(directions[i],inputFrames[i])
			inputFrames.append(frame)
			if i < len(directions)-1 && directions[i+1] == "[":
				pass
			else:
				if !frame in range(inputFrames[i],inputFrames[i]+intervals[i]):
					return
	return motion
