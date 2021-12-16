extends "CastagneFunctions.gd"

func Setup():
	
	RegisterFunction("Attack", [3])
	RegisterFunction("AttackBlock", [1])
	RegisterFunction("AttackMeter", [1, 2, 4])
	RegisterFunction("AttackMomentum", [1,2,4])
	RegisterFunction("AttackMomentumBlock", [1,2,4])
	RegisterFunction("AttackProration", [4])
	RegisterFunction("AttackFlag", [1])
	RegisterFunction("AttackUnflag", [1])
	RegisterFunction("AttackParam", [2])
	
	RegisterFunction("AttackMultiplexer", [0,1], ["TransitionFunc", "FullData"])
	RegisterFunction("ResetGatlings", [0])

func StateSetup(pid, state, _engine):
	state[pid]["NbHurtboxes"] = 0
	state[pid]["NbHitboxes"] = 0
	state[pid]["AttackHasHit"] = false
	state[pid]["AttackCleanHit"] = false
	state[pid]["AttackBlocked"] = false
	state[pid]["ProrationDamage"] = 1000
	state[pid]["ProrationHitstun"] = 1000
	
	state[pid]["AttackData"] = {}
	state[pid]["AttackFlags"] = []
	state[pid]["CanGatling"] = 0
	state[pid]["Gatlings"] = []
	
	state["Hitstop"] = 0

func PreFrame(pid, _playerState, _inputs, _previousState, state):
	state[pid]["AttackData"] = {}

func PostFrame(pid, _playerState, _inputs, _previousState, state):
	if(Castagne.HasFlag("Multihit", pid, state)):
		state[pid]["AttackHasHit"] = false
		state[pid]["AttackCleanHit"] = false
		state[pid]["AttackBlocked"] = false

func PostPhysics(pid, _playerState, _inputs, _previousState, state):
	var events = state[pid]["Events"]
	
	if(events.has("Hit")):
		var hitData = events["Hit"]
		state[pid]["Hitstun"] = hitData["TrueStun"]
	
	if(events.has("Block")):
		var hitData = events["Block"]
		state[pid]["Blockstun"] = hitData["TrueStun"]
	
	for f in state[pid]["AttackFlags"]:
		state[pid]["Flags"] += ["AF"+f]


func IsHitConfirmed(isCurrentlyHit, attackData, defenderPID, _attackerPID, state):
	if(isCurrentlyHit == Castagne.HITCONFIRMED.HIT):
		var attackFlags = attackData["Flags"]
		var defenderState = state[defenderPID]
		var defenderInputs = defenderState["Input"]
		var defenderEvents = defenderState["Events"]
		var defenderFlags = defenderState["Flags"]
		
		if(defenderFlags.has("Hitstun")):
			return isCurrentlyHit
		
		var autoblocking = defenderFlags.has("AutoBlocking")
		var blocking = defenderInputs["TrueBack"] or defenderFlags.has("Blockstun") or autoblocking
		blocking = blocking and defenderFlags.has("CanBlock")
		var lowBreak = attackFlags.has("Low") and ((!autoblocking and !defenderInputs["Down"]) or (autoblocking and !defenderFlags.has("AutoBlockingLow")))
		var highBreak = attackFlags.has("Overhead") and ((!autoblocking and defenderInputs["Down"]) or (autoblocking and !defenderFlags.has("AutoBlockingOverhead")))
		var groundUnblockableBreak = attackFlags.has("GroundUnblockable") and defenderEvents.has("Grounded")
		var airUnblockableBreak = attackFlags.has("AirUnblockable") and defenderEvents.has("Airborne")
		
		var isThrow = attackFlags.has("Throw") or attackFlags.has("Airthrow")
		var throwBreak = attackFlags.has("Throw") and defenderEvents.has("Grounded")
		var airthrowBreak = attackFlags.has("Airthrow") and defenderEvents.has("Airborne")
		var throwTech = attackFlags.has("ThrowTech")
		
		if((blocking or isThrow) and !lowBreak and !highBreak and !groundUnblockableBreak and !airUnblockableBreak and !throwBreak and !airthrowBreak and !throwTech):
			return (Castagne.HITCONFIRMED.NONE if isThrow else Castagne.HITCONFIRMED.BLOCK)
	return isCurrentlyHit

