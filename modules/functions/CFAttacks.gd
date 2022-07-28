extends "../CastagneModule.gd"

func ModuleSetup():
	# :TODO:Panthavma:20211230:Hitstop
	
	RegisterModule("CF Attacks")
	RegisterCategory("Attacks")
	RegisterFunction("Attack", [1,2], null, {
		"Description":"Initiates an attack with default parameters. This should be the first function called for a new attack, then you use other Attack functions to customize it, and finally you use Hitbox to apply it.",
		"Arguments":["Damage", "(Optional) Total frames (must be specified at the first attack at least)"],
		"Flags":["Basic"],
		"Types":["int", "int"],
	})
	RegisterFunction("AttackDuration", [1], null, {
		"Description":"Changes the total duration of the attack. Can replace Attack's second parameter but must be called before it.",
		"Arguments":["Total frames"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackRearm", [0], null, {
		"Description":"Sets the variables to be able to hit with another attack, and should be used between multihits. Resets the hit detection.",
		"Flags":["Medium"],
		"Types":[],
	})
	RegisterFunction("AttackParam", [2], null, {
		"Description":"Sets a generic attack parameter directly. This is an advanced function and should be used either when you need some really specific adjustment, or when you want to add functionality without a module.",
		"Arguments":["Parameter name", "Parameter value"],
		"Flags":["Advanced"],
		"Types":["str","int"],
	})
	
	
	
	RegisterFunction("AttackFlag", [1], null, {
		"Description":"Sets a flag on the attack. All flags are transfered to the hit opponent with the AF prefix (meaning Low become AFLow), and are used by modules during attack checking. See the list of flags for more information.",
		"Arguments":["Flag name"],
		"Flags":["Basic"],
		"Types":["str",],
	})
	RegisterFunction("AttackUnflag", [1], null, {
		"Description":"Removes a flag from an attack.",
		"Arguments":["Flag name"],
		"Types":["str",],
	})
	RegisterFunction("AttackRecievedFlag", [1], null, {
		"Description":"Set an attack flag as if the entity recieved an attack having this flag.",
		"Arguments":["Flag name"],
		"Flags":["Advanced"],
		"Types":["str",],
	})
	RegisterFunction("AttackRecievedUnflag", [1], null, {
		"Description":"Removes an attack flag from a recieved attack.",
		"Arguments":["Flag name"],
		"Flags":["Advanced"],
		"Types":["str",],
	})
	
	RegisterFunction("AttackAttribute", [0, 1], null, {
		"Description":"Sets an attack's attribute. This is used by the Invul-[Attrib] and Guard-[Attrib] family of flags. The Auto attribute will choose an attribute between Air, Mid, High, Low, Throw, and AirThrow depending on the attacker's state.",
		"Arguments":["Attribute. Default: Auto"],
		"Types":["str",],
	})
	
	
	RegisterFunction("AttackFrameAdvantage", [1,2], null, {
		"Description":"Sets an attack's frame advantage automatically on hit and block. This is based on the total duration of the attack and the last use of the multihit flag. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit", "Frame advantage on block"],
		"Flags":["Basic"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackFrameAdvantageHit", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on hit. This is based on the total duration of the attack and the last use of the multihit flag. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackFrameAdvantageBlock", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on block. This is based on the total duration of the attack and the last use of the multihit flag. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on block"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackHitstunBlockstun", [2], null, {
		"Description":"Sets an attack's hitstun and blockstun. Same functionality as AttackFrameAdvantage, but in a more direct way.",
		"Arguments":["Hitstun", "Blockstun"],
		"Flags":["Basic"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackHitstun", [1], null, {
		"Description":"Sets an attack's hitstun. Same functionality as AttackFrameAdvantage, but in a more direct way.",
		"Arguments":["Hitstun"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackBlockstun", [1], null, {
		"Description":"Sets an attack's blockstun. Same functionality as AttackFrameAdvantage, but in a more direct way.",
		"Arguments":["Blockstun"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	
	
	
	RegisterFunction("AttackProrationHitstun", [2], null, {
		"Description":"Sets an attack's proration for hitstun. The lower it is, the more hitstun will decay with each hit. Values are in permil.",
		"Arguments":["First hit proration (used instead of proration for the first hit)", "Subsequent hit proration"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackProrationDamage", [2], null, {
		"Description":"Sets an attack's proration for damage. The lower it is, the more damage will decay with each hit. Values are in permil.",
		"Arguments":["First hit proration (used instead of proration for the first hit)", "Subsequent hit proration"],
		"Types":["int","int"],
	})
	
	
	RegisterFunction("AttackChipDamage", [1], null, {
		"Description":"Sets an attack's chip damage, the damage that gets inflicted when an opponent blocks.",
		"Arguments":["The amount of chip damage"],
		"Types":["int",],
	})
	RegisterFunction("AttackMinDamage", [1], null, {
		"Description":"Sets an attack's minimum damage.",
		"Arguments":["The minimum amount of damage"],
		"Types":["int",],
	})
	
	
	
	RegisterFunction("AttackMomentum", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on hit and block.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
		"Types":["int","int","int","int"],
	})
	RegisterFunction("AttackMomentumHit", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on hit.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
		"Types":["int","int","int","int"],
	})
	RegisterFunction("AttackMomentumBlock", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on block.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
		"Types":["int","int","int","int"],
	})
	RegisterFunction("AttackFloat", [1], null, {
		"Description":"Sets the opponent's gravity on hit to the specified value until the next attack.",
		"Arguments":["New Gravity"],
		"Types":["int",],
	})
	
	
	RegisterFunction("AttackKnockdown", [0,1,2], null, {
		"Description":"Sets an attack's minimum and maximum time on knockdown. Automatically applies the knockdown attack flag. If no arguments are given, use default values. If only one is given, the second is computed automatically from the difference between defaults.",
		"Arguments":["(Optional) The minimum knockdown time", "(Optional) Maximum knockdown time"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackGroundbounce", [1,2,3], null, {
		"Description":"Sets an attack's groundbounce",
		"Arguments":["Groundbounce time", "Groundbounce Momentum", "(Optional) Maximum ground bounces"],
		"Types":["int","int","int"],
	})
	# :TODO:Panthavma:20220331:Return to neutral callback?
	# :TODO:Panthavma:20220331:Wallbounce
	# :TODO:Panthavma:20220331:Attack flag and attack variable register functions
	# :TODO:Panthavma:20220331:Attack attacker pushback (and pushed when next to the wall)
	
	
	
	
	
	RegisterVariableEntity("AttackData", {}, ["ResetEachFrame"])
	RegisterVariableEntity("AttackDuration", 600)
	RegisterVariableEntity("AttackHitEntities", [])
	RegisterVariableEntity("HitstunDuration", 0)
	RegisterVariableEntity("BlockstunDuration", 0)
	RegisterVariableEntity("ProrationHitstun", 1000)
	RegisterVariableEntity("ProrationDamage", 1000)
	RegisterVariableEntity("KnockdownTimeMin", 13)
	RegisterVariableEntity("KnockdownTimeMax", 43)
	RegisterVariableEntity("GroundbounceTime", 0)
	RegisterVariableEntity("GroundbounceMomentum", 0)
	RegisterVariableEntity("Groundbounces", 0)
	RegisterConfig("Attack-ThrowInHitstun", false)
	RegisterConfig("Attack-ThrowInBlockstun", false)
	
	RegisterFlag("Multihit", {"Description":"Allow an attack to hit again."})
	RegisterFlag("AFLow", {"Description":"Makes an attack unblockable while standing up."})
	RegisterFlag("AFOverhead", {"Description":"Makes an attack unblockable while crouching."})
	RegisterFlag("AFInheritMomentum", {"Description":"Makes it so that the attack inherits the attacker's momentum."})
	RegisterFlag("AFFloat", {"Description":"Set by the AttackFloat function. Tells the opponent to override the usual gravity for the next hit."})
	
	RegisterFlag("Invul-All", {"Description":"Can't by hit by any attacks, they will count as whiffed."})
	RegisterFlag("Invul-Air")
	RegisterFlag("Invul-High")
	RegisterFlag("Invul-Mid")
	RegisterFlag("Invul-Low")
	RegisterFlag("Invul-Throw")
	RegisterFlag("Invul-AirThrow")
	RegisterFlag("Invul-Projectile")
	RegisterFlag("Guard-All", {"Description":"Can't by hit by any attacks, they will count as blocked."})
	RegisterFlag("Guard-Air")
	RegisterFlag("Guard-High")
	RegisterFlag("Guard-Mid")
	RegisterFlag("Guard-Low")
	RegisterFlag("Guard-Throw")
	RegisterFlag("Guard-AirThrow")
	RegisterFlag("Guard-Projectile")
	RegisterFlag("Invuled")
	RegisterFlag("Guarded")
	
	
	
	
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
	RegisterFunction("AttackCancelOnTouchAndWhiff", [1,2], null, {
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
	RegisterFunction("AttackAddAllCancelsOnTouchAndWhiff", [1,2], null, {
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
	RegisterVariableEntity("LastAttackFlags", [], null, {"Description":"Stores the attack flags of the last attack recieved."})
	
	RegisterCategory("Default Attack Params")
	RegisterConfig("AttackDefault-ProrationDamage", 700)
	RegisterConfig("AttackDefault-StarterProrationDamage", 950)
	RegisterConfig("AttackDefault-ProrationHitstun", 900)
	RegisterConfig("AttackDefault-StarterProrationHitstun", 950)
	RegisterConfig("AttackDefault-Hitstop", 4)
	RegisterConfig("AttackDefault-Blockstop", 2)
	RegisterConfig("AttackDefault-KnockdownTimeMin", 13)
	RegisterConfig("AttackDefault-KnockdownTimeMax", 43)
	RegisterConfig("AttackDefault-GroundbounceTime", 30)
	RegisterConfig("AttackDefault-GroundbounceMomentum", 1000)
	RegisterConfig("AttackDefault-MaxGroundbounces", 3)
	RegisterConfig("AttackDefault-FloatGravity", 0)

var _defaultAttackData = {}
var _knockdownDefaultTimeDiff = 0
func BattleInit(_state, _data, _battleInitData):
	_defaultAttackData = {
		"Damage": 100, "MinDamage": 1,
		"Hitstun": 20, "Blockstun": 20,
		
		"ChipDamage": 0,
		
		"MetergainHit": 6, "MetergainBlock":0,
		"MetergainFoeHit": 0, "MetergainFoeBlock":0,
		
		"HitMomentumX":1000, "HitMomentumY":0,
		"HitMomentumAirX":1000, "HitMomentumAirY":200,
		"BlockMomentumX":1000, "BlockMomentumY":0,
		"BlockMomentumAirX":1000, "BlockMomentumAirY":0,
		
		"Flags":[], "Attribute":"Auto",
	}
	
	# Take variables from the config stating with AttackDefault
	var configDerivedDataPrefix = "AttackDefault-"
	for configKeyName in configDefault:
		if(configKeyName.begins_with(configDerivedDataPrefix)):
			var attackDataName = configKeyName.right(configDerivedDataPrefix.length())
			_defaultAttackData[attackDataName] = Castagne.configData[configKeyName]
	
	_knockdownDefaultTimeDiff = max(0, Castagne.configData["AttackDefault-KnockdownTimeMax"] - Castagne.configData["AttackDefault-KnockdownTimeMin"])

func ActionPhaseStartEntity(eState, _data):
	for af in eState["LastAttackFlags"]:
		SetFlag(eState, "AF"+af)

func ActionPhaseEndEntity(eState, _data):
	if(HasFlag(eState, "Multihit")):
		AttackRearm(null, eState, _data)

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














# :TODO:Panthavma:20220413:Separate it in smaller functions for easier custom?
func IsAttackConfirmed(hitconfirm, attackData, _hurtboxData, aState, dState, state):
	if(hitconfirm == Castagne.HITCONFIRMED.HIT):
		if(aState["AttackHitEntities"].has(dState["EID"])):
			return Castagne.HITCONFIRMED.NONE
		var dInputs = state["Players"][dState["Player"]]["Inputs"]
		
		# :TODO:Panthavma:20220204:Make "am i trying to defend" independant of physics, maybe an input
		var inBlockstun = HasFlag(dState, "Blockstun")
		var inHitstun = HasFlag(dState, "Hitstun")
		
		var autoblocking = HasFlag(dState, "AutoBlocking")
		var blocking = dInputs["TrueBack"] or inBlockstun or autoblocking
		blocking = blocking and HasFlag(dState, "CanBlock")
		
		var airborne = HasFlag(dState, "PFAirborne")
		
		var lowBreak = HasFlag(attackData, "Low") and ((!autoblocking and !dInputs["Down"]) or (autoblocking and !HasFlag(dState, "AutoBlockingLow")))
		var highBreak = HasFlag(attackData, "Overhead") and ((!autoblocking and dInputs["Down"]) or (autoblocking and !HasFlag(dState, "AutoBlockingOverhead")))
		var groundUnblockableBreak = HasFlag(attackData, "GroundUnblockable") and !airborne
		var airUnblockableBreak = HasFlag(attackData, "AirUnblockable") and airborne
		
		var attribute = attackData["Attribute"]
		if(attribute == "Auto"):
			attribute = AttributeAuto(hitconfirm, attackData, _hurtboxData, aState, dState, state)
		var attributeAttack = attribute in ["Mid", "Low", "High", "Air"] # :TODO:Panthavama:20220413:Make it customizable
		var guarding = HasFlag(dState, "Guard-"+attribute) or HasFlag(dState, "Guard-All") or (attributeAttack and HasFlag(dState, "Guard-Attack"))
		var invuling = HasFlag(dState, "Invul-"+attribute) or HasFlag(dState, "Invul-All") or (attributeAttack and HasFlag(dState, "Invul-Attack"))
		if(guarding):
			SetFlag(dState, "Guarded")
			SetFlag(attackData, "Guarded")
		if(invuling):
			SetFlag(dState, "Invuled")
		
		
		var isThrow = HasFlag(attackData, "Throw")
		var blockBreak = (lowBreak or highBreak or groundUnblockableBreak or airUnblockableBreak)
		blockBreak = blockBreak and !invuling and !guarding
		var phaseAttack = isThrow or invuling
		
		if(isThrow and
			((inBlockstun and !Castagne.configData["Attack-ThrowInBlockstun"]) or
			 (inHitstun and !Castagne.configData["Attack-ThrowInHitstun"]))):
			blockBreak = false
		
		if((blocking or isThrow or guarding or invuling) and !blockBreak):
			return (Castagne.HITCONFIRMED.NONE if phaseAttack else Castagne.HITCONFIRMED.BLOCK)
	return hitconfirm

func AttributeAuto(hitconfirm, attackData, _hurtboxData, aState, dState, state):
	if(HasFlag(aState, "PFAirborne")):
		if(HasFlag(attackData, "Throw")):
			return "AirThrow"
		else:
			return "Air"
	else:
		if(HasFlag(attackData, "Throw")):
			return "Throw"
		elif(HasFlag(attackData, "Overhead")):
			return "High"
		elif(HasFlag(attackData, "Low")):
			return "Low"
		else:
			return "Mid"



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
		dState["HitstunDuration"] = max(1,(attackData["Hitstun"] * prorationHitstun)/Castagne.PRORATION_SCALE)
	else:
		dState["HP"] -= attackData["ChipDamage"]
		dState["BlockstunDuration"] = max(1,attackData["Blockstun"])
	
	if(HasFlag(dState, "PFGrounded")):
		dState["AttackMomentumX"] = aState["Facing"] * attackData[hitBlock+"MomentumX"]
		dState["AttackMomentumY"] = attackData[hitBlock+"MomentumY"]
	else:
		dState["AttackMomentumX"] = aState["Facing"] * attackData[hitBlock+"MomentumAirX"]
		dState["AttackMomentumY"] = attackData[hitBlock+"MomentumAirY"]
	
	if(HasFlag(attackData, "InheritMomentum")):
		dState["AttackMomentumX"] += aState["MomentumX"]
		dState["AttackMomentumY"] += aState["MomentumY"]
	
	if(HasFlag(attackData, "Float")):
		dState["HitstunGravityFloat"] = attackData["FloatGravity"]
	
	
	# Apply specific attack states
	dState["KnockdownTimeMin"] = attackData["KnockdownTimeMin"]
	dState["KnockdownTimeMax"] = attackData["KnockdownTimeMax"]
	if(attackFlags.has("Groundbounce")):
		if(dState["Groundbounces"] < attackData["MaxGroundbounces"]):
			dState["Groundbounces"] += 1
			dState["GroundbounceTime"] = attackData["GroundbounceTime"]
			dState["GroundbounceMomentum"] = attackData["GroundbounceMomentum"]
			attackFlags += ["AnimGroundbounce"]
		else:
			attackFlags.erase("Groundbounce")
	
	state["FreezeFrames"] = max(state["FreezeFrames"], attackData[hitBlock+"stop"])
	
	# :TODO:Panthavma:20220216:Move to physics
	SetFlag(dState, "PF"+hitBlock)
	SetFlag(dState, "PFTouched")
	aState["AttackHitEntities"] += [dState["EID"]]
	
	var flagPrefix = "AF"
	for laf in dState["LastAttackFlags"]:
		UnsetFlag(dState, flagPrefix+laf)
	dState["LastAttackFlags"] = attackFlags
	for f in attackFlags:
		SetFlag(dState, flagPrefix+f)
	


























func Attack(args, eState, data):
	var damage = ArgInt(args, eState, 0)
	var recovery = ArgInt(args, eState, 1, eState["AttackDuration"])
	
	var attackData = _defaultAttackData.duplicate(true)
	attackData["Damage"] = damage
	attackData["MinDamage"] = min(attackData["MinDamage"], damage)
	eState["AttackDuration"] = recovery
	eState["AttackData"] = attackData
	if(eState["AttackInitialFrame"] < 0):
		eState["AttackInitialFrame"] = data["State"]["FrameID"] - eState["StateStartFrame"]
	EnrichDefaultAttack(eState, data)
func EnrichDefaultAttack(eState, _data):
	AttackFrameAdvantage([0], eState, _data)


func AttackDuration(args, eState, _data):
	eState["AttackDuration"] = ArgInt(args, eState, 0)

func AttackRearm(_args, eState, _data):
	eState["AttackHitconfirm_State"] = null
	eState["AttackInitialFrame"] = -1
	eState["AttackHitEntities"] = []
	eState["AttackHasHit"] = false
	eState["AttackWasBlocked"] = false
	eState["AttackHasWhiffed"] = false
	eState["AttackHasTouched"] = false

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
func AttackRecievedFlag(args, eState, _data):
	var flagName = ArgStr(args, eState, 0)
	if(!flagName in eState["LastAttackFlags"]):
		eState["LastAttackFlags"] += [flagName]
		SetFlag(eState, "AF"+flagName)
func AttackRecievedUnflag(args, eState, _data):
	var flagName = ArgStr(args, eState, 0)
	if(flagName in eState["LastAttackFlags"]):
		eState["LastAttackFlags"].erase(flagName)
		UnsetFlag(eState, "AF"+flagName)



func AttackFrameAdvantage(args, eState, _data):
	var hitFA = ArgInt(args, eState, 0)
	#if(hitFA == null):
	#	return ModuleError("AttackFrameAdvantage: hitFA is null")
		# TODO: does it need this everywhere ? should add static code analysis?
	var blockFA = ArgInt(args, eState, 1, hitFA)
	_AttackFrameAdvantage(hitFA, eState, "Hitstun")
	_AttackFrameAdvantage(blockFA, eState, "Blockstun")
func AttackFrameAdvantageHit(args, eState, _data):
	_AttackFrameAdvantage(ArgInt(args, eState, 0), eState, "Hitstun")
func AttackFrameAdvantageBlock(args, eState, _data):
	_AttackFrameAdvantage(ArgInt(args, eState, 0), eState, "Blockstun")
func _AttackFrameAdvantage(FA, eState, stunType):
	var neutralFA = eState["AttackDuration"] - eState["AttackInitialFrame"]
	eState["AttackData"][stunType] = max(neutralFA + FA, 1)
func AttackHitstunBlockstun(args, eState, _data):
	eState["AttackData"]["Hitstun"] = max(ArgInt(args, eState, 0),1)
	eState["AttackData"]["Blockstun"] = max(ArgInt(args, eState, 1),1)
func AttackHitstun(args, eState, _data):
	eState["AttackData"]["Hitstun"] = max(ArgInt(args, eState, 0),1)
func AttackBlockstun(args, eState, _data):
	eState["AttackData"]["Blockstun"] = max(ArgInt(args, eState, 0),1)


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
	eState["AttackData"]["HitMomentumX"] = mh
	eState["AttackData"]["HitMomentumY"] = mv
	eState["AttackData"]["HitMomentumAirX"] = ArgInt(args, eState, 2, mh)
	eState["AttackData"]["HitMomentumAirY"] = ArgInt(args, eState, 3, mv)
func AttackMomentumBlock(args, eState, _data):
	var mh = ArgInt(args, eState, 0)
	var mv = ArgInt(args, eState, 1, 0)
	eState["AttackData"]["BlockMomentumX"] = mh
	eState["AttackData"]["BlockMomentumY"] = mv
	eState["AttackData"]["BlockMomentumAirX"] = ArgInt(args, eState, 2, mh)
	eState["AttackData"]["BlockMomentumAirY"] = ArgInt(args, eState, 3, mv)
func AttackFloat(args, eState, data):
	eState["AttackData"]["FloatGravity"] = -ArgInt(args, eState, 0)
	AttackFlag(["Float"], eState, data)

func AttackKnockdown(args, eState, _data):
	AttackFlag(["Knockdown"], eState, _data)
	var kdMin = Castagne.configData["AttackDefault-KnockdownTimeMin"]
	var kdMax = Castagne.configData["AttackDefault-KnockdownTimeMax"]
	
	if(args.size() >= 1):
		kdMin = max(1, ArgInt(args, eState, 0, kdMin))
		kdMax = max(kdMin, ArgInt(args, eState, 1, kdMin+_knockdownDefaultTimeDiff))
	
	eState["AttackData"]["KnockdownTimeMin"] = kdMin
	eState["AttackData"]["KnockdownTimeMin"] = kdMax

func AttackGroundbounce(args, eState, _data):
	AttackFlag(["Groundbounce"], eState, _data)
	eState["AttackData"]["GroundbounceTime"] = ArgInt(args, eState, 0, Castagne.configData["AttackDefault-GroundbounceTime"])
	eState["AttackData"]["GroundbounceMomentum"] = ArgInt(args, eState, 1, Castagne.configData["AttackDefault-GroundbounceMomentum"])
	eState["AttackData"]["MaxGroundbounces"] = ArgInt(args, eState, 2, Castagne.configData["AttackDefault-MaxGroundbounces"])
	





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
			# Check if the input is in the current cancel list
			if(eState["AttackPossibleCancels" + listToUse].has(notation)):
				var attackName = eState["AttackPossibleCancels"+listToUse][notation]
				
				# We ignore if the attack has already used and that it exists
				if(eState["AttackDoneCancels"].has(attackName)
					or !data["FighterScripts"][eState["FighterID"]].has(attackName)):
					continue
				
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
func AttackCancelOnTouchAndWhiff(args, eState, _data):
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
func AttackAddAllCancelsOnTouchAndWhiff(args, eState, _data):
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
