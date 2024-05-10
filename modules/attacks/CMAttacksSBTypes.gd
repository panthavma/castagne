# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Attacks - Types")
	SetForMainEntitySubEntity(true, false)
	
	AddCategory("All Attacks")
	AddDefine("ATTACK_MinDamage", 20, "Minimum Damage")
	
	AddCategory("Light Attacks")
	AddCategory("Light Attacks/Proration")
	AddDefine("ATTACK_Light_ProrationDamageStarter", 900, "Damage Proration (Starter)")
	AddDefine("ATTACK_Light_ProrationDamage", 900, "Damage Proration")
	AddDefine("ATTACK_Light_ProrationHitstunStarter", 900, "Hitstun Proration (Starter)")
	AddDefine("ATTACK_Light_ProrationHitstun", 980, "Hitstun Proration")
	AddCategory("Light Attacks/Cancels")
	AddDefine("ATTACK_Light_CanCancelIntoLights", true, "Can Cancel into Lights")
	AddDefine("ATTACK_Light_CanCancelIntoMediums", true, "Can Cancel into Mediums")
	AddDefine("ATTACK_Light_CanCancelIntoHeavies", true, "Can Cancel into Heavies")
	AddDefine("ATTACK_Light_CanCancelIntoSpecials", true, "Can Cancel into Specials")
	
	AddCategory("Medium Attacks")
	AddCategory("Medium Attacks/Proration")
	AddDefine("ATTACK_Medium_ProrationDamageStarter", 1000, "Damage Proration (Starter)")
	AddDefine("ATTACK_Medium_ProrationDamage", 900, "Damage Proration")
	AddDefine("ATTACK_Medium_ProrationHitstunStarter", 1000, "Hitstun Proration (Starter)")
	AddDefine("ATTACK_Medium_ProrationHitstun", 980, "Hitstun Proration")
	AddCategory("Medium Attacks/Cancels")
	AddDefine("ATTACK_Medium_CanCancelIntoLights", false, "Can Cancel into Lights")
	AddDefine("ATTACK_Medium_CanCancelIntoMediums", true, "Can Cancel into Mediums")
	AddDefine("ATTACK_Medium_CanCancelIntoHeavies", true, "Can Cancel into Heavies")
	AddDefine("ATTACK_Medium_CanCancelIntoSpecials", true, "Can Cancel into Specials")
	
	AddCategory("Heavy Attacks")
	AddCategory("Heavy Attacks/Proration")
	AddDefine("ATTACK_Heavy_ProrationDamageStarter", 1000, "Damage Proration (Starter)")
	AddDefine("ATTACK_Heavy_ProrationDamage", 900, "Damage Proration")
	AddDefine("ATTACK_Heavy_ProrationHitstunStarter", 1000, "Hitstun Proration (Starter)")
	AddDefine("ATTACK_Heavy_ProrationHitstun", 980, "Hitstun Proration")
	AddCategory("Heavy Attacks/Cancels")
	AddDefine("ATTACK_Heavy_CanCancelIntoLights", false, "Can Cancel into Lights")
	AddDefine("ATTACK_Heavy_CanCancelIntoMediums", false, "Can Cancel into Mediums")
	AddDefine("ATTACK_Heavy_CanCancelIntoHeavies", true, "Can Cancel into Heavies")
	AddDefine("ATTACK_Heavy_CanCancelIntoSpecials", true, "Can Cancel into Specials")
	
	AddCategory("Special Attacks")
	AddCategory("Special Attacks/Proration")
	AddDefine("ATTACK_Special_ProrationDamageStarter", 1000, "Damage Proration (Starter)")
	AddDefine("ATTACK_Special_ProrationDamage", 900, "Damage Proration")
	AddDefine("ATTACK_Special_ProrationHitstunStarter", 1000, "Hitstun Proration (Starter)")
	AddDefine("ATTACK_Special_ProrationHitstun", 980, "Hitstun Proration")
	AddCategory("Special Attacks/Cancels")
	AddDefine("ATTACK_Special_CanCancelIntoEX", true, "Can Cancel into EX")
	AddDefine("ATTACK_Special_CanCancelIntoSuper", true, "Can Cancel into Supers")
	
	AddCategory("EX Attacks")
	AddDefine("ATTACK_EX_MeterCost", 25, "EX Attack Cost")
	AddCategory("EX Attacks/Proration")
	AddDefine("ATTACK_EX_ProrationDamageStarter", 1000, "Damage Proration (Starter)")
	AddDefine("ATTACK_EX_ProrationDamage", 900, "Damage Proration")
	AddDefine("ATTACK_EX_ProrationHitstunStarter", 1000, "Hitstun Proration (Starter)")
	AddDefine("ATTACK_EX_ProrationHitstun", 980, "Hitstun Proration")
	AddCategory("EX Attacks/Cancels")
	AddDefine("ATTACK_EX_CanCancelIntoEX", false, "Can Cancel into EX")
	AddDefine("ATTACK_EX_CanCancelIntoSuper", true, "Can Cancel into Supers")
	
	AddCategory("Super Attacks")
	AddDefine("ATTACK_Super_MeterCost", 50, "Super Attack Cost")
	AddCategory("Super Attacks/Proration")
	AddDefine("ATTACK_Super_ProrationDamageStarter", 500, "Damage Proration (Starter)")
	AddDefine("ATTACK_Super_ProrationDamage", 500, "Damage Proration")
	AddDefine("ATTACK_Super_ProrationHitstunStarter", 1000, "Hitstun Proration (Starter)")
	AddDefine("ATTACK_Super_ProrationHitstun", 980, "Hitstun Proration")
	AddCategory("Super Attacks/Cancels")
	
	AddCategory("Throws")
	AddCategory("Throws/Proration")
	AddDefine("ATTACK_Throw_ProrationDamageStarter", 750, "Damage Proration (Starter)")
	AddDefine("ATTACK_Throw_ProrationDamage", 750, "Damage Proration")
	AddDefine("ATTACK_Throw_ProrationHitstunStarter", 800, "Hitstun Proration (Starter)")
	AddDefine("ATTACK_Throw_ProrationHitstun", 800, "Hitstun Proration")
	AddCategory("Throws/Cancels")
	AddDefine("ATTACK_Throw_CanCancelIntoSpecials", false, "Can Cancel into Specials")
	AddDefine("ATTACK_Throw_CanCancelIntoEX", false, "Can Cancel into EX")
	AddDefine("ATTACK_Throw_CanCancelIntoSuper", false, "Can Cancel into Supers")
	


var graph
var _prefabInterfaceMain = preload("res://castagne/modules/attacks/CMAttacks-TypesBigWindow.tscn")
func CreateInterfaceMain():
	var i = _prefabInterfaceMain.instance()
	graph = i.get_node("Graph/GraphBack/Graph")
	graph.sb = self
	return i
