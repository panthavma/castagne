extends "../CastagneModule.gd"

# :TODO:Panthavma:20220124:Allow different physics.

enum COLBOX_MODES {
	Default, OwnLayer, OtherLayers
}

enum ENVC_TYPES {
	AAPlane
}

enum ENVC_AAPLANE_DIR {
	Right, Up, Left, Down
}

enum ATTACK_CLASH_MODE {
	Disabled, TradePriority, ClashPriority
}

enum FACING_TYPE {
	Physics, Attack, Block, Model
}

var _physicsFlagList = []

func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	# :TODO:Panthavma:20211230:Gravity as a standard implementation
	# :TODO:Panthavma:20211230:More physics functions for flexible movement
	
	RegisterModule("Physics 2D", Castagne.MODULE_SLOTS_BASE.PHYSICS, {
		"Description":"Physics module optimized for 2D fighting games."
	})
	RegisterBaseCaspFile("res://castagne/modules/physics/Base-Physics2D.casp")
	
	RegisterCategory("Position and Movement", {"Description":"These functions allow basic movement and positioning for entities."})
	RegisterFunction("Move", [1,2], null, {
		"Description": "Moves the entity this frame, depending on facing.",
		"Arguments": ["Horizontal move", "(Optional) Vertical move"],
		"Types": ["int", "int"],
		})
	RegisterFunction("MoveAbsolute", [1,2], null, {
		"Description": "Moves the entity this frame, independant of facing.",
		"Arguments": ["Horizontal move", "(Optional) Vertical move"],
		})
	
	# TODO CAST 54 Autotarget opponent
	RegisterFunction("SetPositionRelativeToTarget", [2], null, {
		"Description": "Sets the entity's position based on the target entity, dependant on its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	RegisterFunction("SetPositionRelativeToTargetAbsolute", [2], null, {
		"Description": "Sets the entity's position based on the target entity, independant of its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	RegisterFunction("SetTargetPosition", [2], null, {
		"Description": "Sets the target entity's position based on this entity, dependant of its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	RegisterFunction("SetTargetPositionAbsolute", [2], null, {
		"Description": "Sets the target entity's position based on this entity, independant of its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	
	
	RegisterFunction("SetWorldPosition", [2], null, {
		"Description": "Sets the position relative to the world origin, depending on facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
		})
	RegisterFunction("SetWorldPositionX", [1], null, {
		"Description": "Sets the position relative to the world origin, depending on facing.",
		"Arguments": ["Horizontal position"],
		})
	RegisterFunction("SetWorldPositionY", [1], null, {
		"Description": "Sets the position relative to the world origin, depending on facing.",
		"Arguments": ["Vertical position"],
		})
	RegisterFunction("SetWorldPositionAbsolute", [2], null, {
		"Description": "Sets the position relative to the world origin, independant of facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
		})
	RegisterFunction("SetWorldPositionAbsoluteX", [1], null, {
		"Description": "Sets the position relative to the world origin, independant of facing.",
		"Arguments": ["Horizontal position"],
		})
	
	RegisterVariableEntity("_PositionX", 0)
	RegisterVariableEntity("_PositionY", 0)
	RegisterVariableEntity("_MovementX", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_MovementY", 0, ["ResetEachFrame"])
	
	
	
	
	
	
	
	
	
	RegisterCategory("Momentum", {
		"Description":"Helper functions related to momentum, applies movement from frame to frame."})
	RegisterFunction("AddMomentum", [1,2], null, {
		"Description": "Adds to the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "(Optional) Vertical momentum"],
		})
	RegisterFunction("AddMomentumAbsolute", [1,2], null, {
		"Description": "Adds to the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "(Optional) Vertical momentum"],
		})
	
	RegisterFunction("SetMomentum", [2], null, {
		"Description": "Sets the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("SetMomentumAbsolute", [2], null, {
		"Description": "Sets the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("SetMomentumX", [1], null, {
		"Description": "Sets the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum"],
		})
	RegisterFunction("SetMomentumXAbsolute", [1], null, {
		"Description": "Sets the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum"],
		})
	RegisterFunction("SetMomentumY", [1], null, {
		"Description": "Sets the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Vertical momentum"],
		})
	
	RegisterFunction("BreakMomentum", [1,2], null, {
		"Description": "Reduces the momentum by the amount given.",
		"Arguments": ["Horizontal momentum","(Optional) Vertical momentum"],
		})
	RegisterFunction("BreakMomentumX", [1,2,3], null, {
		"Description": "Reduces the horizontal momentum by the amount given.",
		"Arguments": ["Horizontal momentum break","(Optional) Horizontal momentum cap","(Optional) Horizontal momentum cap max"],
		})
	RegisterFunction("BreakMomentumY", [1,2,3], null, {
		"Description": "Reduces the vertical momentum by the amount given.",
		"Arguments": ["Vertical momentum break","(Optional) Vertical momentum cap","(Optional) Vertical momentum cap max"],
		})
	RegisterFunction("BreakMomentumXAbsolute", [1,2,3], null, {
		"Description": "Reduces the horizontal momentum by the amount given, independant of facing.",
		"Arguments": ["Horizontal momentum break","(Optional) Horizontal momentum cap","(Optional) Horizontal momentum cap max"],
		})
	
	RegisterFunction("CapMomentum", [2,4], null, {
		"Description": "Limits the momentum to those values.",
		"Arguments": ["Horizontal momentum", "(Optional) Horizontal Momentum Max","Vertical momentum", "(Optional) Vertical Momentum Max"],
		})
	RegisterFunction("CapMomentumX", [2], null, {
		"Description": "Limits the momentum to those values.",
		"Arguments": ["Horizontal momentum", "Horizontal Momentum Max"],
		})
	RegisterFunction("CapMomentumY", [2], null, {
		"Description": "Limits the momentum to those values.",
		"Arguments": ["Vertical momentum", "Vertical Momentum Max"],
		})
	RegisterFunction("CapMomentumAbsolute", [2,4], null, {
		"Description": "Limits the momentum to those values, independant of facing.",
		"Arguments": ["Horizontal momentum", "(Optional) Horizontal Momentum Max","Vertical momentum", "(Optional) Vertical Momentum Max"],
		})
	RegisterFunction("CapMomentumXAbsolute", [2], null, {
		"Description": "Limits the momentum to those values, independant of facing.",
		"Arguments": ["Horizontal momentum", "Horizontal Momentum Max"],
		})
	
	RegisterFunction("AddMomentumTurn", [2], null, {
		"Description": "Adds to the momentum, depending on facing. If momentum is going in the opposite direction, cancel it before applying.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("AddMomentumTurnAbsolute", [2], null, {
		"Description": "Adds to the momentum, independant of facing. If momentum is going in the opposite direction, cancel it before applying.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	
	RegisterVariableEntity("_MomentumX", 0)
	RegisterVariableEntity("_MomentumY", 0)
	RegisterFlag("HaltMomentum")
	
	
	
	
	
	
	
	
	RegisterCategory("Facing", {
		"Description": "Functions relative to where the entity is facing, to handle forward / back / side directions.\n"+
		"Several types of facing are available for various purposes."
	})
	
	RegisterFunction("SetFacing", [1,2], null, {
		"Description": "Set an entity's physics facing directly.",
		"Arguments": ["Horizontal Facing", "(Optional) Vertical Facing"],
	})
	RegisterFunction("SetFacingWithType", [2,3], null, {
		"Description": "Set an entity's facing directly, for any type.",
		"Arguments": ["Type of facing to set", "Horizontal Facing", "(Optional) Vertical Facing"],
	})
	RegisterFunction("FlipFacing", [0,1,2], null, {
		"Description": "Flips the horizontal facing of an entity to make it face backwards.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: false)"],
	})
	RegisterFunction("FaceTowardsTarget", [0,1,2], null, {
		"Description": "Faces the entity towards the target.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: false)"],
	})
	RegisterFunction("TargetFaceTowardsSelf", [0,1,2], null, {
		"Description": "Faces the target entity towards this entity.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: false)"],
	})
	RegisterFunction("CopyTargetFacing", [0,1,2], null, {
		"Description": "Copy the facing of the target entity to this entity.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: true)"],
	})
	RegisterFunction("CopyFacingToTarget", [0,1,2], null, {
		"Description": "Copy this entity's facing to the target entity.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: true)"],
	})
	RegisterFunction("CopyFacingToOtherFacing", [1,2,3], null, {
		"Description": "Copy one facing type to another facing type.",
		"Arguments": ["Target facing type", "(Optional) Source facing type (default: physics)", "(Optional) Also adjust vertical facing (default: true)"],
	})
	
	RegisterConstant("FACING_PHYSICS", FACING_TYPE.Physics, {
		"Description":"Facing type constant for the physics facing. This is used for movement."})
	RegisterConstant("FACING_ATTACK", FACING_TYPE.Attack, {
		"Description":"Facing type constant for the attack facing. This is not used for now."})
	RegisterConstant("FACING_BLOCK", FACING_TYPE.Block, {
		"Description":"Facing type constant for the block facing. This is not used for now."})
	RegisterConstant("FACING_MODEL", FACING_TYPE.Model, {
		"Description":"Facing type constant for the model facing. This is used for graphics."})
	
	RegisterVariableEntity("_FacingHPhysics", 1, null, {"Description":"Horizontal physics facing."})
	RegisterVariableEntity("_FacingVPhysics", 0, null, {"Description":"Vertical physics facing. Not used."})
	RegisterVariableEntity("_FacingHAttack", 1, null, {"Description":"Horizontal attack facing. Not used."})
	RegisterVariableEntity("_FacingVAttack", 0, null, {"Description":"Vertical attack facing. Not used."})
	RegisterVariableEntity("_FacingHBlock", 1, null, {"Description":"Horizontal block facing. Not used."})
	RegisterVariableEntity("_FacingVBlock", 0, null, {"Description":"Vertical block facing. Not used."})
	RegisterVariableEntity("_FacingHModel", 1, null, {"Description":"Horizontal model facing."})
	RegisterVariableEntity("_FacingVModel", 0, null, {"Description":"Vertical model facing. Not used."})
	# Search for [TODO FACING V] for when its time to implement
	
	
	
	
	
	
	
	RegisterCategory("Collisions", {
		"Description":"Environment and Attack colliders setup."})
	RegisterFunction("Colbox", [2, 3, 4], null, {
		"Description": "Sets the collision box, which will push other entities.",
		"Arguments": ["Back bound (Optional)", "Front bound", "Down bound (Optional if only two parameters)", "Up bound"],
		})
	RegisterFunction("SetColboxMode", [0,1], null, {
		"Description": "Sets the mode of the Colbox for collisions using one of the COLBOXMODE_ constants.",
		"Arguments": ["(Optional) Colbox mode (default: Default)"]
	})
	RegisterFunction("SetColboxPhantom", [0,1], null, {
		"Description": "Marks the Colbox as Phantom, meaning it will only collide with the environment.",
		"Arguments": ["(Optional) If the colbox is phantom or not (default: true)"],
	})
	RegisterFunction("SetColboxLayer", [0,1], null, {
		"Description": "Sets the layer of this colbox. By default, the layer is equal to the PID+1.",
		"Arguments": ["(Optional) Layer to set (Default: PID+1)"],
	})
	
	
	RegisterFunction("Hurtbox", [2, 3, 4], null, {
		"Description": "Adds a hurtbox, that can be hit by hitboxes.",
		"Arguments": ["Back bound (Optional)", "Front bound", "Down bound (Optional if only two parameters)", "Up bound"],
		})
	RegisterFunction("Hitbox", [2, 3, 4], null, {
		"Description": "Adds a hitbox, that can hit hurtboxes. You need to set attack data beforehand, though the Attack function. This function does not reset the attack data, so you can add several hitboxes for the same attack data by calling Hitbox several times.",
		"Arguments": ["Back bound (Optional)", "Front bound", "Down bound (Optional if only two parameters)", "Up bound"],
		})
	
	
	RegisterFunction("ResetColbox", [0], null, {
		"Description": "Deletes the current colbox.",
		"Arguments": [],
	})
	RegisterFunction("ResetHurtboxes", [0], null, {
		"Description": "Deletes the current hurtboxes.",
		"Arguments": [],
	})
	RegisterFunction("ResetHitboxes", [0], null, {
		"Description": "Deletes the current hitboxes.",
		"Arguments": [],
	})
	
	RegisterVariableEntity("_ColboxPhantom", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_ColboxLayer", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_ColboxMode", COLBOX_MODES.Default, ["ResetEachFrame"])
	RegisterConstant("COLBOXMODE_DEFAULT", COLBOX_MODES.Default)
	RegisterConstant("COLBOXMODE_OWNLAYER", COLBOX_MODES.OwnLayer)
	RegisterConstant("COLBOXMODE_OTHERLAYERS", COLBOX_MODES.OtherLayers)
	
	RegisterVariableEntity("_Colbox", null, ["ResetEachFrame"])
	RegisterVariableEntity("_Hitboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("_Hurtboxes", [], ["ResetEachFrame"])
	
	RegisterConfig("AttackClashMode", ATTACK_CLASH_MODE.TradePriority, {
		"Options":{
			ATTACK_CLASH_MODE.Disabled:"Disabled",
			ATTACK_CLASH_MODE.TradePriority:"Trade Priority (Default)",
			ATTACK_CLASH_MODE.ClashPriority:"Clash Priority"
		}
	})
	
	
	RegisterVariableEntity("_PhysicsFlagBuffer", [], ["ResetEachFrame"])
	RegisterFlag("PFAirborne")
	RegisterFlag("PFGrounded")
	RegisterFlag("PFWall")
	RegisterFlag("PFCeiling")
	RegisterFlag("PFLanding")
	_physicsFlagList = ["PFAirborne", "PFGrounded", "PFWall", "PFCeiling", "PFLanding"]
	
	
	
	
	
	
	
	RegisterCategory("Helpers")
	
	RegisterFunction("GetTargetPositionRelativeToSelf", [1,2], null, {
		"Description": "Computes the position of the Target entity in this entity's physics referential, and stores it in the variables given.",
		"Arguments": ["The variable in which to store the X position of the target", "(Optional) The variable in which to store the Y position of the target"],
	})
	
	RegisterFlag("IgnoreGravity")
	RegisterFlag("IgnoreFriction")
	RegisterFlag("NoHurtbox")
	RegisterFlag("NoColbox")
	RegisterFlag("NoHurtboxSet")
	RegisterFlag("NoHitboxSet")
	RegisterFlag("NoColboxSet")
	RegisterVariableEntity("_Gravity", 0)
	RegisterVariableEntity("_TerminalVelocity", -3000)
	RegisterVariableEntity("_FrictionGround", 0)
	RegisterVariableEntity("_FrictionAir", 0)
	
	RegisterStateFlag("Grounded")
	RegisterStateFlag("Airborne")
	
	RegisterVariableGlobal("_CameraX", 0)
	RegisterVariableGlobal("_CameraY", 0)
	
	
	
	
	
	
	
	RegisterCategory("Arena", {
		"Description":"Arena setup for fighting games."
	})
	
	RegisterConfig("UseFightingArena", true)
	
	RegisterConfig("ArenaSize", 180000)
	RegisterConfig("ArenaMaxPlayerDistance", 75000)
	
	RegisterConfig("PhysicsNbBuckets", 4)

func BattleInit(stateHandle, _battleInitData):
	engine.physicsModule = self

func ActionPhaseStartEntity(stateHandle):
	stateHandle.EntitySet("_ColboxLayer", stateHandle.EntityGet("_Player")+1)
	stateHandle.EntitySetFlag("NoHurtboxSet")
	stateHandle.EntitySetFlag("NoHitboxSet")
	stateHandle.EntitySetFlag("NoColboxSet")
	
func ActionPhaseEndEntity(stateHandle):
	if(!stateHandle.EntityHasFlag("HaltMomentum")):
		#var airborne = stateHandle.EntityHasFlag("PFAirborne")
		#if(!stateHandle.EntityHasFlag("IgnoreGravity") and airborne):
		#	var grav = int(stateHandle.EntityGet("_Gravity"))
		#	var diffToTerminal = min(0, int(stateHandle.EntityGet("_TerminalVelocity")) - stateHandle.EntityGet("_MomentumY"))
		#	stateHandle.EntityAdd("_MomentumY", max(grav, diffToTerminal))
		#if(!stateHandle.EntityHasFlag("IgnoreFriction")):
		#	BreakMomentumX([stateHandle.EntityGet(("_FrictionAir" if airborne else "_FrictionGround"))], stateHandle)
		stateHandle.EntityAdd("_MovementX", stateHandle.EntityGet("_MomentumX"))
		stateHandle.EntityAdd("_MovementY", stateHandle.EntityGet("_MomentumY"))
	#if(stateHandle.EntityHasFlag("ApplyFacing")):
	#	stateHandle.EntitySet("_Facing", stateHandle.EntityGet("_FacingTrue"))


func PhysicsPhaseStart(_stateHandle):
	pass
func PhysicsPhaseStartEntity(stateHandle):
	for pf in _physicsFlagList:
		if(stateHandle.EntityHasFlag(pf)):
			stateHandle.EntityAdd("_PhysicsFlagBuffer", [pf])
			stateHandle.EntitySetFlag(pf, false)
func PhysicsPhaseEndEntity(stateHandle):
	var prevPhysicsFlags = stateHandle.EntityGet("_PhysicsFlagBuffer")
	if(!stateHandle.EntityHasFlag("PFGrounded")):
		stateHandle.EntitySetFlag("PFAirborne")
	if(prevPhysicsFlags.has("PFAirborne") and stateHandle.EntityHasFlag("PFGrounded")):
		stateHandle.EntitySetFlag("PFLanding")
	
	var coreModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
	for pf in _physicsFlagList:
		if(stateHandle.EntityHasFlag(pf)):
			coreModule.FlagNext([pf], stateHandle)
func PhysicsPhaseEnd(stateHandle):
	var nbPlayers = 0
	var camX = 0
	var camY = -99999
	for pid in range(stateHandle.GlobalGet("_NbPlayers")):
		if(stateHandle.PointToPlayerMainEntity(pid)):
			nbPlayers += 1
			camX += stateHandle.EntityGet("_PositionX")
			var posY = stateHandle.EntityGet("_PositionY")
			if(camY < posY):
				camY = posY
	if(nbPlayers > 0):
		camX /= nbPlayers
	stateHandle.GlobalSet("_CameraX", camX)
	stateHandle.GlobalSet("_CameraY", camY)

func InputPhaseStartEntity(stateHandle):
	var castagneInput = stateHandle.Input()
	var inputSchema = castagneInput.GetInputSchema()
	var inputs = stateHandle.EntityGet("_Inputs").duplicate()
	var facing = stateHandle.EntityGet("_FacingHPhysics")
	
	if(inputs.empty()):
		return
	
	for derivedInputName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.DERIVED]:
		var derivedInput = inputSchema[derivedInputName]
		var diType = derivedInput["DerivedType"]
		var diValue = false
		
		if(diType == Castagne.GAMEINPUT_DERIVED_TYPES.DIRECTIONAL):
			var giNames = derivedInput["GINames"]
			var dirID = derivedInput["DirID"]
			
			if(dirID == castagneInput.STICK_DIRECTIONS.BACK):
				diValue = inputs[giNames[(castagneInput.STICK_DIRECTIONS.LEFT if facing > 0 else castagneInput.STICK_DIRECTIONS.RIGHT)]]
			elif(dirID == castagneInput.STICK_DIRECTIONS.FORWARD):
				diValue = inputs[giNames[(castagneInput.STICK_DIRECTIONS.RIGHT if facing > 0 else castagneInput.STICK_DIRECTIONS.LEFT)]]
		else:
			continue
		
		inputs[derivedInputName] = diValue
	
	stateHandle.EntitySet("_Inputs", inputs)