func OnHit(attackData, defenderPID, attackerPID, state, defenderEvents):
	var attackerState = state[attackerPID]
	var defenderState = state[defenderPID]
	
	var prorationDamage = defenderState["ProrationDamage"]
	var prorationHitstun = defenderState["ProrationHitstun"]
	attackerState["AttackCleanHit"] = true
	
	if(defenderState["Flags"].has("Hitstun")):
		defenderState["ProrationDamage"] *= attackData["ProrationDamage"]
		defenderState["ProrationHitstun"] *= attackData["ProrationHitstun"]
		defenderState["ProrationDamage"] /= Castagne.PRORATION_SCALE
		defenderState["ProrationHitstun"] /= Castagne.PRORATION_SCALE
	else:
		defenderState["ProrationDamage"] = attackData["StarterProrationDamage"]
		defenderState["ProrationHitstun"] = attackData["StarterProrationHitstun"]
		prorationDamage = Castagne.PRORATION_SCALE
		prorationHitstun = Castagne.PRORATION_SCALE
	
	defenderState["HP"] -= (attackData["Damage"] * prorationDamage)/Castagne.PRORATION_SCALE
	attackData["TrueStun"] = (attackData["Hitstun"] * prorationHitstun)/Castagne.PRORATION_SCALE
	
	if(defenderEvents.has("Grounded")):
		defenderState["AttackMomentumH"] = attackerState["Facing"] * attackData["HitMomentumH"]
		defenderState["AttackMomentumV"] = attackData["HitMomentumV"]
	else:
		defenderState["AttackMomentumH"] = attackerState["Facing"] * attackData["HitMomentumAirH"]
		defenderState["AttackMomentumV"] = attackData["HitMomentumAirV"]
	
	OnAttackBlock(attackData, defenderPID, attackerPID, state, defenderEvents, attackerState, defenderState)

func OnBlock(attackData, defenderPID, attackerPID, state, defenderEvents):
	var attackerState = state[attackerPID]
	var defenderState = state[defenderPID]
	
	defenderState["HP"] -= attackData["Chip"]
	attackerState["AttackBlocked"] = true
	
	if(defenderEvents.has("Grounded")):
		defenderState["AttackMomentumH"] = attackerState["Facing"] * attackData["BlockMomentumH"]
		defenderState["AttackMomentumV"] = attackData["BlockMomentumV"]
	else:
		defenderState["AttackMomentumH"] = attackerState["Facing"] * attackData["BlockMomentumAirH"]
		defenderState["AttackMomentumV"] = attackData["BlockMomentumAirV"]
	
	attackData["TrueStun"] = attackData["Blockstun"]
	OnAttackBlock(attackData, defenderPID, attackerPID, state, defenderEvents, attackerState, defenderState)

func OnAttackBlock(attackData, _defenderPID, _attackerPID, state, _defenderEvents, attackerState, defenderState):
	attackerState["AttackHasHit"] = true
	state["Hitstop"] = attackData["Hitstop"]
	if(defenderState["HP"] <= 0):
		attackData["Flags"] += ["Die"]
	defenderState["AttackFlags"] = attackData["Flags"]


func Attack(args, pid, state):
	var damage = GetInt(args[0], pid, state)
	var hitstun = GetInt(args[1], pid, state)
	var blockstun = GetInt(args[2], pid, state)
	
	var attackData = {
		"Damage": damage,
		"Hitstun": hitstun,
		"Blockstun": blockstun,
		
		"Chip": 0,
		
		"MetergainHit": 6, "MetergainBlock":0,
		"MetergainFoeHit": 0, "MetergainFoeBlock":0,
		
		"HitMomentumH":1000, "HitMomentumV":0,
		"HitMomentumAirH":1000, "HitMomentumAirV":200,
		"BlockMomentumH":1000, "BlockMomentumV":0,
		"BlockMomentumAirH":1000, "BlockMomentumAirV":0,
		
		"ProrationDamage": 950, "StarterProrationDamage": 950,
		"ProrationHitstun": 950, "StarterProrationHitstun": 950,
		
		"Flags":[],
		"Hitstop":3,
	}
	
	state[pid]["AttackData"] = attackData

func AttackBlock(args, pid, state):
	var chip = GetInt(args[0], pid, state)
	
	state[pid]["AttackData"]["Chip"] = chip

func AttackMeter(args, pid, state):
	var mh = GetInt(args[0],pid,state)
	var mb = (GetInt(args[1],pid,state) if args.size() >= 2 else 0)
	var mfh = (GetInt(args[2],pid,state) if args.size >= 4 else 0)
	var mfb = (GetInt(args[3],pid,state) if args.size >= 4 else 0)
	
	state[pid]["AttackData"]["MetergainHit"] = mh
	state[pid]["AttackData"]["MetergainBlock"] = mb
	state[pid]["AttackData"]["MetergainFoeHit"] = mfh
	state[pid]["AttackData"]["MetergainFoeBlock"] = mfb

