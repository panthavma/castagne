# CMCore: Castagne Core Module
# Contains the most basic functions and flow of the engine
# It is possible but not recommended to replace it.

extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Core", Castagne.MODULE_SLOTS_BASE.CORE, {
		"Description":"Contains the absolute core functions of the engine. This should be included in virtually all cases, and tends to be relied upon by the engine itself."
		})
	RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Core.casp", -9000)
	
	# Category : Variables -------------------------------------------------------------------------
	RegisterCategory("Variables", {
		"Description": "These functions are focused on basic variable and flag manipulation."})
	
	RegisterFunction("Flag", [1], ["AllPhases"], {
		"Description": "Raises a flag. Flags are reset at the beginning of each frame and allow you to communicate easily between modules. Flags are tested with L branches.",
		"Arguments": ["Flag name"],
		"Flags":["Basic"],
		"Types": ["str"],
		})
	RegisterFunction("Unflag", [1], ["AllPhases"], {
		"Description": "Unsets a flag, if it was set earlier.",
		"Arguments": ["Flag name"],
		"Flags":["Basic"],
		"Types": ["str"],
		})
	RegisterFunction("FlagNext", [1], ["AllPhases"], {
		"Description": "Raises a flag at the beginning of the next frame.",
		"Arguments": ["Flag name"],
		"Flags":["Basic"],
		"Types": ["str"],
		})
	RegisterFunction("UnflagNext", [1], ["AllPhases"], {
		"Description": "Unsets a flag for the next frame, if it was set earlier with FlagNext.",
		"Arguments": ["Flag name"],
		"Flags":["Basic"],
		"Types": ["str"],
		})
	RegisterVariableEntity("_Flags", [], ["ResetEachFrame"], {
		"Description":"The list of flags held by the entity",
		"Flags":["Expert"],
		})
	RegisterVariableEntity("_FlagsNext", [], null, {
		"Description":"The list of flags to be raised at the beginning of next frame.",
		"Flags":["Expert"],
		})
	
	RegisterFunction("Set", [2], null, {
		"Description": "Sets a variable to a given integer value.",
		"Arguments": ["Variable name", "Value"],
		"Flags":["Basic"],
		"Types": ["var", "int"],
		})
	RegisterFunction("SetStr", [2], null, {
		"Description": "Sets a variable to a given string (text) value.",
		"Arguments": ["Variable name", "Value"],
		"Flags":["Basic"],
		"Types": ["var", "str"],
		})
	




	RegisterCategory("Mathematics (Simple)", {"Description":"Basic mathematical functions."})
	RegisterFunction("Add", [2,3], null, {
		"Description": "Adds two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"],
		"Flags":["Basic"],
		"Types": ["int", "int", "var"],
	})
	RegisterFunction("Sub", [2,3], null, {
		"Description": "Substracts two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"],
		"Flags":["Basic"],
		"Types": ["int", "int", "var"],
	})
	RegisterFunction("Mul", [2,3], null, {
		"Description": "Multiplies two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"],
		"Flags":["Basic"],
		"Types": ["int", "int", "var"],
	})
	RegisterFunction("Div", [2,3], null, {
		"Description": "Divides two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"],
		"Flags":["Basic"],
		"Types": ["int", "int", "var"],
	})
	RegisterFunction("Mod", [2,3], null, {
		"Description": "Computes the remainder of the division between two numbers and stores it in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"],
		"Flags":["Basic"],
		"Types": ["int", "int", "var"],
	})
	RegisterFunction("Max", [2,3], null, {
		"Description": "Stores the bigger of the two numbers in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"],
		"Flags":["Basic"],
		"Types": ["int", "int", "var"],
	})
	RegisterFunction("Min", [2,3], null, {
		"Description": "Stores the smaller of the two numbers in the first variable or an optional third variable.",
		"Arguments": ["First number", "Second number", "(Optional) Destination Variable"],
		"Flags":["Basic"],
		"Types": ["int", "int", "var"],
	})
	
	# :TODO:Panthavma:20211230:Booleans (as consts)
	
	
	# Category : Entities --------------------------------------------------------------------------
	RegisterCategory("Entities", {"Description":
"""These functions are focused on entity manipulation.

These functions work using a concept known as the Target Entity, which can be any other entity. This may be selected through the 'TargetEntity' family of functions.

This entity may then be used as a reference point for specific functions.
Something to keep in mind is that the data gathered from the target entity like this will be from the end of last frame, while the data alteration directives will be effective at the end of the phase.
In the case of targetting an entity currently being created, the values will be set just after creation, at the beginning of the next frame.

If several entities want to alter the same value on the same target entity, the behaviour should be considered undefined (but in practice, will use the one from the entity with the highest ID).

The target entity is reset at the beginning of each frame, to the current entity (it targets itself).
This can be overriden by other modules (mainly, FlowFighting which will target the opponent if playing with two players)"""})
	
	RegisterFunction("CreateEntity", [1], null, {
		"Description": "Creates a new entity at the beginning of the next frame, using the given entity name, and targets it.\n"+
		"Also sets some parameters to make entity creation easier (position at root, copy facing)",
		"Arguments":["Init Script"],
		"Flags":["Intermediate"],
		"Types": ["str"],
	})
	RegisterFunction("CreateEntityRaw", [1], null, {
		"Description": "Creates a new entity at the beginning of the next frame, using the given entity name, and targets it.",
		"Arguments":["Init Script"],
		"Flags":["Intermediate"],
		"Types": ["str"],
	})
	# :TODO:Panthavma:20220310:What happens if it was the main entity?
	RegisterFunction("DestroyEntity", [0], null, {
		"Description": "Deletes the currently targetted entity at the beginning of the next frame.",
		"Arguments":[],
		"Flags":["Intermediate"],
		"Types": ["str"],
	})
	
	RegisterFunction("GetCurrentEntityID", [1], null, {
		"Description":"Write the current entity ID to a variable.",
		"Arguments":["The variable to write the ID to"],
		"Flags":["Advanced"],
		"Types": ["var"],
	})
	RegisterFunction("GetTargetEntityID", [1], null, {
		"Description":"Write the target entity ID to a variable.",
		"Arguments":["The variable to write the ID to"],
		"Flags":["Advanced"],
		"Types": ["var"],
	})
	
	RegisterFunction("TargetEntityByID", [1], null, {
		"Description":"Targets an entity using its ID",
		"Arguments":["The ID of the entity to target"],
		"Flags":["Advanced"],
		"Types": ["int"],
	})
	RegisterFunction("TargetEntitySelf", [0], null, {
		"Description":"Targets the current entity (autotargetting).",
		"Arguments":[],
		"Flags":["Advanced"],
	})
	# :TODO:Panthavma:20221223:Add functions to target opponent entities
	
	RegisterFunction("CopyFromTarget", [1,2], null, {
		"Description":"Copies a variable from the target entity. This will however copy the variable value from the end of the last frame.",
		"Arguments":["Variable name on current entity", "(Optional) Variable name on target entity"],
		"Flags":["Intermediate"],
		"Types": ["var", "var"],
	})
	RegisterFunction("CopyToTarget", [1,2], null, {
		"Description":"Copies a variable to the target entity. This will be applied at the end of the phase, or at initialization for new entities.",
		"Arguments":["Variable name on current entity", "(Optional) Variable name on target entity"],
		"Flags":["Intermediate"],
		"Types": ["var", "var"],
	})
	RegisterFunction("SetIntInTarget", [2], null, {
		"Description":"Sets a variable in the target entity. This will be applied at the end of the phase, or at initialization for new entities.",
		"Arguments":["Variable name on target entity", "Variable Value"],
		"Flags":["Intermediate"],
		"Types": ["var", "int"],
	})
	RegisterFunction("SetStrInTarget", [2], null, {
		"Description":"Sets a variable in the target entity. This will be applied at the end of the phase, or at initialization for new entities.",
		"Arguments":["Variable name on target entity", "Variable Value"],
		"Flags":["Intermediate"],
		"Types": ["var", "str"],
	})
	RegisterFunction("FlagInTarget", [1], null, {
		"Description":"Sets a flag in the target. This will be applied at the end of the phase, but doesn't carry over to the next frame, meaning you'll most likely only access it in Reaction phase.",
		"Arguments":["Flag Name"],
		"Flags":["Intermediate"],
		"Types": ["str"],
	})
	RegisterFunction("UnflagInTarget", [1], null, {
		"Description":"Unsets a flag in the target. This will be applied at the end of the phase, but doesn't carry over to the next frame, meaning you'll most likely only access it in Reaction phase.",
		"Arguments":["Flag Name"],
		"Flags":["Intermediate"],
		"Types": ["str"],
	})
	
	RegisterVariableGlobal("_CopyToBuffer", [], null, {
		"Description":"Global buffer to hold the variables entities set to each other.",
		"Flags":["Expert"],
		})
	RegisterVariableGlobal("_FlagTargetBuffer", [], ["ResetEachFrame"], {
		"Description":"Global buffer to hold the flags entities set to each other.",
		"Flags":["Expert"],
		})
	RegisterVariableEntity("_TargetEID", -1, ["ResetEachFrame"], {
		"Description":"Hold the current target EID, reset each frame.",
		"Flags":["Advanced"],
		})
	
	
	
	
	
	
	
	# Category : States ----------------------------------------------------------------------------
	RegisterCategory("States", {
		"Description":"Holds functions and variables pertaining to the states themselves. Handles transitions, and state calls."
		})
	
	RegisterFunction("Transition", [0,1,2,3], ["Init", "Reaction"], {
		"Description": "Changes the current script/state. If multiple changes are made in the same frame, the first one with the biggest priority wins. Changes from one state to itself are ignored, except if allowing self-transition in the arguments. The change is buffered and executed at the end of the transition phase or the init phase. Calling the function without arguments will cancel the transition.",
		"Arguments": ["State name", "(Optional) Priority", "(Optional) Allow self-transition"],
		"Flags":["Basic"],
		"Types": ["str", "int", "bool"],
		})
	RegisterFunction("TransitionBuffer", [0,1,2,3], ["Init", "Action", "Reaction"], {
		"Description": "Same as Transition, but also works during the action phase. This can make some code simpler, and is separated because some confusing logic may happen when buffering all the time.",
		"Arguments": ["State name", "(Optional) Priority", "(Optional) Allow self-transition"],
		"Flags":["Basic"],
		"Types": ["str", "int", "bool"],
		})
	#RegisterFunction("InstantTransition", [1,2,3], ["TransitionFunc"])
	#RegisterFunction("ResetFrameID", [0], ["TransitionFunc"])
	RegisterVariableEntity("_State", "Init-Main", ["NoInit"], {
		"Description":"The name of the current state",
		"Flags":["Intermediate"],
		})
	RegisterVariableEntity("_StateTarget", null, ["ResetEachFrame"], {
		"Description":"The name of the state we want to transition to.",
		"Flags":["Advanced"],
		})
	RegisterVariableEntity("_StateFrameID", 0, ["ResetEachFrame"], {
		"Description":"The FrameID counted from when we transitionned into the state. (Starts at 1, 0 being the frame the transition is done in.)",
		"Flags":["Intermediate"],
		})
	RegisterVariableEntity("_StateChangePriority", -100000, ["ResetEachFrame"], {
		"Description":"Current priority for the state transition, given by Transition()",
		"Flags":["Expert"],
		})
	RegisterVariableEntity("_StateStartFrame", 0, null, {
		"Description":"The FrameID the current state started in.",
		"Flags":["Expert"],
		})
	
	RegisterFunction("Call", [1], ["Init", "Action", "Reaction", "Freeze"], {
		"Description": "Executes another script/state. When the script is known at compile time, it is inlined and thus doesn't slow down execution.",
		"Arguments": ["Name of the state to call"],
		"Flags":["Basic"],
		"Types": ["str"],
		})
	RegisterFunction("CallParent", [1], ["Init", "Action", "Reaction", "Freeze"], {
		"Description": "Execute another script/state on the parent skeleton.",
		"Arguments": ["Name of the state to call."],
		"Flags":["Intermediate"],
		"Types": ["str"],
		})
	RegisterVariableEntity("_CallParentLevel", 0, ["ResetEachFrame"], {"Description":"Helper variable for which level the CallParent function shall call to."})
	
	RegisterFunction("ExecuteAfter", [0,1], ["Init", "Action", "Reaction", "Freeze"], {
		"Description": "Schedules a call to be executed after the current one has been done.\n"+
		"These will be executed only once - ExecuteAfter calls inside an ExecuteAfter are ignored.\n"+
		"Giving no arguments will cancel existing calls, if done before the end.",
		"Arguments":["(Optional) Name of state to call"],
		"Flags":["Intermediate"],
		"Types": ["str"],
	})
	RegisterVariableEntity("_ExecuteAfterCalls", [], ["ResetEachFrame"], {
		"Description":"Hold the list of states that will be called after the main state, filled by ExecuteAfter()",
		"Flags":["Expert"],
		})
	
	
	# :TODO:Panthavma:20220131:Add callparent with 0 arguments
	# :TODO:Panthavma:20220131:Add functions to manipulate state transitions better
	
	
	# Category : Debug -----------------------------------------------------------------------------
	RegisterCategory("Debug", {"Description":"Functions that help understanding what happens inside the code."})
	
	RegisterFunction("Log", [1], ["Init", "Action", "Freeze"], {
		"Description": "Writes a log to the console output during the Action phase.",
		"Arguments": ["Text to write"],
		"Flags":["Basic"],
		})
	RegisterFunction("LogR", [1], ["Reaction"], {
		"Description": "Writes a log to the console output during the Reaction phase only.",
		"Arguments": ["Text to write"],
		"Flags":["Intermediate"],
		})
	RegisterFunction("LogB", [1], ["Init", "Action", "Reaction"], {
		"Description": "Writes a log to the console output during the Init, Action, and Reaction phases.",
		"Arguments": ["Text to write"],
		"Flags":["Intermediate"],
		})
	
	
	
	
	
	RegisterCategory("Engine Functions", {"Description":"Functions to control the engine flow."})
	
	RegisterFunction("FreezeFrames", [1], null, {
		"Description": "Sets an amount of freeze frames to be effective immediately. Uses the max of the remaining frames and current frames.",
		"Arguments": ["Amount of frames to wait"],
		"Flags":["Intermediate"],
		"Types": ["int"],
		})
	
	
	# Category : Game specific ----------------------------------------------------------
	RegisterCategory("Game Configuration", {"Description":"Configuration related to the game itself, including Characters and Stages."})
	
	RegisterConfig("GameTitle","Untitled Castagne Game", {
		"Description":"The name of the game.",
		"Flags":["Basic"],
		})
	RegisterConfig("GameVersion","Unspecified Version", {
		"Description":"The version of the game, can be used to differenciate patches.",
		"Flags":["Basic"],
		})
	RegisterCustomConfig("Genre Select", "GenreSelector", {"Flags":["ReloadFull", "LockBack"]})
	RegisterConfig("CharacterPaths","res://castagne/example/fighter/baston/Baston.casp, res://castagne/example/fighter/baston/Baston2D.casp", {
		"Flags":["Hidden"],
		"Description":"The list of characters that can be loaded."
		})
	RegisterConfig("Skeletons", "", {
		"Flags":["Hidden"],
		"Description":"The list of skeletons that may be loaded. Used when the Skeleton parameter of a character is set to an int, or when none is given."
		})
	RegisterCustomConfig("Manage Characters", "CharacterSet", {"Flags":["LockBack"]})
	RegisterConfig("StagePaths","res://castagne/example/stage/Stage.tscn", {
		"Description":"The list of stages that may be loaded.",
		"Flags":["Intermediate"],
		})
	
	
	# Category : General engine variables ----------------------------------------------------------
	RegisterCategory("Castagne Internals", {"Description":"Variables and configurations relating to the engine itself. Please be careful when changing these."})
	
	RegisterVariableGlobal("_FrameID", 0, null, {
		"Description":"The number of game frames since the beginning of the match.",
		"Flags":["Advanced"],
		})
	RegisterVariableGlobal("_TrueFrameID", 0, null, {
		"Description":"The number of actual frames since the beginning of the match.",
		"Flags":["Advanced"],
		})
	RegisterVariableGlobal("_SkipFrame", false, ["ResetEachFrame"], {
		"Description":"Tells the engine if it should do a skip loop.",
		"Flags":["Expert"],
		})
	RegisterVariableGlobal("_FrozenFrame", false, ["ResetEachFrame"], {
		"Description":"Tells the engine if it should do a freeze loop",
		"Flags":["Expert"],
		})
	RegisterVariableGlobal("_SkipFrames", 0, null, {
		"Description":"Helper variable, counting the number of frames to skip remaining.",
		"Flags":["Expert"],
		})
	RegisterVariableGlobal("_FreezeFrames", 0, null, {
		"Description":"Helper variable, counting the number of frames in freeze remaining.",
		"Flags":["Expert"],
		})
	
	RegisterVariableGlobal("_CurrentEntityID", 0, null, {
		"Description":"Remembers the next ID for a new entity.",
		"Flags":["Expert"],
		})
	RegisterVariableGlobal("_EntitiesToInit", [], null, {
		"Description":"List of entities to handle in the next Init Phase",
		"Flags":["Expert"],
		})
	RegisterVariableGlobal("_EntitiesToDestroy", [], null, {
		"Description":"List of entities to destroy at the beginning of the next loop.",
		"Flags":["Expert"],
		})
	RegisterVariableGlobal("_ActiveEntities", [], null, {
		"Description":"List of entities that are executed each frame.",
		"Flags":["Expert"],
		})
	#RegisterVariableEntity("_VariablesSet", [])
	
	# Variables defined in Engine, here for documentation
	#RegisterVariableGlobal("_Players", [], ["NoInit"])
	# These are per player
	# :TODO:Panthavma:20220319:Document these
	#RegisterVariableEntity("RawInputs", {}, ["NoInit"])
	#RegisterVariableEntity("Inputs", {}, ["NoInit"])
	#RegisterVariableEntity("MainEntity", -1, ["NoInit"])
	#RegisterVariableEntity("PID", -1, ["NoInit"])
	
	RegisterVariableGlobal("_NbPlayers", 0, null, {
		"Description":"Remembers the amount of players.",
		"Flags":["Advanced"],
		})
	
	
	RegisterConfig("CastagneVersion","Castagne v0.53", {
		"Flags":["Hidden", "Reload", "Advanced"],
		"Description":"Internal version of the Castagne engine."
		})
	RegisterConfig("PathEngine", "res://castagne/engine/CastagneEngine.tscn", {
		"Flags":["Expert"],
		"Description":"Filepath to the engine scene."
		})
	RegisterConfig("PathEditor", "res://castagne/editor/CastagneEditor.tscn", {
		"Flags":["Expert"], "Description":"Filepath to the editor scene."
		})
	RegisterConfig("PathDevTools", "res://castagne/devtools/DevTools.tscn", {
		"Flags":["Expert"],
		"Description":"Filepath to the devtools scene."
		})
	RegisterConfig("PathMainMenu","res://castagne/menus/mainmenu/DefaultMainMenu.tscn", {
		"Flags":["Advanced"],
		"Description":"Filepath to the main menu scene."
		})
	RegisterConfig("PathCharacterSelect","res://castagne/menus/characterselect/DefaultCharacterSelect.tscn", {
		"Flags":["Advanced"],
		"Description":"Filepath to the character select screen scene."
		})
	RegisterConfig("PathPostBattle","res://castagne/menus/postbattle/DefaultPostBattle.tscn", {
		"Flags":["Advanced"],
		"Description":"Filepath to the post battle scene."
		})
	
	#RegisterConfig("Skeleton-default", "base")
	#RegisterConfig("Skeleton-base", "res://castagne/Base.casp", {"Flags":["Advanced"]})
	
	
	RegisterConfig("ConfigSkeleton", "", {
		"Flags":["ReloadFull", "Advanced"],
		"Description":"Path to the config skeleton of this file. Used to build additively on top of a base config, which is done for the genre selection for instance."
		})
	
	
	#RegisterBattleInitData("map",0)
	#RegisterBattleInitData("music",0)
	#RegisterBattleInitData("mode","Training")
	#RegisterBattleInitData("online",false)
	
	RegisterCategory("Castagne Modules", {"Description":"Configurations relating to the module system of Castagne."})
	RegisterCustomConfig("Set Modules", "ModuleSet", {"Flags":["Advanced", "ReloadFull", "LockBack"]})
	RegisterConfig("Modules","coreset, physics, graphics, flow, user", {
		"Flags":["Hidden","ReloadFull", "Advanced"],
		"Description":"List of modules to load for matches."}
		)
	var castagneStandardModules = {
		# Coreset
		"coreset":"editor, functions, attacks, sound, input, menus, tmp",
		"editor":"res://castagne/modules/castagne/CMEditor.gd",
		"functions":"res://castagne/modules/coreset/CMFunctions.gd",
		"sound":"res://castagne/modules/coreset/CMSound.gd",
		"attacks":"res://castagne/modules/coreset/CMAttacks.gd",
		"input":"res://castagne/modules/coreset/CMInput.gd",
		"menus":"res://castagne/modules/coreset/CMMenus.gd",
		
		# Flow
		"flow": "flowfighting",
		"flowgeneric": "res://castagne/modules/flow/CMFlow.gd",
		"flowfighting": "res://castagne/modules/flow/CMFlowFighting.gd",
		"flowuser": "",
		
		# Physics
		"physics": "physics2d",
		"physics2d": "res://castagne/modules/physics/CMPhysics2D.gd",
		"physicsuser": "",
		
		# Graphics
		"graphics": "graphics25d",
		"graphics2d": "res://castagne/modules/graphics/CMGraphics2D.gd",
		"graphics25d": "res://castagne/modules/graphics/CMGraphics2HalfD.gd",
		"graphics3d": "res://castagne/modules/graphics/CMGraphics3D.gd",
		"graphicsuser": "",
		
		# User
		"user": "",
		
		# Temporary Modules
		"tmp": "ui",
		"ui": "res://castagne/modules/ui/FightingUI.tscn",
	}
	var castagneStandardModulesList = null
	
	for moduleName in castagneStandardModules:
		var modulePath = castagneStandardModules[moduleName]
		if(modulePath.ends_with(".tscn") or modulePath.ends_with(".gd")):
			if(castagneStandardModulesList == null):
				castagneStandardModulesList = ""
			else:
				castagneStandardModulesList += ", "
			castagneStandardModulesList += moduleName
		
		RegisterConfig("Modules-"+moduleName, modulePath, {
			"Flags":["Hidden", "ReloadFull", "Expert"],
			"Description":"Standard Castagne Module. See the respective documentation for more info."})
	
	if(castagneStandardModulesList == null):
		castagneStandardModulesList = ""
	RegisterConfig("Modules-castagne-standard", castagneStandardModulesList, {
		"Flags":["Hidden", "Advanced"],
		"Description":"List of the standard castagne modules, which are loaded automatically for documentation purposes"})
	
	RegisterCategory("Castagne Starter", {"Description":"Data relating to the CastagneStarter system, which may start the editor or game depending on how the project is launched."})
	RegisterConfig("Starter-Option", 0, {
		"Flags":["Hidden", "Advanced"],
		"Description":"Remembers the option chosen in the starter."}
		)
	RegisterConfig("Starter-Timer", 0, {
		"Flags":["Intermediate"],
		"Description":"Time before a choice is made automatically, can be stopped with any keyboard input. Set to zero to skip the timer, or -1 to disable the time limit."
		})
	RegisterConfig("Starter-P1", 0, {
		"Flags":["Hidden", "Advanced"],
		"Description":"Obsolete"})
	RegisterConfig("Starter-P2", 0, {
		"Flags":["Hidden", "Advanced"],
		"Description":"Obsolete"})
	


