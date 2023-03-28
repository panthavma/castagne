extends "../CastagneModule.gd"

func ModuleSetup():
	# :TODO:Panthavma:20211230:Hitstop
	
	RegisterModule("Attacks", null, {"Description":"Specialized module to help with making attacks and combat systems."})
	RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Attacks.casp", -5000)
	
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
	
	
	
	
	
	RegisterVariableEntity("_AttackData", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackDuration", 600)
	RegisterVariableEntity("_AttackHitEntities", [])
	RegisterVariableEntity("_HitstunDuration", 0)
	RegisterVariableEntity("_BlockstunDuration", 0)
	RegisterVariableEntity("_ProrationHitstun", 1000)
	RegisterVariableEntity("_ProrationDamage", 1000)
	RegisterVariableEntity("_KnockdownTimeMin", 13)
	RegisterVariableEntity("_KnockdownTimeMax", 43)
	RegisterVariableEntity("_GroundbounceTime", 0)
	RegisterVariableEntity("_GroundbounceMomentum", 0)
	RegisterVariableEntity("_Groundbounces", 0)
	RegisterConfig("Attack-ThrowInHitstun", false)
	RegisterConfig("Attack-ThrowInBlockstun", false)
	
	
	RegisterVariableEntity("_AttackMomentumX", 0)
	RegisterVariableEntity("_AttackMomentumY", 0)
	
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
	
	RegisterStateFlag("Attack")
	RegisterStateFlag("AttackLow")
	RegisterStateFlag("AttackOverhead")
	
	
	RegisterCategory("Attack Cancels")
	
	RegisterFunction("AttackApplyCancels", [0,1], ["Reaction"], {
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
	
	RegisterVariableEntity("_AttackInitialFrame", -1)
	RegisterVariableEntity("_AttackHitconfirm_State", null)
	RegisterVariableEntity("_AttackDoneCancels", [])
	RegisterVariableEntity("_AttackPossibleCancelsWhiff", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsBlock", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsHit", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsNeutral", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackHasHit", false)
	RegisterVariableEntity("_AttackWasBlocked", false) 
	RegisterVariableEntity("_AttackHasWhiffed", false)
	RegisterVariableEntity("_AttackHasTouched", false)
	RegisterVariableEntity("_LastAttackFlags", [], null, {"Description":"Stores the attack flags of the last attack recieved."})
	
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
func BattleInit(stateHandle, _battleInitData):
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
			_defaultAttackData[attackDataName] = stateHandle.ConfigData().Get(configKeyName)
	
	_knockdownDefaultTimeDiff = max(0, stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMax") - stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMin"))

func ActionPhaseStartEntity(stateHandle):
	for af in stateHandle.EntityGet("_LastAttackFlags"):
		stateHandle.EntitySetFlag("AF"+af)

func ActionPhaseEndEntity(stateHandle):
	if(stateHandle.EntityHasFlag("Multihit")):
		AttackRearm(null, stateHandle)

func PhysicsPhaseEndEntity(stateHandle):
	# :TODO:Panthavma:20220314:Optim: Maybe replace the string check by a int
	var hitconfirmState = stateHandle.EntityGet("_AttackHitconfirm_State")
	if(stateHandle.EntityGet("_Hitboxes").size() > 0 and hitconfirmState == null):
		stateHandle.EntitySet("_AttackHitconfirm_State", "Whiff")
	if(hitconfirmState != null):
		stateHandle.EntitySet("_AttackHasHit", (hitconfirmState == "Hit"))
		stateHandle.EntitySet("_AttackWasBlocked", (hitconfirmState == "Block"))
		stateHandle.EntitySet("_AttackHasWhiffed", (hitconfirmState == "Whiff"))
		stateHandle.EntitySet("_AttackHasTouched", (stateHandle.EntityGet("_AttackHasHit") or stateHandle.EntityGet("_AttackWasBlocked")))














# :TODO:Panthavma:20220413:Separate it in smaller functions for easier custom?
func IsAttackConfirmed(hitconfirm, attackData, _hurtboxData, attackerHandle, defenderHandle):
	if(hitconfirm == Castagne.HITCONFIRMED.HIT):
		if(attackerHandle.EntityGet("_AttackHitEntities").has(defenderHandle.EntityGet("_EID"))):
			return Castagne.HITCONFIRMED.NONE
		var dInputs = defenderHandle.PlayerGet("Inputs")
		
		# :TODO:Panthavma:20220204:Make "am i trying to defend" independant of physics, maybe an input
		var inBlockstun = defenderHandle.EntityHasFlag("Blockstun")
		var inHitstun = defenderHandle.EntityHasFlag("Hitstun")
		
		var autoblocking = defenderHandle.EntityHasFlag("AutoBlocking")
		var blocking = dInputs["TrueBack"] or inBlockstun or autoblocking
		blocking = blocking and defenderHandle.EntityHasFlag("CanBlock")
		
		var airborne = defenderHandle.EntityHasFlag("PFAirborne")
		
		var lowBreak = HasFlag(attackData, "Low") and ((!autoblocking and !dInputs["Down"]) or (autoblocking and !defenderHandle.EntityHasFlag("AutoBlockingLow")))
		var highBreak = HasFlag(attackData, "Overhead") and ((!autoblocking and dInputs["Down"]) or (autoblocking and !defenderHandle.EntityHasFlag("AutoBlockingOverhead")))
		var groundUnblockableBreak = HasFlag(attackData, "GroundUnblockable") and !airborne
		var airUnblockableBreak = HasFlag(attackData, "AirUnblockable") and airborne
		
		var attribute = attackData["Attribute"]
		if(attribute == "Auto"):
			attribute = AttributeAuto(hitconfirm, attackData, _hurtboxData, attackerHandle, defenderHandle)
		var attributeAttack = attribute in ["Mid", "Low", "High", "Air"] # :TODO:Panthavama:20220413:Make it customizable
		var guarding = defenderHandle.EntityHasFlag("Guard-"+attribute) or defenderHandle.EntityHasFlag("Guard-All") or (attributeAttack and defenderHandle.EntityHasFlag("Guard-Attack"))
		var invuling = defenderHandle.EntityHasFlag("Invul-"+attribute) or defenderHandle.EntityHasFlag("Invul-All") or (attributeAttack and defenderHandle.EntityHasFlag("Invul-Attack"))
		if(guarding):
			defenderHandle.EntitySetFlag("Guarded")
			SetFlag(attackData, "Guarded")
		if(invuling):
			defenderHandle.EntitySetFlag("Invuled")
		
		
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

func AttributeAuto(_hitconfirm, attackData, _hurtboxData, attackerHandle, _defenderHandle):
	if(attackerHandle.EntityHasFlag("PFAirborne")):
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



func OnAttackConfirmed(hitconfirm, attackData, _hurtboxData, attackerHandle, defenderHandle):
	# :TODO:Panthavma:20220214:Rework attack logic : one attack per entity. How to manage multiple hits on the same frame ?
	
	var hit = (hitconfirm == Castagne.HITCONFIRMED.HIT)
	var hitBlock = ("Hit" if hit else "Block")
	var attackFlags = attackData["Flags"]
	
	attackerHandle.EntitySet("_AttackHitconfirm_State", hitBlock)
	
	if(hit):
		var prorationDamage = Castagne.PRORATION_SCALE
		var prorationHitstun = Castagne.PRORATION_SCALE
		if(defenderHandle.EntityHasFlag("Hitstun")):
			prorationDamage = defenderHandle.EntityGet("_ProrationDamage")
			prorationHitstun = defenderHandle.EntityGet("_ProrationHitstun")
			defenderHandle.EntitySet("_ProrationDamage", defenderHandle.EntityGet("_ProrationDamage") * attackData["ProrationDamage"])
			defenderHandle.EntitySet("_ProrationHitstun", defenderHandle.EntityGet("_ProrationHitstun") * attackData["ProrationHitstun"])
			defenderHandle.EntitySet("_ProrationDamage", defenderHandle.EntityGet("_ProrationDamage") / Castagne.PRORATION_SCALE)
			defenderHandle.EntitySet("_ProrationHitstun", defenderHandle.EntityGet("_ProrationHitstun") / Castagne.PRORATION_SCALE)
		else:
			defenderHandle.EntitySet("_ProrationDamage", attackData["StarterProrationDamage"])
			defenderHandle.EntitySet("_ProrationHitstun", attackData["StarterProrationHitstun"])
		defenderHandle.EntityAdd("HP", -(attackData["Damage"] * prorationDamage)/Castagne.PRORATION_SCALE)
		defenderHandle.EntitySet("_HitstunDuration", max(1,(attackData["Hitstun"] * prorationHitstun)/Castagne.PRORATION_SCALE))
	else:
		defenderHandle.EntityAdd("HP", -attackData["ChipDamage"])
		defenderHandle.EntitySet("_BlockstunDuration", max(1,attackData["Blockstun"]))
	
	if(defenderHandle.EntityHasFlag("PFGrounded")):
		defenderHandle.EntitySet("_AttackMomentumX", attackerHandle.EntityGet("_Facing") * attackData[hitBlock+"MomentumX"])
		defenderHandle.EntitySet("_AttackMomentumY", attackData[hitBlock+"MomentumY"])
	else:
		defenderHandle.EntitySet("_AttackMomentumX", attackerHandle.EntityGet("_Facing") * attackData[hitBlock+"MomentumAirX"])
		defenderHandle.EntitySet("_AttackMomentumY", attackData[hitBlock+"MomentumAirY"])
	
	if(HasFlag(attackData, "InheritMomentum")):
		defenderHandle.EntityAdd("AttackMomentumX", attackerHandle.EntityGet("_MomentumX"))
		defenderHandle.EntityAdd("AttackMomentumY", attackerHandle.EntityGet("_MomentumY"))
	
	if(HasFlag(attackData, "Float")):
		defenderHandle.EntitySet("_HitstunGravityFloat", attackData["FloatGravity"])
	
	
	# Apply specific attack states
	defenderHandle.EntitySet("_KnockdownTimeMin", attackData["KnockdownTimeMin"])
	defenderHandle.EntitySet("_KnockdownTimeMax", attackData["KnockdownTimeMax"])
	if(attackFlags.has("Groundbounce")):
		if(defenderHandle.EntityGet("_Groundbounces") < attackData["MaxGroundbounces"]):
			defenderHandle.EntityAdd("Groundbounces", 1)
			defenderHandle.EntitySet("_GroundbounceTime", attackData["GroundbounceTime"])
			defenderHandle.EntitySet("_GroundbounceMomentum", attackData["GroundbounceMomentum"])
			attackFlags += ["AnimGroundbounce"]
		else:
			attackFlags.erase("Groundbounce")
	
	defenderHandle.GlobalSet("_FreezeFrames", max(defenderHandle.GlobalGet("_FreezeFrames"), attackData[hitBlock+"stop"]))
	
	# :TODO:Panthavma:20220216:Move to physics
	defenderHandle.EntitySetFlag("PF"+hitBlock)
	defenderHandle.EntitySetFlag("PFTouched")
	attackerHandle.EntityAdd("AttackHitEntities", [defenderHandle.EntityGet("_EID")])
	
	var flagPrefix = "AF"
	for laf in defenderHandle.EntityGet("_LastAttackFlags"):
		defenderHandle.EntitySetFlag(flagPrefix+laf, false)
	defenderHandle.EntitySet("_LastAttackFlags", attackFlags)
	for f in attackFlags:
		defenderHandle.EntitySetFlag(flagPrefix+f)
	


























func Attack(args, stateHandle):
	var damage = ArgInt(args, stateHandle, 0)
	var recovery = ArgInt(args, stateHandle, 1, stateHandle.EntityGet("_AttackDuration"))
	
	var attackData = _defaultAttackData.duplicate(true)
	attackData["Damage"] = damage
	attackData["MinDamage"] = min(attackData["MinDamage"], damage)
	stateHandle.EntitySet("_AttackDuration", recovery)
	stateHandle.EntitySet("_AttackData", attackData)
	if(stateHandle.EntityGet("_AttackInitialFrame") < 0):
		stateHandle.EntitySet("_AttackInitialFrame", stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame"))
	EnrichDefaultAttack(stateHandle)
func EnrichDefaultAttack(stateHandle):
	AttackFrameAdvantage([0], stateHandle)


func AttackDuration(args, stateHandle):
	stateHandle.EntitySet("_AttackDuration", ArgInt(args, stateHandle, 0))

func AttackRearm(_args, stateHandle):
	stateHandle.EntitySet("_AttackHitconfirm_State", null)
	stateHandle.EntitySet("_AttackInitialFrame", -1)
	stateHandle.EntitySet("_AttackHitEntities", [])
	stateHandle.EntitySet("_AttackHasHit", false)
	stateHandle.EntitySet("_AttackWasBlocked", false)
	stateHandle.EntitySet("_AttackHasWhiffed", false)
	stateHandle.EntitySet("_AttackHasTouched", false)

func AttackParam(args, stateHandle):
	var paramName = ArgStr(args, stateHandle, 0)
	var value = ArgInt(args, stateHandle, 1)
	
	stateHandle.EntityGet("_AttackData")[paramName] = value



func AttackFlag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(!flagName in stateHandle.EntityGet("_AttackData")["Flags"]):
		stateHandle.EntityGet("_AttackData")["Flags"] += [flagName]
func AttackUnflag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(flagName in stateHandle.EntityGet("_AttackData")["Flags"]):
		stateHandle.EntityGet("_AttackData")["Flags"].erase(flagName)
func AttackRecievedFlag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(!flagName in stateHandle.EntityGet("_LastAttackFlags")):
		stateHandle.EntityAdd("LastAttackFlags", [flagName])
		stateHandle.EntitySetFlag("AF"+flagName)
func AttackRecievedUnflag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(flagName in stateHandle.EntityGet("_LastAttackFlags")):
		stateHandle.EntityGet("_LastAttackFlags").erase(flagName)
		stateHandle.EntitySetFlag("AF"+flagName, false)

func AttackAttribute(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["Attribute"] = ArgStr(args, stateHandle, 0, "Auto")


func AttackFrameAdvantage(args, stateHandle):
	var hitFA = ArgInt(args, stateHandle, 0)
	#if(hitFA == null):
	#	return ModuleError("AttackFrameAdvantage: hitFA is null")
		# TODO: does it need this everywhere ? should add static code analysis?
	var blockFA = ArgInt(args, stateHandle, 1, hitFA)
	_AttackFrameAdvantage(hitFA, stateHandle, "Hitstun")
	_AttackFrameAdvantage(blockFA, stateHandle, "Blockstun")
func AttackFrameAdvantageHit(args, stateHandle):
	_AttackFrameAdvantage(ArgInt(args, stateHandle, 0), stateHandle, "Hitstun")
func AttackFrameAdvantageBlock(args, stateHandle):
	_AttackFrameAdvantage(ArgInt(args, stateHandle, 0), stateHandle, "Blockstun")
func _AttackFrameAdvantage(FA, stateHandle, stunType):
	var neutralFA = stateHandle.EntityGet("_AttackDuration") - stateHandle.EntityGet("_AttackInitialFrame")
	stateHandle.EntityGet("_AttackData")[stunType] = max(neutralFA + FA, 1)
func AttackHitstunBlockstun(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["Hitstun"] = max(ArgInt(args, stateHandle, 0),1)
	stateHandle.EntityGet("_AttackData")["Blockstun"] = max(ArgInt(args, stateHandle, 1),1)
func AttackHitstun(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["Hitstun"] = max(ArgInt(args, stateHandle, 0),1)
func AttackBlockstun(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["Blockstun"] = max(ArgInt(args, stateHandle, 0),1)


func AttackProrationHitstun(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["StarterProrationHitstun"] = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_AttackData")["ProrationHitstun"] = ArgInt(args, stateHandle, 1)
func AttackProrationDamage(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["StarterProrationDamage"] = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_AttackData")["ProrationDamage"] = ArgInt(args, stateHandle, 1)


func AttackChipDamage(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["ChipDamage"] = ArgInt(args, stateHandle, 0)
func AttackMinDamage(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["MinDamage"] = ArgInt(args, stateHandle, 0)



func AttackMomentum(args, stateHandle):
	AttackMomentumHit(args, stateHandle)
	AttackMomentumBlock(args, stateHandle)
func AttackMomentumHit(args, stateHandle):
	var mh = ArgInt(args, stateHandle, 0)
	var mv = ArgInt(args, stateHandle, 1, 0)
	stateHandle.EntityGet("_AttackData")["HitMomentumX"] = mh
	stateHandle.EntityGet("_AttackData")["HitMomentumY"] = mv
	stateHandle.EntityGet("_AttackData")["HitMomentumAirX"] = ArgInt(args, stateHandle, 2, mh)
	stateHandle.EntityGet("_AttackData")["HitMomentumAirY"] = ArgInt(args, stateHandle, 3, mv)
func AttackMomentumBlock(args, stateHandle):
	var mh = ArgInt(args, stateHandle, 0)
	var mv = ArgInt(args, stateHandle, 1, 0)
	stateHandle.EntityGet("_AttackData")["BlockMomentumX"] = mh
	stateHandle.EntityGet("_AttackData")["BlockMomentumY"] = mv
	stateHandle.EntityGet("_AttackData")["BlockMomentumAirX"] = ArgInt(args, stateHandle, 2, mh)
	stateHandle.EntityGet("_AttackData")["BlockMomentumAirY"] = ArgInt(args, stateHandle, 3, mv)
func AttackFloat(args, stateHandle):
	stateHandle.EntityGet("_AttackData")["FloatGravity"] = -ArgInt(args, stateHandle, 0)
	AttackFlag(["Float"], stateHandle)

func AttackKnockdown(args, stateHandle):
	AttackFlag(["Knockdown"], stateHandle)
	var kdMin = Castagne.configData["AttackDefault-KnockdownTimeMin"]
	var kdMax = Castagne.configData["AttackDefault-KnockdownTimeMax"]
	
	if(args.size() >= 1):
		kdMin = max(1, ArgInt(args, stateHandle, 0, kdMin))
		kdMax = max(kdMin, ArgInt(args, stateHandle, 1, kdMin+_knockdownDefaultTimeDiff))
	
	stateHandle.EntityGet("_AttackData")["KnockdownTimeMin"] = kdMin
	stateHandle.EntityGet("_AttackData")["KnockdownTimeMax"] = kdMax

func AttackGroundbounce(args, stateHandle):
	AttackFlag(["Groundbounce"], stateHandle)
	stateHandle.EntityGet("_AttackData")["GroundbounceTime"] = ArgInt(args, stateHandle, 0, Castagne.configData["AttackDefault-GroundbounceTime"])
	stateHandle.EntityGet("_AttackData")["GroundbounceMomentum"] = ArgInt(args, stateHandle, 1, Castagne.configData["AttackDefault-GroundbounceMomentum"])
	stateHandle.EntityGet("_AttackData")["MaxGroundbounces"] = ArgInt(args, stateHandle, 2, Castagne.configData["AttackDefault-MaxGroundbounces"])
	





func AttackApplyCancels(args, stateHandle):
	var prefix = ArgStr(args, stateHandle, 0, "")
	
	var listToUse = "Neutral"
	if(stateHandle.EntityHasFlag("Attacking")):
		listToUse = stateHandle.EntityGet("_AttackHitconfirm_State")
		if(listToUse == null):
			return
	
	var alwaysAllowNeutralV = (prefix != "") # Prevents cancels to 5x when crouching
	
	# TODO Refactor ?
	var input = stateHandle.PlayerGet("Inputs")
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
			if(stateHandle.EntityGet("_AttackPossibleCancels" + listToUse).has(notation)):
				var attackName = stateHandle.EntityGet("_AttackPossibleCancels"+listToUse)[notation]
				
				# We ignore if the attack has already used and that it exists
				if(stateHandle.EntityGet("_AttackDoneCancels").has(attackName)
					or !stateHandle.FighterScripts()[stateHandle.EntityGet("_FighterID")].has(attackName)):
					continue
				
				stateHandle.EntityAdd("AttackDoneCancels", [attackName])
				CallFunction("Transition", [attackName, 100], stateHandle)
				return
func AttackResetDoneCancels(_args, stateHandle):
	stateHandle.EntitySet("_AttackDoneCancels", [])


func AttackCancelOnWhiff(args, stateHandle):
	_AttackCancelRegister(args, stateHandle, ["Whiff"])
func AttackCancelOnBlock(args, stateHandle):
	_AttackCancelRegister(args, stateHandle, ["Block"])
func AttackCancelOnHit(args, stateHandle):
	_AttackCancelRegister(args, stateHandle, ["Hit"])
func AttackCancelOnTouch(args, stateHandle):
	_AttackCancelRegister(args, stateHandle, ["Block", "Hit"])
func AttackCancelOnTouchAndWhiff(args, stateHandle):
	_AttackCancelRegister(args, stateHandle, ["Whiff", "Block", "Hit"])
func AttackCancelNeutral(args, stateHandle):
	_AttackCancelRegister(args, stateHandle, ["Neutral"])
func AttackCancelOnTouchAndNeutral(args, stateHandle):
	_AttackCancelRegister(args, stateHandle, ["Block", "Hit", "Neutral"])
func _AttackCancelRegister(args, stateHandle, lists):
	var notation = ArgStr(args, stateHandle, 0)
	var attackName = ArgStr(args, stateHandle, 1, notation)
	for l in lists:
		stateHandle.EntityGet("_AttackPossibleCancels"+l)[notation] = attackName

func AttackAddAllCancelsOnWhiff(args, stateHandle):
	_AttackAllCancelRegister(args, stateHandle, ["Whiff"])
func AttackAddAllCancelsOnBlock(args, stateHandle):
	_AttackAllCancelRegister(args, stateHandle, ["Block"])
func AttackAddAllCancelsOnHit(args, stateHandle):
	_AttackAllCancelRegister(args, stateHandle, ["Hit"])
func AttackAddAllCancelsOnTouch(args, stateHandle):
	_AttackAllCancelRegister(args, stateHandle, ["Block", "Hit"])
func AttackAddAllCancelsOnTouchAndWhiff(args, stateHandle):
	_AttackAllCancelRegister(args, stateHandle, ["Whiff", "Block", "Hit"])
func AttackAddAllCancelsNeutral(args, stateHandle):
	_AttackAllCancelRegister(args, stateHandle, ["Neutral"])
func AttackAddAllCancelsOnTouchAndNeutral(args, stateHandle):
	_AttackAllCancelRegister(args, stateHandle, ["Block", "Hit", "Neutral"])
func _AttackAllCancelRegister(args, stateHandle, lists):
	var button = ArgStr(args, stateHandle, 0)
	var prefix = ArgStr(args, stateHandle, 1, "")
	for l in lists:
		for i in range(1, 10):
			var notation = prefix+str(i)+button
			stateHandle.EntityGet("_AttackPossibleCancels"+l)[notation] = notation
