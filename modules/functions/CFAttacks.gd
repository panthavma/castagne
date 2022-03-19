extends "../CastagneModule.gd"

func ModuleSetup():
	# :TODO:Panthavma:20211230:Hitstop
	
	RegisterModule("CF Attacks")
	RegisterCategory("Attacks")
	RegisterFunction("Attack", [1,2], null, {
		"Description":"Initiates an attack with default parameters. This should be the first function called for a new attack, then you use other Attack functions to customize it, and finally you use Hitbox to apply it.",
		"Arguments":["Damage", "(Optional) Total frames (must be specified at the first attack at least)"],
		"Flags":["Basic"],
	})
	RegisterFunction("AttackDuration", [1], null, {
		"Description":"Changes the total duration of the attack. Can replace Attack's second parameter but must be called before it.",
		"Arguments":["Total frames"],
		"Flags":["Basic"],
	})
	RegisterFunction("AttackParam", [2], null, {
		"Description":"Sets a generic attack parameter directly. This is an advanced function and should be used either when you need some really specific adjustment, or when you want to add functionality without a module.",
		"Arguments":["Parameter name", "Parameter value"],
		"Flags":["Advanced"],
	})
	
	
	
	RegisterFunction("AttackFlag", [1], null, {
		"Description":"Sets a flag on the attack. All flags are transfered to the hit opponent with the AF prefix (meaning Low become AFLow), and are used by modules during attack checking. See the list of flags for more information.",
		"Arguments":["Flag name"],
		"Flags":["Basic"],
	})
	RegisterFunction("AttackUnflag", [1], null, {
		"Description":"Removes a flag from an attack.",
		"Arguments":["Flag name"],
	})
	
	
	
	RegisterFunction("AttackFrameAdvantage", [1,2], null, {
		"Description":"Sets an attack's frame advantage automatically on hit and block. This is based on the total duration of the attack and the last use of the multihit flag. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit", "Frame advantage on block"],
		"Flags":["Basic"],
	})
	
	
	
	RegisterFunction("AttackProrationHitstun", [2], null, {
		"Description":"Sets an attack's proration for hitstun. The lower it is, the more hitstun will decay with each hit. Values are in permil.",
		"Arguments":["First hit proration (used instead of proration for the first hit)", "Subsequent hit proration"],
	})
	RegisterFunction("AttackProrationDamage", [2], null, {
		"Description":"Sets an attack's proration for damage. The lower it is, the more damage will decay with each hit. Values are in permil.",
		"Arguments":["First hit proration (used instead of proration for the first hit)", "Subsequent hit proration"],
	})
	
	
	RegisterFunction("AttackChipDamage", [1], null, {
		"Description":"Sets an attack's chip damage, the damage that gets inflicted when an opponent blocks.",
		"Arguments":["The amount of chip damage"],
	})
	RegisterFunction("AttackMinDamage", [1], null, {
		"Description":"Sets an attack's minimum damage.",
		"Arguments":["The minimum amount of damage"],
	})
	
	
	
	RegisterFunction("AttackMomentum", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on hit and block.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
	})
	RegisterFunction("AttackMomentumHit", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on hit.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
	})
	RegisterFunction("AttackMomentumBlock", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on block.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
	})
	
	
	
	RegisterFunction("AttackSetHitstunBlockstun", [2], null, {
		"Description":"Sets an attack's hitstun and blockstun. Same functionality as AttackFrameAdvantage, but in a more direct way.",
		"Arguments":["Hitstun", "Blockstun"],
		"Flags":["Advanced"],
	})
	
	
	RegisterVariableEntity("AttackData", {}, ["ResetEachFrame"])
	RegisterVariableEntity("AttackDuration", 600)
	RegisterVariableEntity("AttackFlags", [])
	RegisterVariableEntity("AttackHitEntities", [])
	RegisterVariableEntity("HitstunDuration", 0)
	RegisterVariableEntity("BlockstunDuration", 0)
	RegisterVariableEntity("ProrationHitstun", 1000)
	RegisterVariableEntity("ProrationDamage", 1000)
	
	RegisterFlag("Multihit", {"Description":"Allow an attack to hit again."})
	RegisterFlag("AFLow", {"Description":"Makes an attack unblockable while standing up."})
	RegisterFlag("AFOverhead", {"Description":"Makes an attack unblockable while crouching."})
	
	
	
	
	RegisterCategory("Attack Cancels")
	
	RegisterFunction("AttackApplyCancels", [0,1], ["Transition"], {
		"Description":"Manages the transitions of attacks using numpad notation. A prefix can be added. It will only cancel into an attack if it wasn't already used since the last call to AttackResetDoneCancels.",
		"Arguments":["(Optional) Prefix"]
	})
	RegisterFunction("AttackResetDoneCancels", [0], null, {
		"Description":"Resets the list of used attacks in cancels, meaning you can use them again. Mostly used when returning to neutral.",
		"Flags":["Advanced"],
	})
	
	
	
	RegisterFunction("AttackCancelOnWhiff", [1,2], null, {
		"Description":"Adds a possible cancel on whiff.",
		"Arguments":["The command to be used in numpad notation.", "(Optional) Attack name if different from the numpad notation."]
	})
	RegisterFunction("AttackCancelOnBlock", [1,2], null, {
		"Description":"Adds a possible cancel on block.",
		"Arguments":["The command to be used in numpad notation.", "(Optional) Attack name if different from the numpad notation."]
	})
	RegisterFunction("AttackCancelOnHit", [1,2], null, {
		"Description":"Adds a possible cancel on hit.",
		"Arguments":["The command to be used in numpad notation.", "(Optional) Attack name if different from the numpad notation."]
	})
	RegisterFunction("AttackCancelOnTouch", [1,2], null, {
		"Description":"Adds a possible cancel on block or hit.",
		"Arguments":["The command to be used in numpad notation.", "(Optional) Attack name if different from the numpad notation."]
	})
	RegisterFunction("AttackCancelOnWhiffOrTouch", [1,2], null, {
		"Description":"Adds a possible cancel on whiff, block, or hit.",
		"Arguments":["The command to be used in numpad notation.", "(Optional) Attack name if different from the numpad notation."]
	})
	RegisterFunction("AttackCancelNeutral", [1,2], null, {
		"Description":"Adds a possible cancel when in a neutral state.",
		"Arguments":["The command to be used in numpad notation.", "(Optional) Attack name if different from the numpad notation."]
	})
	RegisterFunction("AttackCancelOnTouchAndNeutral", [1,2], null, {
		"Description":"Adds a possible cancel when in a neutral state or on block or hit.",
		"Arguments":["The command to be used in numpad notation.", "(Optional) Attack name if different from the numpad notation."]
	})
	
	RegisterFunction("AttackAddAllCancelsOnWhiff", [1,2], null, {
		"Description":"Adds all cancels from a button on whiff. For example using B and j as parameters will add j1B, j2B, j3B and so on.",
		"Arguments":["The base button to use.", "(Optional) Prefix."]
	})
	RegisterFunction("AttackAddAllCancelsOnBlock", [1,2], null, {
		"Description":"Adds all cancels from a button on block. For example using B and j as parameters will add j1B, j2B, j3B and so on.",
		"Arguments":["The base button to use.", "(Optional) Prefix."]
	})
	RegisterFunction("AttackAddAllCancelsOnHit", [1,2], null, {
		"Description":"Adds all cancels from a button on hit. For example using B and j as parameters will add j1B, j2B, j3B and so on.",
		"Arguments":["The base button to use.", "(Optional) Prefix."]
	})
	RegisterFunction("AttackAddAllCancelsOnTouch", [1,2], null, {
		"Description":"Adds all cancels from a button on block or hit. For example using B and j as parameters will add j1B, j2B, j3B and so on.",
		"Arguments":["The base button to use.", "(Optional) Prefix."]
	})
	RegisterFunction("AttackAddAllCancelsOnWhiffOrTouch", [1,2], null, {
		"Description":"Adds all cancels from a button on whiff, block, or hit. For example using B and j as parameters will add j1B, j2B, j3B and so on.",
		"Arguments":["The base button to use.", "(Optional) Prefix."]
	})
	RegisterFunction("AttackAddAllCancelsNeutral", [1,2], null, {
		"Description":"Adds all cancels from a button when in a neutral state. For example using B and j as parameters will add j1B, j2B, j3B and so on.",
		"Arguments":["The base button to use.", "(Optional) Prefix."]
	})
	RegisterFunction("AttackAddAllCancelsOnTouchAndNeutral", [1,2], null, {
		"Description":"Adds all cancels from a button when in a neutral state, or on block or hit. For example using B and j as parameters will add j1B, j2B, j3B and so on.",
		"Arguments":["The base button to use.", "(Optional) Prefix."]
	})
	
	RegisterVariableEntity("AttackInitialFrame", -1)
	RegisterVariableEntity("AttackHitconfirm_State", null)
	RegisterVariableEntity("AttackDoneCancels", [])
	RegisterVariableEntity("AttackPossibleCancelsWhiff", {}, ["ResetEachFrame"])
	RegisterVariableEntity("AttackPossibleCancelsBlock", {}, ["ResetEachFrame"])
	RegisterVariableEntity("AttackPossibleCancelsHit", {}, ["ResetEachFrame"])
	RegisterVariableEntity("AttackPossibleCancelsNeutral", {}, ["ResetEachFrame"])
	RegisterVariableEntity("AttackHasHit", false)
	RegisterVariableEntity("AttackWasBlocked", false) 
	RegisterVariableEntity("AttackHasWhiffed", false)
	RegisterVariableEntity("AttackHasTouched", false)
	RegisterVariableGlobal("Hitstop", 0)
	
	RegisterCategory("Default Attack Params")
	RegisterConfig("AttackDefault-ProrationDamage", 700)
	RegisterConfig("AttackDefault-StarterProrationDamage", 950)
	RegisterConfig("AttackDefault-ProrationHitstun", 900)
	RegisterConfig("AttackDefault-StarterProrationHitstun", 950)
	RegisterConfig("AttackDefault-Hitstop", 3)

