extends "../CastagneModule.gd"

# :TODO:Panthavma:20220124:Allow different physics.

func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	# :TODO:Panthavma:20211230:Gravity as a standard implementation
	# :TODO:Panthavma:20211230:More physics functions for flexible movement
	
	RegisterModule("CF Physics", {"Description":"All these base themselves on the reference entity's values"})
	RegisterCategory("Movement")
	RegisterFunction("Move", [2], null, {
		"Description": "Moves the entity this frame, depending on facing.",
		"Arguments": ["Horizontal move", "Vertical move"],
		})
	RegisterFunction("MoveAbsolute", [2], null, {
		"Description": "Moves the entity this frame, independant of facing.",
		"Arguments": ["Horizontal move", "Vertical move"],
		})
	RegisterFunction("AddMomentum", [2], null, {
		"Description": "Adds to the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("AddMomentumAbsolute", [2], null, {
		"Description": "Adds to the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("SetMomentum", [2], null, {
		"Description": "Sets the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("SetMomentumAbsolute", [2], null, {
		"Description": "Sets the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("BreakMomentum", [2], null, {
		"Description": "Reduces the momentum by the amount given.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("CapMomentum", [2], null, {
		"Description": "Limits the momentum to those values. Ignores a direction if using a negative number.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("AddMomentumTurn", [2], null, {
		"Description": "Adds to the momentum, depending on facing. If momentum is going in the opposite direction, cancel it before applying.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("AddMomentumTurnAbsolute", [2], null, {
		"Description": "Adds to the momentum, independant of facing. If momentum is going in the opposite direction, cancel it before applying.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
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
	RegisterFunction("SetWorldPositionAbsolute", [2], null, {
		"Description": "Sets the position relative to the world origin, independant of facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
		})
	RegisterFunction("CopyRefFacing", [0], null, {
		"Description": "Sets the facing to the one of the reference entity's.",
		"Arguments": [],
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
	
	RegisterVariableEntity("Hitboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("Hurtboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("Colbox", {"Left":-1, "Right":1, "Down":0, "Up":1}, ["ResetEachFrame"])

func BattleInit(_state, _data, _battleInitData):
	engine.physicsModule = self

func ActionPhaseEndEntity(eState, _data):
	eState["MovementX"] += eState["MomentumX"]
	eState["MovementY"] += eState["MomentumY"]
	if(HasFlag(eState, "ApplyFacing")):
		eState["Facing"] = eState["FacingTrue"]


func PhysicsPhaseStart(_state, _data):
	pass
func PhysicsPhaseStartEntity(eState, _data):
	eState["PositionX"] += eState["MovementX"]
	eState["PositionY"] += eState["MovementY"]
func PhysicsPhaseEndEntity(eState, _data):
	if(HasFlag(eState, "PFGrounded")):
		eState["MomentumY"] = max(eState["MomentumY"], 0)
func PhysicsPhaseEnd(_state, _data):
	pass

























# --------------------------------------------------------------------------------------------------
# Functions



func Move(args, eState, data):
	MoveAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), args[1]], eState, data)
func MoveAbsolute(args, eState, _data):
	eState["MovementX"] += ArgInt(args, eState, 0)
	eState["MovementY"] += ArgInt(args, eState, 1)
	
func AddMomentum(args, eState, data):
	AddMomentumAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), args[1]], eState, data)
func AddMomentumAbsolute(args, eState, _data):
	eState["MomentumX"] += ArgInt(args, eState, 0)
	eState["MomentumY"] += ArgInt(args, eState, 1)
	
func SetMomentum(args, eState, data):
	SetMomentumAbsolute([data["rState"]["Facing"]*ArgInt(args, eState, 0), args[1]], eState, data)
func SetMomentumAbsolute(args, eState, _data):
	eState["MomentumX"] = ArgInt(args, eState, 0)
	eState["MomentumY"] = ArgInt(args, eState, 1)
	
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
	var v = min(ArgInt(args, eState, 1), abs(eState["MomentumY"]))
	eState["MomentumX"] -= sign(eState["MomentumX"]) * h
	eState["MomentumY"] -= sign(eState["MomentumY"]) * v

func CapMomentum(args, eState, _data):
	var h = ArgInt(args, eState, 0)
	var v = ArgInt(args, eState, 1)
	
	if(h >= 0):
		eState["MomentumX"] = sign(eState["MomentumX"]) * min(abs(eState["MomentumX"]), h)
	if(v >= 0):
		eState["MomentumY"] = sign(eState["MomentumY"]) * min(abs(eState["MomentumY"]), v)


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

func CopyRefFacing(_args, eState, data):
	eState["Facing"] = data["rState"]["Facing"]








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


























# --------------------------------------------------------------------------------------------------
# Physics code






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
	
	
	# 3. Resolve hitbox/hurtbox collisions
	for t in teams:
		PhysicsResolveHitboxHurtbox(state, hitboxes[t], hurtboxes[t])

func PhysicsResolveColboxes(state, previousState, eids):
	var nbEntities = eids.size()
	# :TODO:Panthavma:20220203:Allow more than two entities
	
	var arenaSize = engine.ARENA_SIZE
	var cameraSize = engine.CAMERA_SIZE
	
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
	if(signCam != 0 and abs(state["CameraX"]) > (engine.ARENA_SIZE - engine.CAMERA_SIZE)):
		state["CameraX"] = signCam * (engine.ARENA_SIZE - engine.CAMERA_SIZE)

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