# --------------------------------------------------------------------------------------------------
# Functions



func Move(args, stateHandle):
	MoveAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, 0)], stateHandle)
func MoveAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_MovementX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_MovementY", ArgInt(args, stateHandle, 1, 0))

func SetPositionRelativeToRef(args, stateHandle):
	SetPositionRelativeToRefAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetPositionRelativeToRefAbsolute(args, stateHandle):
	stateHandle.EntitySet("_PositionX", stateHandle.EntityGet("_PositionX") + ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_PositionY", stateHandle.EntityGet("_PositionY") + ArgInt(args, stateHandle, 1))

func SetPositionRelativeToTarget(args, stateHandle, useAbsolute=false):
	var pos = [ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1)]
	var eid = stateHandle.GetEntityID()
	var targetEID = stateHandle.GetTargetEntity()
	stateHandle.PointToEntity(targetEID)
	if(useAbsolute):
		pos = TransformWorldPosToEntityAbsolute(pos, stateHandle)
	else:
		pos = TransformWorldPosToEntity(pos, stateHandle)
	stateHandle.PointToEntity(eid)
	SetVariableInTarget(stateHandle, "_PositionX", pos[0])
	SetVariableInTarget(stateHandle, "_PositionY", pos[1])
func SetPositionRelativeToTargetAbsolute(args, stateHandle):
	SetPositionRelativeToTarget(args, stateHandle, true)