var _defaultAttackData = {}
func BattleInit(_state, _data, _battleInitData):
	_defaultAttackData = {
		"Damage": 100, "MinDamage": 1,
		"Hitstun": 20, "Blockstun": 20,
		
		"ChipDamage": 0,
		
		"MetergainHit": 6, "MetergainBlock":0,
		"MetergainFoeHit": 0, "MetergainFoeBlock":0,
		
		"HitMomentumH":1000, "HitMomentumV":0,
		"HitMomentumAirH":1000, "HitMomentumAirV":200,
		"BlockMomentumH":1000, "BlockMomentumV":0,
		"BlockMomentumAirH":1000, "BlockMomentumAirV":0,
		
		"Flags":[],
	}
	
	# Take variables from the config stating with AttackDefault
	var configDerivedDataPrefix = "AttackDefault-"
	for configKeyName in configDefault:
		if(configKeyName.begins_with(configDerivedDataPrefix)):
			var attackDataName = configKeyName.right(configDerivedDataPrefix.length())
			_defaultAttackData[attackDataName] = Castagne.configData[configKeyName]


func ActionPhaseEndEntity(eState, _data):
	if(HasFlag(eState, "Multihit")):
		eState["AttackHitconfirm_State"] = null
		eState["AttackInitialFrame"] = -1
		eState["AttackHitEntities"] = []
		eState["AttackHasHit"] = false
		eState["AttackWasBlocked"] = false
		eState["AttackHasWhiffed"] = false
		eState["AttackHasTouched"] = false

