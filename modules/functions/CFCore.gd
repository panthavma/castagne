extends "../CastagneModule.gd"

func ModuleSetup():# :TODO:Panthavma:20211230:Move some functions to graphics/physics/other/fightinggame
	# :TODO:Panthavma:20211230:Entity function
	
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the functions
	# :TODO:Panthavma:20211230:Document the variables
	
	RegisterModule("CF Core", {"Description":"Contains the absolute core functions of the engine. This should be included in virtually all cases."})
	
	# Category : Variables -------------------------------------------------------------------------
	RegisterCategory("Variables", {
		"Description": "These functions are focused on variable and flag manipulation. You can change both variables added by modules or added by the :Variables: block."})
	
	RegisterFunction("Flag", [1], null, {
		"Description": "Raises a flag. Flags are reset at the beginning of each frame and allow you to communicate easily between modules. Flags are tested with L branches.",
		"Arguments": ["Flag name"],
		})
	RegisterFunction("Unflag", [1], null, {
		"Description": "Unsets a flag, if it was set earlier.",
		"Arguments": ["Flag name"],
		})
	RegisterVariableEntity("Flags", [], ["ResetEachFrame"])
	
	RegisterFunction("Set", [2], null, {
		"Description": "",
		"Arguments": [""],
		})
	#RegisterFunction("SetStr", [2])
	
	# :TODO:Panthavma:20211230:Booleans (as consts)
	# :TODO:Panthavma:20211230:Add/Mult/Sub/Divide as math functions
	
	
	# Category : Entities --------------------------------------------------------------------------
	RegisterCategory("Entities")
	# CreateEntity
	# SelectEntity
	# SelectMainEntity
	# GetEntityID
	# SelectOpponentEntity
	
	
	# Category : States ----------------------------------------------------------------------------
	RegisterCategory("States")
	
	RegisterFunction("Transition", [1,2,3], ["Transition"], {
		"Description": "Changes the current script/state. If multiple changes are made in the same frame, the first one with the biggest priority wins. Changes from one state to itself are ignored, except if allowing self-transition in the arguments.",
		"Arguments": ["State name", "(Optional) Priority", "(Optional) Allow self-transition"],
		})
	#RegisterFunction("InstantTransition", [1,2,3], ["TransitionFunc"])
	#RegisterFunction("ResetFrameID", [0], ["TransitionFunc"])
	RegisterVariableEntity("State", "Init")
	RegisterVariableEntity("StateChangePriority", -1000, ["ResetEachFrame"])
	RegisterVariableEntity("StateStartFrame", 0)
	#state[pid]["StateStartFrame"] = 0
	#state[pid]["StateFrameID"] = 0
	
	RegisterFunction("Call", [1], ["Init", "Action", "Transition"], {
		"Description": "Executes another script/state.",
		"Arguments": ["Name of the state to call"],
		})
	RegisterFunction("CallParent", [1], ["Init", "Action", "Transition"], {
		"Description": "Execute another script/state on the parent skeleton.",
		"Arguments": ["Name of the state to call."],
		})
	RegisterVariableEntity("CallParentLevel", 0, ["ResetEachFrame"])
	
	
	# :TODO:Panthavma:20220131:Add callparent with 0 arguments
	# :TODO:Panthavma:20220131:Add functions to manipulate state transitions better
	
	
	# Category : Debug -----------------------------------------------------------------------------
	RegisterCategory("Debug")
	
	RegisterFunction("Log", [1], null, {
		"Description": "Writes a log to the console output.",
		"Arguments": ["Text to write"],
		})
	RegisterFunction("LogT", [1], ["Transition"], {
		"Description": "Writes a log to the console output during the Transition phase only.",
		"Arguments": ["Text to write"],
		})
	RegisterFunction("LogB", [1], ["Init", "Action", "Transition"], {
		"Description": "Writes a log to the console output during the Init, Action, and Transition phases.",
		"Arguments": ["Text to write"],
		})
	
	
	
	# Category : General engine variables ----------------------------------------------------------
	RegisterCategory("Castagne")
	
	RegisterVariableGlobal("FrameID", 0)
	RegisterVariableGlobal("TrueFrameID", 0)
	RegisterVariableGlobal("SkipFrame", false)
	
	RegisterVariableGlobal("CurrentEntityID", 0)
	#RegisterVariableGlobal("EntitiesToInit", [])
	RegisterVariableGlobal("ActiveEntities", [])
	#RegisterVariableGlobal("Players", []) # See if the player init evolves before uncommenting this




func InitPhaseStartEntity(eState, data):
	data["State"]["ActiveEntities"].append(eState["EID"])
	var fighterVars = data["InstancedData"]["ParsedFighters"][eState["FighterID"]]["Variables"]
	Castagne.FuseDataOverwrite(eState, fighterVars)




# --------------------------------------------------------------------------------------------------
# Variables
func Flag(args, eState, _data):
	SetFlag(eState, ArgStr(args, eState, 0))

func Unflag(args, eState, _data):
	eState["Flags"].erase(ArgStr(args, eState, 0))

func Set(args, eState, _data):
	var paramName = ArgStr(args, eState, 0)
	var value = ArgInt(args, eState, 1)
	eState[paramName] = value


# --------------------------------------------------------------------------------------------------
# Entities





# --------------------------------------------------------------------------------------------------
# States
func Transition(args, eState, data):
	var newStateName = ArgStr(args, eState, 0)
	var priority = ArgInt(args, eState, 1, 0)
	var allowSelfTransition = ArgBool(args, eState, 2, false)
	
	if(eState["StateChangePriority"] >= priority):
		return
	if(newStateName == eState["State"] and !allowSelfTransition):
		return
	
	eState["StateChangePriority"] = priority
	eState["StateStartFrame"] = data["State"]["FrameID"]
	eState["State"] = newStateName


func Call(args, eState, data):
	var stateName = ArgStr(args, eState, 0)
	
	var fighterScript = engine.GetFighterScript(eState["FighterID"], stateName)
	if(fighterScript == null):
		Castagne.Error("Call: Calling undefined state " + str(stateName))
		return
	
	var callParentLevel = eState["CallParentLevel"]
	eState["CallParentLevel"] = 0
	engine.ExecuteFighterScript(fighterScript, eState["EID"], data)
	eState["CallParentLevel"] = callParentLevel

func CallParent(args, eState, data):
	var stateName = ArgStr(args, eState, 0)
	var level = eState["CallParentLevel"] + 1
	for _i in range(level):
		stateName = "Parent:"+stateName
	
	var fighterScript = engine.GetFighterScript(eState["FighterID"], stateName)
	if(fighterScript == null):
		Castagne.Error("CallParent: Calling undefined state " + str(stateName))
		return
	
	eState["CallParentLevel"] = level
	engine.ExecuteFighterScript(fighterScript, eState["EID"], data)
	eState["CallParentLevel"] = level - 1



# --------------------------------------------------------------------------------------------------
# Debug

# :TODO:Panthavma:20220131:Make it more flexible to be able to show variable's value ? Or just raw
func Log(args, eState, _data):
	Castagne.Log("State Log "+str(eState["EID"])+" : " + ArgStr(args, eState, 0))
func LogB(args, eState, _data):
	Log(args, eState, _data)
func LogT(args, eState, _data):
	Log(args, eState, _data)











