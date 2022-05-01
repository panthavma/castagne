extends "../CastagneModule.gd"

# :TODO:Panthavma:20220124:Allow different physics.

func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	# :TODO:Panthavma:20211230:Gravity as a standard implementation
	# :TODO:Panthavma:20211230:More physics functions for flexible movement
	
	RegisterModule("CF Physics", {"Description":"All these base themselves on the reference entity's values"})
	RegisterCategory("Positionning")
	RegisterFunction("Move", [1,2], null, {
		"Description": "Moves the entity this frame, depending on facing.",
		"Arguments": ["Horizontal move", "(Optional) Vertical move"],
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
	RegisterFlag("PFAirborne")
	RegisterFlag("PFGrounded")
	RegisterFlag("AllowArenaExit")
	
	RegisterVariableEntity("Facing", 1)
	RegisterVariableEntity("FacingTrue", 1)
	
	RegisterVariableGlobal("PlayerOnTheLeft", 0)
	RegisterVariableGlobal("CameraX", 0)
	RegisterVariableGlobal("CameraY", 0)
	
	RegisterVariableEntity("PositionX", 0)
	RegisterVariableEntity("PositionY", 0)
	RegisterVariableEntity("MovementX", 0, ["ResetEachFrame"])
	RegisterVariableEntity("MovementY", 0, ["ResetEachFrame"])
	RegisterVariableEntity("MomentumX", 0)
	RegisterVariableEntity("MomentumY", 0)
	RegisterVariableEntity("Gravity", 0)
	RegisterVariableEntity("TerminalVelocity", -3000)
	RegisterVariableEntity("FrictionGround", 0)
	RegisterVariableEntity("FrictionAir", 0)
	
	RegisterVariableEntity("Hitboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("Hurtboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("Colbox", {"Left":-1, "Right":1, "Down":0, "Up":1}, ["ResetEachFrame"])
	
	RegisterConfig("ArenaSize", 150000)
	RegisterConfig("CameraSize", 70000)

func BattleInit(_state, _data, _battleInitData):
	engine.physicsModule = self
	arenaSize = Castagne.configData["ArenaSize"]
	cameraSize = Castagne.configData["CameraSize"]

func ActionPhaseStartEntity(eState, _data):
	if(eState["PositionY"] > 0):
		SetFlag(eState, "PFAirborne")
	else:
		SetFlag(eState, "PFGrounded")
func ActionPhaseEndEntity(eState, _data):
	if(!HasFlag(eState, "HaltMomentum")):
		var airborne = HasFlag(eState, "PFAirborne")
		if(!HasFlag(eState, "IgnoreGravity") and airborne):
			var grav = int(eState["Gravity"])
			var diffToTerminal = min(0, int(eState["TerminalVelocity"]) - eState["MomentumY"])
			eState["MomentumY"] += max(grav, diffToTerminal)
		if(!HasFlag(eState, "IgnoreFriction")):
			BreakMomentumX([eState[("FrictionAir" if airborne else "FrictionGround")]], eState, _data)
		eState["MovementX"] += eState["MomentumX"]
		eState["MovementY"] += eState["MomentumY"]
	if(HasFlag(eState, "ApplyFacing")):
		eState["Facing"] = eState["FacingTrue"]


func PhysicsPhaseStart(_state, _data):
	pass
func PhysicsPhaseStartEntity(eState, _data):
	UnsetFlag(eState, "PFAirborne")
	UnsetFlag(eState, "PFGrounded")
	eState["PositionX"] += eState["MovementX"]
	eState["PositionY"] += eState["MovementY"]
	if(!HasFlag(eState, "AllowArenaExit")):
		eState["PositionX"] = sign(eState["PositionX"]) * min(abs(eState["PositionX"]), arenaSize)
	
func PhysicsPhaseEndEntity(eState, _data):
	if(HasFlag(eState, "PFGrounded")):
		eState["MomentumY"] = max(eState["MomentumY"], 0)
func PhysicsPhaseEnd(_state, _data):
	pass

























# --------------------------------------------------------------------------------------------------
# Functions



func Move(args, eState, data):
	MoveAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), ArgInt(args, eState, 1, 0)], eState, data)
func MoveAbsolute(args, eState, _data):
	eState["MovementX"] += ArgInt(args, eState, 0)
	eState["MovementY"] += ArgInt(args, eState, 1, 0)

func SetPositionRelativeToRef(args, eState, data):
	SetPositionRelativeToRefAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), args[1]], eState, data)
func SetPositionRelativeToRefAbsolute(args, eState, data):
	eState["PositionX"] = data["rState"]["PositionX"] + ArgInt(args, eState, 0)
	eState["PositionY"] = data["rState"]["PositionY"] + ArgInt(args, eState, 1)