func PhysicsPhaseEndEntity(eState, _data):
	# :TODO:Panthavma:20220314:Optim: Maybe replace the string check by a int
	var hitconfirmState = eState["AttackHitconfirm_State"]
	if(eState["Hitboxes"].size() > 0 and hitconfirmState == null):
		eState["AttackHitconfirm_State"] = "Whiff"
	if(hitconfirmState != null):
		eState["AttackHasHit"] = (hitconfirmState == "Hit")
		eState["AttackWasBlocked"] = (hitconfirmState == "Block")
		eState["AttackHasWhiffed"] = (hitconfirmState == "Whiff")
		eState["AttackHasTouched"] = (eState["AttackHasHit"] or eState["AttackWasBlocked"])















func IsAttackConfirmed(hitconfirm, attackData, _hurtboxData, aState, dState, state):
	if(hitconfirm == Castagne.HITCONFIRMED.HIT):
		if(aState["AttackHitEntities"].has(dState["EID"])):
			return Castagne.HITCONFIRMED.NONE
		
		#var attackFlags = attackData["Flags"]
		var dInputs = state["Players"][dState["Player"]]["Inputs"]
		
		if(HasFlag(dState, "Hitstun")):
			return hitconfirm
		
		# :TODO:Panthavma:20220204:Make "am i trying to defend" independant of physics, maybe an input
		var autoblocking = HasFlag(dState, "AutoBlocking")
		var blocking = dInputs["TrueBack"] or HasFlag(dState, "Blockstun") or autoblocking
		blocking = blocking and HasFlag(dState, "CanBlock")
		
		var lowBreak = HasFlag(attackData, "Low") and ((!autoblocking and !dInputs["Down"]) or (autoblocking and !HasFlag(dState, "AutoBlockingLow")))
		var highBreak = HasFlag(attackData, "Overhead") and ((!autoblocking and dInputs["Down"]) or (autoblocking and !HasFlag(dState, "AutoBlockingOverhead")))
		var groundUnblockableBreak = HasFlag(attackData, "GroundUnblockable") and HasFlag(dState, "PFGrounded")
		var airUnblockableBreak = HasFlag(attackData, "AirUnblockable") and HasFlag(dState, "PFAirborne")
		
		var isThrow = HasFlag(attackData, "Throw") or HasFlag(attackData, "Airthrow")
		var throwBreak = HasFlag(attackData, "Throw") and HasFlag(dState, "PFGrounded")
		var airthrowBreak = HasFlag(attackData, "Airthrow") and HasFlag(dState, "PFAirborne")
		var throwTech = HasFlag(attackData, "ThrowTech")
		
		if((blocking or isThrow) and !lowBreak and !highBreak and !groundUnblockableBreak and !airUnblockableBreak and !throwBreak and !airthrowBreak and !throwTech):
			return (Castagne.HITCONFIRMED.NONE if isThrow else Castagne.HITCONFIRMED.BLOCK)
	return hitconfirm