func BattleInit(stateHandle, _battleInitData):
	stateHandle._engine.physicsModule = self
	stateHandle._engine.graphicsModule = self
	stateHandle._engine.editorModule = self

func PhysicsPhase(_gameStateHandle, _previousGameStateHandle, _activeEIDs):
	pass

# :TODO:Panthavma:20220401:Add a way to execute scripts during freeze, another phase?
func FrameStart(stateHandle):
	if(stateHandle.GlobalGet("_SkipFrames") > 0):
		stateHandle.GlobalAdd("_SkipFrames", -1)
		stateHandle.GlobalSet("_SkipFrame", true)
	elif(stateHandle.GlobalGet("_FreezeFrames") > 0):
		stateHandle.GlobalAdd("_FreezeFrames", -1)
		stateHandle.GlobalSet("_FrozenFrame", true)

func InitPhaseStartEntity(stateHandle):
	CommonPhaseStartEntity(stateHandle)
	stateHandle.GlobalGet("_ActiveEntities").append(stateHandle.EntityGet("_EID"))
	stateHandle.EntitySet("_StateTarget", stateHandle.EntityGet("_State"))
	
	# Kinda jank but this works with the current flow
	_HandleCopyToBuffer(stateHandle.Memory(), [stateHandle.EntityGet("_EID")])
