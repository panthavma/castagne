# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Attacks - Mechanics")
	SetForMainEntitySubEntity(true, false)
	
	#AddCategory("Groundbounces")
	#AddDefine("ATTACK_GroundbouncesMaxPerCombo", 3, "Groundbounces per Combo")
	
	AddCategory("Blocking")
	AddDefine("ATTACK_HoldBackToBlock", true)
	AddDefine("ATTACK_UseBlockButtonToBlock", false)
	AddDefine("ATTACK_CanBlockInAir", true)
	AddDefine("ATTACK_ContinueBlockingAfterFirstHit", true)
	