func OnAttackConfirmed(hitconfirm, attackData, _hurtboxData, aState, dState, state):
	# :TODO:Panthavma:20220214:Rework attack logic : one attack per entity. How to manage multiple hits on the same frame ?
	
	var hit = (hitconfirm == Castagne.HITCONFIRMED.HIT)
	var hitBlock = ("Hit" if hit else "Block")
	var attackFlags = attackData["Flags"]
	
	aState["AttackHitconfirm_State"] = hitBlock
	
	if(hit):
		var prorationDamage = Castagne.PRORATION_SCALE
		var prorationHitstun = Castagne.PRORATION_SCALE
		if(HasFlag(dState, "Hitstun")):
			prorationDamage = dState["ProrationDamage"]
			prorationHitstun = dState["ProrationHitstun"]
			dState["ProrationDamage"] *= attackData["ProrationDamage"]
			dState["ProrationHitstun"] *= attackData["ProrationHitstun"]
			dState["ProrationDamage"] /= Castagne.PRORATION_SCALE
			dState["ProrationHitstun"] /= Castagne.PRORATION_SCALE
		else:
			dState["ProrationDamage"] = attackData["StarterProrationDamage"]
			dState["ProrationHitstun"] = attackData["StarterProrationHitstun"]
		dState["HP"] -= (attackData["Damage"] * prorationDamage)/Castagne.PRORATION_SCALE
		dState["HitstunDuration"] = (attackData["Hitstun"] * prorationHitstun)/Castagne.PRORATION_SCALE
	else:
		dState["HP"] -= attackData["ChipDamage"]
		dState["BlockstunDuration"] = attackData["Blockstun"]
	
	if(HasFlag(dState, "PFGrounded")):
		dState["AttackMomentumH"] = aState["Facing"] * attackData[hitBlock+"MomentumH"]
		dState["AttackMomentumV"] = attackData[hitBlock+"MomentumV"]
	else:
		dState["AttackMomentumH"] = aState["Facing"] * attackData[hitBlock+"MomentumAirH"]
		dState["AttackMomentumV"] = attackData[hitBlock+"MomentumAirV"]
	
	# :TODO:Panthavma:20220216:Inherit momentum
	# :TODO:Panthavma:20220216:Rework hitstun/blockstun to account for ground/air
	
	
	# :TODO:Panthavma:20220216:Move to physics
	SetFlag(dState, "PF"+hitBlock)
	aState["AttackHitEntities"] += [dState["EID"]]
	
	state["Hitstop"] = attackData["Hitstop"]
	
	var flagPrefix = ("AF" if hit else "BF")
	for f in attackFlags:
		SetFlag(dState, flagPrefix+f)
	


