func InitPhaseEndEntity(stateHandle):
	CommonPhaseEndEntity(stateHandle)

func ActionPhaseStartEntity(stateHandle):
	CommonPhaseStartEntity(stateHandle)
	stateHandle.EntitySet("_StateFrameID", stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame"))
	for f in stateHandle.EntityGet("_FlagsNext"):
		stateHandle.EntitySetFlag(f)
	stateHandle.EntitySet("_FlagsNext", [])

func ActionPhaseEndEntity(stateHandle):
	CommonPhaseEndEntity(stateHandle)

func ActionPhaseEnd(stateHandle):
	var activeEIDs = stateHandle.GlobalGet("_ActiveEntities")
	_HandleCopyToBuffer(stateHandle.Memory(), activeEIDs)
	_HandleFlagTargetBuffer(stateHandle, activeEIDs)

func ReactionPhaseStartEntity(stateHandle):
	CommonPhaseStartEntity(stateHandle)

func ReactionPhaseEndEntity(stateHandle):
	CommonPhaseEndEntity(stateHandle)

func ReactionPhaseEnd(stateHandle):
	var activeEIDs = stateHandle.GlobalGet("_ActiveEntities")
	_HandleCopyToBuffer(stateHandle.Memory(), activeEIDs)
	_HandleFlagTargetBuffer(stateHandle, activeEIDs)


func CommonPhaseStartEntity(stateHandle):
	stateHandle.EntitySet("_ExecuteAfterCalls", [])
func CommonPhaseEndEntity(stateHandle):
	# Execute after
	var execAfter = stateHandle.EntityGet("_ExecuteAfterCalls")
	var fighterID = stateHandle.EntityGet("_FighterID")
	for eaStateName in execAfter:
		var fighterScript = engine.GetFighterScript(fighterID, eaStateName)
		if(fighterScript == null):
			ModuleError("ExecuteAfter call to " + eaStateName + " failed: script not found!", stateHandle)
		engine.ExecuteFighterScript(fighterScript, stateHandle)
	
	TransitionApply(stateHandle)

func _HandleCopyToBuffer(memory, eidsToHandle):
	var copyToBuffer = memory.GlobalGet("_CopyToBuffer")
	var newBuffer = []
	var doMultipleChecks = true
	
	var variablesSetByOrigin = {}
	var variablesSetByTarget = {}
	
	copyToBuffer.sort_custom(self, "_CopyToBufferSort")
	
	for ctb in copyToBuffer:
		var targetEID = ctb["TargetEID"]
		if(targetEID in eidsToHandle):
			var originalEID = ctb["OriginEID"]
			var varName = ctb["Variable"]
			
			if(doMultipleChecks):
				if(!variablesSetByOrigin.has(originalEID)):
					variablesSetByOrigin[originalEID] = {}
				if(!variablesSetByOrigin[originalEID].has(targetEID)):
					variablesSetByOrigin[originalEID][targetEID] = []
				if(!variablesSetByTarget.has(targetEID)):
					variablesSetByTarget[targetEID] = []
				
				if(varName in variablesSetByOrigin[originalEID][targetEID]):
					ModuleError("EID "+str(originalEID)+" is setting the variable " +str(varName)+" on target EID "+str(targetEID)+" several times. Behaviour undefined.")
					# :TODO:Panthavma:20221227:Actually could be filtered beforehand at set time
				if(varName in variablesSetByTarget[targetEID]):
					ModuleLog("Warning: Variable " +str(varName)+" set on other entities on target EID "+str(targetEID)+" several times.")
			
			memory.EntitySet(targetEID, varName, ctb["Value"])
		else:
			newBuffer += [ctb]
	
	memory.GlobalSet("_CopyToBuffer", newBuffer)
	
func _HandleFlagTargetBuffer(stateHandle, eidsToHandle):
	var flagTargetBuffer = stateHandle.GlobalGet("_FlagTargetBuffer")
	flagTargetBuffer.sort_custom(self, "_CopyToBufferSort")
	
	for ftb in flagTargetBuffer:
		var targetEID = ftb["TargetEID"]
		if(targetEID in eidsToHandle):
			var originalEID = ftb["OriginEID"]
			var flagName = ftb["Flag"]
			var value = ftb["Value"]
			
			stateHandle.PointToEntity(targetEID)
			stateHandle.EntitySetFlag(flagName, value)
	stateHandle.GlobalSet("_FlagTargetBuffer", [])

func _CopyToBufferSort(a, b):
	return a["OriginEID"] < b["OriginEID"]

# --------------------------------------------------------------------------------------------------
# Variables
func Flag(args, stateHandle):
	stateHandle.EntitySetFlag(ArgStr(args, stateHandle, 0))
func Unflag(args, stateHandle):
	stateHandle.EntitySetFlag(ArgStr(args, stateHandle, 0), false)
func FlagNext(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(!stateHandle.EntityGet("_FlagsNext").has(flagName)):
		stateHandle.EntityAdd("_FlagsNext", [flagName])
func UnflagNext(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(stateHandle.EntityGet("_FlagsNext").has(flagName)):
		stateHandle.EntityGet("_FlagsNext").erase(flagName)

func Set(args, stateHandle):
	var paramName = ArgVar(args, stateHandle, 0)
	var value = ArgInt(args, stateHandle, 1)
	# TODO Need check
	#stateHandle.Memory().EntitySet(stateHandle.EntityGet("_EID"), paramName, value, true)
	stateHandle.EntitySet(paramName, value)
func SetStr(args, stateHandle):
	var paramName = ArgVar(args, stateHandle, 0)
	var value = ArgStr(args, stateHandle, 1)
	stateHandle.EntitySet(paramName, value)






# --------------------------------------------------------------------------------------------------
# Mathematics
func Add(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, ArgInt(args, stateHandle, 0) + ArgInt(args, stateHandle, 1))
func Sub(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, ArgInt(args, stateHandle, 0) - ArgInt(args, stateHandle, 1))
func Mul(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, ArgInt(args, stateHandle, 0) * ArgInt(args, stateHandle, 1))
func Div(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	var b = ArgInt(args, stateHandle, 1)
	if(b == 0):
		ModuleError("Div: Dividing by zero!", stateHandle)
		return
	stateHandle.EntitySet(destVar, ArgInt(args, stateHandle, 0) / b)
func Mod(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	var b = ArgInt(args, stateHandle, 1)
	if(b == 0):
		ModuleError("Mod: Dividing by zero!", stateHandle)
		return
	stateHandle.EntitySet(destVar, ArgInt(args, stateHandle, 0) % b)
func Max(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, max(ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1)))
func Min(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, min(ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1)))


# --------------------------------------------------------------------------------------------------
# Entities
func CreateEntity(args, stateHandle):
	CreateEntityRaw(args, stateHandle)
	CopyToTarget(["_PositionX"], stateHandle)
	CopyToTarget(["_PositionY"], stateHandle)
	CopyToTarget(["_FacingHPhysics"], stateHandle)
	CopyToTarget(["_FacingVPhysics"], stateHandle)
	CopyToTarget(["_FacingHModel"], stateHandle)
	CopyToTarget(["_FacingVModel"], stateHandle)

func CreateEntityRaw(args, stateHandle):
	var playerID = stateHandle.EntityGet("_Player")
	var fighterID = stateHandle.EntityGet("_FighterID")
	var newEID = stateHandle.Engine().AddNewEntity(stateHandle, playerID, fighterID, ArgStr(args, stateHandle, 0))
	stateHandle.SetTargetEntity(newEID)

func DestroyEntity(_args, stateHandle):
	if(!stateHandle.GlobalGet("_EntitiesToDestroy").has(stateHandle.EntityGet("_EID"))):
		stateHandle.GlobalGet("_EntitiesToDestroy").append(stateHandle.EntityGet("_EID"))


func GetCurrentEntityID(args, stateHandle):
	var targetVar = ArgVar(args, stateHandle, 0)
	stateHandle.EntitySet(targetVar, stateHandle.GetEntityID())

func GetTargetEntityID(args, stateHandle):
	var targetVar = ArgVar(args, stateHandle, 0)
	stateHandle.EntitySet(targetVar, stateHandle.GetTargetEntity())

func TargetEntityByID(args, stateHandle):
	var targetID = ArgInt(args, stateHandle, 0)
	stateHandle.EntitySet("_TargetEID", targetID)
	stateHandle.SetTargetEntity(targetID)

func TargetEntitySelf(_args, stateHandle):
	stateHandle.EntitySet("_TargetEID", stateHandle.GetEntityID())
	stateHandle.SetTargetEntity(stateHandle.GetEntityID())

func CopyFromTarget(args, stateHandle):
	if(!stateHandle.GetTargetEntity() in stateHandle.GlobalGet("_ActiveEntities")):
		ModuleError("CopyFromTarget: Copying from a non initialized entity!", stateHandle)
		return
	# :TODO:Panthavma:20230506:Not thread safe atm
	var varCurEntity = ArgVar(args, stateHandle, 0)
	var varTargetEntity = ArgStr(args, stateHandle, 1, varCurEntity)
	stateHandle.EntitySet(varCurEntity, stateHandle.TargetEntityGet(varTargetEntity))

func CopyToTarget(args, stateHandle):
	# TODO check if already in?
	var varCurEntity = ArgVar(args, stateHandle, 0)
	var varTargetEntity = ArgStr(args, stateHandle, 1, varCurEntity)
	var value = stateHandle.EntityGet(varCurEntity)
	SetVariableInTarget(stateHandle, varTargetEntity, value)

func SetIntInTarget(args, stateHandle):
	var varTargetEntity = ArgStr(args, stateHandle, 0)
	var value = ArgInt(args, stateHandle, 1)
	SetVariableInTarget(stateHandle, varTargetEntity, value)

func SetStrInTarget(args, stateHandle):
	var varTargetEntity = ArgStr(args, stateHandle, 0)
	var value = ArgStr(args, stateHandle, 1)
	SetVariableInTarget(stateHandle, varTargetEntity, value)

func FlagInTarget(args, stateHandle, flagValue = true):
	var flagName = ArgStr(args, stateHandle, 0)
	SetFlagInTarget(stateHandle, flagName, flagValue)
func UnflagInTarget(args, stateHandle):
	FlagInTarget(args, stateHandle, false)

# --------------------------------------------------------------------------------------------------
# States
func Transition(args, stateHandle):
	if(args.size() == 0):
		stateHandle.EntitySet("_StateChangePriority", -100000)
		stateHandle.EntitySet("_StateTarget", null)
		return
	
	var newStateName = ArgStr(args, stateHandle, 0)
	var priority = ArgInt(args, stateHandle, 1, 0)
	var allowSelfTransition = ArgBool(args, stateHandle, 2, false)
	
	if(stateHandle.EntityGet("_StateChangePriority") >= priority):
		return
	if(newStateName == stateHandle.EntityGet("_State") and !allowSelfTransition):
		return
	
	stateHandle.EntitySet("_StateChangePriority", priority)
	stateHandle.EntitySet("_StateTarget", newStateName)
func TransitionBuffer(args, stateHandle):
	Transition(args, stateHandle)
func TransitionApply(stateHandle):
	if(stateHandle.EntityGet("_StateTarget") != null):
		stateHandle.EntitySet("_State", stateHandle.EntityGet("_StateTarget"))
		stateHandle.EntitySet("_StateStartFrame", stateHandle.GlobalGet("_FrameID"))
		stateHandle.EntitySet("_StateChangePriority", -100000)
		stateHandle.EntitySet("_StateTarget", null)


func Call(args, stateHandle):
	var stateName = ArgStr(args, stateHandle, 0)
	
	var fighterScript = engine.GetFighterScript(stateHandle.EntityGet("_FighterID"), stateName)
	if(fighterScript == null):
		Castagne.Error("Call: Calling undefined state " + str(stateName))
		return
	
	var callParentLevel = stateHandle.EntityGet("_CallParentLevel")
	stateHandle.EntitySet("_CallParentLevel", 0)
	engine.ExecuteFighterScript(fighterScript, stateHandle)
	stateHandle.EntitySet("_CallParentLevel", callParentLevel)

func CallParent(args, stateHandle):
	var stateName = ArgStr(args, stateHandle, 0)
	var level = stateHandle.EntityGet("_CallParentLevel") + 1
	for _i in range(level):
		stateName = "Parent:"+stateName
	
	var fighterScript = engine.GetFighterScript(stateHandle.EntityGet("_FighterID"), stateName)
	if(fighterScript == null):
		Castagne.Error("CallParent: Calling undefined state " + str(stateName))
		return
	# :TODO:Panthavma:20220315:Probably needs more tests? "Should" work but haven't extensively tested since v0.3
	stateHandle.EntitySet("_CallParentLevel", level)
	engine.ExecuteFighterScript(fighterScript, stateHandle)
	stateHandle.EntitySet("_CallParentLevel", level - 1)

func ExecuteAfter(args, stateHandle):
	if(args.size() == 0):
		stateHandle.EntitySet("_ExecuteAfterCalls", [])
	else:
		var stateName = ArgStr(args, stateHandle, 0)
		stateHandle.EntityAdd("_ExecuteAfterCalls", [stateName])

# --------------------------------------------------------------------------------------------------
# Debug

# :TODO:Panthavma:20220131:Make it more flexible to be able to show variable's value ? Or just raw
func Log(args, stateHandle):
	Castagne.Log("["+str(stateHandle.GlobalGet("_TrueFrameID"))+"] State Log "+str(stateHandle.EntityGet("_EID"))+" : " + ArgStr(args, stateHandle, 0))
func LogB(args, stateHandle):
	Log(args, stateHandle)
func LogR(args, stateHandle):
	Log(args, stateHandle)

# --------------------------------------------------------------------------------------------------
# Engine Functions

func FreezeFrames(args, stateHandle):
	stateHandle.GlobalSet("_FreezeFrames", max(stateHandle.GlobalGet("_FreezeFrames"), ArgInt(args, stateHandle, 0)))


