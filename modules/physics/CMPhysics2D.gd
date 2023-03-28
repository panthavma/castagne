extends "../CastagneModule.gd"

# :TODO:Panthavma:20220124:Allow different physics.

func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	# :TODO:Panthavma:20211230:Gravity as a standard implementation
	# :TODO:Panthavma:20211230:More physics functions for flexible movement
	
	RegisterModule("CF Physics", Castagne.MODULE_SLOTS_BASE.PHYSICS, {
		"Description":"All these base themselves on the reference entity's values"
	})
	RegisterBaseCaspFile("res://castagne/modules/physics/Base-Physics2D.casp")
	
	RegisterCategory("Positionning")
	RegisterFunction("Move", [1,2], null, {
		"Description": "Moves the entity this frame, depending on facing.",
		"Arguments": ["Horizontal move", "(Optional) Vertical move"],
		"Types": ["int", "int"],
		})
	RegisterFunction("MoveAbsolute", [1,2], null, {
		"Description": "Moves the entity this frame, independant of facing.",
		"Arguments": ["Horizontal move", "(Optional) Vertical move"],
		})
	RegisterFunction("SetPositionRelativeToRef", [2], null, {
		"Description": "Sets the position based on the reference entity's position, depending on facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
		})
	RegisterFunction("SetPositionRelativeToRefAbsolute", [2], null, {
		"Description": "Sets the position based on the reference entity's position, independant of facing.",
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
	RegisterFunction("SwitchFacing", [0], null, {
		"Description": "Changes the facing to the other direction.",
		"Arguments": [],
		})
	RegisterFunction("CopyRefFacing", [0], null, {
		"Description": "Sets the facing to the one of the reference entity's.",
		"Arguments": [],
		})
		
		
		
	RegisterCategory("Momentum")
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
	
	RegisterCategory("Collision")
	RegisterFunction("Colbox", [4], null, {
		"Description": "Sets the collision box, which will push other entities.",
		"Arguments": ["Back bound", "Front bound", "Down bound", "Up bound"],
		})
	RegisterFunction("Hurtbox", [4], null, {
		"Description": "Adds a hurtbox, that can be hit by hitboxes.",
		"Arguments": ["Back bound", "Front bound", "Down bound", "Up bound"],
		})
	RegisterFunction("Hitbox", [4], null, {
		"Description": "Adds a hitbox, that can hit hurtboxes. You need to set attack data beforehand, though the Attack function. This function does not reset the attack data, so you can add several hitboxes for the same attack data by calling Hitbox several times.",
		"Arguments": ["Back bound", "Front bound", "Down bound", "Up bound"],
		})
	#RegisterFunction("ResetHurtboxes", [0])
	#RegisterFunction("ResetHitboxes", [0])
	
	RegisterFlag("HaltMomentum")
	RegisterFlag("IgnoreGravity")
	RegisterFlag("IgnoreFriction")
	RegisterFlag("ApplyFacing")
	RegisterFlag("PFAirborne")
	RegisterFlag("PFGrounded")
	RegisterFlag("AllowArenaExit")
	
	RegisterVariableEntity("_Facing", 1)
	RegisterVariableEntity("_FacingTrue", 1)
	
	RegisterVariableGlobal("_PlayerOnTheLeft", 0)
	RegisterVariableGlobal("_CameraX", 0)
	RegisterVariableGlobal("_CameraY", 0)
	
	RegisterVariableEntity("_PositionX", 0)
	RegisterVariableEntity("_PositionY", 0)
	RegisterVariableEntity("_MovementX", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_MovementY", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_MomentumX", 0)
	RegisterVariableEntity("_MomentumY", 0)
	RegisterVariableEntity("_Gravity", 0)
	RegisterVariableEntity("_TerminalVelocity", -3000)
	RegisterVariableEntity("_FrictionGround", 0)
	RegisterVariableEntity("_FrictionAir", 0)
	
	RegisterVariableEntity("_Hitboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("_Hurtboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("_Colbox", {"Left":-1, "Right":1, "Down":0, "Up":1}, ["ResetEachFrame"])
	
	RegisterConfig("ArenaSize", 180000)
	RegisterConfig("CameraSize", 90000)
	
	RegisterStateFlag("Grounded")
	RegisterStateFlag("Airborne")

func BattleInit(stateHandle, _battleInitData):
	engine.physicsModule = self
	arenaSize = stateHandle.ConfigData().Get("ArenaSize")
	cameraSize = stateHandle.ConfigData().Get("CameraSize")

func ActionPhaseStartEntity(stateHandle):
	if(stateHandle.EntityGet("_PositionY") > 0):
		stateHandle.EntitySetFlag("PFAirborne")
	else:
		stateHandle.EntitySetFlag("PFGrounded")
func ActionPhaseEndEntity(stateHandle):
	if(!stateHandle.EntityHasFlag("HaltMomentum")):
		var airborne = stateHandle.EntityHasFlag("PFAirborne")
		if(!stateHandle.EntityHasFlag("IgnoreGravity") and airborne):
			var grav = int(stateHandle.EntityGet("_Gravity"))
			var diffToTerminal = min(0, int(stateHandle.EntityGet("_TerminalVelocity")) - stateHandle.EntityGet("_MomentumY"))
			stateHandle.EntityAdd("_MomentumY", max(grav, diffToTerminal))
		if(!stateHandle.EntityHasFlag("IgnoreFriction")):
			BreakMomentumX([stateHandle.EntityGet(("_FrictionAir" if airborne else "_FrictionGround"))], stateHandle)
		stateHandle.EntityAdd("_MovementX", stateHandle.EntityGet("_MomentumX"))
		stateHandle.EntityAdd("_MovementY", stateHandle.EntityGet("_MomentumY"))
	if(stateHandle.EntityHasFlag("ApplyFacing")):
		stateHandle.EntitySet("_Facing", stateHandle.EntityGet("_FacingTrue"))


func PhysicsPhaseStart(_stateHandle):
	pass
func PhysicsPhaseStartEntity(stateHandle):
	stateHandle.EntitySetFlag("PFAirborne", false)
	stateHandle.EntitySetFlag("PFGrounded", false)
	stateHandle.EntityAdd("_PositionX", stateHandle.EntityGet("_MovementX"))
	stateHandle.EntityAdd("_PositionY", stateHandle.EntityGet("_MovementY"))
	if(!stateHandle.EntityHasFlag("AllowArenaExit")):
		stateHandle.EntitySet("_PositionX", sign(stateHandle.EntityGet("_PositionX")) * min(abs(stateHandle.EntityGet("_PositionX")), arenaSize))
	
func PhysicsPhaseEndEntity(stateHandle):
	if(stateHandle.EntityHasFlag("PFGrounded")):
		stateHandle.EntitySet("_MomentumY", max(stateHandle.EntityGet("_MomentumY"), 0))
func PhysicsPhaseEnd(_stateHandle):
	pass

func InputPhaseStartEntity(stateHandle):
	var castagneInput = stateHandle.Input()
	var inputSchema = castagneInput.GetInputSchema()
	var inputs = stateHandle.EntityGet("_Inputs").duplicate()
	var facing = stateHandle.EntityGet("_Facing")
	
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
	MoveAbsolute([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, 0)], stateHandle)
func MoveAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_MovementX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_MovementY", ArgInt(args, stateHandle, 1, 0))

func SetPositionRelativeToRef(args, stateHandle):
	SetPositionRelativeToRefAbsolute([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetPositionRelativeToRefAbsolute(args, stateHandle):
	stateHandle.EntitySet("_PositionX", stateHandle.EntityGet("_PositionX") + ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_PositionY", stateHandle.EntityGet("_PositionY") + ArgInt(args, stateHandle, 1))

func SetWorldPosition(args, stateHandle):
	SetWorldPositionAbsolute([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetWorldPositionAbsolute(args, stateHandle):
	stateHandle.EntitySet("_PositionX", ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_PositionY", ArgInt(args, stateHandle, 1))
func SetWorldPositionX(args, stateHandle):
	SetWorldPositionAbsoluteX([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0)], stateHandle)
func SetWorldPositionAbsoluteX(args, stateHandle):
	stateHandle.EntityGet("_PositionX", ArgInt(args, stateHandle, 0))
func SetWorldPositionY(args, stateHandle):
	stateHandle.EntityGet("_PositionY", ArgInt(args, stateHandle, 0))

func SwitchFacing(_args, stateHandle):
	stateHandle.EntitySet("_Facing", -stateHandle.EntityGet("_Facing"))
	
func CopyRefFacing(_args, stateHandle):
	stateHandle.EntitySet("_Facing", stateHandle.EntityGet("_Facing"))






func AddMomentum(args, stateHandle):
	AddMomentumAbsolute([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, 0)], stateHandle)
func AddMomentumAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_MomentumX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_MomentumY", ArgInt(args, stateHandle, 1, 0))
	
func SetMomentum(args, stateHandle):
	SetMomentumAbsolute([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetMomentumAbsolute(args, stateHandle):
	stateHandle.EntitySet("_MomentumX", ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_MomentumY", ArgInt(args, stateHandle, 1))
func SetMomentumX(args, stateHandle):
	SetMomentumAbsolute([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0)], stateHandle)
func SetMomentumXAbsolute(args, stateHandle):
	stateHandle.EntitySet("_MomentumX", ArgInt(args, stateHandle, 0))
func SetMomentumY(args, stateHandle):
	stateHandle.EntitySet("_MomentumY", ArgInt(args, stateHandle, 0))
	
func AddMomentumTurn(args, stateHandle):
	AddMomentumTurnAbsolute([stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
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
	_BreakMomentumAxis(args, stateHandle, "_MomentumX", stateHandle.EntityGet("_Facing"))
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
		m -= min(diff, mBreak)
	elif(m < mMin):
		var diff = mMin-m
		m += min(diff, mBreak)
	stateHandle.EntitySet(axis, m)

func CapMomentum(args, stateHandle):
	CapMomentumAbsolute(args, stateHandle, stateHandle.EntityGet("_Facing"))
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
	_CapMomentmAxis(args, stateHandle, "_MomentumX", stateHandle.EntityGet("_Facing"))
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










func Colbox(args, stateHandle):
	stateHandle.EntitySet("_Colbox", {
		"Left":ArgInt(args, stateHandle, 0),
		"Right":ArgInt(args, stateHandle, 1),
		"Down":ArgInt(args, stateHandle, 2),
		"Up":ArgInt(args, stateHandle, 3),
		"Owner":stateHandle.EntityGet("_EID"),
	})

func Hurtbox(args, stateHandle):
	stateHandle.EntityGet("_Hurtboxes").append({
		"Left":ArgInt(args, stateHandle, 0),
		"Right":ArgInt(args, stateHandle, 1),
		"Down":ArgInt(args, stateHandle, 2),
		"Up":ArgInt(args, stateHandle, 3),
		"Owner":stateHandle.EntityGet("_EID"),
		"Data":{},
	})

func Hitbox(args, stateHandle):
	stateHandle.EntityGet("_Hitboxes").append({
		"Left":ArgInt(args, stateHandle, 0),
		"Right":ArgInt(args, stateHandle, 1),
		"Down":ArgInt(args, stateHandle, 2),
		"Up":ArgInt(args, stateHandle, 3),
		"Owner":stateHandle.EntityGet("_EID"),
		"AttackData":stateHandle.EntityGet("_AttackData").duplicate(),
	})

func GizmoBox(emodule, args, lineActive, _stateHandle, type):
	var color = [Color(0.4, 0.4, 1.0), Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4)][type]
	var colorBack = [Color(0.3, 0.3, 1.0, 0.45), Color(1.0, 0.3, 0.3, 0.45), Color(0.3, 1.0, 0.3, 0.45)][type]
	var widthActive = [6,6,6][type]
	var widthInactive = [2,2,2][type]
	var l = ArgInt(args, null, 0, 0)
	var r = ArgInt(args, null, 1, 0)
	var d = ArgInt(args, null, 2, 0)
	var t = ArgInt(args, null, 3, 0)
	if(lineActive):
		emodule.GizmoFilledBox(Vector2(l,t), Vector2(r,d), colorBack, color, widthActive)
	else:
		emodule.GizmoBox(Vector2(l,t), Vector2(r,d), color, widthInactive)

func GizmoHurtbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 0)
func GizmoHitbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 1)
func GizmoColbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 2)

























# --------------------------------------------------------------------------------------------------
# Physics code




var arenaSize 
var cameraSize 

func PhysicsPhase(stateHandle, previousHandle, activeEIDs):
	# :TODO:Panthavma:20220203:Allow more than two entities for colbox
	var teams = [0,1]
	var mainEIDs = [null, null]
	
	stateHandle.PointToPlayer(0)
	mainEIDs[0] = stateHandle.PlayerGet("MainEntity")
	stateHandle.PointToPlayer(1)
	mainEIDs[1] = stateHandle.PlayerGet("MainEntity")
	
	# 1. Resolve colboxes between the two main entities
	PhysicsResolveColboxes(stateHandle, previousHandle, mainEIDs)
	
	# 2. Gather hitboxes and hurtboxes per player
	# :TODO:Panthavma:20220203:Make it per team, and allow friendly fire/more teams
	# :TODO:Panthavma:20220203:Gather hitboxes/hurtboxes earlier ?
	var hitboxes = [[], []]
	var hurtboxes = [[], []]
	
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)
		var pid = stateHandle.EntityGet("_Player")
		var atkPID = 1-pid
		
		hurtboxes[pid].append_array(stateHandle.EntityGet("_Hurtboxes"))
		hitboxes[atkPID].append_array(stateHandle.EntityGet("_Hitboxes"))
		for h in stateHandle.EntityGet("_Hitboxes"):
			if(h["AttackData"]["Flags"].has("FriendlyFire")):
				hitboxes[pid].push_back(h)
	
	
	# 3. Resolve hitbox/hurtbox collisions
	var secondStateHandle = stateHandle.CloneStateHandle()
	for t in teams:
		PhysicsResolveHitboxHurtbox(stateHandle, secondStateHandle, hitboxes[t], hurtboxes[t])

func PhysicsResolveColboxes(stateHandle, previousHandle, eids):
	var nbEntities = eids.size()
	# :TODO:Panthavma:20220203:Allow more than two entities
	
	
	if(!previousHandle.Memory().PlayerHas(eids[1],"PositionX") or !previousHandle.Memory().PlayerHas(eids[0], "PositionX")):
		return #:TODO:Panthavma:20220203:Is there a more elegant way to ch
	
	# Find out who is one the left and who is on the right
	var posDiff = previousHandle.Memory().PlayerHas(eids[1], "PositionX") - previousHandle.Memory().PlayerHas(eids[0],"PositionX")
	var playerOnTheLeft = (0 if posDiff > 0 else 1)
	# Use the previous frame's result if there is doubt (stored because of jumps)
	if(posDiff == 0):
		playerOnTheLeft = previousHandle.GlobalGet("_PlayerOnTheLeft")
	stateHandle.EntitySet("_PlayerOnTheLeft", playerOnTheLeft)
	
	# Find out collisions and camera postion for better placement
	var camCenter = previousHandle.GlobalGet("_CameraX") # TODO Recompute ?
	stateHandle.PointToEntity(eids[0])
	var p1Colbox = GetBoxPosition(stateHandle, stateHandle.EntityGet("_Colbox"))
	stateHandle.PointToEntity(eids[1])
	var p2Colbox = GetBoxPosition(stateHandle, stateHandle.EntityGet("_Colbox"))
	var areBoxesOverlapping = AreBoxesOverlapping(p1Colbox, p2Colbox)
	var overlapAmount = 0
	if(areBoxesOverlapping):
		if(playerOnTheLeft == 0):
			overlapAmount = p1Colbox["Right"] - p2Colbox["Left"]
		else:
			overlapAmount = p2Colbox["Right"] - p1Colbox["Left"]
	
	
	for i in range(nbEntities):
		var eid = eids[i]
		stateHandle.PointToEntity(eid)
		var minX = max(-arenaSize, camCenter - cameraSize)
		var maxX = min(arenaSize, camCenter + cameraSize)
		
		# Prevent corner steal and push the boxes if in the corner
		if(i == playerOnTheLeft):
			maxX -= 1 + overlapAmount
		else:
			minX += 1 + overlapAmount
		
		# Check Collisions
		var positionX = stateHandle.EntityGet("_PositionX")
		if(i == playerOnTheLeft):
			positionX -= overlapAmount/2
		else:
			positionX += overlapAmount/2
		positionX = clamp(positionX, minX, maxX)
		stateHandle.EntitySet("_PositionX", positionX)
		
		var newFacing = (1 if i == playerOnTheLeft else -1)
		if(stateHandle.EntityGet("_FacingTrue") != newFacing):
			stateHandle.EntitySetFlag("PFSwitchFacing")
			stateHandle.EntitySet("_FacingTrue", newFacing)
		
		if(stateHandle.EntityGet("_PositionY") <= 0):
			stateHandle.EntitySet("_PositionY", 0)
			stateHandle.EntitySetFlag("PFGrounded")
		else:
			stateHandle.EntitySetFlag("PFAirborne")
	
	stateHandle.GlobalSet("_CameraX", (stateHandle.Memory().EntityGet(eids[0], "PositionX")+stateHandle.Memory().EntityGet(eids[1], "PositionX"))/2)
	stateHandle.GlobalSet("_CameraY", (stateHandle.Memory().EntityGet(eids[0], "PositionY")+stateHandle.Memory().EntityGet(eids[1], "PositionY"))/2)
	
	var signCam = sign(stateHandle.GlobalGet("_CameraX"))
	if(signCam != 0 and abs(stateHandle.GlobalGet("_CameraX")) > (arenaSize - cameraSize)):
		stateHandle.GlobalSet("_CameraX", signCam * (arenaSize - cameraSize))

func PhysicsResolveHitboxHurtbox(aStateHandle, dStateHandle, hitboxes, hurtboxes):
	
	# :TODO:Panthavma:20220204:Do we allow several hitboxes to hit at the same frame ? Do we add priority ?
	# :TODO:Panthavma:20220204:One hitbox vs several hurtboxes ? Needs some refactoring
	
	for hitbox in hitboxes:
		var aEID = hitbox["Owner"]
		aStateHandle.PointToEntity(aEID)
		
		var hitboxPos = GetBoxPosition(aStateHandle, hitbox)
		
		var hitconfirm = Castagne.HITCONFIRMED.NONE
		var hurtboxData = null
		var dEID
		
		for hurtbox in hurtboxes:
			dEID = hurtbox["Owner"]
			dStateHandle.PointToEntity(dEID)
			# :TODO:Panthavma:20220204:Maybe do the position computations earlier, since with more teams it would compute twice
			var hurtboxPos = GetBoxPosition(dStateHandle, hurtbox)
			
			if(AreBoxesOverlapping(hurtboxPos, hitboxPos)):
				hitconfirm = Castagne.HITCONFIRMED.HIT
				hurtboxData = hurtbox["Data"]
				break # Only use first hurtbox for now
		
		if(hitconfirm != Castagne.HITCONFIRMED.NONE):
			var attackData = hitbox["AttackData"]
			for m in engine.modules:
				hitconfirm = m.IsAttackConfirmed(hitconfirm, attackData, hurtboxData, aStateHandle, dStateHandle)
			
			if(hitconfirm == Castagne.HITCONFIRMED.NONE):
				continue
			
			for m in engine.modules:
				m.OnAttackConfirmed(hitconfirm, attackData, hurtboxData, aStateHandle, dStateHandle)
			break 

func GetBoxPosition(fighterStateHandle, box):
	var boxLeft = fighterStateHandle.EntityGet("_PositionX")
	var boxRight = fighterStateHandle.EntityGet("_PositionX")
	
	if(fighterStateHandle.EntityGet("_Facing") > 0):
		boxLeft += box["Left"]
		boxRight += box["Right"]
	else:
		boxLeft -= box["Right"]
		boxRight -= box["Left"]
	
	var boxDown = fighterStateHandle.EntityGet("_PositionY") + box["Down"]
	var boxUp = fighterStateHandle.EntityGet("_PositionY") + box["Up"]
	
	return {"Left":boxLeft, "Right":boxRight,"Down":boxDown,"Up":boxUp}

func AreBoxesOverlapping(boxA, boxB):
	return (boxA["Right"] > boxB["Left"]
		and boxA["Left"] < boxB["Right"]
		and boxA["Up"] > boxB["Down"]
		and boxA["Down"] < boxB["Up"])



func TranslatePosEntityToGlobal(pos, stateHandle):
	var x = stateHandle.EntityGet("_PositionX")
	var y = stateHandle.EntityGet("_PositionY")
	
	return Vector2(x + pos.x * (1 if stateHandle.EntityGet("_Facing") > 0 else -1), y + pos.y)