func Attack(args, eState, data):
	var damage = ArgInt(args, eState, 0)
	var recovery = ArgInt(args, eState, 1, eState["AttackDuration"])
	
	var attackData = _defaultAttackData.duplicate(true)
	attackData["Damage"] = damage
	eState["AttackDuration"] = recovery
	eState["AttackData"] = attackData
	if(eState["AttackInitialFrame"] < 0):
		eState["AttackInitialFrame"] = data["State"]["FrameID"] - eState["StateStartFrame"]
	EnrichDefaultAttack(eState, data)
func EnrichDefaultAttack(eState, _data):
	AttackFrameAdvantage([0], eState, _data)


func AttackDuration(args, eState, _data):
	eState["AttackDuration"] = ArgInt(args, eState, 0)


func AttackParam(args, eState, _data):
	var paramName = ArgStr(args, eState, 0)
	var value = ArgInt(args, eState, 1)
	
	eState["AttackData"][paramName] = value



func AttackFlag(args, eState, _data):
	var flagName = ArgStr(args, eState, 0)
	if(!flagName in eState["AttackData"]["Flags"]):
		eState["AttackData"]["Flags"] += [flagName]
func AttackUnflag(args, eState, _data):
	var flagName = ArgStr(args, eState, 0)
	if(flagName in eState["AttackData"]["Flags"]):
		eState["AttackData"]["Flags"].erase(flagName)



func AttackFrameAdvantage(args, eState, _data):
	var neutralFA = eState["AttackDuration"] - eState["AttackInitialFrame"]
	var hitFA = ArgInt(args, eState, 0)
	var blockFA = ArgInt(args, eState, 1, hitFA)
	eState["AttackData"]["Hitstun"] = neutralFA + hitFA
	eState["AttackData"]["Blockstun"] = neutralFA + blockFA
func AttackSetHitstunBlockstun(args, eState, _data):
	eState["AttackData"]["Hitstun"] = ArgInt(args, eState, 0)
	eState["AttackData"]["Blockstun"] = ArgInt(args, eState, 1)


func AttackProrationHitstun(args, eState, _data):
	eState["AttackData"]["StarterProrationHitstun"] = ArgInt(args, eState, 0)
	eState["AttackData"]["ProrationHitstun"] = ArgInt(args, eState, 1)
func AttackProrationDamage(args, eState, _data):
	eState["AttackData"]["StarterProrationDamage"] = ArgInt(args, eState, 0)
	eState["AttackData"]["ProrationDamage"] = ArgInt(args, eState, 1)


func AttackChipDamage(args, eState, _data):
	eState["AttackData"]["ChipDamage"] = ArgInt(args, eState, 0)
func AttackMinDamage(args, eState, _data):
	eState["AttackData"]["MinDamage"] = ArgInt(args, eState, 0)



func AttackMomentum(args, eState, data):
	AttackMomentumHit(args, eState, data)
	AttackMomentumBlock(args, eState, data)
func AttackMomentumHit(args, eState, _data):
	var mh = ArgInt(args, eState, 0)
	var mv = ArgInt(args, eState, 1, 0)
	eState["AttackData"]["HitMomentumH"] = mh
	eState["AttackData"]["HitMomentumV"] = mv
	eState["AttackData"]["HitMomentumAirH"] = ArgInt(args, eState, 2, mh)
	eState["AttackData"]["HitMomentumAirV"] = ArgInt(args, eState, 3, mv)