func SetWorldPosition(args, eState, data):
	SetWorldPositionAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), args[1]], eState, data)
func SetWorldPositionAbsolute(args, eState, _data):
	eState["PositionX"] = ArgInt(args, eState, 0)
	eState["PositionY"] = ArgInt(args, eState, 1)
func SetWorldPositionX(args, eState, data):
	SetWorldPositionAbsoluteX([data["rState"]["Facing"]*ArgInt(args, eState, 0)], eState, data)
func SetWorldPositionAbsoluteX(args, eState, _data):
	eState["PositionX"] = ArgInt(args, eState, 0)
func SetWorldPositionY(args, eState, _data):
	eState["PositionY"] = ArgInt(args, eState, 0)

func SwitchFacing(_args, eState, _data):
	eState["Facing"] = -eState["Facing"]
	
func CopyRefFacing(_args, eState, data):
	eState["Facing"] = data["rState"]["Facing"]






func AddMomentum(args, eState, data):
	AddMomentumAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), ArgInt(args, eState, 1, 0)], eState, data)
func AddMomentumAbsolute(args, eState, _data):
	eState["MomentumX"] += ArgInt(args, eState, 0)
	eState["MomentumY"] += ArgInt(args, eState, 1, 0)
	
func SetMomentum(args, eState, data):
	SetMomentumAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), args[1]], eState, data)
func SetMomentumAbsolute(args, eState, _data):
	eState["MomentumX"] = ArgInt(args, eState, 0)
	eState["MomentumY"] = ArgInt(args, eState, 1)
func SetMomentumX(args, eState, data):
	SetMomentumAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0)], eState, data)
func SetMomentumXAbsolute(args, eState, _data):
	eState["MomentumX"] = ArgInt(args, eState, 0)
func SetMomentumY(args, eState, _data):
	eState["MomentumY"] = ArgInt(args, eState, 0)
	
func AddMomentumTurn(args, eState, data):
	AddMomentumTurnAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), args[1]], eState, data)
func AddMomentumTurnAbsolute(args, eState, data):
	var h = ArgInt(args, eState, 0)
	var v = ArgInt(args, eState, 1)
	
	if(h != 0 and sign(h) != sign(eState["MomentumX"])):
		eState["MomentumX"] = 0
	if(v != 0 and sign(v) != sign(eState["MomentumY"])):
		eState["MomentumY"] = 0
	
	AddMomentumAbsolute(args, eState, data)


func BreakMomentum(args, eState, _data):
	var h = min(ArgInt(args, eState, 0), abs(eState["MomentumX"]))
	var v = min(ArgInt(args, eState, 1, 0), abs(eState["MomentumY"]))
	eState["MomentumX"] -= sign(eState["MomentumX"]) * h
	eState["MomentumY"] -= sign(eState["MomentumY"]) * v
func BreakMomentumX(args, eState, _data):
	_BreakMomentumAxis(args, eState, _data, "MomentumX", eState["Facing"])
func BreakMomentumY(args, eState, _data):
	_BreakMomentumAxis(args, eState, _data, "MomentumY")
func BreakMomentumXAbsolute(args, eState, _data):
	_BreakMomentumAxis(args, eState, _data, "MomentumX")
func _BreakMomentumAxis(args, eState, _data, axis, facing=1.0):
	var m = eState[axis]
	var mBreak = abs(ArgInt(args, eState, 0))
	var mMin = ArgInt(args, eState, 1, 0) * facing
	var mMax = ArgInt(args, eState, 2, -mMin) * facing
	
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
	eState[axis] = m

func CapMomentum(args, eState, _data):
	CapMomentumAbsolute(args, eState, _data, eState["Facing"])
func CapMomentumAbsolute(args, eState, _data, facing=1.0):
	var hMin
	var hMax
	var vMin
	var vMax
	if(args.size() > 2): # 4 args
		hMin = ArgInt(args, eState, 0)
		hMax = ArgInt(args, eState, 1)
		vMin = ArgInt(args, eState, 2)
		vMax = ArgInt(args, eState, 3)
		if(hMin > hMax or vMin > vMax):
			ModuleError("CapMomentum: Enveloppe has no volume", eState)
		if(facing < 0):
			var a = hMin
			hMin = -hMax
			hMax = -a
	else: # 2 args
		hMax = abs(ArgInt(args, eState, 0))
		vMax = abs(ArgInt(args, eState, 1))
		hMin = -hMax
		vMin = -vMax
	
	eState["MomentumX"] = max(min(eState["MomentumX"], hMax), hMin)
	eState["MomentumY"] = max(min(eState["MomentumY"], vMax), vMin)
func CapMomentumX(args, eState, _data):
	_CapMomentmAxis(args, eState, _data, "MomentumX", eState["Facing"])