func SetTargetPosition(args, stateHandle, useAbsolute=false):
	var pos = [ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1)]
	if(useAbsolute):
		pos = TransformPosEntityAbsoluteToWorld(pos, stateHandle)
	else:
		pos = TransformPosEntityToWorld(pos, stateHandle)
	SetVariableInTarget(stateHandle, "_PositionX", pos[0])
	SetVariableInTarget(stateHandle, "_PositionY", pos[1])
func SetTargetPositionAbsolute(args, stateHandle):
	SetTargetPosition(args, stateHandle, true)

func SetWorldPosition(args, stateHandle):
	SetWorldPositionAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetWorldPositionAbsolute(args, stateHandle):
	stateHandle.EntitySet("_PositionX", ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_PositionY", ArgInt(args, stateHandle, 1))
func SetWorldPositionX(args, stateHandle):
	SetWorldPositionAbsoluteX([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0)], stateHandle)
func SetWorldPositionAbsoluteX(args, stateHandle):
	stateHandle.EntityGet("_PositionX", ArgInt(args, stateHandle, 0))
func SetWorldPositionY(args, stateHandle):
	stateHandle.EntityGet("_PositionY", ArgInt(args, stateHandle, 0))















func AddMomentum(args, stateHandle):
	AddMomentumAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, 0)], stateHandle)
func AddMomentumAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_MomentumX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_MomentumY", ArgInt(args, stateHandle, 1, 0))
	
func SetMomentum(args, stateHandle):
	SetMomentumAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetMomentumAbsolute(args, stateHandle):
	stateHandle.EntitySet("_MomentumX", ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_MomentumY", ArgInt(args, stateHandle, 1))
func SetMomentumX(args, stateHandle):
	SetMomentumAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0)], stateHandle)
func SetMomentumXAbsolute(args, stateHandle):
	stateHandle.EntitySet("_MomentumX", ArgInt(args, stateHandle, 0))
func SetMomentumY(args, stateHandle):
	stateHandle.EntitySet("_MomentumY", ArgInt(args, stateHandle, 0))
	
func AddMomentumTurn(args, stateHandle):
	AddMomentumTurnAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func AddMomentumTurnAbsolute(args, stateHandle):
	var h = ArgInt(args, stateHandle, 0)
	var v = ArgInt(args, stateHandle, 1)
	
	if(h != 0 and sign(h) != sign(stateHandle.EntityGet("_MomentumX"))):
		stateHandle.EntitySet("_MomentumX", 0)
	if(v != 0 and sign(v) != sign(stateHandle.EntityGet("_MomentumY"))):
		stateHandle.EntitySet("_MomentumY", 0)
	
	AddMomentumAbsolute(args, stateHandle)


func BreakMomentum(args, stateHandle):
	var h = min(ArgInt(args, stateHandle, 0), abs(stateHandle.EntityGet("_MomentumX")))
	var v = min(ArgInt(args, stateHandle, 1, 0), abs(stateHandle.EntityGet("_MomentumY")))
	stateHandle.EntityAdd("_MomentumX", -sign(stateHandle.EntityGet("_MomentumX")) * h)
	stateHandle.EntityAdd("_MomentumY", -sign(stateHandle.EntityGet("_MomentumY")) * v)
func BreakMomentumX(args, stateHandle):
	_BreakMomentumAxis(args, stateHandle, "_MomentumX", stateHandle.EntityGet("_FacingHPhysics"))
func BreakMomentumY(args, stateHandle):
	_BreakMomentumAxis(args, stateHandle, "_MomentumY")
func BreakMomentumXAbsolute(args, stateHandle):
	_BreakMomentumAxis(args, stateHandle, "_MomentumX")
func _BreakMomentumAxis(args, stateHandle, axis, facing=1.0):
	var m = stateHandle.EntityGet(axis)
	var mBreak = abs(ArgInt(args, stateHandle, 0))
	var mMin = ArgInt(args, stateHandle, 1, 0) * facing
	var mMax = ArgInt(args, stateHandle, 2, -mMin)
	
	if(mMin > mMax):
		var a = mMin
		mMin = mMax
		mMax = a
	
	if(m > mMax):
		var diff = m-mMax
		m -= int(min(diff, mBreak))
	elif(m < mMin):
		var diff = mMin-m
		m += int(min(diff, mBreak))
	stateHandle.EntitySet(axis, m)

func CapMomentum(args, stateHandle):
	CapMomentumAbsolute(args, stateHandle, stateHandle.EntityGet("_FacingHPhysics"))
func CapMomentumAbsolute(args, stateHandle, facing=1.0):
	var hMin
	var hMax
	var vMin
	var vMax
	if(args.size() > 2): # 4 args
		hMin = ArgInt(args, stateHandle, 0)
		hMax = ArgInt(args, stateHandle, 1)
		vMin = ArgInt(args, stateHandle, 2)
		vMax = ArgInt(args, stateHandle, 3)
		if(hMin > hMax or vMin > vMax):
			ModuleError("CapMomentum: Enveloppe has no volume", stateHandle)
		if(facing < 0):
			var a = hMin
			hMin = -hMax
			hMax = -a
	else: # 2 args
		hMax = abs(ArgInt(args, stateHandle, 0))
		vMax = abs(ArgInt(args, stateHandle, 1))
		hMin = -hMax
		vMin = -vMax
	
	stateHandle.EntitySet("_MomentumX", max(min(stateHandle.EntityGet("_MomentumX"), hMax), hMin))
	stateHandle.EntitySet("_MomentumY", max(min(stateHandle.EntityGet("_MomentumY"), vMax), vMin))
func CapMomentumX(args, stateHandle):
	_CapMomentmAxis(args, stateHandle, "_MomentumX", stateHandle.EntityGet("_FacingHPhysics"))
func CapMomentumY(args, stateHandle):
	_CapMomentmAxis(args, stateHandle, "_MomentumY")
func CapMomentumXAbsolute(args, stateHandle):
	_CapMomentmAxis(args, stateHandle, "_MomentumX")
func _CapMomentmAxis(args, stateHandle, axis, facing=1.0):
	var aMin = ArgInt(args, stateHandle, 0)
	var aMax = ArgInt(args, stateHandle, 1)
	if(aMin > aMax):
		ModuleError("CapMomentumAxis: Enveloppe has no volume", stateHandle)
	if(facing < 0):
		var a = aMin
		aMin = -aMax
		aMax = -a
	stateHandle.EntitySet(axis, max(min(stateHandle.EntityGet(axis), aMax), aMin))






