func AttackMomentumBlock(args, eState, _data):
	var mh = ArgInt(args, eState, 0)
	var mv = ArgInt(args, eState, 1, 0)
	eState["AttackData"]["BlockMomentumH"] = mh
	eState["AttackData"]["BlockMomentumV"] = mv
	eState["AttackData"]["BlockMomentumAirH"] = ArgInt(args, eState, 2, mh)
	eState["AttackData"]["BlockMomentumAirV"] = ArgInt(args, eState, 3, mv)



func AttackApplyCancels(args, eState, data):
	var prefix = ArgStr(args, eState, 0, "")
	
	var listToUse = "Neutral"
	if(HasFlag(eState, "Attacking")):
		listToUse = eState["AttackHitconfirm_State"]
		if(listToUse == null):
			return
	
	
	
	
	var alwaysAllowNeutralV = (prefix != "") # Prevents cancels to 5x when crouching
	
	# TODO Refactor ?
	var input = data["State"]["Players"][eState["Player"]]["Inputs"]
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
	
	if(input["DPress"]):
		attackButtons += ["D"]
	if(input["CPress"]):
		attackButtons += ["C"]
	if(input["BPress"]):
		attackButtons += ["B"]
	if(input["APress"]):
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
	
	
	for b in attackButtons:
		for d in directions:
			var notation = prefix + d + b
			# We ignore if already used
			if(eState["AttackDoneCancels"].has(notation)):
				continue
			# Check if it's in the current cancel list
			if(eState["AttackPossibleCancels" + listToUse].has(notation)
			and data["FighterScripts"][eState["FighterID"]].has(notation)):
				var attackName = eState["AttackPossibleCancels"+listToUse][notation]
				eState["AttackDoneCancels"] += [attackName]
				CallFunction("Transition", [attackName, 100], eState, data)
				return
func AttackResetDoneCancels(_args, eState, _data):
	eState["AttackDoneCancels"] = []


func AttackCancelOnWhiff(args, eState, _data):
	_AttackCancelRegister(args, eState, ["Whiff"])
func AttackCancelOnBlock(args, eState, _data):
	_AttackCancelRegister(args, eState, ["Block"])
func AttackCancelOnHit(args, eState, _data):
	_AttackCancelRegister(args, eState, ["Hit"])
func AttackCancelOnTouch(args, eState, _data):
	_AttackCancelRegister(args, eState, ["Block", "Hit"])
func AttackCancelOnWhiffOrTouch(args, eState, _data):
	_AttackCancelRegister(args, eState, ["Whiff", "Block", "Hit"])
func AttackCancelNeutral(args, eState, _data):
	_AttackCancelRegister(args, eState, ["Neutral"])
func AttackCancelOnTouchAndNeutral(args, eState, _data):
	_AttackCancelRegister(args, eState, ["Block", "Hit", "Neutral"])
func _AttackCancelRegister(args, eState, lists):
	var notation = ArgStr(args, eState, 0)
	var attackName = ArgStr(args, eState, 1, notation)
	for l in lists:
		eState["AttackPossibleCancels"+l][notation] = attackName

func AttackAddAllCancelsOnWhiff(args, eState, _data):
	_AttackAllCancelRegister(args, eState, ["Whiff"])
func AttackAddAllCancelsOnBlock(args, eState, _data):
	_AttackAllCancelRegister(args, eState, ["Block"])
func AttackAddAllCancelsOnHit(args, eState, _data):
	_AttackAllCancelRegister(args, eState, ["Hit"])
func AttackAddAllCancelsOnTouch(args, eState, _data):
	_AttackAllCancelRegister(args, eState, ["Block", "Hit"])
func AttackAddAllCancelsOnWhiffOrTouch(args, eState, _data):
	_AttackAllCancelRegister(args, eState, ["Whiff", "Block", "Hit"])
func AttackAddAllCancelsNeutral(args, eState, _data):
	_AttackAllCancelRegister(args, eState, ["Neutral"])
func AttackAddAllCancelsOnTouchAndNeutral(args, eState, _data):
	_AttackAllCancelRegister(args, eState, ["Block", "Hit", "Neutral"])
func _AttackAllCancelRegister(args, eState, lists):
	var button = ArgStr(args, eState, 0)
	var prefix = ArgStr(args, eState, 1, "")
	for l in lists:
		for i in range(1, 10):
			var notation = prefix+str(i)+button
			eState["AttackPossibleCancels"+l][notation] = notation