func CapMomentumY(args, eState, _data):
	_CapMomentmAxis(args, eState, _data, "MomentumY")
func CapMomentumXAbsolute(args, eState, _data):
	_CapMomentmAxis(args, eState, _data, "MomentumX")
func _CapMomentmAxis(args, eState, _date, axis, facing=1.0):
	var aMin = ArgInt(args, eState, 0)
	var aMax = ArgInt(args, eState, 1)
	if(aMin > aMax):
		ModuleError("CapMomentumAxis: Enveloppe has no volume", eState)
	if(facing < 0):
		var a = aMin
		aMin = -aMax
		aMax = -a
	eState[axis] = max(min(eState[axis], aMax), aMin)










func Colbox(args, eState, _data):
	eState["Colbox"] = {
		"Left":ArgInt(args, eState, 0),
		"Right":ArgInt(args, eState, 1),
		"Down":ArgInt(args, eState, 2),
		"Up":ArgInt(args, eState, 3),
		"Owner":eState["EID"],
	}

func Hurtbox(args, eState, _data):
	eState["Hurtboxes"].append({
		"Left":ArgInt(args, eState, 0),
		"Right":ArgInt(args, eState, 1),
		"Down":ArgInt(args, eState, 2),
		"Up":ArgInt(args, eState, 3),
		"Owner":eState["EID"],
		"Data":{},
	})

func Hitbox(args, eState, _data):
	eState["Hitboxes"].append({
		"Left":ArgInt(args, eState, 0),
		"Right":ArgInt(args, eState, 1),
		"Down":ArgInt(args, eState, 2),
		"Up":ArgInt(args, eState, 3),
		"Owner":eState["EID"],
		"AttackData":eState["AttackData"],
	})

func GizmoBox(emodule, args, lineActive, gdata, type):
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

func GizmoHurtbox(emodule, args, lineActive, gdata):
	GizmoBox(emodule, args, lineActive, gdata, 0)
func GizmoHitbox(emodule, args, lineActive, gdata):
	GizmoBox(emodule, args, lineActive, gdata, 1)
func GizmoColbox(emodule, args, lineActive, gdata):
	GizmoBox(emodule, args, lineActive, gdata, 2)

























# --------------------------------------------------------------------------------------------------
# Physics code




var arenaSize 
var cameraSize 

func PhysicsPhase(state, previousState, activeEIDs):
	# :TODO:Panthavma:20220203:Allow more than two entities for colbox
	var teams = [0,1]
	var mainEIDs = [
		state["Players"][0]["MainEntity"],
		state["Players"][1]["MainEntity"],
	]
	
	# 1. Resolve colboxes between the two main entities
	PhysicsResolveColboxes(state, previousState, mainEIDs)
	
	# 2. Gather hitboxes and hurtboxes per player
	# :TODO:Panthavma:20220203:Make it per team, and allow friendly fire/more teams
	# :TODO:Panthavma:20220203:Gather hitboxes/hurtboxes earlier ?
	var hitboxes = [[], []]
	var hurtboxes = [[], []]
	
	for eid in activeEIDs:
		var eState = state[eid]
		var pid = eState["Player"]
		var atkPID = 1-pid
		
		hurtboxes[pid].append_array(eState["Hurtboxes"])
		hitboxes[atkPID].append_array(eState["Hitboxes"])
		for h in eState["Hitboxes"]:
			if(h["AttackData"]["Flags"].has("FriendlyFire")):
				hitboxes[pid].push_back(h)
	
	
	# 3. Resolve hitbox/hurtbox collisions
	for t in teams:
		PhysicsResolveHitboxHurtbox(state, hitboxes[t], hurtboxes[t])