func SetFacing(args, stateHandle, facingType = FACING_TYPE.Physics):
	var facingH = ArgInt(args, stateHandle, 0)
	var facingV = ArgInt(args, stateHandle, 1, GetFacingHV(stateHandle, facingType)[1])
	SetFacingHV(stateHandle, facingH, facingV, facingType)
func SetFacingWithType(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0)
	var facingH = ArgInt(args, stateHandle, 1)
	var facingV = ArgInt(args, stateHandle, 2, GetFacingHV(stateHandle, facingType)[1])
	SetFacingHV(stateHandle, facingH, facingV, facingType)


func FlipFacing(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, false)
	var facing = GetFacingHV(stateHandle, facingType)
	
	facing[0] *= -1
	# [TODO FACING V]
	
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)

func FaceTowardsTarget(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, false)
	var selfPosX = stateHandle.EntityGet("_PositionX")
	var targetPosX = stateHandle.TargetEntityGet("_PositionX")
	# [TODO FACING V]
	if(selfPosX == targetPosX):
		return
	var facing = GetFacingHV(stateHandle, facingType)
	facing[0] = (1 if targetPosX > selfPosX else -1)
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
func TargetFaceTowardsSelf(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, false)
	var selfPosX = stateHandle.EntityGet("_PositionX")
	var targetPosX = stateHandle.TargetEntityGet("_PositionX")
	# [TODO FACING V]
	if(selfPosX == targetPosX):
		return
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	var facing = GetFacingHV(stateHandle, facingType)
	facing[0] = (-1 if targetPosX > selfPosX else 1)
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
	stateHandle.PointToEntity(selfEID)

func CopyTargetFacing(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, true)
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	var facing = GetFacingHV(stateHandle, facingType)
	stateHandle.PointToEntity(selfEID)
	if(!alsoAdjustV):
		facing[1] = GetFacingHV(stateHandle, facingType)[1]
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
func CopyFacingToTarget(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, true)
	var facing = GetFacingHV(stateHandle, facingType)
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	if(!alsoAdjustV):
		facing[1] = GetFacingHV(stateHandle, facingType)[1]
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
	stateHandle.PointToEntity(selfEID)
func CopyFacingToOtherFacing(args, stateHandle):
	var targetFacingType = ArgInt(args, stateHandle, 0)
	var sourceFacingType = ArgInt(args, stateHandle, 1, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 2, true)
	var facing = GetFacingHV(stateHandle, sourceFacingType)
	if(!alsoAdjustV):
		facing[1] = GetFacingHV(stateHandle, targetFacingType)[1]
	SetFacingHV(stateHandle, facing[0], facing[1], targetFacingType)





















func _BoxCreate(args, stateHandle):
	var box ={
		"Owner":stateHandle.EntityGet("_EID"),
	}
	if(args.size() > 3):
		box["Left"] = ArgInt(args, stateHandle, 0)
		box["Right"] = ArgInt(args, stateHandle, 1)
		box["Down"] = ArgInt(args, stateHandle, 2)
		box["Up"] = ArgInt(args, stateHandle, 3)
	elif(args.size() > 2):
		box["Right"] = ArgInt(args, stateHandle, 0)
		box["Down"] = ArgInt(args, stateHandle, 1)
		box["Up"] = ArgInt(args, stateHandle, 2)
		box["Left"] = -box["Right"]
	else:
		box["Right"] = ArgInt(args, stateHandle, 0)
		box["Up"] = ArgInt(args, stateHandle, 1)
		box["Down"] = -box["Up"]
		box["Left"] = -box["Right"]
	return box

func Colbox(args, stateHandle):
	var box = _BoxCreate(args, stateHandle)
	stateHandle.EntitySet("_Colbox", box)
	stateHandle.EntitySetFlag("NoColboxSet", false)

func Hurtbox(args, stateHandle):
	var box = _BoxCreate(args, stateHandle)
	box["Data"] = {}
	stateHandle.EntityGet("_Hurtboxes").append(box)
	stateHandle.EntitySetFlag("NoHurtboxSet", false)

func Hitbox(args, stateHandle):
	var box = _BoxCreate(args, stateHandle)
	box["AttackData"] = stateHandle.EntityGet("_AttackData").duplicate()
	stateHandle.EntityGet("_Hitboxes").append(box)
	stateHandle.EntitySetFlag("NoHitboxSet", false)

func GizmoBox(emodule, args, lineActive, _stateHandle, type):
	var color = [Color(0.4, 0.4, 1.0), Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4)][type]
	var colorBack = [Color(0.3, 0.3, 1.0, 0.45), Color(1.0, 0.3, 0.3, 0.45), Color(0.3, 1.0, 0.3, 0.45)][type]
	var widthActive = [6,6,6][type]
	var widthInactive = [2,2,2][type]
	var l = 0
	var r = 0
	var b = 0
	var t = 0
	if(args.size() > 3):
		l = ArgInt(args, null, 0, 0)
		r = ArgInt(args, null, 1, 0)
		b = ArgInt(args, null, 2, 0)
		t = ArgInt(args, null, 3, 0)
	elif(args.size() > 2):
		r = ArgInt(args, null, 0, 0)
		b = ArgInt(args, null, 1, 0)
		t = ArgInt(args, null, 2, 0)
		l = -r
	else:
		r = ArgInt(args, null, 0, 0)
		t = ArgInt(args, null, 1, 0)
		l = -r
		b = -t
	var hc = (l+r)/2
	var vc = (b+t)/2
	var drawRhombus = (type == 2)
	var width = (widthActive if lineActive else widthInactive)
	
	if(lineActive):
		emodule.GizmoFilledBox([l,t,0], [r,b,0], colorBack, color, width)
	else:
		emodule.GizmoBox([l,t,0], [r,b,0], color, width)
	
	if(drawRhombus):
		emodule.GizmoLine([l, vc,0], [hc, t,0], color, width)
		emodule.GizmoLine([hc, t,0], [r, vc,0], color, width)
		emodule.GizmoLine([r, vc,0], [hc, b,0], color, width)
		emodule.GizmoLine([hc, b,0], [l, vc,0], color, width)

func GizmoHurtbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 0)
func GizmoHitbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 1)
func GizmoColbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 2)


func GizmoMoveLine(emodule, args, lineActive, _stateHandle, type):
	var color = [Color(0.4, 0.4, 1.0), Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4)][type]
	var widthActive = [6,6,6][type]
	var widthInactive = [2,2,2][type]
	var width = (widthActive if lineActive else widthInactive)
	
	var h = ArgInt(args, null, 0, 0)
	var v = ArgInt(args, null, 1, 0)
	
	emodule.GizmoLine([0,0,0], [h,v,0], color, width)

func GizmoMove(emodule, args, lineActive, stateHandle):
	return
	GizmoMoveLine(emodule, args, lineActive, stateHandle, 0)



func SetColboxMode(args, stateHandle):
	var colboxMode = ArgInt(args, stateHandle, 0, COLBOX_MODES.Default)
	stateHandle.EntitySet("_ColboxMode", colboxMode)
