extends "CastagneFunctions.gd"

func Setup():
	RegisterFunction("Anim", [1, 2])
	RegisterFunction("Transition", [1,2,3], ["TransitionFunc"])
	RegisterFunction("InstantTransition", [1,2,3], ["TransitionFunc"])
	RegisterFunction("ResetFrameID", [0], ["TransitionFunc"])
	RegisterFunction("Flag", [1])
	RegisterFunction("Unflag", [1])
	RegisterFunction("Set", [2])
	RegisterFunction("SetStr", [2])
	RegisterFunction("Type", [1])
	RegisterFunction("Call", [1], ["FrameFunc", "TransitionFunc", "FullData"])
	RegisterFunction("CallParent", [1], ["FrameFunc", "TransitionFunc", "FullData"])
	RegisterFunction("Log", [1], ["FrameFunc"])
	RegisterFunction("LogT", [1], ["TransitionFunc"])
	RegisterFunction("LogB", [1], ["FrameFunc", "TransitionFunc"])
	RegisterFunction("SwitchFacing", [0])
	RegisterFunction("PlaySound", [1], ["TransitionFunc", "FullData"])


func StateSetup(pid, state, engine):
	state[pid]["HP"] = int(state[pid]["HPMax"])#int(engine.constants[pid]["HPMax"])
	state[pid]["Meter"] = 0
	state[pid]["State"] = engine.constants[pid]["InitialState"]
	state[pid]["StateStartFrame"] = 0
	state[pid]["StateChangePriority"] = -1000
	state[pid]["Anim"] = "Stand"
	state[pid]["AnimOffset"] = 0
	state[pid]["Input"] = null
	state["FrameID"] = 0
	state["TrueFrameID"] = 0
	state["SkipFrame"] = false
	state["Timer"] = 60*100
	state["CameraHor"] = 0
	state["CameraVer"] = 0
	state["PlayerOnTheLeft"] = 0
	state["WhoHasWon"] = 0
	state[pid]["StateFrameID"] = 0
	state[pid]["Facing"] = 1
	state[pid]["FacingTrue"] = 1
	state[pid]["PositionHor"] = 0
	state[pid]["PositionVer"] = 0
	state[pid]["Events"] = {}
	state[pid]["Flags"] = []
	state[pid]["CallParentLevel"] = 0

func FrameStart(_previousState, state, _engine):
	if(false and state["Hitstop"] > 0): # TODO reenable it when I make a better input buffer
		state["Hitstop"] -= 1
		state["SkipFrame"] = true

func PreFrame(pid, _playerState, _inputs, _previousState, state):
	state[pid]["Flags"] = []
	state[pid]["StateChangePriority"] = -1000
	state[pid]["Events"] = {}
	state[pid]["StateFrameID"] = state["FrameID"] - state[pid]["StateStartFrame"]
	state[pid]["CallParentLevel"] = 0
	#if(pid == "p1"):
	#	state["Timer"] -= 1
	# TODO real timer outside of kronian titans

func PostFrame(pid, _playerState, _inputs, _previousState, state):
	if(Castagne.HasFlag("ApplyFacing", pid, state)):
		state[pid]["Facing"] = state[pid]["FacingTrue"]

func Anim(args, pid, state):
	state[pid]["Anim"] = args[0]
	state[pid]["AnimOffset"] = (GetInt(args[1], pid, state) if args.size() >= 2 else 0)

func Transition(args, pid, state, updateFrameID = true):
	var newStateName = args[0]
	var priority = 0
	var allowSelfTransition = false
	if(args.size() >= 2):
		priority = GetInt(args[1], pid, state)
	if(args.size() >= 3):
		allowSelfTransition = Castagne.GetBool(args[2], pid, state)
	
	if(state[pid]["StateChangePriority"] >= priority):
		return
	if(newStateName == state[pid]["State"] and !allowSelfTransition):
		return
	
	state[pid]["StateChangePriority"] = priority
	state[pid]["State"] = newStateName
	if(updateFrameID):
		state[pid]["StateStartFrame"] = state["FrameID"]

func InstantTransition(args, pid, state):
	Transition(args, pid, state, false)

func ResetFrameID(_args, pid, state):
	state[pid]["StateStartFrame"] = state["FrameID"]

func Flag(args, pid, state):
	state[pid]["Flags"] += [args[0]]
func Unflag(args, pid, state):
	state[pid]["Flags"].erase(args[0])

func Set(args, pid, state):
	var paramName = GetStr(args[0], pid, state)
	var value = GetInt(args[1], pid, state)
	state[pid][paramName] = value

func ParseType(parser, args):
	parser._currentState["Type"] = args[0]

func Call(args, pid, state, engine, neededFlag):
	var stateName = args[0]
	if(!stateName in engine.states[pid]):
		Castagne.Error("Call: Calling undefined state " + str(stateName))
		return
	var callParentLevel = state[pid]["CallParentLevel"]
	state[pid]["CallParentLevel"] = 0
	_CallCommon(stateName, pid, state, engine, neededFlag)
	state[pid]["CallParentLevel"] = callParentLevel

func CallParent(args, pid, state, engine, neededFlag):
	var stateName = args[0]
	var level = state[pid]["CallParentLevel"] + 1
	for _i in range(level):
		stateName = "Parent:"+stateName
	if(!engine.states[pid].has(stateName)):
		Castagne.Error("CallParent: Calling undefined state " + str(stateName))
		return
	
	state[pid]["CallParentLevel"] = level
	_CallCommon(stateName, pid, state, engine, neededFlag)
	state[pid]["CallParentLevel"] = level - 1

func _CallCommon(stateName, pid, state, engine, neededFlag):
	var playerState = engine.states[pid][stateName]
	engine.FrameAdvancePlayerPlayActions(pid, playerState, state, neededFlag)

func Log(args, pid, _state):
	Castagne.Log("State Log "+str(pid)+" : " + args[0])
func LogB(args, pid, state):
	Log(args, pid, state)
func LogT(args, pid, state):
	Log(args, pid, state)

func SwitchFacing(_args, pid, state):
	state[pid]["Facing"] = -state[pid]["Facing"]

func PlaySound(args, pid, state, engine, _neededFlag):
	var soundName = GetStrArg(0, null, args, pid, state)
	var soundRoot = engine.instances[pid]["Sounds"]
	if(soundRoot == null):
		return
	var soundNode = soundRoot.get_node(soundName)
	var nbChildren = soundNode.get_child_count()
	if(nbChildren > 0):
		soundNode = soundNode.get_child(randi() % nbChildren)
	soundNode.play()