func AttackMomentum(args, pid, state, prefix="Hit"):
	var mh = GetInt(args[0],pid,state)
	var mv = (GetInt(args[1],pid,state) if args.size() >= 2 else 0)
	var mah = (GetInt(args[2],pid,state) if args.size() >= 4 else mh)
	var mav = (GetInt(args[3],pid,state) if args.size() >= 4 else mv)
	
	state[pid]["AttackData"][prefix+"MomentumH"] = mh
	state[pid]["AttackData"][prefix+"MomentumV"] = mv
	state[pid]["AttackData"][prefix+"MomentumAirH"] = mah
	state[pid]["AttackData"][prefix+"MomentumAirV"] = mav
func AttackMomentumBlock(args, pid, state):
	AttackMomentum(args, pid, state, "Block")

func AttackProration(args, pid, state):
	state[pid]["AttackData"]["ProrationDamage"] = GetInt(args[0],pid,state)
	state[pid]["AttackData"]["StarterProrationDamage"] = GetInt(args[1],pid,state)
	state[pid]["AttackData"]["ProrationHitstun"] = GetInt(args[2],pid,state)
	state[pid]["AttackData"]["StarterProrationHitstun"] = GetInt(args[3],pid,state)

func AttackFlag(args, pid, state):
	var flagName = GetStr(args[0], pid, state)
	if(!flagName in state[pid]["AttackData"]["Flags"]):
		state[pid]["AttackData"]["Flags"] += [flagName]
func AttackUnflag(args, pid, state):
	var flagName = GetStr(args[0], pid, state)
	if(flagName in state[pid]["AttackData"]["Flags"]):
		state[pid]["AttackData"]["Flags"].erase(flagName)

func AttackParam(args, pid, state):
	var paramName = GetStr(args[0], pid, state)
	var value = GetInt(args[1], pid, state)
	
	state[pid]["AttackData"][paramName] = value

func AttackMultiplexer(args, pid, state, engine, _neededFlag):
	var prefix = ""
	if(args.size() >= 1):
		prefix = Castagne.GetStr(args[0], pid, state)
	
	var alwaysAllowNeutralV = (prefix != "")
	
	var gatlingCancel = false
	if(Castagne.HasFlag("Attacking", pid, state)):
		#var frameID = state["FrameID"] - state[pid]["StateStartFrame"]
		if(state[pid]["CanGatling"] <= 0 or !state[pid]["AttackHasHit"]):
			return
		gatlingCancel = true
	
	# TODO Refactor ?
	var input = state[pid]["Input"]
	var directions = []
	
	if(input["Up"]):
		if(input["Forward"]):
			directions += ["9"]
		elif(input["Back"]):
			directions += ["7"]
		directions += ["8"]
	elif(input["Down"]):
		if(input["Forward"]):
			directions += ["3"]
		elif(input["Back"]):
			directions += ["1"]
		directions += ["2"]
	
	if(directions.empty() or alwaysAllowNeutralV):
		if(input["Forward"]):
			directions += ["6"]
		elif(input["Back"]):
			directions += ["4"]
		directions += ["5"]
	
	var attackButtons = []
	if(input["APress"] and input["BPress"] and input["CPress"]):
		attackButtons += ["ABC"]
	if(input["BPress"] and input["CPress"]):
		attackButtons += ["BC"]
	if(input["APress"] and input["CPress"]):
		attackButtons += ["AC"]
	if(input["APress"] and input["BPress"]):
		attackButtons += ["AB"]
	
	if(input["CPress"]):
		attackButtons += ["C"]
	if(input["BPress"]):
		attackButtons += ["B"]
	if(input["APress"]):
		attackButtons += ["A"]
	
	for b in attackButtons:
		for d in directions:
			var attackName = prefix + d + b
			var alreadyUsedInGatling = attackName in state[pid]["Gatlings"]
			if(engine.states[pid].has(attackName) and (!gatlingCancel or !alreadyUsedInGatling)):
				state[pid]["Gatlings"] += [attackName]
				CallOtherFunction("Transition", [attackName, 100], pid, state)
				return

func ResetGatlings(_args, pid, state):
	state[pid]["Gatlings"] = []