func SetColboxPhantom(args, stateHandle):
	var phantom = ArgBool(args, stateHandle, 0, true)
	stateHandle.EntitySet("_ColboxPhantom", phantom)
func SetColboxLayer(args, stateHandle):
	var layer = ArgInt(args, stateHandle, 0, stateHandle.EntityGet("_Player")+1)
	stateHandle.EntitySet("_ColboxLayer", layer)

func ResetColbox(args, stateHandle):
	stateHandle.EntitySet("_Colbox", null)
	stateHandle.EntitySetFlag("NoColboxSet")
func ResetHurtboxes(args, stateHandle):
	stateHandle.EntitySet("_Hurtboxes", [])
	stateHandle.EntitySetFlag("NoHurtboxSet")
func ResetHitboxes(args, stateHandle):
	stateHandle.EntitySet("_Hitboxes", [])
	stateHandle.EntitySetFlag("NoHitboxSet")











func GetTargetPositionRelativeToSelf(args, stateHandle):
	var posXName = ArgVar(args, stateHandle, 0)
	var posYName = ArgVar(args, stateHandle, 1, "")
	
	var targetPosX = stateHandle.TargetEntityGet("_PositionX")
	var targetPosY = stateHandle.TargetEntityGet("_PositionY")
	
	var pos = TransformWorldPosToEntity([targetPosX, targetPosY], stateHandle)
	
	stateHandle.EntitySet(posXName, pos[0])
	if(posYName != ""):
		stateHandle.EntitySet(posYName, pos[1])
















# --------------------------------------------------------------------------------------------------
# Physics code

func PhysicsPhase(stateHandle, prevStateHandle, activeEIDs):
	# 1. Colbox and Environment Collisions
	PhysicsPhaseEnvironment(stateHandle, prevStateHandle, activeEIDs)
	
	# 2. Attack collisions
	PhysicsPhaseAttack(stateHandle, activeEIDs)

func PhysicsPhaseEnvironment(stateHandle, prevStateHandle, activeEIDs):
	# Checks environment collisions for each entity separately
	
	var nbBuckets = stateHandle.ConfigData().Get("PhysicsNbBuckets")
	
	# Gather colboxes and env constraints
	var envConstraints = GetEnvironmentConstraints(stateHandle, prevStateHandle)
	var colboxes = []
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)
		var c = stateHandle.EntityGet("_Colbox")
		if(c == null):
			continue
		c = c.duplicate()
		c["Phantom"] = stateHandle.EntityGet("_ColboxPhantom")
		c["Mode"] = stateHandle.EntityGet("_ColboxMode")
		c["Layer"] = stateHandle.EntityGet("_ColboxLayer")
		colboxes.push_back(c)
	
	var nbColboxes = colboxes.size()
	var nbEnvConstraints = envConstraints.size()
	
	# Check who can collide with others based on layers
	var validColboxCollisions = []
	var validEnvironmentCollisions = []
	
	for i in range(nbColboxes-1):
		for j in range(i+1, nbColboxes):
			var colboxA = colboxes[i]
			var colboxB = colboxes[j]
			if(colboxA["Phantom"] or colboxB["Phantom"]):
				continue
			if(PhysicsEnv_CanLayersCollide(colboxA, colboxB)):
				validColboxCollisions.push_back([i,j])
	
	for i in range(nbColboxes):
		for j in range(nbEnvConstraints):
			var colbox = colboxes[i]
			var envc = envConstraints[j]
			if(PhysicsEnv_CanLayersCollide(colbox, envc)):
				validEnvironmentCollisions.push_back([i,j])
	
	# Create Movement Buckets
	var movementBuckets = {}
	#var positions = {} 
	
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)
		#positions[eid] = [stateHandle.EntityGet("_PositionX"), stateHandle.EntityGet("_PositionY")]
		var movement = [stateHandle.EntityGet("_MovementX"), stateHandle.EntityGet("_MovementY")]
		var bucketMovement = [movement[0]/nbBuckets, movement[1]/nbBuckets]
		var buckets = []
		for i in range(nbBuckets):
			buckets.push_back(bucketMovement.duplicate())
		buckets[0][0] += movement[0]%nbBuckets
		buckets[0][1] += movement[1]%nbBuckets
		movementBuckets[eid] = buckets
	
	# Main Loop
	for loopID in nbBuckets:
		# Apply movement
		for eid in activeEIDs:
			var movement = movementBuckets[eid][loopID]
			stateHandle.PointToEntity(eid)
			stateHandle.EntityAdd("_PositionX", movement[0])
			stateHandle.EntityAdd("_PositionY", movement[1])
		
		# Do colbox interactions
		for colboxCol in validColboxCollisions:
			var colboxA = colboxes[colboxCol[0]]
			var colboxB = colboxes[colboxCol[1]]
			PhysicsEnv_ColboxColbox(stateHandle, prevStateHandle, colboxA, colboxB)
		
		# Do environment constraints
		for envCol in validEnvironmentCollisions:
			var colbox = colboxes[envCol[0]]
			var envConstraint = envConstraints[envCol[1]]
			var movement = PhysicsEnv_ApplyEnvConstraint(stateHandle, colbox, envConstraint)

func PhysicsEnv_ApplyEnvConstraint(stateHandle, colbox, envc):
	var movement = [0,0]
	var envcType = envc["Type"]
	
	stateHandle.PointToEntity(colbox["Owner"])
	var colpos = GetBoxPosition(stateHandle, colbox)
	
	if(envcType == ENVC_TYPES.AAPlane):
		var envcDir = envc["Dir"]
		var envcPos = envc["Position"]
		var envcStopMomentum = envc["StopMomentum"]
		
		var colboxPos = 0
		var moveXMult = 0
		var moveYMult = 0
		var invertAxis = 1
		var flag = null
		
		if(envcDir == ENVC_AAPLANE_DIR.Right):
			colboxPos = colpos["Left"]
			moveXMult = -1
			flag = "PFWall"
		elif(envcDir == ENVC_AAPLANE_DIR.Up):
			colboxPos = colpos["Down"]
			moveYMult = -1
			flag = "PFGrounded"
		elif(envcDir == ENVC_AAPLANE_DIR.Left):
			colboxPos = colpos["Right"]
			moveXMult = 1
			invertAxis = -1
			flag = "PFWall"
		elif(envcDir == ENVC_AAPLANE_DIR.Down):
			colboxPos = colpos["Up"]
			moveYMult = 1
			invertAxis = -1
			flag = "PFCeiling"
		else:
			ModuleError("PhysicsEnv: Direction "+str(envcDir) + " not valid for AAPlanes")
			return
		
		var diff = (colboxPos - envcPos) * invertAxis
		var margin = 10 # TODO CAST 54 Config
		if(diff <= margin):
			EntitySetFlag(stateHandle, flag)
		
		if(diff < 0):
			stateHandle.EntityAdd("_PositionX", diff * moveXMult)
			stateHandle.EntityAdd("_PositionY", diff * moveYMult)
			if(envcStopMomentum):
				if(moveYMult != 0):
					stateHandle.EntitySet("_MomentumY", max(stateHandle.EntityGet("_MomentumY")*invertAxis, 0)*invertAxis)
	else:
		ModuleError("PhysicsEnv: Env Constraint of unknown type: "+ str(envcType))

