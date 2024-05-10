# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Attacks - Throws")
	SetForMainEntitySubEntity(true, false)
	
	AddCategory("Ground Throw")
	AddDefine("ATTACK_Throw_CanGroundThrow", true, "Can Ground Throw")
	AddDefine("ATTACK_Throw_Ground_ThrowFState", "ThrowF", "Forward Throw State")
	AddDefine("ATTACK_Throw_Ground_ThrowBState", "ThrowB", "Back Throw State")
	AddDefine("ATTACK_Throw_Ground_ThrowBAutoFlip", true, "Auto Flip Back Throw")
	AddDefine("ATTACK_Throw_Ground_HoldPointX", 10000, "Holding Point X")
	AddDefine("ATTACK_Throw_Ground_HoldPointY", 0, "Holding Point Y")
	AddDefine("ATTACK_Throw_Ground_TimeHold", 30, "Holding Time")
	
	AddCategory("Air Throw")
	AddDefine("ATTACK_Throw_CanAirThrow", true, "Can Air Throw")
	AddDefine("ATTACK_Throw_Air_ThrowFState", "AirThrowF", "Forward Throw State")
	AddDefine("ATTACK_Throw_Air_ThrowBState", "AirThrowB", "Back Throw State")
	AddDefine("ATTACK_Throw_Air_ThrowBAutoFlip", true, "Auto Flip Back Throw")
	AddDefine("ATTACK_Throw_Air_HoldPointX", 10000, "Holding Point X")
	AddDefine("ATTACK_Throw_Air_HoldPointY", 0, "Holding Point Y")
	AddDefine("ATTACK_Throw_Air_TimeHold", 30, "Holding Time")
	
	AddCategory("System", false)
	AddCategory("System/Teching")
	AddDefine("ATTACK_Throw_Tech_LockoutTime", 60, "Teching Lockout Window")
	AddDefine("ATTACK_Throw_Tech_ActiveTime", 20, "Teching Window")
	AddCategory("System/Teching States", false)
	AddDefine("ATTACK_Throw_Ground_HoldingState", "ThrowHolding", "Ground Holding State")
	AddDefine("ATTACK_Throw_Ground_HeldState", "ThrowHeld", "Ground Held State")
	AddDefine("ATTACK_Throw_Air_HoldingState", "AirThrowHolding", "Air Holding State")
	AddDefine("ATTACK_Throw_Air_HeldState", "AirThrowHeld", "Air Held State")
	AddDefine("ATTACK_Throw_Ground_TechingState", "ThrowTeching", "Ground Teching State")
	AddDefine("ATTACK_Throw_Ground_TechedState", "ThrowTeched", "Ground Teched State")
	AddDefine("ATTACK_Throw_Air_TechingState", "AirThrowTeching", "Air Teching State")
	AddDefine("ATTACK_Throw_Air_TechedState", "AirThrowTeched", "Air Teched State")
	
