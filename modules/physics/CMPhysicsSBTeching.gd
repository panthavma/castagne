# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Physics - Recovery (2D)")
	SetForMainEntitySubEntity(true, false)
	
	AddCategory("General")
	AddDefine("MOVE_Tech_Friction_Ground", 20, "Recovering Friction (Ground)")
	AddDefine("MOVE_Tech_Friction_Air", 20, "Recovering Friction (Air)")
	AddDefine("MOVE_Tech_Gravity", -50, "Recovering Gravity")
	
	
	
	AddCategory("Grounded")
	AddCategory("Grounded/Neutral")
	AddDefine("ATTACK_Tech_Grounded_Neutral_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Grounded_Neutral_MomentumX", -300, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Grounded_Neutral_MomentumY", 1000, "Recovery Vertical Momentum")
	
	AddCategory("Grounded/Forward")
	AddDefine("ATTACK_Tech_Grounded_CanTechForward", true, "Can Recover Forward")
	AddDefine("ATTACK_Tech_Grounded_Forward_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Grounded_Forward_MomentumX", 600, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Grounded_Forward_MomentumY", 800, "Recovery Vertical Momentum")
	
	AddCategory("Grounded/Back")
	AddDefine("ATTACK_Tech_Grounded_CanTechBackward", true, "Can Recover Backward")
	AddDefine("ATTACK_Tech_Grounded_Backward_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Grounded_Backward_MomentumX", -800, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Grounded_Backward_MomentumY", 800, "Recovery Vertical Momentum")
	
	AddCategory("Grounded/Up")
	AddDefine("ATTACK_Tech_Grounded_CanTechUp", true, "Can Recover Upward")
	AddDefine("ATTACK_Tech_Grounded_Up_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Grounded_Up_MomentumX", -400, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Grounded_Up_MomentumY", 1800, "Recovery Vertical Momentum")
	
	
	
	AddCategory("Airborne")
	AddDefine("ATTACK_Hitstun_CanRecoverInAir", true, "Can Recover in Air")
	
	AddCategory("Airborne/Neutral")
	AddDefine("ATTACK_Tech_Airborne_Neutral_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Airborne_Neutral_MomentumX", -200, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Airborne_Neutral_MomentumY", 800, "Recovery Vertical Momentum")
	
	AddCategory("Airborne/Forward")
	AddDefine("ATTACK_Tech_Airborne_CanTechForward", true, "Can Recover Forward")
	AddDefine("ATTACK_Tech_Airborne_Forward_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Airborne_Forward_MomentumX", 800, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Airborne_Forward_MomentumY", 500, "Recovery Vertical Momentum")
	
	AddCategory("Airborne/Back")
	AddDefine("ATTACK_Tech_Airborne_CanTechBackward", true, "Can Recover Backward")
	AddDefine("ATTACK_Tech_Airborne_Backward_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Airborne_Backward_MomentumX", -800, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Airborne_Backward_MomentumY", 500, "Recovery Vertical Momentum")
	
	AddCategory("Airborne/Up")
	AddDefine("ATTACK_Tech_Airborne_CanTechUp", true, "Can Recover Upward")
	AddDefine("ATTACK_Tech_Airborne_Up_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Airborne_Up_MomentumX", 0, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Airborne_Up_MomentumY", 1000, "Recovery Vertical Momentum")
	
	AddCategory("Airborne/Down")
	AddDefine("ATTACK_Tech_Airborne_CanTechDown", true, "Can Recover Downward")
	AddDefine("ATTACK_Tech_Airborne_Down_Time", 10, "Recovery Time")
	AddDefine("ATTACK_Tech_Airborne_Down_MomentumX", 0, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Airborne_Down_MomentumY", -500, "Recovery Vertical Momentum")
	
	AddCategory("Knockdown")
	
	AddCategory("Knockdown/Neutral")
	AddDefine("ATTACK_Tech_Knockdown_Neutral_Time", 30, "Recovery Time")
	AddDefine("ATTACK_Tech_Knockdown_Neutral_MomentumX", 0, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Neutral_MomentumY", 0, "Recovery Vertical Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Neutral_RecoverCrouching", true, "Recover Crouching")
	
	AddCategory("Knockdown/Forward")
	AddDefine("ATTACK_Tech_Knockdown_CanTechForward", true, "Can Recover Forward")
	AddDefine("ATTACK_Tech_Knockdown_Forward_Time", 30, "Recovery Time")
	AddDefine("ATTACK_Tech_Knockdown_Forward_MomentumX", 2000, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Forward_MomentumY", 0, "Recovery Vertical Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Forward_RecoverCrouching", true, "Recover Crouching")
	
	AddCategory("Knockdown/Back")
	AddDefine("ATTACK_Tech_Knockdown_CanTechBackward", true, "Can Recover Backward")
	AddDefine("ATTACK_Tech_Knockdown_Backward_Time", 30, "Recovery Time")
	AddDefine("ATTACK_Tech_Knockdown_Backward_MomentumX", -2000, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Backward_MomentumY", 0, "Recovery Vertical Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Backward_RecoverCrouching", true, "Recover Crouching")
	
	AddCategory("Knockdown/Up")
	AddDefine("ATTACK_Tech_Knockdown_CanTechUp", true, "Can Recover Upward")
	AddDefine("ATTACK_Tech_Knockdown_Up_Time", 15, "Recovery Time")
	AddDefine("ATTACK_Tech_Knockdown_Up_MomentumX", 0, "Recovery Horizontal Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Up_MomentumY", 2000, "Recovery Vertical Momentum")
	AddDefine("ATTACK_Tech_Knockdown_Up_RecoverCrouching", false, "Recover Crouching")



func Gizmos(emodule, stateHandle):
	pass