func PhysicsEnv_ColboxColbox(stateHandle, prevStateHandle, colboxA, colboxB):
	stateHandle.PointToEntity(colboxA["Owner"])
	var colposA = GetBoxPosition(stateHandle, colboxA)
	var prevXA = stateHandle.EntityGet("_PositionX")
	if(prevStateHandle.PointToEntity(colboxA["Owner"])):
		prevXA = prevStateHandle.EntityGet("_PositionX")
	
	stateHandle.PointToEntity(colboxB["Owner"])
	var colposB = GetBoxPosition(stateHandle, colboxB)
	var prevXB = stateHandle.EntityGet("_PositionX")
	if(prevStateHandle.PointToEntity(colboxB["Owner"])):
		prevXB = prevStateHandle.EntityGet("_PositionX")
	
	# Check collision
	if(!AreBoxesOverlapping(colposA, colposB)):
		return
	
	var overlap = 0
	if(colposA["Left"] < colposB["Left"]):
		overlap = colposA["Right"] - colposB["Left"]
	else:
		overlap = colposB["Right"] - colposA["Left"]
	
	var centerHA = (colposA["Right"] + colposA["Left"])/2
	var centerVA = (colposA["Up"] + colposA["Down"])/2
	var centerHB = (colposB["Right"] + colposB["Left"])/2
	var centerVB = (colposB["Up"] + colposB["Down"])/2
	
	var pushbackDirA = (-1 if prevXB > prevXA else 1)
	if(prevXA == prevXB):
		pushbackDirA = (-1 if centerHB > centerHA else 1)
	# TODO Take facing into account and other heuristics
	
	stateHandle.PointToEntity(colboxA["Owner"])
	stateHandle.EntityAdd("_PositionX", pushbackDirA*overlap/2)
	stateHandle.PointToEntity(colboxB["Owner"])
	stateHandle.EntityAdd("_PositionX", -pushbackDirA*overlap/2)
	
	# TODO Control of pushback
	# TODO Check for wall ?
	

func PhysicsEnv_CanLayersCollide(a, b):
	var layerA = a["Layer"]
	var modeA = a["Mode"]
	var layerB = b["Layer"]
	var modeB = b["Mode"]
	
	var commonLayerA = (modeA == COLBOX_MODES.Default or layerA == 0)
	var commonLayerB = (modeB == COLBOX_MODES.Default or layerB == 0)
	if(commonLayerA and commonLayerB):
		return true
	
	var sameLayer = (layerA == layerB)
	var noColSameLayer = (modeA == COLBOX_MODES.OtherLayers or modeB == COLBOX_MODES.OtherLayers)
	if(noColSameLayer and !sameLayer):
		return true
	if(!noColSameLayer and sameLayer):
		return true
	return false

func PhysicsPhaseAttack(stateHandle, activeEIDs):
	var clashMode = stateHandle.ConfigData().Get("AttackClashMode")
	
	var hurtboxes = {}
	var hitboxes = {}
	var friendlyFireHitboxes = {}
	var aaBoxes = {} # [hurtbox, hitbox, friendlyfire], if null ignore collision
	
	# Build EID List
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)
		
		var hurt = []
		var hurtboxAA = null
		var entityHurtboxList = stateHandle.EntityGet("_Hurtboxes")
		for hurtboxOriginal in entityHurtboxList:
			var h = hurtboxOriginal.duplicate()
			var pos = GetBoxPosition(stateHandle, hurtboxOriginal)
			
			if(hurtboxAA == null):
				hurtboxAA = pos
			else:
				ExpandAABox(hurtboxAA, pos)
			
			for k in pos:
				h[k] = pos[k]
			h["Hitbox"] = false
			hurt.push_back(h)
			
		
		var hit = []
		var ffHit = []
		var hitboxAA = null
		var ffHitboxAA = null
		var entityHitboxList = stateHandle.EntityGet("_Hitboxes")
		for hitboxOriginal in entityHitboxList:
			var h = hitboxOriginal.duplicate()
			var pos = GetBoxPosition(stateHandle, hitboxOriginal)
			
			if(hitboxAA == null):
				hitboxAA = pos
			else:
				ExpandAABox(hitboxAA, pos)
			
			for k in pos:
				h[k] = pos[k]
			h["Hitbox"] = true
			
			var hitboxFriendlyFire = h["AttackData"]["Flags"].has("FriendlyFire")
			if(hitboxFriendlyFire):
				if(ffHitboxAA == null):
					hitboxFriendlyFire = pos
				else:
					ExpandAABox(ffHitboxAA, pos)
				ffHit.push_back(h)
			hit.push_back(h)
		
		if(clashMode == ATTACK_CLASH_MODE.TradePriority):
			for hitbox in hit:
				hurt.push_back(hitbox)
		elif(clashMode == ATTACK_CLASH_MODE.ClashPriority):
			var h = hit.duplicate()
			for hurtbox in hurt:
				h.push_back(hurtbox)
			hurt = h
		
		if(hitboxAA != null and clashMode != ATTACK_CLASH_MODE.Disabled):
			if(hurtboxAA == null):
				hurtboxAA = hitboxAA
			else:
				ExpandAABox(hurtboxAA, hitboxAA)
		
		# TODO Clash happens on friendly fire ? too complex and niche i think
		
		aaBoxes[eid] = [hurtboxAA, hitboxAA, ffHitboxAA]
		hurtboxes[eid] = hurt
		hitboxes[eid] = hit
		friendlyFireHitboxes[eid] = ffHit
	
	# Gather potential character collisions
	for eidAID in range(activeEIDs.size()-1):
		var eidA = activeEIDs[eidAID]
		for eidBID in range(1, activeEIDs.size()):
			var eidB = activeEIDs[eidBID]
			var aaBoxesA = aaBoxes[eidA]
			var aaBoxesB = aaBoxes[eidB]
			stateHandle.PointToEntity(eidA)
			var pidA = stateHandle.EntityGet("_Player")
			stateHandle.PointToEntity(eidB)
			var pidB = stateHandle.EntityGet("_Player")
			var sameTeam = (pidA == pidB)
			var aaHitboxID = (2 if sameTeam else 1)
			
			# A attacker, B defender
			if(aaBoxesB[0] != null and aaBoxesA[aaHitboxID] != null and AreBoxesOverlapping(aaBoxesB[0], aaBoxesA[aaHitboxID])):
				var atkH = (friendlyFireHitboxes[eidA] if sameTeam else hitboxes[eidA])
				PhysicsAtk_HandleAttackDefend(stateHandle, eidA, eidB, atkH, hurtboxes[eidB])
			# B attacker, A defender
			if(aaBoxesA[0] != null and aaBoxesB[aaHitboxID] != null and AreBoxesOverlapping(aaBoxesA[0], aaBoxesB[aaHitboxID])):
				var atkH = (friendlyFireHitboxes[eidB] if sameTeam else hitboxes[eidB])
				PhysicsAtk_HandleAttackDefend(stateHandle, eidB, eidA, atkH, hurtboxes[eidA])

