# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

var ATTACK_FLAG_PREFIX = "AF_"

func ModuleSetup():
	RegisterModule("Attacks", Castagne.MODULE_SLOTS_BASE.ATTACKS, {"Description":"Specialized module to help with making attacks and combat systems."})
	RegisterBaseCaspFile("res://castagne/modules/attacks/Base-Attacks.casp", -5000)
	RegisterSpecblock("AttacksTypes", "res://castagne/modules/attacks/CMAttacksSBTypes.gd")
	RegisterSpecblock("AttacksThrows", "res://castagne/modules/attacks/CMAttacksSBThrows.gd")
	RegisterSpecblock("AttacksMechanics", "res://castagne/modules/attacks/CMAttacksSBMechanics.gd")
	
	
	# [F_BASICS] -----------------------------------------------------------------------------------
	RegisterCategory("Attack Basics")
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
	RegisterFunction("AttackInternalRegister", [1,2], ["AllPhases"], {
		"Description":"Internal trick to improve performance. Don't use it.",
		"Arguments":["Type", "(Optional) Notation"],
		"Flags":["Basic"],
		"Types":["str", "str"],
	})
	RegisterFunction("AttackInternalRegisterNoNotation", [1], ["AllPhases"], {
		"Description":"Internal trick to improve performance. Don't use it.",
		"Arguments":["Type"],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("AttackInit", [0], ["AllPhases"], {
		"Description":"Internal call for various data set.",
		"Arguments":[],
		"Flags":["Expert"],
	})
	RegisterFunction("AttackDuration", [1], null, {
		"Description":"Changes the total duration of the attack. Can replace Attack's second parameter but must be called before it.",
		"Arguments":["Total frames"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackRearm", [0], null, {
		"Description":"Sets the variables to be able to hit with another attack, and should be used between new attacks (done by CASP automatically). Resets the hit detection.",
		"Flags":["Expert"],
	})
	RegisterFunction("AttackMultihit", [0], null, {
		"Description":"Allows an attack to hit a second time, hit detection won't be reset and proration will be nullified (through CASP).",
		"Flags":["Intermediate"],
	})
	RegisterVariableEntity("_AttackData", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackDuration", 600)
	RegisterVariableEntity("_AttackHitEntities", [])
	RegisterVariableEntity("_AttackHitEntitiesMultihit", [])
	RegisterVariableEntity("_RecievedAttackData", {}, null, {"Description":"Stores the last attack recieved."})
	RegisterVariableEntity("_InflictedAttackData", {}, null, {"Description":"Stores the last attack inflicted."})

	RegisterVariableEntity("_RegisteredAttacksForEntityByType", {})
	
	
	
	
	
	
	# [F_GENERICS] ---------------------------------------------------------------------------------
	RegisterCategory("Generics")
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
		"Description":"Set an attack flag on the last recieved attack.",
		"Arguments":["Flag name"],
		"Flags":["Advanced"],
		"Types":["str",],
	})
	RegisterFunction("AttackRecievedUnflag", [1], null, {
		"Description":"Removes an attack flag on the last recieved attack.",
		"Arguments":["Flag name"],
		"Flags":["Advanced"],
		"Types":["str",],
	})
	RegisterFunction("AttackInflictedFlag", [1], null, {
		"Description":"Set an attack flag on the last inflicted attack.",
		"Arguments":["Flag name"],
		"Flags":["Advanced"],
		"Types":["str",],
	})
	RegisterFunction("AttackInflictedUnflag", [1], null, {
		"Description":"Removes an attack flag on the last inflicted attack.",
		"Arguments":["Flag name"],
		"Flags":["Advanced"],
		"Types":["str",],
	})
	RegisterAttackDefault("_Flags", [])
	RegisterAttackDefault("_Unflag", [])
	
	
	RegisterFunction("AttackParam", [2], null, {
		"Description":"Sets a generic attack parameter directly. This is an advanced function and should be used either when you need some really specific adjustment, or when you want to add functionality without a module.",
		"Arguments":["Parameter name", "Parameter value"],
		"Flags":["Advanced"],
		"Types":["str","int"],
	})
	RegisterFunction("AttackRecievedGetParam", [2, 3], null, {
		"Description":"Extracts a parameter from the recieved attack",
		"Arguments":["Parameter name", "Target Variable", "(Optional) Default Value"],
		"Flags":["Intermediate"],
	})
	RegisterFunction("AttackRecievedSetParam", [2], null, {
		"Description":"Sets a parameter in the recieved attack data",
		"Arguments":["Parameter name", "Parameter Value"],
		"Flags":["Advanced"],
	})
	RegisterFunction("AttackInflictedGetParam", [2, 3], null, {
		"Description":"Extracts a parameter from the inflicted attack",
		"Arguments":["Parameter name", "Target Variable", "(Optional) Default Value"],
		"Flags":["Intermediate"],
	})
	RegisterFunction("AttackInflictedSetParam", [2], null, {
		"Description":"Sets a parameter in the inflicted attack data",
		"Arguments":["Parameter name", "Parameter Value"],
		"Flags":["Advanced"],
	})
	
	
	
	
	
	# [F_STUNS]-------------------------------------------------------------------------------------
	RegisterCategory("Stuns")
	RegisterFunction("AttackFrameAdvantage", [1,2], null, {
		"Description":"Sets an attack's frame advantage automatically on hit and block. This is based on the total duration of the attack and the last use of the multihit flag. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit", "Frame advantage on block"],
		"Flags":["Basic"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackFrameAdvantageHit", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on hit. This is based on the total duration of the attack and the last hit possibility. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackFrameAdvantageBlock", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on block. This is based on the total duration of the attack and the last hit possibility. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on block"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackFA", [1,2], null, {
		"Description":"Sets an attack's frame advantage automatically on hit and block. This is based on the total duration of the attack and the last use of the multihit flag. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit", "Frame advantage on block"],
		"Flags":["Basic"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackFAHit", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on hit. This is based on the total duration of the attack and the last hit possibility. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
		"Arguments":["Frame advantage on hit"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterFunction("AttackFABlock", [1], null, {
		"Description":"Sets an attack's frame advantage automatically on block. This is based on the total duration of the attack and the last hit possibility. Same functionality as AttackSetHitstunBlockstun, but in an easier way.",
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
	RegisterFunction("AttackMinHitstun", [1], null, {
		"Description":"Sets an attack's minimum hitstun hitstun, regardless of proration.",
		"Arguments":["Hitstun"],
		"Flags":["Basic"],
		"Types":["int",],
	})
	RegisterAttackDefault("MinHitstun", 1)
	
	RegisterFunction("AttackHitstop", [1], null, {
		"Description":"Sets an attack's hitstop, which is a small pause when the hit connects.",
		"Arguments":["Hitstop"],
	})
	RegisterFunction("AttackBlockstop", [1], null, {
		"Description":"Sets an attack's blockstop, which is a small pause when the attack is blocked.",
		"Arguments":["Blockstop"],
	})
	RegisterFunction("AttackHitstopBlockstop", [2], null, {
		"Description":"Sets an attack's hitstop and blockstop, which is a small pause when the attack hits or is blocked.",
		"Arguments":["Hitstop", "Blockstop"],
	})
	RegisterAttackDefault("Hitstun", -1)
	RegisterAttackDefault("Blockstun", -1)
	RegisterAttackDefault("Hitstop", 4)
	RegisterAttackDefault("Blockstop", 2)
	RegisterVariableEntity("_HitstunDuration", 0)
	RegisterVariableEntity("_BlockstunDuration", 0)




	
	# [F_DAMAGE] -----------------------------------------------------------------------------------
	RegisterCategory("Damage")
	
	RegisterFunction("AttackDamage", [1], null, {})
	RegisterAttackDefault("Damage", 100)
	RegisterAttackDefault("ChipDamage", 0)
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
	RegisterAttackDefault("MinDamage", 1)





	# [F_BLOCKING] ---------------------------------------------------------------------------------
	RegisterCategory("Blocking")
	RegisterFunction("AttackMustBlock", [1], null, {
		"Description":"Allows an attack to bypass blocking if the opponents doesn't have a corresponding CanBlock- flag. Only one MustBlock and CanBlock need to match for the attack to be blocked.",
		"Arguments":["Property to target (Low, Overhead...)"],
		"Flags":["Basic"],
		"Types":["str"],
	})
	RegisterFunction("AttackUnblockable", [1], null, {
		"Description":"Allows an attack to bypass blocking if the target has the specified flag. Useful for anti-airs (PF_Airborne) and throws (PF_Grounded), which have been made into helper functions.",
		"Arguments":["The flag to target"],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("AttackUnblockableGround", [0], null, {
		"Description":"This attack can't be blocked by grounded opponents. Equivalent to AttackUnblockable(PF_Grounded)",
		"Flags":["Intermediate"],
	})
	RegisterFunction("AttackUnblockableAirborne", [0], null, {
		"Description":"This attack can't be blocked by airborne opponents. Equivalent to AttackUnblockable(PF_Airborne)",
		"Flags":["Intermediate"],
	})
	RegisterAttackFlag("MustBlock-X", {"Description":"Attack can't be blocked unless it has a CanBlock-[X] and Blocking-[X] flag."})
	RegisterAttackFlag("Unblockable-X", {"Description":"Attack can't be blocked if opponent has [X] flag"})
	RegisterAttackFlag("PhaseBlock", {"Description": "Attack counts as missing instead of blocked."})
	RegisterFlag("CanBlock", {"Description":"Allows blocking using the Blocking flag."})
	RegisterFlag("CanBlock-X", {"Description":"Allows blocking attacks using the MustBlock-[X] flag."})
	RegisterFlag("CanBlock-All", {"Description":"Same as CanBlock-[X] for all values of [X]."})
	RegisterFlag("Blocking", {"Description": "Signifies the character is attempting to block, and will do so if abled by the CanBlock flag."})
	RegisterFlag("Blocking-X", {"Description": "Signifies the character is attempting to block [X] attacks, and will do so if abled by a corresponding CanBlock-[X] flag."})
	RegisterFlag("Blocking-All", {"Description": "Counts as Blocking-[X] for all values of [X]."})
	
	
	
	
	
	# [F_OVERRIDES] --------------------------------------------------------------------------------
	RegisterCategory("Overrides")
	RegisterFunction("AttackOverride", [0, 1], null, {
		"Description":"Sets the next parameters to be part of an override. When said override is activated, the parameters will replace the regular ones. See the full documentation for more details.",
		"Arguments":["Override to set (leave empty to cancel)"],
	})
	RegisterFunction("AttackOverrideMultiple", [1, 2, 3, 4, 5, 6], null, {
		"Description":"Adds another override condition to the list, allowing for overrides depending on two distinct activations. See the full documentation for details.",
		"Arguments":["Override to add", "(Optional)", "(Optional)", "(Optional)", "(Optional)", "(Optional)"],
	})
	RegisterFunction("AttackRecievedOverride", [1], null, {
		"Description":"Activates an override on the last recieved attack.",
		"Arguments":["Override to activate"],
	})
	RegisterFunction("AttackInflictedOverride", [1], null, {
		"Description":"Activates an override on the last inflicted attack.",
		"Arguments":["Override to activate"],
	})
	# List of overrides
	# Block, FirstHit, CounterHit, Punish, Hit, Airborne, Grounded, Clash, Multihit
	RegisterVariableEntity("_AttackOverrides", [], ["ResetEachFrame"]) # Sorted
	RegisterAttackDefault("_Overrides", [])
	
	
	
	
	
	# [F_PRORATION] --------------------------------------------------------------------------------
	RegisterCategory("Proration")
	RegisterFunction("AttackProrationHitstun", [1, 2], null, {
		"Description":"Sets an attack's proration for hitstun. The lower it is, the more hitstun will decay with each hit. Values are in permil.",
		"Arguments":["Hit proration", "First hit proration"],
		"Flags":["Intermediate"],
		"Types":["int","int"],
	})
	RegisterFunction("AttackProrationDamage", [1, 2], null, {
		"Description":"Sets an attack's proration for damage. The lower it is, the more damage will decay with each hit. Values are in permil.",
		"Arguments":["Hit proration", "First hit proration"],
		"Flags":["Intermediate"],
		"Types":["int","int"],
	})
	RegisterAttackDefault("ProrationDamage", 1000)
	RegisterAttackDefault("ProrationHitstun", 1000)
	RegisterAttackFlag("IgnoreProrationDamage")
	RegisterAttackFlag("IgnoreProrationHitstun")
	RegisterAttackFlag("IgnoreProration")
	
	
	
	
	# [F_MOVEMENT] ---------------------------------------------------------------------------------
	RegisterCategory("Movement")
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
	RegisterAttackDefault("MomentumX", 1000)
	RegisterAttackDefault("MomentumY", 0)
	RegisterAttackDefault("MomentumZ", 0)
	RegisterAttackDefault("InheritMomentumX", 0)
	RegisterAttackDefault("InheritMomentumY", 0)
	RegisterAttackDefault("InheritMomentumZ", 0)
	
	RegisterFunction("AttackFloat", [1], null, {
		"Description":"Sets the opponent's gravity on hit to the specified value until the next attack.",
		"Arguments":["New Gravity"],
		"Flags":["Intermediate"],
		"Types":["int",],
	})
	RegisterAttackDefault("FloatGravity", 0)
	RegisterVariableEntity("_HitstunGravityFloat", 0)
	
	
	RegisterCategory("Special")
	
	
	RegisterFunction("AttackKnockdown", [0,1,2], null, {
		"Description":"Sets an attack's minimum and maximum time on knockdown. Automatically applies the knockdown attack flag. If no arguments are given, use default values. If only one is given, the second is computed automatically from the difference between defaults.",
		"Arguments":["(Optional) The minimum knockdown time", "(Optional) Maximum knockdown time"],
		"Flags":["Intermediate"],
		"Types":["int","int"],
	})
	#RegisterFunction("AttackGroundbounce", [1,2], null, {
	#	"Description":"Sets an attack's groundbounce",
	#	"Arguments":["Groundbounce time", "Groundbounce Momentum"],
	#	"Flags":["Intermediate"],
	#	"Types":["int","int","int"],
	#})
	RegisterAttackDefault("KnockdownTimeMin", 13)
	RegisterAttackDefault("KnockdownTimeMax", 43)

	#RegisterAttackDefault("GroundbounceTime", 30)
	#RegisterAttackDefault("GroundbounceMomentum", 1000)
	RegisterVariableEntity("_KnockdownTimeMin", 13)
	RegisterVariableEntity("_KnockdownTimeMax", 43)
	RegisterVariableEntity("_GroundbounceTime", 0)
	RegisterVariableEntity("_GroundbounceMomentum", 0)
	
	
	RegisterFunction("AttackTransitionTo", [1], null, {
		"Description": "The attack will make the defender transition to another state on hit.",
		"Arguments": ["The state to transition to"],
	})
	RegisterAttackDefault("TransitionTo", "Hitstun")
	
	RegisterCategory("Misc")
	
	

	RegisterStateFlag("Attack")
	
	RegisterStateFlag("AttackMB-Low")
	RegisterStateFlag("AttackMB-Overhead")
	RegisterStateFlag("AttackUB-PF_Grounded")
	RegisterStateFlag("AttackUB-PF_Airborne")
	
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





	# [F_CANCELS] ----------------------------------------------------------------------------------
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
	RegisterFunction("AttackCancelPrefix", [0,1], ["Action", "Freeze"], {
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
	RegisterVariableEntity("_AttackInitialOutFrame", -1)
	RegisterVariableEntity("_AttackHitconfirm_State", null)
	RegisterVariableEntity("_AttackPossibleCancelsWhiff", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsBlock", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsHit", {}, ["ResetEachFrame"])
	RegisterVariableEntity("_AttackPossibleCancelsNeutral", {}, ["ResetEachFrame"])
	RegisterFlag("AttackHasHit")
	RegisterFlag("AttackWasBlocked")
	RegisterFlag("AttackHasWhiffed")
	RegisterFlag("AttackHasTouched")
	RegisterFlag("AttackStartup")
	RegisterFlag("AttackWasActive")


func RegisterAttackFlag(flagName, data = null):
	RegisterFlag(ATTACK_FLAG_PREFIX+flagName, data)
func RegisterAttackDefault(fieldName, value):
	RegisterConfig("AttackDefault-"+fieldName, value)

var _defaultAttackData = {}
var _knockdownDefaultTimeDiff = 0
func BattleInit(stateHandle, _battleInitData):
	_defaultAttackData = {}

	# Take variables from the config stating with AttackDefault
	var configDerivedDataPrefix = "AttackDefault-"
	for configKeyName in stateHandle.ConfigData().GetConfigKeys():
		if(configKeyName.begins_with(configDerivedDataPrefix)):
			var attackDataName = configKeyName.right(configDerivedDataPrefix.length())
			_defaultAttackData[attackDataName] = stateHandle.ConfigData().Get(configKeyName)

	_knockdownDefaultTimeDiff = max(0, stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMax") - stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMin"))

func InitPhaseStartEntity(stateHandle):
	var fighterScripts = engine.GetFighterAllScripts(stateHandle.EntityGet("_FighterID"))
	var entityName = stateHandle.EntityGet("_Entity")#stateHandle.EntityGet("_State").right(5) # Init-
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
	
	stateHandle.EntitySet("_RecievedAttackData", _defaultAttackData.duplicate(true))

func ActionPhaseStartEntity(stateHandle):
	_HandleAttackFlagSet(stateHandle)
	var attackData = _defaultAttackData.duplicate(true)
	stateHandle.EntitySet("_AttackData", attackData)
	_UpdateAttackHitFlags(stateHandle)
func ActionPhaseEndEntity(stateHandle):
	if(stateHandle.EntityGet("_AttackInitialOutFrame") < 0 and !stateHandle.EntityHasFlag("NoHitboxSet")):
		stateHandle.EntitySet("_AttackInitialOutFrame", stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame"))

func _HandleAttackFlagUnset(stateHandle):
	for laf in stateHandle.EntityGet("_RecievedAttackData")["_Flags"]:
		stateHandle.EntitySetFlag(ATTACK_FLAG_PREFIX +laf, false)
func _HandleAttackFlagSet(stateHandle):
	for af in stateHandle.EntityGet("_RecievedAttackData")["_Flags"]:
		stateHandle.EntitySetFlag(ATTACK_FLAG_PREFIX +af)

func FreezePhaseStartEntity(stateHandle):
	_HandleAttackFlagSet(stateHandle)
	_UpdateAttackHitFlags(stateHandle)

func PhysicsPhaseEndEntity(stateHandle):
	# :TODO:Panthavma:20220314:Optim: Maybe replace the string check by a int
	var hitconfirmState = stateHandle.EntityGet("_AttackHitconfirm_State")
	if(stateHandle.EntityGet("_Hitboxes").size() > 0 and hitconfirmState == null):
		stateHandle.EntitySet("_AttackHitconfirm_State", "Whiff")
		# :TODO:Panthavma:20220525:Improve whiff detection to be AFTER hitboxes disappear
	_UpdateAttackHitFlags(stateHandle)
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
		var cancelData = cancelList[rawNotation]
		var attackName = cancelData["State"]
		var attackPriority = cancelData["Priority"]

		if(stateHandle.EntityGet("_AttackDoneCancels").has(attackName)):
			continue
		inputModule.AddInputTransitionFlag(stateHandle, notation, attackName, null, null, cancelData)


func _UpdateAttackHitFlags(stateHandle):
	var hitconfirmState = stateHandle.EntityGet("_AttackHitconfirm_State")
	stateHandle.EntitySetFlag("AttackHasHit", (hitconfirmState == "Hit"))
	stateHandle.EntitySetFlag("AttackWasBlocked", (hitconfirmState == "Block"))
	stateHandle.EntitySetFlag("AttackHasWhiffed", (hitconfirmState == "Whiff"))
	stateHandle.EntitySetFlag("AttackHasTouched", (hitconfirmState == "Hit") or (hitconfirmState == "Block"))





# Returns true if the hit is confirmed and search should stop
func HandleHit(attackerHandle, defenderHandle, hitbox, hurtbox):
	var attackData = hitbox["AttackData"]
	
	var attackHit = IsAttackHitting(attackData, attackerHandle, hitbox, defenderHandle, hurtbox)
	if(attackHit == Castagne.HITCONFIRMED.NONE):
		return false
	
	ApplyAttackToEntities(attackHit, attackData, attackerHandle, hitbox, defenderHandle, hurtbox)
	
	return true


func IsAttackHitting(attackData, attackerHandle, hitbox, defenderHandle, hurtbox):
	# Preliminary check: can we still hit with that attack or are we clashing ?
	if(attackerHandle.EntityGet("_AttackHitEntities").has(defenderHandle.EntityGet("_EID"))):
		return Castagne.HITCONFIRMED.NONE
	if(hurtbox["Hitbox"]):
		return Castagne.HITCONFIRMED.CLASH
	
	# Basic check: can and are we trying to block ?
	var dCanBlock = defenderHandle.EntityHasFlag("CanBlock")
	var dBlocking = defenderHandle.EntityHasFlag("Blocking")
	if(!dCanBlock or !dBlocking):
		return Castagne.HITCONFIRMED.HIT
	
	# Gather some blocking info from the attack
	var attackFlags = attackData["_Flags"]
	var mustBlocks = []
	var unblockables = []
	for af in attackFlags:
		if(af.begins_with("MustBlock-")):
			mustBlocks.push_back(af.right(10))
		elif(af.begins_with("Unblockable-")):
			unblockables.push_back(af.right(12))
	
	# Block break: in we must block a certain way, can we and are we ?
	var dCanBlockAll = defenderHandle.EntityHasFlag("CanBlock-All")
	var dBlockingAll = defenderHandle.EntityHasFlag("Blocking-All")
	for mb in mustBlocks:
		if(!(dCanBlockAll or defenderHandle.EntityHasFlag("CanBlock-"+mb))
			or !(dBlockingAll or defenderHandle.EntityHasFlag("Blocking-"+mb))):
			return Castagne.HITCONFIRMED.HIT
	
	# Unblockable break: if the defender has a certain flag, he can't defend
	for ub in unblockables:
		if(defenderHandle.EntityHasFlag(ub)):
			return Castagne.HITCONFIRMED.HIT
	
	# We successfully blocked! Last check to see if we register it as a block or a miss
	var phaseBlock = ("PhaseBlock" in attackFlags)
	return Castagne.HITCONFIRMED.NONE if phaseBlock else Castagne.HITCONFIRMED.BLOCK
	
	



# Does the actual attack behavior by calling the given callbacks
func ApplyAttackToEntities(hitconfirm, attackData, attackerHandle, hitbox, defenderHandle, hurtbox):
	var hit = (hitconfirm != Castagne.HITCONFIRMED.BLOCK)
	var clashed = (hitconfirm == Castagne.HITCONFIRMED.CLASH)
	
	var attackerEID = attackerHandle.EntityGet("_EID")
	var defenderEID = defenderHandle.EntityGet("_EID")
	
	var hitBlock = ("Hit" if hit else "Block")
	attackerHandle.EntitySet("_AttackHitconfirm_State", hitBlock)
	attackerHandle.EntityAdd("_AttackHitEntities", [defenderEID])
	
	var engine = defenderHandle.Engine()
	attackData = attackData.duplicate()
	
	# Clash has a different flow, with just one call
	if(clashed):
		attackerHandle.EntitySet("_InflictedAttackData", attackData)
		engine.ExecuteCASPCallback("CCB_OnAttackClashed", attackerHandle, defenderEID, "Manual")
		return
	
	# Multihit test
	if(defenderEID in attackerHandle.EntityGet("_AttackHitEntitiesMultihit")):
		_ADApplyOverride(attackData, "Multihit")
	else:
		attackerHandle.EntityAdd("_AttackHitEntitiesMultihit", [defenderEID])
	
	# Initial call: helps to apply overrides mostly before attacker gets to it
	var initialCallback = "CCB_OnHitRecieved_Initial" if hit else "CCB_OnBlock_Initial"
	_HandleAttackFlagUnset(defenderHandle)
	defenderHandle.EntitySet("_RecievedAttackData", attackData)
	_HandleAttackFlagSet(defenderHandle)
	engine.ExecuteCASPCallback(initialCallback, defenderHandle, attackerEID, "Manual")
	
	# Attacker call: So he can read back data for the hit
	var attackerCallback = "CCB_OnAttackHit" if hit else "CCB_OnAttackBlocked"
	attackerHandle.EntitySet("_InflictedAttackData", defenderHandle.EntityGet("_RecievedAttackData"))
	engine.ExecuteCASPCallback(attackerCallback, attackerHandle, defenderEID, "Manual")
	attackData = attackerHandle.EntityGet("_InflictedAttackData").duplicate()
	
	# Defender call: finally, apply attack to the defender, main part
	var defenderCallback = "CCB_OnHitRecieved" if hit else "CCB_OnBlock"
	_HandleAttackFlagUnset(defenderHandle)
	defenderHandle.EntitySet("_RecievedAttackData", attackData)
	_HandleAttackFlagSet(defenderHandle)
	engine.ExecuteCASPCallback(defenderCallback, defenderHandle, attackerEID, "Manual")



























# [F_BASICS] ---------------------------------------------------------------------------------------
func AttackRegister(args, stateHandle):
	AttackRegisterNoNotation(args, stateHandle)
func AttackRegisterNoNotation(_args, _stateHandle):
	# Should never get called
	pass
func AttackAddNotation(_args, _stateHandle):
	pass
func AttackInternalRegister(_args, _stateHandle):
	pass
func AttackInternalRegisterNoNotation(_args, _stateHandle):
	pass
func AttackInit(args, stateHandle):
	if(stateHandle.EntityGet("_StateFrameID") == 1):
		stateHandle.EntityAdd("_AttackDoneCancels", [stateHandle.EntityGet("_State")])

func AttackDuration(args, stateHandle):
	stateHandle.EntitySet("_AttackDuration", ArgInt(args, stateHandle, 0))
	if(stateHandle.EntityGet("_AttackData")["Hitstun"] <= 0):
		AttackFrameAdvantageHit([0], stateHandle)
	if(stateHandle.EntityGet("_AttackData")["Blockstun"] <= 0):
		AttackFrameAdvantageBlock([0], stateHandle) # TODO: fix

func AttackRearm(args, stateHandle):
	stateHandle.EntitySet("_AttackInitialOutFrame", -1)
	stateHandle.EntitySet("_AttackHitEntitiesMultihit", [])
	stateHandle.EntitySet("_AttackHitEntities", [])
	stateHandle.EntitySet("_AttackHitconfirm_State", null)
	_UpdateAttackHitFlags(stateHandle)
func AttackMultihit(args, stateHandle):
	stateHandle.EntitySet("_AttackHitEntities", [])
	stateHandle.EntitySet("_AttackInitialOutFrame", -1)




# [F_GENERICS] -------------------------------------------------------------------------------------
func AttackFlag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	var p = _GetCurrentOverridePrefix(stateHandle)
	var flagField = p + "_Flags"
	if not (flagField in stateHandle.EntityGet("_AttackData")):
		stateHandle.EntityGet("_AttackData")[flagField] = [flagName]
		return
	if(!flagName in stateHandle.EntityGet("_AttackData")[flagField]):
		stateHandle.EntityGet("_AttackData")[flagField] += [flagName]
func AttackUnflag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	var p = _GetCurrentOverridePrefix(stateHandle)
	var flagField = p + "_Flags"
	if(p != ""):
		flagField = p + "_Unflag"
		if not (flagField in stateHandle.EntityGet("_AttackData")):
			stateHandle.EntityGet("_AttackData")[flagField] = [flagName]
			return
		if(!flagName in stateHandle.EntityGet("_AttackData")[flagField]):
			stateHandle.EntityGet("_AttackData")[flagField] += [flagName]
	else:
		if(flagName in stateHandle.EntityGet("_AttackData")["_Flags"]):
			stateHandle.EntityGet("_AttackData")["_Flags"].erase(flagName)
func AttackRecievedFlag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(!flagName in stateHandle.EntityGet("_RecievedAttackData")["_Flags"]):
		stateHandle.EntityGet("_RecievedAttackData")["_Flags"] += [flagName]
		stateHandle.EntitySetFlag(ATTACK_FLAG_PREFIX + flagName)
func AttackRecievedUnflag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(flagName in stateHandle.EntityGet("_RecievedAttackData")["_Flags"]):
		stateHandle.EntityGet("_RecievedAttackData")["_Flags"].erase(flagName)
		stateHandle.EntitySetFlag(ATTACK_FLAG_PREFIX + flagName, false)
func AttackInflictedFlag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(!flagName in stateHandle.EntityGet("_InflictedAttackData")["_Flags"]):
		stateHandle.EntityGet("_InflictedAttackData")["_Flags"] += [flagName]
		stateHandle.EntitySetFlag(ATTACK_FLAG_PREFIX + flagName)
func AttackInflictedUnflag(args, stateHandle):
	var flagName = ArgStr(args, stateHandle, 0)
	if(flagName in stateHandle.EntityGet("_InflictedAttackData")["_Flags"]):
		stateHandle.EntityGet("_InflictedAttackData")["_Flags"].erase(flagName)


func AttackParam(args, stateHandle):
	var paramName = ArgStr(args, stateHandle, 0)
	var value = ArgInt(args, stateHandle, 1)
	_ADSet(stateHandle, paramName, value)
func AttackRecievedGetParam(args, stateHandle, attackDataName = "_RecievedAttackData"):
	var paramName = ArgRaw(args, 0)
	var targetVariable = ArgVar(args, stateHandle, 1)
	var recievedAttackData = stateHandle.EntityGet(attackDataName)
	var value = 0
	if(recievedAttackData.has(paramName)):
		value = recievedAttackData[paramName]
	elif(args.size() >= 3):
		value = ArgInt(args, stateHandle, 2)
	else:
		#AttackRecievedGetParam AttackInflictedGetParam (for search use)
		ModuleError("Attack"+("Recieved" if attackDataName == "_RecievedAttackData" else "Inflicted")+"GetParam: Can't find parameter "+str(paramName)+"!", stateHandle)
		return
	stateHandle.EntitySet(targetVariable, value)
func AttackRecievedSetParam(args, stateHandle, attackDataName = "_RecievedAttackData"):
	var paramName = ArgRaw(args, 0)
	var paramValue = ArgInt(args, stateHandle, 1)
	var recievedAttackData = stateHandle.EntityGet(attackDataName)
	recievedAttackData[paramName] = paramValue
	stateHandle.EntitySet(attackDataName, recievedAttackData)
func AttackInflictedGetParam(args, stateHandle):
	AttackRecievedGetParam(args, stateHandle, "_InflictedAttackData")
func AttackInflictedSetParam(args, stateHandle):
	AttackRecievedSetParam(args, stateHandle, "_InflictedAttackData")





# [F_STUNS]-----------------------------------------------------------------------------------------
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
	var initialFrame = stateHandle.EntityGet("_AttackInitialOutFrame")
	if(initialFrame < 0):
		initialFrame = stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame")
	var neutralFA = stateHandle.EntityGet("_AttackDuration") - initialFrame
	_ADSet(stateHandle, stunType, max(neutralFA + FA, 1))
func AttackFA(args, stateHandle):
	AttackFrameAdvantage(args, stateHandle)
func AttackFAHit(args, stateHandle):
	AttackFrameAdvantageHit(args, stateHandle)
func AttackFABlock(args, stateHandle):
	AttackFrameAdvantageBlock(args, stateHandle)
func AttackHitstunBlockstun(args, stateHandle):
	_ADSet(stateHandle, "Hitstun", max(ArgInt(args, stateHandle, 0),1))
	_ADSet(stateHandle, "Blockstun", max(ArgInt(args, stateHandle, 1),1))
func AttackHitstun(args, stateHandle):
	_ADSet(stateHandle, "Hitstun", max(ArgInt(args, stateHandle, 0),1))
func AttackBlockstun(args, stateHandle):
	_ADSet(stateHandle, "Blockstun", max(ArgInt(args, stateHandle, 0),1))
func AttackMinHitstun(args, stateHandle):
	_ADSet(stateHandle, "MinHitstun", max(ArgInt(args, stateHandle, 0),1))
func AttackHitstopBlockstop(args, stateHandle):
	_ADSet(stateHandle, "Hitstop", max(ArgInt(args, stateHandle, 0),1))
	_ADSet(stateHandle, "Blockstop", max(ArgInt(args, stateHandle, 1),1))
func AttackHitstop(args, stateHandle):
	_ADSet(stateHandle, "Hitstop", max(ArgInt(args, stateHandle, 0),1))
func AttackBlockstop(args, stateHandle):
	_ADSet(stateHandle, "Blockstop", max(ArgInt(args, stateHandle, 0),1))
	




# [F_DAMAGE] ---------------------------------------------------------------------------------------
func AttackDamage(args, stateHandle):
	_ADSet(stateHandle, "Damage", ArgInt(args, stateHandle, 0))
func AttackChipDamage(args, stateHandle):
	_ADSet(stateHandle, "ChipDamage",  ArgInt(args, stateHandle, 0))
func AttackMinDamage(args, stateHandle):
	_ADSet(stateHandle, "MinDamage",  ArgInt(args, stateHandle, 0))





# [F_BLOCKING] -------------------------------------------------------------------------------------
func AttackMustBlock(args, stateHandle):
	var flag = ArgRaw(args, 0)
	AttackFlag(["MustBlock-"+flag], stateHandle)
func AttackUnblockable(args, stateHandle):
	var flag = ArgRaw(args, 0)
	AttackFlag(["Unblockable-"+flag], stateHandle)
func AttackUnblockableGround(_args, stateHandle):
	AttackUnblockable(["Grounded"], stateHandle)
func AttackUnblockableAirborne(_args, stateHandle):
	AttackUnblockable(["Airborne"], stateHandle)




# [F_OVERRIDES] ------------------------------------------------------------------------------------
func AttackOverride(args, stateHandle):
	var o = []
	if(args.size() > 0):
		o = [ArgStr(args, stateHandle, 0)]
	stateHandle.EntitySet("_AttackOverrides", o)
func AttackOverrideMultiple(args, stateHandle):
	var o = stateHandle.EntityGet("_AttackOverrides")
	for i in range(args.size()):
		var a = ArgStr(args, stateHandle, i)
		if not a in o:
			o.push_back(a)
	o.sort()
	stateHandle.EntitySet("_AttackOverrides", o)
func AttackRecievedOverride(args, stateHandle, attackDataName = "_RecievedAttackData"):
	var ad = stateHandle.EntityGet(attackDataName)
	var o = ArgStr(args, stateHandle, 0)
	ad = _ADApplyOverride(ad, o)
	stateHandle.EntitySet(attackDataName, ad)
func AttackInflictedOverride(args, stateHandle):
	AttackRecievedOverride(args, stateHandle, "_InflictedAttackData")



# [F_PRORATION] ------------------------------------------------------------------------------------
func AttackProrationHitstun(args, stateHandle):
	var p = ArgInt(args, stateHandle, 0)
	_ADSet(stateHandle, "ProrationHitstun", p)
	_ADSetPlusOverrides(stateHandle, "ProrationHitstun", ArgInt(args, stateHandle, 1, p), ["FirstHit"])
func AttackProrationDamage(args, stateHandle):
	var p = ArgInt(args, stateHandle, 0)
	_ADSet(stateHandle, "ProrationDamage", p)
	_ADSetPlusOverrides(stateHandle, "ProrationDamage", ArgInt(args, stateHandle, 1, p), ["FirstHit"])





# [F_MOVEMENT] ---------------------------------------------------------------------------------
func AttackMomentum(args, stateHandle):
	AttackMomentumHit(args, stateHandle)
	AttackMomentumBlock(args, stateHandle)
func AttackMomentumHit(args, stateHandle):
	var mh = ArgInt(args, stateHandle, 0)
	var mv = ArgInt(args, stateHandle, 1, 0)
	_ADSet(stateHandle, "MomentumX",  mh)
	_ADSet(stateHandle, "MomentumY",  mv)
	_ADSetPlusOverrides(stateHandle, "MomentumX", ArgInt(args, stateHandle, 2, mh), ["Airborne"], ["Grounded"])
	_ADSetPlusOverrides(stateHandle, "MomentumY", ArgInt(args, stateHandle, 3, mv), ["Airborne"], ["Grounded"])
func AttackMomentumBlock(args, stateHandle):
	var mh = ArgInt(args, stateHandle, 0)
	var mv = ArgInt(args, stateHandle, 1, 0)
	_ADSetPlusOverrides(stateHandle, "MomentumX", mh, ["Block"], ["Hit"])
	_ADSetPlusOverrides(stateHandle, "MomentumY", mv, ["Block"], ["Hit"])
	_ADSetPlusOverrides(stateHandle, "MomentumX", ArgInt(args, stateHandle, 2, mh), ["Airborne", "Block"], ["Grounded", "Hit"])
	_ADSetPlusOverrides(stateHandle, "MomentumY", ArgInt(args, stateHandle, 3, mv), ["Airborne", "Block"], ["Grounded", "Hit"])
func AttackInheritMomentum(args, stateHandle):
	AttackInheritMomentumHit(args, stateHandle)
	AttackInheritMomentumBlock(args, stateHandle)
func AttackInheritMomentumHit(args, stateHandle, onBlock = false):
	#AttackFlag(["InheritMomentum"+situation], stateHandle)
	var imGroundX = ArgInt(args, stateHandle, 0, 1000)
	var imGroundY = ArgInt(args, stateHandle, 1, imGroundX)
	var imAirX = ArgInt(args, stateHandle, 2, imGroundX)
	var imAirY = ArgInt(args, stateHandle, 3, imGroundY)
	
	if(onBlock):
		_ADSetPlusOverrides(stateHandle, "InheritMomentumX", imGroundX, ["Block"], ["Hit"])
		_ADSetPlusOverrides(stateHandle, "InheritMomentumY", imGroundY, ["Block"], ["Hit"])
		_ADSetPlusOverrides(stateHandle, "InheritMomentumX", imAirX, ["Airborne", "Block"], ["Grounded", "Hit"])
		_ADSetPlusOverrides(stateHandle, "InheritMomentumY", imAirY, ["Airborne", "Block"], ["Grounded", "Hit"])
	else:
		_ADSet(stateHandle, "InheritMomentumX", imGroundX)
		_ADSet(stateHandle, "InheritMomentumY", imGroundY)
		_ADSetPlusOverrides(stateHandle, "InheritMomentumX", imAirX, ["Airborne"], ["Grounded"])
		_ADSetPlusOverrides(stateHandle, "InheritMomentumY", imAirY, ["Airborne"], ["Grounded"])
func AttackInheritMomentumBlock(args, stateHandle):
	AttackInheritMomentumHit(args, stateHandle, true)





# [F_CANCELS] ----------------------------------------------------------------------------------
func AttackCancel(args, stateHandle):
	var attackName = ArgStr(args, stateHandle, 0)
	var notation = ArgStr(args, stateHandle, 1, attackName)
	var flags = ArgInt(args, stateHandle, 2, 1+2+8) # ATTACKCANCEL_ON_TOUCH_NEUTRAL
	var priority = ArgInt(args, stateHandle, 3, stateHandle.ConfigData().Get("AttackCancelPriorityDefault"))
	AddAttackCancel(stateHandle, notation, attackName, flags, priority)

func AttackAddRegisteredCancels(args, stateHandle):
	var type = ArgStr(args, stateHandle, 0)
	var flags = ArgInt(args, stateHandle, 1, 1+2+8) # ATTACKCANCEL_ON_TOUCH_NEUTRAL
	var priority = ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("AttackCancelPriorityDefault"))

	var registeredAttacks = stateHandle.EntityGet("_RegisteredAttacksForEntityByType")
	if(registeredAttacks.has(type)):
		for notation in registeredAttacks[type]:
			var attackName = registeredAttacks[type][notation]
			AddAttackCancel(stateHandle, notation, attackName, flags, priority)

func AddAttackCancel(stateHandle, notation, attackName, flags, priority):
	var flagsRef = ["Hit", "Block", "Whiff", "Neutral"]
	for i in range(flagsRef.size()):
		if(flags % 2):
			stateHandle.EntityGet("_AttackPossibleCancels"+flagsRef[i])[notation] = {
				"State":attackName,
				"Priority":priority,
				}
		flags /= 2

func _AttackCancelRegister(args, stateHandle, lists):
	var notation = ArgStr(args, stateHandle, 0)
	var attackName = ArgStr(args, stateHandle, 1, notation)
	var attackPriority = ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("AttackCancelPriorityDefault"))
	for l in lists:
		stateHandle.EntityGet("_AttackPossibleCancels"+l)[notation] = {
			"State":attackName,
			"Priority":attackPriority,
			}

func AttackCancelPrefix(args, stateHandle):
	var acp = ArgStr(args, stateHandle, 0, "")
	stateHandle.EntitySet("_AttackCancelPrefix", acp)
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










































func AttackAttribute(args, stateHandle):
	_ADSet(stateHandle, "Attribute", ArgStr(args, stateHandle, 0, "Auto"))







func AttackFloat(args, stateHandle):
	_ADSet(stateHandle, "FloatGravity",  -ArgInt(args, stateHandle, 0))
	AttackFlag(["Float"], stateHandle)

func AttackKnockdown(args, stateHandle):
	AttackFlag(["Knockdown"], stateHandle)
	var kdMin = stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMin")
	var kdMax = stateHandle.ConfigData().Get("AttackDefault-KnockdownTimeMax")

	if(args.size() >= 1):
		kdMin = max(1, ArgInt(args, stateHandle, 0, kdMin))
		kdMax = max(kdMin, ArgInt(args, stateHandle, 1, kdMin+_knockdownDefaultTimeDiff))

	_ADSet(stateHandle, "KnockdownTimeMin", kdMin)
	_ADSet(stateHandle, "KnockdownTimeMax", kdMax)

func AttackGroundbounce(args, stateHandle):
	AttackFlag(["Groundbounce"], stateHandle)
	_ADSet(stateHandle, "GroundbounceTime", ArgInt(args, stateHandle, 0, stateHandle.ConfigData().Get("AttackDefault-GroundbounceTime")))
	_ADSet(stateHandle, "GroundbounceMomentum", ArgInt(args, stateHandle, 1, stateHandle.ConfigData().Get("AttackDefault-GroundbounceMomentum")))
	#_ADSet(stateHandle, "MaxGroundbounces", ArgInt(args, stateHandle, 2, stateHandle.ConfigData().Get("AttackDefault-MaxGroundbounces")))

func AttackTransitionTo(args, stateHandle):
	var targetState = ArgStr(args, stateHandle, 0)
	_ADSet(stateHandle, "TransitionTo", targetState)











# ----
# Helpers


func _GetOverridePrefix(overrides):
	# we assume its sorted
	var p = ""
	for o in overrides:
		p += str(o)+"-"
	return p
func _GetCurrentOverridePrefix(stateHandle):
	return _GetOverridePrefix(stateHandle.EntityGet("_AttackOverrides"))
func _ADSet(stateHandle, fieldName, value):
	_ADSetDirect(stateHandle, _GetCurrentOverridePrefix(stateHandle) + fieldName, value)
func _ADSetDirect(stateHandle, fieldName, value):
	stateHandle.EntityGet("_AttackData")[fieldName] = value
func _ADSetCustomOverrides(stateHandle, fieldName, value, overrides):
	overrides.sort()
	_ADSetDirect(stateHandle, _GetOverridePrefix(overrides) + fieldName, value)
func _ADSetPlusOverrides(stateHandle, fieldName, value, overridesToAdd, overridesToDelete = []):
	var o = stateHandle.EntityGet("_AttackOverrides").duplicate()
	for oD in overridesToDelete:
		o.erase(oD)
	for oA in overridesToAdd:
		if not oA in o:
			o.push_back(oA)
	o.sort()
	_ADSetDirect(stateHandle, _GetOverridePrefix(o) + fieldName, value)
func _ADApplyOverride(attackData, newOverride):
	var appliedOverrides = attackData["_Overrides"]
	if(newOverride in appliedOverrides):
		return attackData
	appliedOverrides.push_back(newOverride)
	
	var multipleOverrides = {}
	
	# Apply single overrides while gathing the multiple overrides
	for fullfield in attackData:
		if(fullfield.begins_with("_")):
			continue # Special fields like flags and overrides
		var sep = fullfield.find_last("-")
		if(sep == -1):
			continue # no override here
		var overridesText = fullfield.left(sep)
		var overrides = overridesText.split("-")
		var field = fullfield.right(sep+1)
		if(overrides.size() == 1):
			if(overrides[0] == newOverride):
				attackData[field] = attackData[fullfield]
		else:
			# Check if this is active
			var apply = true
			if not (newOverride in overrides):
				# If the new one is lacking, don't do it
				apply = false
			else:
				for o in overrides:
					# If one isn't active, don't do it
					if not (o in appliedOverrides):
						apply = false
						break
			if(!apply):
				continue
			
			if not overridesText in multipleOverrides:
				multipleOverrides[overridesText] = {
					"Overrides":overrides,
					"NbOverrides":overrides.size(),
					"OverridesText":overridesText,
					"Fields":[]
				}
			# TODO: Check overrides
			multipleOverrides[overridesText]["Fields"].push_back([field, attackData[fullfield]])
			
	
	# Sort the multiple overrides and apply them in order
	# Maybe not most efficient but at this point what is ? Will do a better system later in v0.7
	multipleOverrides = multipleOverrides.values()
	multipleOverrides.sort_custom(self, "_AD_SortOverrideLists")
	
	for i in range(-1, multipleOverrides.size()):
		# Apply flags
		var ovprefix = (newOverride+"-" if i == -1 else multipleOverrides[i]["OverridesText"])
		var flagsField = ovprefix+"_Flags"
		var unflagsField = ovprefix+"_Unflags"
		
		if(flagsField in attackData):
			var flags = attackData[flagsField]
			for f in flags:
				if not (f in attackData["_Flags"]):
					attackData["_Flags"].push_back(f)
		if(unflagsField in attackData):
			var unflags = attackData[unflagsField]
			for uf in unflags:
				attackData["_Flags"].erase(uf)
		
		if(i == -1):
			continue
		# Apply multiple overrides one after the other
		var mo = multipleOverrides[i]
		for f in mo["Fields"]:
			attackData[f[0]] = f[1]
	
	return attackData
func _AD_SortOverrideLists(a, b):
	if(a["NbOverrides"] < b["NbOverrides"]):
		return true
	elif(a["NbOverrides"] > b["NbOverrides"]):
		return false
	else:
		return a["OverridesText"] < b["OverridesText"]
		# Should work, as "-" is before characters on the ascii table, so it should serve as a natural separator
