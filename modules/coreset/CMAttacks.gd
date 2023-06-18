extends "../CastagneModule.gd"

func ModuleSetup():
	# :TODO:Panthavma:20211230:Hitstop
	
	RegisterModule("Attacks", Castagne.MODULE_SLOTS_BASE.ATTACKS, {"Description":"Specialized module to help with making attacks and combat systems."})
	RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Attacks.casp", -5000)
	# TODO Docs
	RegisterCategory("Attacks")
	RegisterFunction("AttackRegister", [1,2], ["AllPhases"], {
		"Description":"Initiates an attack with default parameters. This should be the first function called for a new attack, then you use other Attack functions to customize it, and finally you use Hitbox to apply it.",
		"Arguments":["Type", "(Optional) Notation"],
		"Flags":["Basic"],
		"Types":["str", "str"],
	})
	RegisterFunction("AttackRegisterNoNotation", [1], ["AllPhases"], {
		"Description":"Same as AttackRegister, but won't actually add the attack to the list of cancels, which you'll have to do manually.",
		"Arguments":["Type"],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("AttackAddNotation", [1], ["AllPhases"], {
		"Description":"Registers the attack under an additional notation input. This will still count as the same attack.",
		"Arguments":["Notation"],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("AttackDamage", [1], null, {})
	RegisterFunction("AttackDuration", [1], null, {
		"Description":"Changes the total duration of the attack. Can replace Attack's second parameter but must be called before it.",
		"Arguments":["Total frames"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackRearm", [0, 1], null, {
		"Description":"Sets the variables to be able to hit with another attack, and should be used between multihits. Resets the hit detection.",
		"Flags":["Intermediate"],
		"Arguments":["(Optional) Treat as a new attack instead of a multihit (reapplies proration and resets hit/block/clash flags) (Default: False)"],
		"Types":["bool"],
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
		"Flags":["Intermediate"],
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
		"Flags":["Intermediate"],
		"Types":["str",],
	})
	
	
	RegisterFunction("AttackFrameAdvantage", [1,2], null, {
		"Description":"Sets an attack's frame advantage automatically on hit and block. This is based on the total duration of the attack and the last use of the multihit flag. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit", "Frame advantage on block"],
		"Flags":["Basic"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackFrameAdvantageHit", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on hit. This is based on the total duration of the attack and the last use of the AttackRearm function. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackFrameAdvantageBlock", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on block. This is based on the total duration of the attack and the last use of the AttackRearm function. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
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
		"Flags":["Intermediate"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackProrationDamage", [2], null, {
		"Description":"Sets an attack's proration for damage. The lower it is, the more damage will decay with each hit. Values are in permil.",
		"Arguments":["First hit proration (used instead of proration for the first hit)", "Subsequent hit proration"],
		"Flags":["Intermediate"],
		"Types":["int","int"],
	})
	
	
	RegisterFunction("AttackChipDamage", [1], null, {
		"Description":"Sets an attack's chip damage, the damage that gets inflicted when an opponent blocks.",
		"Arguments":["The amount of chip damage"],
		"Flags":["Intermediate"],
		"Types":["int",],
	})
	RegisterFunction("AttackMinDamage", [1], null, {
		"Description":"Sets an attack's minimum damage.",
		"Arguments":["The minimum amount of damage"],
		"Flags":["Intermediate"],
		"Types":["int",],
	})
	
	
	
	RegisterFunction("AttackMomentum", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on hit and block.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
		"Flags":["Basic"],
		"Types":["int","int","int","int"],
	})
	RegisterFunction("AttackMomentumHit", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on hit.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
		"Flags":["Intermediate"],
		"Types":["int","int","int","int"],
	})
	RegisterFunction("AttackMomentumBlock", [1, 2, 3, 4], null, {
		"Description":"Sets an attacks's added momentum to the opponent on block.",
		"Arguments":["Horizontal grounded momentum", "(Optional) Vertical grounded momentum", "(Optional) Horizontal airborne momentum", "(Optional) Vertical airborne momentum"],
		"Flags":["Intermediate"],
		"Types":["int","int","int","int"],
	})
	RegisterFunction("AttackInheritMomentum", [0, 1, 2, 4], null, {
		"Description":"Makes an attack inherit the momentum of the attacker, in permil. Happens on hit and block.",
		"Arguments":["Ratio of Ground X Momentum conserved in permil", "Ratio of Ground Y Momentum conserved in permil",
			"Ratio of Air X Momentum conserved in permil", "Ratio of Air Y Momentum conserved in permil"],
		"Flags":["Intermediate"],
		"Types":["int", "int", "int", "int"],
	})
	RegisterFunction("AttackInheritMomentumHit", [0, 1, 2, 4], null, {
		"Description":"Makes an attack inherit the momentum of the attacker, in permil. Happens on hit.",
		"Arguments":["Ratio of Ground X Momentum conserved in permil", "Ratio of Ground Y Momentum conserved in permil",
			"Ratio of Air X Momentum conserved in permil", "Ratio of Air Y Momentum conserved in permil"],
		"Flags":["Intermediate"],
		"Types":["int", "int", "int", "int"],
	})
	RegisterFunction("AttackInheritMomentumBlock", [0, 1, 2, 4], null, {
		"Description":"Makes an attack inherit the momentum of the attacker, in permil. Happens on block.",
		"Arguments":["Ratio of Ground X Momentum conserved in permil", "Ratio of Ground Y Momentum conserved in permil",
			"Ratio of Air X Momentum conserved in permil", "Ratio of Air Y Momentum conserved in permil"],
		"Flags":["Intermediate"],
		"Types":["int", "int", "int", "int"],
	})
	
	RegisterFunction("AttackFloat", [1], null, {
		"Description":"Sets the opponent's gravity on hit to the specified value until the next attack.",
		"Arguments":["New Gravity"],
		"Flags":["Intermediate"],
		"Types":["int",],
	})
	
	
	RegisterFunction("AttackKnockdown", [0,1,2], null, {
		"Description":"Sets an attack's minimum and maximum time on knockdown. Automatically applies the knockdown attack flag. If no arguments are given, use default values. If only one is given, the second is computed automatically from the difference between defaults.",
		"Arguments":["(Optional) The minimum knockdown time", "(Optional) Maximum knockdown time"],
		"Flags":["Intermediate"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackGroundbounce", [1,2,3], null, {
		"Description":"Sets an attack's groundbounce",
		"Arguments":["Groundbounce time", "Groundbounce Momentum", "(Optional) Maximum ground bounces"],
		"Flags":["Intermediate"],
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
	
	RegisterVariableEntity("HP", 1)
	
	RegisterVariableEntity("_AttackMomentumX", 0)
	RegisterVariableEntity("_AttackMomentumY", 0)
	
	RegisterFlag("AFLow", {"Description":"Makes an attack unblockable while standing up."})
	RegisterFlag("AFOverhead", {"Description":"Makes an attack unblockable while crouching."})
	RegisterFlag("AFInheritMomentumHit", {"Description":"Makes it so that the attack inherits the attacker's momentum on hit, ratio determined by attack data."})
	RegisterFlag("AFInheritMomentumBlock", {"Description":"Makes it so that the attack inherits the attacker's momentum on block, ratio determined by attack data."})
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
	RegisterStateFlag("AttackType-Light")
	RegisterStateFlag("AttackType-Medium")
	RegisterStateFlag("AttackType-Heavy")
	RegisterStateFlag("AttackType-Special")
	RegisterStateFlag("AttackType-EX")
	RegisterStateFlag("AttackType-Super")
	RegisterStateFlag("AttackType-Throw")
	RegisterStateFlag("AttackType-AirLight")
	RegisterStateFlag("AttackType-AirMedium")
	RegisterStateFlag("AttackType-AirHeavy")
	RegisterStateFlag("AttackType-AirSpecial")
	RegisterStateFlag("AttackType-AirEX")
	RegisterStateFlag("AttackType-AirSuper")
	RegisterStateFlag("AttackType-AirThrow")
	RegisterStateFlag("Neutral")
	
	
	RegisterCategory("Attack Cancels")
	
	RegisterFunction("AttackCancel", [1,2,3,4], null, {
		"Description":"Adds an attack cancel. These will be active automatically in the sitations given by the 3rd argument.",
		"Arguments":["State Name", "(Optional) Command in numpad notation. See InputTransition for more details. (Default: State Name)",
			"(Optional) Cancel situation using ATTACKCANCEL_ON flags (default: ATTACKCANCEL_ON_TOUCH_NEUTRAL)",
			"(Optional) Priority (Default: AttackCancelPriorityDefault config key)"],
		"Flags":["Basic"],
		"Types":["str", "str", "int", "int"],
	})
	RegisterFunction("AttackAddRegisteredCancels", [1, 2, 3], null, {
		"Description":"Adds all attack cancels of a given type.",
		"Arguments":["Attack type",
			"(Optional) Cancel situation using ATTACKCANCEL_ON flags (default: ATTACKCANCEL_ON_TOUCH_NEUTRAL)",
			"(Optional) Priority (Default: AttackCancelPriorityDefault config key)"],
		"Flags":["Intermediate"],
		"Types":["str", "int", "int"],
	})
	RegisterFunction("AttackCancelPrefix", [0,1], null, {
		"Description":"Set the prefix used when looking for attack cancels",
		"Arguments":["New prefix to use for this frame."],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("AttackResetDoneCancels", [0], null, {
		"Description":"Resets the list of used attacks in cancels, meaning you can use them again. Mostly used when returning to neutral.",
		"Flags":["Advanced"],
	})
	
	var attackCancelConstants = ["_HIT", "_BLOCK", "_WHIFF", "_NEUTRAL"]
	for value in range(pow(attackCancelConstants.size(), 2)):
		var flags = []
		var i = value
		for j in range(attackCancelConstants.size()):
			flags.push_back(i%2)
			i /= 2
		var text = ""
		var textTouch = ""
		for j in range(attackCancelConstants.size()):
			if(!flags[j]):
				continue
			var f = attackCancelConstants[j]
			text += f
			if(j >= 2):
				textTouch += f
		if(text == ""):
			continue
		RegisterConstant("ATTACKCANCEL_ON"+text, value, {"Type":Castagne.VARIABLE_TYPE.Int})
		if(flags[0] and flags[1]):
			textTouch = "_TOUCH" + textTouch
			RegisterConstant("ATTACKCANCEL_ON"+textTouch, value, {"Type":Castagne.VARIABLE_TYPE.Int})
	
	RegisterConfig("AttackCancelPriorityDefault", 10000)
	
	RegisterVariableEntity("_AttackCancelPrefix", "", ["ResetEachFrame"])
	RegisterVariableEntity("_AttackDoneCancels", [])
	RegisterVariableEntity("_AttackInitialFrame", -1)
	RegisterVariableEntity("_AttackHitconfirm_State", null)
	RegisterVariableEntity("_AttackPossibleCancelsWhiff", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsBlock", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsHit", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsNeutral", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackHasHit", false)
	RegisterVariableEntity("_AttackWasBlocked", false) 
	RegisterVariableEntity("_AttackHasWhiffed", false)
	RegisterVariableEntity("_AttackHasTouched", false)
	RegisterVariableEntity("_HitstunGravityFloat", 0)
	RegisterVariableEntity("_LastAttackFlags", [], null, {"Description":"Stores the attack flags of the last attack recieved."})
	
	RegisterVariableEntity("_RegisteredAttacksForEntityByType", {})
	
	RegisterCategory("Default Attack Params")
	RegisterConfig("AttackDefault-Damage", 100)
	RegisterConfig("AttackDefault-MinDamage", 1)
	RegisterConfig("AttackDefault-Hitstun", -1)
	RegisterConfig("AttackDefault-Blockstun", -1)
	RegisterConfig("AttackDefault-ChipDamage", 0)
	
	RegisterConfig("AttackDefault-HitMomentumX", 1000)
	RegisterConfig("AttackDefault-HitMomentumY", 0)
	RegisterConfig("AttackDefault-HitMomentumAirX", 1000)
	RegisterConfig("AttackDefault-HitMomentumAirY", 200)
	
	RegisterConfig("AttackDefault-BlockMomentumX", 1000)
	RegisterConfig("AttackDefault-BlockMomentumY", 0)
	RegisterConfig("AttackDefault-BlockMomentumAirX", 1000)
	RegisterConfig("AttackDefault-BlockMomentumAirY", 200)
	
	RegisterConfig("AttackDefault-Attribute", "Auto")
	RegisterConfig("AttackDefault-Flags", [])
	
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
	
	RegisterConfig("AttackDefault-InheritMomentumHitGroundX", 1000)
	RegisterConfig("AttackDefault-InheritMomentumHitGroundY", 1000)
	RegisterConfig("AttackDefault-InheritMomentumHitAirX", 1000)
	RegisterConfig("AttackDefault-InheritMomentumHitAirY", 1000)
	RegisterConfig("AttackDefault-InheritMomentumBlockGroundX", 1000)
	RegisterConfig("AttackDefault-InheritMomentumBlockGroundY", 1000)
	RegisterConfig("AttackDefault-InheritMomentumBlockAirX", 1000)
	RegisterConfig("AttackDefault-InheritMomentumBlockAirY", 1000)

var _defaultAttackData = {}
var _knockdownDefaultTimeDiff = 0
func BattleInit(stateHandle, _battleInitData):
	_defaultAttackData = {}
	
	# Take variables from the config stating with AttackDefault
	var configDerivedDataPrefix = "AttackDefault-"
	for configKeyName in configDefault:
		if(configKeyName.begins_with(configDerivedDataPrefix)):
			var attackDataName = configKeyName.right(configDerivedDataPrefix.length())
			_defaultAttackData[attackDataName] = stateHandle.ConfigData().Get(configKeyName)
	
	_knockdownDefaultTimeDiff = max(0, stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMax") - stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMin"))

func InitPhaseStartEntity(stateHandle):
	var fighterScripts = engine.GetFighterAllScripts(stateHandle.EntityGet("_FighterID"))
	var entityName = stateHandle.EntityGet("_State").right(5) # Init-
	var attacks = {null:{}}
	for stateName in fighterScripts:
		var fs = fighterScripts[stateName]
		if(fs["Metadata"]["AttackNotations"].empty() or fs["Metadata"]["Entity"] != entityName or fs["Metadata"]["ParentLevel"] > 0):
			continue
		var notations = fs["Metadata"]["AttackNotations"]
		var type = fs["Metadata"]["AttackType"]
		
		attacks[null][stateName] = {"Type":type, "Notations":notations}
		if(!attacks.has(type)):
			attacks[type] = {}
		for notation in notations:
			attacks[type][notation] = stateName
		
		#ModuleLog("Attack found: " + stateName +" Notation:"+ fs["Metadata"]["AttackNotation"])
	stateHandle.EntitySet("_RegisteredAttacksForEntityByType", attacks)

func ActionPhaseStartEntity(stateHandle):
	for af in stateHandle.EntityGet("_LastAttackFlags"):
		stateHandle.EntitySetFlag("AF"+af)
	var attackData = _defaultAttackData.duplicate(true)
	stateHandle.EntitySet("_AttackData", attackData)

func PhysicsPhaseEndEntity(stateHandle):
	# :TODO:Panthavma:20220314:Optim: Maybe replace the string check by a int
	var hitconfirmState = stateHandle.EntityGet("_AttackHitconfirm_State")
	if(stateHandle.EntityGet("_Hitboxes").size() > 0 and hitconfirmState == null):
		stateHandle.EntitySet("_AttackHitconfirm_State", "Whiff")
		# :TODO:Panthavma:20220525:Improve whiff detection to be AFTER hitboxes disappear
	if(hitconfirmState != null):
		stateHandle.EntitySet("_AttackHasHit", (hitconfirmState == "Hit"))
		stateHandle.EntitySet("_AttackWasBlocked", (hitconfirmState == "Block"))
		stateHandle.EntitySet("_AttackHasWhiffed", (hitconfirmState == "Whiff"))
		stateHandle.EntitySet("_AttackHasTouched", (stateHandle.EntityGet("_AttackHasHit") or stateHandle.EntityGet("_AttackWasBlocked")))
	
	# TODO add input transitions
	
	var listToUse = "Neutral"
	if(stateHandle.EntityHasFlag("Attacking")):
		listToUse = stateHandle.EntityGet("_AttackHitconfirm_State")
		if(listToUse == null):
			return
	var cancelList = stateHandle.EntityGet("_AttackPossibleCancels"+listToUse)
	
	var inputModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.INPUT)
	var attackCancelPrefix = stateHandle.EntityGet("_AttackCancelPrefix")
	var attackCancelPrefixLength = attackCancelPrefix.length()
	for rawNotation in cancelList:
		if(!rawNotation.begins_with(attackCancelPrefix)):
			continue
		var notation = rawNotation.right(attackCancelPrefixLength)
		var attackName = cancelList[rawNotation]
		
		if(stateHandle.EntityGet("_AttackDoneCancels").has(attackName)):
			continue
		var data = {
			"Priority": 0
		}
		inputModule.AddInputTransition(stateHandle, notation, attackName)






# Returns true if the hit is confirmed and search should stop
func HandleHit(stateHandle, attackerEID, hitbox, defenderEID, hurtbox):
	var attackData = hitbox["AttackData"]
	var defenderHandle = stateHandle.CloneStateHandle()
	defenderHandle.PointToEntity(defenderEID)
	stateHandle.PointToEntity(attackerEID)
	
	var attackHit = IsAttackHitting(attackData, stateHandle, hitbox, defenderHandle, hurtbox)
	if(attackHit == Castagne.HITCONFIRMED.NONE):
		return false
	
	ApplyAttackToAttacker(attackHit, attackData, stateHandle, hitbox, defenderHandle, hurtbox)
	
	if(attackHit != Castagne.HITCONFIRMED.CLASH):
		ApplyAttackToDefender(attackHit, attackData, stateHandle, hitbox, defenderHandle, hurtbox)
	
	return true


# :TODO:Panthavma:20220413:Separate it in smaller functions for easier custom?
func IsAttackHitting(attackData, attackerHandle, hitbox, defenderHandle, hurtbox):
	if(attackerHandle.EntityGet("_AttackHitEntities").has(defenderHandle.EntityGet("_EID"))):
		return Castagne.HITCONFIRMED.NONE
	if(hurtbox["Hitbox"]):
		return Castagne.HITCONFIRMED.CLASH
	
	var dInputs = defenderHandle.EntityGet("_Inputs")
	
	# :TODO:Panthavma:20220204:Make "am i trying to defend" independant of physics, maybe an input
	var inBlockstun = defenderHandle.EntityHasFlag("Blockstun")
	var inHitstun = defenderHandle.EntityHasFlag("Hitstun")
	var autoblocking = defenderHandle.EntityHasFlag("AutoBlocking")
	# :TODO:Panthavma:20230513:Use block facing here
	var blocking = dInputs["Back"] or inBlockstun or autoblocking
	blocking = blocking and defenderHandle.EntityHasFlag("CanBlock")
	
	var airborne = defenderHandle.EntityHasFlag("Airborne")
	
	var lowBreak = HasFlag(attackData, "Low") and ((!autoblocking and !dInputs["Down"]) or (autoblocking and !defenderHandle.EntityHasFlag("AutoBlockingLow")))
	var highBreak = HasFlag(attackData, "Overhead") and ((!autoblocking and dInputs["Down"]) or (autoblocking and !defenderHandle.EntityHasFlag("AutoBlockingOverhead")))
	var groundUnblockableBreak = HasFlag(attackData, "GroundUnblockable") and !airborne
	var airUnblockableBreak = HasFlag(attackData, "AirUnblockable") and airborne
	
	var attribute = attackData["Attribute"]
	if(attribute == "Auto"):
		attribute = AttributeAuto(attackData, attackerHandle)
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
		((inBlockstun and !attackerHandle.ConfigData().Get("Attack-ThrowInBlockstun")) or
		 (inHitstun and !attackerHandle.ConfigData().Get("Attack-ThrowInHitstun")))):
		blockBreak = false
	
	if((airborne and HasFlag(attackData, "PhasethroughAir")) or (!airborne and HasFlag(attackData, "PhasethroughGround"))):
		blockBreak = false
		phaseAttack = true
		invuling = true
	
	if((blocking or isThrow or guarding or invuling) and !blockBreak):
		return (Castagne.HITCONFIRMED.NONE if phaseAttack else Castagne.HITCONFIRMED.BLOCK)
	
	return Castagne.HITCONFIRMED.HIT


func AttributeAuto(attackData, attackerHandle):
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

func ApplyAttackToAttacker(hitconfirm, attackData, attackerHandle, hitbox, defenderHandle, hurtbox):
	var hit = (hitconfirm != Castagne.HITCONFIRMED.BLOCK)
	var hitBlock = ("Hit" if hit else "Block")
	attackerHandle.EntitySet("_AttackHitconfirm_State", hitBlock)
	attackerHandle.EntityAdd("_AttackHitEntities", [defenderHandle.EntityGet("_EID")])
	
	var coreModule = attackerHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
	var targetEID = attackerHandle.GetTargetEntity()
	attackerHandle.SetPhase("Manual")
	attackerHandle.SetTargetEntity(defenderHandle.EntityGet("_EID"))
	if(hitconfirm == Castagne.HITCONFIRMED.HIT):
		coreModule.Call(["OnAttackHit"], attackerHandle)
	elif(hitconfirm == Castagne.HITCONFIRMED.BLOCK):
		coreModule.Call(["OnAttackBlock"], attackerHandle)
	else:
		coreModule.Call(["OnAttackClash"], attackerHandle)
	attackerHandle.SetTargetEntity(targetEID)

func ApplyAttackToDefender(hitconfirm, attackData, attackerHandle, hitbox, defenderHandle, hurtbox):
	var hit = (hitconfirm != Castagne.HITCONFIRMED.BLOCK)
	var hitBlock = ("Hit" if hit else "Block")
	var attackFlags = attackData["Flags"]
	
	var physicsModule = attackerHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS)
	var attackerFacing = physicsModule.GetFacingHV(attackerHandle)
	var defenderFacing = physicsModule.GetFacingHV(defenderHandle)
	var defenderGrounded = defenderHandle.EntityHasFlag("PFGrounded")
	var defenderGroundAir = ("Ground" if defenderGrounded else "Air")
	var defenderNoGroundAir = ("" if defenderGrounded else "Air")
	
	
	# :TODO:Panthavma:20230513:Momentum here is physics dependant, should move it there I think
	
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
	
	defenderHandle.EntitySet("_AttackMomentumX", attackerFacing[0] * defenderFacing[0] * attackData[hitBlock+"Momentum"+defenderNoGroundAir+"X"])
	defenderHandle.EntitySet("_AttackMomentumY", attackData[hitBlock+"Momentum"+defenderNoGroundAir+"Y"])
	
	var inheritMomentum = (hit and HasFlag(attackData, "InheritMomentumHit")) or (!hit and HasFlag(attackData, "InheritMomentumBlock"))
	if(inheritMomentum):
		var inheritMomentumX = attackData["InheritMomentum"+hitBlock+defenderGroundAir+"X"]
		var inheritMomentumY = attackData["InheritMomentum"+hitBlock+defenderGroundAir+"Y"]
		
		defenderHandle.EntityAdd("_AttackMomentumX", defenderFacing[0] * attackerHandle.EntityGet("_MomentumX") * inheritMomentumX / 1000)
		defenderHandle.EntityAdd("_AttackMomentumY", attackerHandle.EntityGet("_MomentumY") * inheritMomentumY / 1000)
	
	if(HasFlag(attackData, "Float")):
		defenderHandle.EntitySet("_HitstunGravityFloat", attackData["FloatGravity"])
	
	
	# Apply specific attack states
	defenderHandle.EntitySet("_KnockdownTimeMin", attackData["KnockdownTimeMin"])
	defenderHandle.EntitySet("_KnockdownTimeMax", attackData["KnockdownTimeMax"])
	if(attackFlags.has("Groundbounce")):
		if(defenderHandle.EntityGet("_Groundbounces") < attackData["MaxGroundbounces"]):
			defenderHandle.EntityAdd("_Groundbounces", 1)
			defenderHandle.EntitySet("_GroundbounceTime", attackData["GroundbounceTime"])
			defenderHandle.EntitySet("_GroundbounceMomentum", attackData["GroundbounceMomentum"])
			attackFlags += ["AnimGroundbounce"]
		else:
			attackFlags.erase("Groundbounce")
	
	defenderHandle.GlobalSet("_FreezeFrames", max(defenderHandle.GlobalGet("_FreezeFrames"), attackData[hitBlock+"stop"]))
	
	# :TODO:Panthavma:20220216:Move to physics
	defenderHandle.EntitySetFlag("PF"+hitBlock)
	defenderHandle.EntitySetFlag("PFTouched")
	
	var flagPrefix = "AF"
	for laf in defenderHandle.EntityGet("_LastAttackFlags"):
		defenderHandle.EntitySetFlag(flagPrefix+laf, false)
	defenderHandle.EntitySet("_LastAttackFlags", attackFlags)
	for f in attackFlags:
		defenderHandle.EntitySetFlag(flagPrefix+f)
	
	var coreModule = attackerHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
	var targetEID = defenderHandle.GetTargetEntity()
	defenderHandle.SetPhase("Manual")
	defenderHandle.SetTargetEntity(attackerHandle.EntityGet("_EID"))
	if(hit):
		coreModule.Call(["OnHit"], defenderHandle)
	else:
		coreModule.Call(["OnBlock"], defenderHandle)
	defenderHandle.SetTargetEntity(targetEID)
	


























func AttackRegister(args, stateHandle):
	AttackRegisterNoNotation(args, stateHandle)
func AttackRegisterNoNotation(args, stateHandle):
	var attackType = ArgStr(args, stateHandle, 0) # TODO CAST 54 Default
	var core = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
	core.Call(["AttackType-"+attackType], stateHandle)
	if(stateHandle.EntityGet("_StateFrameID") == 1):
		stateHandle.EntityAdd("_AttackDoneCancels", [stateHandle.EntityGet("_State")])
	if(stateHandle.EntityGet("_AttackInitialFrame") < 0):
		stateHandle.EntitySet("_AttackInitialFrame", stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame"))
func AttackAddNotation(_args, _stateHandle):
	pass

func AttackDamage(args, stateHandle):
	var damage = ArgInt(args, stateHandle, 0)
	var attackData = stateHandle.EntityGet("_AttackData")
	attackData["Damage"] = damage
	attackData["MinDamage"] = min(attackData["MinDamage"], damage)
func AttackDuration(args, stateHandle):
	stateHandle.EntitySet("_AttackDuration", ArgInt(args, stateHandle, 0))
	if(stateHandle.EntityGet("_AttackData")["Hitstun"] <= 0):
		AttackFrameAdvantageHit([0], stateHandle)
	if(stateHandle.EntityGet("_AttackData")["Blockstun"] <= 0):
		AttackFrameAdvantageBlock([0], stateHandle)

func AttackRearm(args, stateHandle):
	var newAttack = ArgBool(args, stateHandle, 0, false)
	# :TODO:Panthavma:20230617:Manage Proration
	stateHandle.EntitySet("_AttackInitialFrame", -1)
	stateHandle.EntitySet("_AttackHitEntities", [])
	if(newAttack):
		stateHandle.EntitySet("_AttackHitconfirm_State", null)
		stateHandle.EntitySet("_AttackHasHit", false)
		stateHandle.EntitySet("_AttackWasBlocked", false)
		stateHandle.EntitySet("_AttackHasWhiffed", false)
		stateHandle.EntitySet("_AttackHasTouched", false)

func AttackParam(args, stateHandle):
	var paramName = ArgStr(args, stateHandle, 0)
	var value = ArgInt(args, stateHandle, 1)
	
	_SetInPrepareAttackData(stateHandle, paramName, value)



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
	_SetInPrepareAttackData(stateHandle, "Attribute", ArgStr(args, stateHandle, 0, "Auto"))


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
	_SetInPrepareAttackData(stateHandle, stunType, max(neutralFA + FA, 1))
func AttackHitstunBlockstun(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "Hitstun", max(ArgInt(args, stateHandle, 0),1))
	_SetInPrepareAttackData(stateHandle, "Blockstun", max(ArgInt(args, stateHandle, 1),1))
func AttackHitstun(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "Hitstun", max(ArgInt(args, stateHandle, 0),1))
func AttackBlockstun(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "Blockstun", max(ArgInt(args, stateHandle, 0),1))


func AttackProrationHitstun(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "StarterProrationHitstun", ArgInt(args, stateHandle, 0))
	_SetInPrepareAttackData(stateHandle, "ProrationHitstun", ArgInt(args, stateHandle, 1))
func AttackProrationDamage(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "StarterProrationDamage", ArgInt(args, stateHandle, 0))
	_SetInPrepareAttackData(stateHandle, "ProrationDamage",  ArgInt(args, stateHandle, 1))


func AttackChipDamage(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "ChipDamage",  ArgInt(args, stateHandle, 0))
func AttackMinDamage(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "MinDamage",  ArgInt(args, stateHandle, 0))



func AttackMomentum(args, stateHandle):
	AttackMomentumHit(args, stateHandle)
	AttackMomentumBlock(args, stateHandle)
func AttackMomentumHit(args, stateHandle):
	var mh = ArgInt(args, stateHandle, 0)
	var mv = ArgInt(args, stateHandle, 1, 0)
	_SetInPrepareAttackData(stateHandle, "HitMomentumX",  mh)
	_SetInPrepareAttackData(stateHandle, "HitMomentumY",  mv)
	_SetInPrepareAttackData(stateHandle, "HitMomentumAirX",  ArgInt(args, stateHandle, 2, mh))
	_SetInPrepareAttackData(stateHandle, "HitMomentumAirY",  ArgInt(args, stateHandle, 3, mv))
func AttackMomentumBlock(args, stateHandle):
	var mh = ArgInt(args, stateHandle, 0)
	var mv = ArgInt(args, stateHandle, 1, 0)
	_SetInPrepareAttackData(stateHandle, "BlockMomentumX",  mh)
	_SetInPrepareAttackData(stateHandle, "BlockMomentumY",  mv)
	_SetInPrepareAttackData(stateHandle, "BlockMomentumAirX",  ArgInt(args, stateHandle, 2, mh))
	_SetInPrepareAttackData(stateHandle, "BlockMomentumAirY",  ArgInt(args, stateHandle, 3, mv))
func AttackInheritMomentum(args, stateHandle):
	AttackInheritMomentumHit(args, stateHandle)
	AttackInheritMomentumBlock(args, stateHandle)
func AttackInheritMomentumHit(args, stateHandle, situation = "Hit"):
	AttackFlag(["InheritMomentum"+situation], stateHandle)
	if(args.size() > 0):
		var imGroundX = ArgInt(args, stateHandle, 0)
		var imGroundY = ArgInt(args, stateHandle, 1, imGroundX)
		var imAirX = ArgInt(args, stateHandle, 2, imGroundX)
		var imAirY = ArgInt(args, stateHandle, 3, imGroundY)
		
		_SetInPrepareAttackData(stateHandle, "InheritMomentum"+situation+"GroundX", imGroundX)
		_SetInPrepareAttackData(stateHandle, "InheritMomentum"+situation+"GroundY", imGroundY)
		_SetInPrepareAttackData(stateHandle, "InheritMomentum"+situation+"AirX", imAirX)
		_SetInPrepareAttackData(stateHandle, "InheritMomentum"+situation+"AirY", imAirY)
func AttackInheritMomentumBlock(args, stateHandle):
	AttackInheritMomentumHit(args, stateHandle, "Block")
func AttackFloat(args, stateHandle):
	_SetInPrepareAttackData(stateHandle, "FloatGravity",  -ArgInt(args, stateHandle, 0))
	AttackFlag(["Float"], stateHandle)

func AttackKnockdown(args, stateHandle):
	AttackFlag(["Knockdown"], stateHandle)
	var kdMin = stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMin")
	var kdMax = stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMax")
	
	if(args.size() >= 1):
		kdMin = max(1, ArgInt(args, stateHandle, 0, kdMin))
		kdMax = max(kdMin, ArgInt(args, stateHandle, 1, kdMin+_knockdownDefaultTimeDiff))
	
	_SetInPrepareAttackData(stateHandle, "KnockdownTimeMin", kdMin)
	_SetInPrepareAttackData(stateHandle, "KnockdownTimeMax", kdMax)

func AttackGroundbounce(args, stateHandle):
	AttackFlag(["Groundbounce"], stateHandle)
	_SetInPrepareAttackData(stateHandle, "GroundbounceTime", ArgInt(args, stateHandle, 0, stateHandle.ConfigData().Get("AttackDefault-GroundbounceTime")))
	_SetInPrepareAttackData(stateHandle, "GroundbounceMomentum", ArgInt(args, stateHandle, 1, stateHandle.ConfigData().Get("AttackDefault-GroundbounceMomentum")))
	_SetInPrepareAttackData(stateHandle, "MaxGroundbounces", ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("AttackDefault-MaxGroundbounces")))
	






func AttackResetDoneCancels(_args, stateHandle):
	stateHandle.EntitySet("_AttackDoneCancels", [])


func AttackCancel(args, stateHandle):
	var attackName = ArgStr(args, stateHandle, 0)
	var notation = ArgStr(args, stateHandle, 1, attackName)
	var flags = ArgInt(args, stateHandle, 2, 1+2+8) # ATTACKCANCEL_ON_TOUCH_NEUTRAL
	var priority = ArgInt(args, stateHandle, 3, stateHandle.ConfigData().Get("AttackCancelPriorityDefault"))
	AddAttackCancel(stateHandle, notation, attackName, flags)

func AttackAddRegisteredCancels(args, stateHandle):
	var type = ArgStr(args, stateHandle, 0)
	var flags = ArgInt(args, stateHandle, 1, 1+2+8) # ATTACKCANCEL_ON_TOUCH_NEUTRAL
	var priority = ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("AttackCancelPriorityDefault"))
	
	var registeredAttacks = stateHandle.EntityGet("_RegisteredAttacksForEntityByType")
	if(registeredAttacks.has(type)):
		for notation in registeredAttacks[type]:
			var attackName = registeredAttacks[type][notation]
			AddAttackCancel(stateHandle, notation, attackName, flags)

func AddAttackCancel(stateHandle, notation, attackName, flags):
	var flagsRef = ["Hit", "Block", "Whiff", "Neutral"]
	for i in range(flagsRef.size()):
		if(flags % 2):
			stateHandle.EntityGet("_AttackPossibleCancels"+flagsRef[i])[notation] = attackName
		flags /= 2

func _AttackCancelRegister(args, stateHandle, lists):
	var notation = ArgStr(args, stateHandle, 0)
	var attackName = ArgStr(args, stateHandle, 1, notation)
	for l in lists:
		stateHandle.EntityGet("_AttackPossibleCancels"+l)[notation] = attackName

func AttackCancelPrefix(args, stateHandle):
	var acp = ArgStr(args, stateHandle, 0, "")
	stateHandle.EntitySet("_AttackCancelPrefix", acp)


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


# ----
# Helpers

func _SetInPrepareAttackData(stateHandle, fieldName, value):
	stateHandle.EntityGet("_AttackData")[fieldName] = value