func PhysicsAtk_HandleAttackDefend(stateHandle, attackerEID, defenderEID, attackerHitboxes, defenderHurtboxes):
	var attackModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.ATTACKS)
	for hitbox in attackerHitboxes:
		for hurtbox in defenderHurtboxes:
			if(AreBoxesOverlapping(hitbox, hurtbox)):
				if(attackModule.HandleHit(stateHandle, attackerEID, hitbox, defenderEID, hurtbox)):
					return true
	return false

func GetEnvironmentConstraints(stateHandle, prevStateHandle):
	if(stateHandle.ConfigData().Get("UseFightingArena")):
		return CreateFightingArena(stateHandle, prevStateHandle)
	return []

func CreateFightingArena(stateHandle, prevStateHandle):
	# Ground
	# If two player: special walls and camera
	# If other count: normal walls
	var nbPlayers = stateHandle.GlobalGet("_NbPlayers")
	var arenaSize = stateHandle.ConfigData().Get("ArenaSize")
	var cameraSize = stateHandle.ConfigData().Get("ArenaMaxPlayerDistance")
	
	var envConstraints = [
		{"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Up, "Position":0, "StopMomentum":true, "Layer":0, "Mode":COLBOX_MODES.OwnLayer},
	]
	
	# TODO CAST 54 Corner steal
	if(nbPlayers == 2):
		stateHandle.PointToPlayer(0)
		var eid1 = stateHandle.PlayerGet("MainEntity")
		stateHandle.PointToEntity(eid1)
		var p1Pos = stateHandle.EntityGet("_PositionX")
		
		stateHandle.PointToPlayer(1)
		var eid2 = stateHandle.PlayerGet("MainEntity")
		stateHandle.PointToEntity(eid2)
		var p2Pos = stateHandle.EntityGet("_PositionX")
		
		var centerPos = (p1Pos+p2Pos)/2
		var p1Left = (p1Pos <= p2Pos)
		
		# TODO Investigate: This works when both players have the same colbox, but might not in other cases.
		# Just giving priority to the player below would be janky too
		
		if(p1Pos == p2Pos):
			var p1OldPos = p1Pos
			var p2OldPos = p2Pos
			
			if(prevStateHandle.PointToEntity(eid1)):
				p1OldPos = prevStateHandle.EntityGet("_PositionX")
			if(prevStateHandle.PointToEntity(eid2)):
				p2OldPos = prevStateHandle.EntityGet("_PositionX")
			p1Left = (p1OldPos <= p2OldPos)
		
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":-arenaSize + (0 if p1Left else 1),
		"StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":arenaSize - (1 if p1Left else 0),
		"StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":-arenaSize + (1 if p1Left else 0),
		"StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":arenaSize - (0 if p1Left else 1),
		"StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
		# Center pos
		
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":centerPos-cameraSize, "StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":centerPos+cameraSize, "StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":centerPos-cameraSize, "StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":centerPos+cameraSize, "StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
	
	envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
	"Position":-arenaSize, "StopMomentum":true, "Layer":0, "Mode":COLBOX_MODES.OwnLayer})
	envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
	"Position":arenaSize, "StopMomentum":true, "Layer":0, "Mode":COLBOX_MODES.OwnLayer})
	
	return envConstraints

func GetBoxPosition(stateHandle, box):
	var cornerTL = TransformPosEntityToWorld([box["Left"], box["Up"],0], stateHandle)
	var cornerBR = TransformPosEntityToWorld([box["Right"], box["Down"],0], stateHandle)
	var facingHV = GetFacingHV(stateHandle)
	if(facingHV[0] >= 0):
		return {"Left":cornerTL[0], "Right":cornerBR[0],"Down":cornerBR[1],"Up":cornerTL[1]}
	else:
		return {"Left":cornerBR[0], "Right":cornerTL[0],"Down":cornerBR[1],"Up":cornerTL[1]}

func AreBoxesOverlapping(boxA, boxB):
	return (boxA["Right"] > boxB["Left"]
		and boxA["Left"] < boxB["Right"]
		and boxA["Up"] > boxB["Down"]
		and boxA["Down"] < boxB["Up"])

func ExpandAABox(aabox, newBox):
	aabox["Left"] = min(aabox["Left"], newBox["Left"])
	aabox["Right"] = max(aabox["Right"], newBox["Right"])
	aabox["Down"] = min(aabox["Down"], newBox["Down"])
	aabox["Up"] = max(aabox["Up"], newBox["Up"])

func GetFacingHV(stateHandle, facingType = FACING_TYPE.Physics):
	var facings = ["Physics", "Attack", "Block", "Model"]
	var hv = [stateHandle.EntityGet("_FacingH"+facings[facingType]), stateHandle.EntityGet("_FacingV"+facings[facingType])]
	if(hv[0] == null):
		hv[0] = 1
	if(hv[1] == null):
		hv[1] = 0
	return hv

func SetFacingHV(stateHandle, facingH, facingV, facingType = FACING_TYPE.Physics):
	var facings = ["Physics", "Attack", "Block", "Model"]
	stateHandle.EntitySet("_FacingH"+facings[facingType], facingH)
	stateHandle.EntitySet("_FacingV"+facings[facingType], facingV)

func TransformPosEntityToAbsolute(pos, stateHandle, facingType = FACING_TYPE.Physics):
	var facingHV = GetFacingHV(stateHandle, facingType)
	return [pos[0] * (1 if facingHV[0] > 0 else -1), pos[1], 0]

func TransformPosEntityToWorld(pos, stateHandle, facingType = FACING_TYPE.Physics):
	var absolutePos = TransformPosEntityToAbsolute(pos, stateHandle, facingType)
	return TransformPosEntityAbsoluteToWorld(absolutePos, stateHandle, facingType)

func TransformPosEntityAbsoluteToWorld(absolutePos, stateHandle, facingType = FACING_TYPE.Physics):
	var x = stateHandle.EntityGet("_PositionX")
	var y = stateHandle.EntityGet("_PositionY")
	if(x == null):
		x = 0
	if(y == null):
		y = 0
	
	return [x + absolutePos[0], y + absolutePos[1], 0]

func TransformWorldPosToEntityAbsolute(pos, stateHandle):
	var x = stateHandle.EntityGet("_PositionX")
	var y = stateHandle.EntityGet("_PositionY")
	return [pos[0] - x, pos[1] - y, 0]

func TransformWorldPosToEntity(pos, stateHandle, facingType = FACING_TYPE.Physics):
	var absolutePos = TransformWorldPosToEntityAbsolute(pos, stateHandle)
	var facingHV = GetFacingHV(stateHandle, facingType)
	return [absolutePos[0] * (1 if facingHV[0] > 0 else -1), absolutePos[1]]

