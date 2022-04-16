extends "../CastagneModule.gd"

func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	RegisterModule("CF Core", {"Description":"Contains the absolute core functions of the engine. This should be included in virtually all cases."})
	
	# Category : Variables -------------------------------------------------------------------------
	RegisterCategory("Variables", {
		"Description": "These functions are focused on variable and flag manipulation. You can change both variables added by modules or added by the :Variables: block."})
	
	RegisterFunction("Flag", [1], ["AllPhases"], {
		"Description": "Raises a flag. Flags are reset at the beginning of each frame and allow you to communicate easily between modules. Flags are tested with L branches.",
		"Arguments": ["Flag name"],
		})
	RegisterFunction("Unflag", [1], ["AllPhases"], {
		"Description": "Unsets a flag, if it was set earlier.",
		"Arguments": ["Flag name"],
		})
	RegisterVariableEntity("Flags", [], ["ResetEachFrame"])
	
	RegisterFunction("Set", [2], null, {
		"Description": "Sets a variable to a given integer value.",
		"Arguments": ["Variable name", "Value"],
		})
	RegisterFunction("SetStr", [2], null, {
		"Description": "Sets a variable to a given string (text) value.",
		"Arguments": ["Variable name", "Value"],
		})
	

	RegisterCategory("Mathematics")
	RegisterFunction("Add", [2,3], null, {
		"Description": "Adds two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"]
	})
	RegisterFunction("Sub", [2,3], null, {
		"Description": "Substracts two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"]
	})
	RegisterFunction("Mul", [2,3], null, {
		"Description": "Multiplies two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"]
	})
	RegisterFunction("Div", [2,3], null, {
		"Description": "Divides two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"]
	})
	RegisterFunction("Mod", [2,3], null, {
		"Description": "Computes the remainder of the division between two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"]
	})
	RegisterFunction("Max", [2,3], null, {
		"Description": "Stores the bigger of the two numbers in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"]
	})
	RegisterFunction("Min", [2,3], null, {
		"Description": "Stores the smaller of the two numbers in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"]
	})
	
	# :TODO:Panthavma:20211230:Booleans (as consts)
	
	
	# Category : Entities --------------------------------------------------------------------------
	RegisterCategory("Entities", {"Description":"""These functions are focused on entity manipulation.
	If not using any entity functions, the entity controlled will be the one that called the script (the original entity).
	However, you may select another, which will then change to whom functions will be applied.
	You can use the functions to select the main entity, the original entity, the opponent's main entity, or directly through ID.
	An additional reference is given through the Reference Entity, which resets using the same rule, and can be used to copy variables or give additional context to functions.
	The selected entity is reset to the original one at the beginning of the action and transition phase."""})
	
	# :TODO:Panthavma:20220310:Add parser support for that, and preload
	RegisterFunction("CreateEntity", [1,2], null, {
		"Description": "Creates a new entity at the beginning of the next frame, using the given init script, and selects it.",
		"Arguments":["Init Script", "(Optional) Path to the script from which to load."],
	})
	# :TODO:Panthavma:20220310:What happens if it was the main entity?
	RegisterFunction("DestroyEntity", [0], null, {
		"Description": "Deletes the currently selected entity at the beginning of the next frame.",
		"Arguments":[],
	})
	
	RegisterFunction("GetEntityID", [1], null, {
		"Description": "Writes the selected entity ID to a variable.",
		"Arguments":["The variable to write the ID to"]
	})
	RegisterFunction("GetEntityIDToRefVariable", [1], null, {
		"Description": "Writes the selected entity ID to a variable of the reference entity.",
		"Arguments":["The variable to write the ID to"]
	})
	RegisterFunction("GetRefEntityID", [1], null, {
		"Description": "Writes the selected entity ID to a variable.",
		"Arguments":["The variable to write the ID to"]
	})
	RegisterFunction("GetRefEntityIDToRefVariable", [1], null, {
		"Description": "Writes the selected entity ID to a variable of the reference entity.",
		"Arguments":["The variable to write the ID to"]
	})
	
	
	RegisterFunction("SelectEntityByID", [1], ["Init", "Action", "Transition"], {
		"Description": "Selects an entity using its ID. All functions will then act on that entity.",
		"Arguments":["The Entity ID to use"]
	})
	RegisterFunction("SelectRefEntity", [0], ["Init", "Action", "Transition"], {
		"Description": "Selects the reference entity. All functions will then act on that entity.",
		"Arguments":[]
	})
	RegisterFunction("SelectMainEntity", [0], ["Init", "Action", "Transition"], {
		"Description": "Selects the main entity (based on the reference entity). All functions will then act on that entity.",
		"Arguments":[]
	})
	RegisterFunction("SelectOriginalEntity", [0], ["Init", "Action", "Transition"], {
		"Description": "Selects the original entity, the one that called the script in the first place. All functions will then act on that entity.",
		"Arguments":[]
	})
	RegisterFunction("SelectOpponentMainEntity", [0,1], ["Init", "Action", "Transition"], {
		"Description": "Selects the opponent's main entity (based on the reference entity). All functions will then act on that entity.",
		"Arguments":["(Optional) The opponent player's ID. Optional if not ambiguous."]
	})
	
	
	RegisterFunction("SetRefEntityByID", [1], ["Init", "Action", "Transition"], {
		"Description": "The reference entity will be set to the one having this ID. Some functions will use it to get data.",
		"Arguments":["The Entity ID to use"]
	})
	RegisterFunction("SetRefEntityToSelectedEntity", [0], ["Init", "Action", "Transition"], {
		"Description": "The reference entity will now be the selected entity. Some functions will use it to get data.",
		"Arguments":[]
	})
	RegisterFunction("SetRefEntityToMainEntity", [0], ["Init", "Action", "Transition"], {
		"Description": "The reference entity will now be the main entity (based on the reference entity). Some functions will use it to get data.",
		"Arguments":[]
	})
	RegisterFunction("SetRefEntityToOriginalEntity", [0], ["Init", "Action", "Transition"], {
		"Description": "The reference entity will now be the original entity, the one that called the script in the first place. Some functions will use it to get data.",
		"Arguments":[]
	})
	RegisterFunction("SetRefEntityToOpponentMainEntity", [0,1], ["Init", "Action", "Transition"], {
		"Description": "The reference entity will now be the opponent's main entity (based on the reference entity). Some functions will use it to get data.",
		"Arguments":["(Optional) The opponent player's ID. Optional if not ambiguous."]
	})
	
	
	RegisterFunction("SetMainEntityToSelectedEntity", [0], ["Init", "Action", "Transition"], { 
		"Description": "The main entity of the selected entity's player will now be the selected entity.",
		"Arguments":[],
	})
	RegisterFunction("SetMainEntityToReferenceEntity", [0], ["Init", "Action", "Transition"], {
		"Description": "The main entity of the selected entity's player will now be the reference entity.",
		"Arguments":[],
	})
	RegisterFunction("SetMainEntityByID", [1], ["Init", "Action", "Transition"], { 
		"Description": "The main entity of the selected entity's player will now be the entity referred to by the ID.",
		"Arguments":["The Entity ID"],
	})
	
	
	RegisterFunction("CopyFighterVariables", [0,1], null, {
		"Description": "Copies the variables from the :Variables: block to the character. By default, this is the Reference Entity's script.",
		"Arguments":["(Optional) Fighter script to use. Uses the Reference Entity's script by default."],
	})
	
	RegisterFunction("CopyVariable", [1,2], null, {
		"Description": "Copies one variable from the Reference Entity to this entity.",
		"Arguments":["The Reference Entity's variable name", "(Optional) Variable to copy the value too. Same name as the original by default."]
	})
	
	RegisterFunction("CopyVariableFromMain", [1,2], null, {
		"Description": "Copies one variable from the Main Entity to this entity.",
		"Arguments":["The Main Entity's variable name", "(Optional) Variable to copy the value too. Same name as the original by default."]
	})
	
	# Copy all variables from the ref entity?
	
	
	# Category : States ----------------------------------------------------------------------------
	RegisterCategory("States")
	
	RegisterFunction("Transition", [0,1,2,3], ["Init", "Transition"], {
		"Description": "Changes the current script/state. If multiple changes are made in the same frame, the first one with the biggest priority wins. Changes from one state to itself are ignored, except if allowing self-transition in the arguments. The change is buffered and executed at the end of the transition phase or the init phase. Calling the function without arguments will cancel the transition.",
		"Arguments": ["State name", "(Optional) Priority", "(Optional) Allow self-transition"],
		})
	RegisterFunction("TransitionBuffer", [0,1,2,3], ["Init", "Action", "Transition"], {
		"Description": "Same as Transition, but also works during the action phase. This can make some code simpler, and is separated because some confusing logic may happen when buffering all the time.",
		"Arguments": ["State name", "(Optional) Priority", "(Optional) Allow self-transition"],
		})
	#RegisterFunction("InstantTransition", [1,2,3], ["TransitionFunc"])
	#RegisterFunction("ResetFrameID", [0], ["TransitionFunc"])
	RegisterVariableEntity("State", "Init", ["NoInit"])
	RegisterVariableEntity("StateTarget", null, ["ResetEachFrame"])
	RegisterVariableEntity("StateFrameID", 0, ["ResetEachFrame"])
	RegisterVariableEntity("StateChangePriority", -100000, ["ResetEachFrame"])
	RegisterVariableEntity("StateStartFrame", 0)
	#state[pid]["StateStartFrame"] = 0
	#state[pid]["StateFrameID"] = 0
	
	RegisterFunction("Call", [1], ["Init", "Action", "Transition", "Freeze"], {
		"Description": "Executes another script/state.",
		"Arguments": ["Name of the state to call"],
		})
	RegisterFunction("CallParent", [1], ["Init", "Action", "Transition", "Freeze"], {
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
	
	
	
	
	
	RegisterCategory("Engine Functions")
	RegisterFunction("FreezeFrames", [1], null, {
		"Description": "Sets an amount of freeze frames to be effective immediately. Uses the max of the remaining frames and current frames.",
		"Arguments": ["Amount of frames to wait"],
		})
	
	
	
	
	# Category : General engine variables ----------------------------------------------------------
	RegisterCategory("Castagne Internals")
	
	RegisterVariableGlobal("FrameID", 0)
	RegisterVariableGlobal("TrueFrameID", 0)
	RegisterVariableGlobal("SkipFrame", false, ["ResetEachFrame"])
	RegisterVariableGlobal("FreezeFrames", 0)
	
	RegisterVariableGlobal("CurrentEntityID", 0)
	RegisterVariableGlobal("EntitiesToInit", [])
	RegisterVariableGlobal("EntitiesToDestroy", [])
	RegisterVariableGlobal("ActiveEntities", [])
	
	# Variables defined in Engine, here for documentation
	RegisterVariableGlobal("Players", [], ["NoInit"])
	# These are per player
	# :TODO:Panthavma:20220319:Document these
	#RegisterVariableEntity("RawInputs", {}, ["NoInit"])
	#RegisterVariableEntity("Inputs", {}, ["NoInit"])
	#RegisterVariableEntity("MainEntity", -1, ["NoInit"])
	#RegisterVariableEntity("PID", -1, ["NoInit"])
	
	
	RegisterConfig("Engine", "res://castagne/engine/CastagneEngine.tscn")
	RegisterConfig("Editor", "res://castagne/editor/CastagneEditor.tscn")
	RegisterConfig("MainMenu","res://castagne/menus/mainmenu/DefaultMainMenu.tscn")
	RegisterConfig("CharacterSelect","res://castagne/menus/characterselect/DefaultCharacterSelect.tscn")
	RegisterConfig("PostBattle","res://castagne/menus/postbattle/DefaultPostBattle.tscn")
	
	RegisterConfig("Modules",["default-fg25D"])
	RegisterConfig("Modules-basic", ["res://castagne/modules/functions/Basic.tscn"])
	RegisterConfig("Modules-attacks", ["res://castagne/modules/functions/Attacks.tscn"])
	RegisterConfig("Modules-physics2d", ["res://castagne/modules/functions/Physics.tscn"])
	RegisterConfig("Modules-graphics25d", ["res://castagne/modules/graphics/CMGraphics2HalfD.tscn"])
	RegisterConfig("Modules-fightinggame", ["res://castagne/modules/gamemodes/CMFightingGame.tscn"])
	RegisterConfig("Modules-ui", ["res://castagne/modules/ui/FightingUI.tscn"])
	
	RegisterConfig("Modules-25d",["physics2d", "graphics25d"])
			
	RegisterConfig("Modules-default-fg25D",["basic", "25d", "attacks", "fightinggame", "ui"])
	
	RegisterConfig("CharacterPaths",["res://castagne/example/fighter/Castagneur.casp"])
	RegisterConfig("StagePaths",["res://castagne/example/stage/Stage.tscn"])
	RegisterConfig("InputProviders",{"local":"res://castagne/modules/input/InputLocal.tscn", "online":"res://castagne/modules/input/InputOnline.tscn",
		"ai":"res://castagne/modules/input/InputAI.tscn", "dummy":"res://castagne/modules/input/InputDummy.tscn",
		"replay":"res://castagne/modules/input/InputReplay.tscn"})
	
	RegisterConfig("GameTitle","Untitled Castagne Game")
	RegisterConfig("GameVersion","Unspecified Version")
	RegisterConfig("CastagneVersion","Castagne v0.4")
	
	RegisterConfig("Starter-Option", 0)
	RegisterConfig("Starter-Timer", 2000)
	RegisterConfig("Starter-P1", 0)
	RegisterConfig("Starter-P2", 0)
	
	
	RegisterBattleInitData("map",0)
	RegisterBattleInitData("music",0)
	RegisterBattleInitData("mode","Training")
	RegisterBattleInitData("online",false)



# :TODO:Panthavma:20220401:Add a way to execute scripts during freeze, another phase?
func FrameStart(state, _data):
	if(state["FreezeFrames"] > 0):
		state["FreezeFrames"] -= 1
		state["SkipFrame"] = true

func InitPhaseStartEntity(eState, data):
	data["State"]["ActiveEntities"].append(eState["EID"])
func InitPhaseEndEntity(eState, data):
	TransitionApply(eState, data)

func ActionPhaseStartEntity(eState, data):
	eState["StateFrameID"] = data["State"]["FrameID"] - eState["StateStartFrame"]

func TransitionPhaseEndEntity(eState, data):
	TransitionApply(eState, data)




# --------------------------------------------------------------------------------------------------
# Variables
func Flag(args, eState, _data):
	SetFlag(eState, ArgStr(args, eState, 0))
func Unflag(args, eState, _data):
	UnsetFlag(eState, ArgStr(args, eState, 0))

func Set(args, eState, _data):
	var paramName = ArgVar(args, eState, 0)
	var value = ArgInt(args, eState, 1)
	eState[paramName] = value
func SetStr(args, eState, _data):
	var paramName = ArgVar(args, eState, 0)
	var value = ArgStr(args, eState, 1)
	eState[paramName] = value






# --------------------------------------------------------------------------------------------------
# Mathematics
func Add(args, eState, _data):
	var destVar = ArgVar(args, eState, 2, ArgVar(args, eState, 0))
	eState[destVar] = ArgInt(args, eState, 0) + ArgInt(args, eState, 1)
func Sub(args, eState, _data):
	var destVar = ArgVar(args, eState, 2, ArgVar(args, eState, 0))
	eState[destVar] = ArgInt(args, eState, 0) - ArgInt(args, eState, 1)
func Mul(args, eState, _data):
	var destVar = ArgVar(args, eState, 2, ArgVar(args, eState, 0))
	eState[destVar] = ArgInt(args, eState, 0) * ArgInt(args, eState, 1)
func Div(args, eState, _data):
	var destVar = ArgVar(args, eState, 2, ArgVar(args, eState, 0))
	var b = ArgInt(args, eState, 1)
	if(b == 0):
		ModuleError("Div: Dividing by zero!", eState)
		return
	eState[destVar] = ArgInt(args, eState, 0) / b
func Mod(args, eState, _data):
	var destVar = ArgVar(args, eState, 2, ArgVar(args, eState, 0))
	var b = ArgInt(args, eState, 1)
	if(b == 0):
		ModuleError("Mod: Dividing by zero!", eState)
		return
	eState[destVar] = ArgInt(args, eState, 0) % b
func Max(args, eState, _data):
	var destVar = ArgVar(args, eState, 2, ArgVar(args, eState, 0))
	eState[destVar] = max(ArgInt(args, eState, 0), ArgInt(args, eState, 1))
func Min(args, eState, _data):
	var destVar = ArgVar(args, eState, 2, ArgVar(args, eState, 0))
	eState[destVar] = min(ArgInt(args, eState, 0), ArgInt(args, eState, 1))


# --------------------------------------------------------------------------------------------------
# Entities
func CreateEntity(args, eState, data):
	if(args.size() > 1):
		ModuleError("CreateEntity: Second parameter is not yet supported", eState)
		# :TODO:Panthavma:20220310:Support it
		return
	
	var playerID = eState["Player"]
	var fighterID = eState["FighterID"]
	var newEID = engine.AddNewEntity(data["State"], playerID, fighterID, ArgStr(args, eState, 0))
	data["SelectedEID"] = newEID

func DestroyEntity(_args, eState, data):
	data["State"]["EntitiesToDestroy"].append(eState["EID"])



func GetEntityID(args, eState, data):
	eState[ArgStr(args, eState, 0)] = data["SelectedEID"]

func GetEntityIDToRefVariable(args, eState, data):
	data["rState"][ArgStr(args, eState, 0)] = data["SelectedEID"]

func GetRefEntityID(args, eState, data):
	eState[ArgStr(args, eState, 0)] = data["RefEID"]

func GetRefEntityIDToRefVariable(args, eState, data):
	data["rState"][ArgStr(args, eState, 0)] = data["RefEID"]



func SelectEntityByID(args, eState, data):
	data["SelectedEID"] = ArgInt(args, eState, 0)

func SelectRefEntity(_args, _eState, data):
	data["SelectedEID"] = data["RefEID"]

func SelectMainEntity(_args, _eState, data):
	data["SelectedEID"] = data["State"]["Players"][data["rState"]["Player"]]["MainEntity"]

func SelectOriginalEntity(_args, _eState, data):
	data["SelectedEID"] = data["OriginalEID"]

func SelectOpponentMainEntity(_args, _eState, data):
	var oPID = data["State"]["Players"][data["rState"]["Player"]]["Opponent"]
	data["SelectedEID"] = data["State"]["Players"][oPID]["MainEntity"]



func SetRefEntityByID(args, eState, data):
	data["RefEID"] = ArgInt(args, eState, 0)

func SetRefEntityToSelectedEntity(_args, _eState, data):
	data["RefEID"] = data["SelectedEID"]

func SetRefEntityToMainEntity(_args, _eState, data):
	data["RefEID"] = data["State"]["Players"][data["rState"]["Player"]]["MainEntity"]

func SetRefEntityToOriginalEntity(_args, _eState, data):
	data["RefEID"] = data["OriginalEID"]

func SetRefEntityToOpponentMainEntity(_args, _eState, data):
	var oPID = data["State"]["Players"][data["rState"]["Player"]]["Opponent"]
	data["RefEID"] = data["State"]["Players"][oPID]["MainEntity"]



func SetMainEntityToSelectedEntity(_args, eState, data):
	data["State"]["Players"][eState["Player"]]["MainEntity"] = data["SelectedEID"]

func SetMainEntityToReferenceEntity(_args, eState, data):
	data["State"]["Players"][eState["Player"]]["MainEntity"] = data["RefEID"]

func SetMainEntityByID(args, eState, data):
	data["State"]["Players"][eState["Player"]]["MainEntity"] = ArgInt(args, eState, 0)


func CopyFighterVariables(args, eState, data):
	if(args.size() > 0):
		ModuleError("CopyFighterVariables: Using another fighter script is not supported yet")
		# :TODO:Panthavma:20220310:Support it
		return
	
	var fighterVars = data["InstancedData"]["ParsedFighters"][eState["FighterID"]]["Variables"]
	Castagne.FuseDataOverwrite(eState, fighterVars)

func CopyVariable(args, eState, data):
	var refVarName = ArgStr(args, eState, 0)
	var targetVarName = ArgStr(args, eState, 1, refVarName)
	# :TODO:Panthavma:20220311:Can't work completely until I implement a way to ignore the variable name translation (*operator ?)
	eState[targetVarName] = data["State"][data["RefEID"]][refVarName]

func CopyVariableFromMain(args, eState, data):
	var refVarName = ArgStr(args, eState, 0)
	var targetVarName = ArgStr(args, eState, 1, refVarName)
	# :TODO:Panthavma:20220311:Can't work completely until I implement a way to ignore the variable name translation (*operator ?)
	var meid = data["State"]["Players"][eState["Player"]]["MainEntity"]
	eState[targetVarName] = data["State"][meid][refVarName]


# --------------------------------------------------------------------------------------------------
# States
func Transition(args, eState, data):
	if(args.size() == 0):
		eState["StateChangePriority"] = -100000
		eState["StateTarget"] = null
		return
	
	var newStateName = ArgStr(args, eState, 0)
	var priority = ArgInt(args, eState, 1, 0)
	var allowSelfTransition = ArgBool(args, eState, 2, false)
	
	if(eState["StateChangePriority"] >= priority):
		return
	if(newStateName == eState["State"] and !allowSelfTransition):
		return
	
	eState["StateChangePriority"] = priority
	eState["StateTarget"] = newStateName
func TransitionBuffer(args, eState, data):
	Transition(args, eState, data)
func TransitionApply(eState, data):
	if(eState["StateTarget"] != null):
		eState["State"] = eState["StateTarget"]
		eState["StateStartFrame"] = data["State"]["FrameID"]
		eState["StateChangePriority"] = -100000
		eState["StateTarget"] = null


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
	# :TODO:Panthavma:20220315:Probably needs more tests? "Should" work but haven't extensively tested since v0.3
	eState["CallParentLevel"] = level
	engine.ExecuteFighterScript(fighterScript, eState["EID"], data)
	eState["CallParentLevel"] = level - 1



# --------------------------------------------------------------------------------------------------
# Debug

# :TODO:Panthavma:20220131:Make it more flexible to be able to show variable's value ? Or just raw
func Log(args, eState, data):
	Castagne.Log("["+str(data["State"]["TrueFrameID"])+"] State Log "+str(eState["EID"])+" : " + ArgStr(args, eState, 0))
func LogB(args, eState, data):
	Log(args, eState, data)
func LogT(args, eState, data):
	Log(args, eState, data)


func FreezeFrames(args, eState, data):
	data["State"]["FreezeFrames"] = max(data["State"]["FreezeFrames"], ArgInt(args, eState, 0))