func PhysicsResolveColboxes(state, previousState, eids):
	var nbEntities = eids.size()
	# :TODO:Panthavma:20220203:Allow more than two entities
	
	
	if(!previousState[eids[1]].has("PositionX") or !previousState[eids[0]].has("PositionX")):
		return #:TODO:Panthavma:20220203:Is there a more elegant way to ch
	
	# Find out who is one the left and who is on the right
	var posDiff = previousState[eids[1]]["PositionX"] - previousState[eids[0]]["PositionX"]
	var playerOnTheLeft = (0 if posDiff > 0 else 1)
	# Use the previous frame's result if there is doubt (stored because of jumps)
	if(posDiff == 0):
		playerOnTheLeft = previousState["PlayerOnTheLeft"]
	state["PlayerOnTheLeft"] = playerOnTheLeft
	
	# Find out collisions and camera postion for better placement
	var camCenter = previousState["CameraX"] # TODO Recompute ?
	var p1Colbox = GetBoxPosition(state[eids[0]], state[eids[0]]["Colbox"])
	var p2Colbox = GetBoxPosition(state[eids[1]], state[eids[1]]["Colbox"])
	var areBoxesOverlapping = AreBoxesOverlapping(p1Colbox, p2Colbox)
	var overlapAmount = 0
	if(areBoxesOverlapping):
		if(playerOnTheLeft == 0):
			overlapAmount = p1Colbox["Right"] - p2Colbox["Left"]
		else:
			overlapAmount = p2Colbox["Right"] - p1Colbox["Left"]
	
	
	for i in range(nbEntities):
		var eid = eids[i]
		var eState = state[eid]
		var minX = max(-arenaSize, camCenter - cameraSize)
		var maxX = min(arenaSize, camCenter + cameraSize)
		
		# Prevent corner steal and push the boxes if in the corner
		if(i == playerOnTheLeft):
			maxX -= 1 + overlapAmount
		else:
			minX += 1 + overlapAmount
		
		# Check Collisions
		var positionX = eState["PositionX"]
		if(i == playerOnTheLeft):
			positionX -= overlapAmount/2
		else:
			positionX += overlapAmount/2
		positionX = clamp(positionX, minX, maxX)
		eState["PositionX"] = positionX 
		
		var newFacing = (1 if i == playerOnTheLeft else -1)
		if(eState["FacingTrue"] != newFacing):
			SetFlag(eState, "PFSwitchFacing")
			eState["FacingTrue"] = newFacing
		
		if(eState["PositionY"] <= 0):
			eState["PositionY"] = 0
			SetFlag(eState, "PFGrounded")
		else:
			SetFlag(eState, "PFAirborne")
	
	state["CameraX"] = (state[eids[0]]["PositionX"]+state[eids[1]]["PositionX"])/2
	state["CameraY"] = (state[eids[0]]["PositionY"]+state[eids[1]]["PositionY"])/2
	
	var signCam = sign(state["CameraX"])
	if(signCam != 0 and abs(state["CameraX"]) > (arenaSize - cameraSize)):
		state["CameraX"] = signCam * (arenaSize - cameraSize)

func PhysicsResolveHitboxHurtbox(state, hitboxes, hurtboxes):
	
	# :TODO:Panthavma:20220204:Do we allow several hitboxes to hit at the same frame ? Do we add priority ?
	# :TODO:Panthavma:20220204:One hitbox vs several hurtboxes ? Needs some refactoring
	
	for hitbox in hitboxes:
		var aEID = hitbox["Owner"]
		var aState = state[aEID]
		
		var hitboxPos = GetBoxPosition(aState, hitbox)
		
		var hitconfirm = Castagne.HITCONFIRMED.NONE
		var hurtboxData = null
		var dEID
		var dState
		
		for hurtbox in hurtboxes:
			dEID = hurtbox["Owner"]
			dState = state[dEID]
			# :TODO:Panthavma:20220204:Maybe do the position computations earlier, since with more teams it would compute twice
			var hurtboxPos = GetBoxPosition(dState, hurtbox)
			
			if(AreBoxesOverlapping(hurtboxPos, hitboxPos)):
				hitconfirm = Castagne.HITCONFIRMED.HIT
				hurtboxData = hurtbox["Data"]
				break # Only use first hurtbox for now
		
		if(hitconfirm != Castagne.HITCONFIRMED.NONE):
			var attackData = hitbox["AttackData"]
			for m in engine.modules:
				hitconfirm = m.IsAttackConfirmed(hitconfirm, attackData, hurtboxData, aState, dState, state)
			
			if(hitconfirm == Castagne.HITCONFIRMED.NONE):
				continue
			
			for m in engine.modules:
				m.OnAttackConfirmed(hitconfirm, attackData, hurtboxData, aState, dState, state)
			break 

func GetBoxPosition(fighterState, box):
	var boxLeft = fighterState["PositionX"]
	var boxRight = fighterState["PositionX"]
	
	if(fighterState["Facing"] > 0):
		boxLeft += box["Left"]
		boxRight += box["Right"]
	else:
		boxLeft -= box["Right"]
		boxRight -= box["Left"]
	
	var boxDown = fighterState["PositionY"] + box["Down"]
	var boxUp = fighterState["PositionY"] + box["Up"]
	
	return {"Left":boxLeft, "Right":boxRight,"Down":boxDown,"Up":boxUp}

func AreBoxesOverlapping(boxA, boxB):
	return (boxA["Right"] > boxB["Left"]
		and boxA["Left"] < boxB["Right"]
		and boxA["Up"] > boxB["Down"]
		and boxA["Down"] < boxB["Up"])



func TranslatePosEntityToGlobal(pos, eState):
	var x = eState["PositionX"]
	var y = eState["PositionY"]
	
	return Vector2(x + pos.x * (1 if eState["Facing"] > 0 else -1), y + pos.y)
