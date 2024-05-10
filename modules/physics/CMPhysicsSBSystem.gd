# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Physics - System (2D)")
	SetForMainEntitySubEntity(true, false)
	
	AddCategory("Colliders")
	AddDefine("PHYSICS_StandardHurtbox_Use", true, "Use Standard Hurtbox")
	AddDefine("PHYSICS_StandardColbox_Use", true, "Use Standard Colbox")
	
	AddCategory("Colliders/Hurtbox (Standing)")
	AddDefine("PHYSICS_StandardHurtbox_Width", 5000, "Hurtbox Width (Standing)")
	AddDefine("PHYSICS_StandardHurtbox_Bottom", 0, "Hurtbox Bottom (Standing)")
	AddDefine("PHYSICS_StandardHurtbox_Top", 20000, "Hurtbox Top (Standing)")
	AddCategory("Colliders/Hurtbox (Crouching)")
	AddDefine("PHYSICS_StandardHurtbox_Crouching_Width", 5000, "Hurtbox Width (Crouching)")
	AddDefine("PHYSICS_StandardHurtbox_Crouching_Bottom", 0, "Hurtbox Bottom (Crouching)")
	AddDefine("PHYSICS_StandardHurtbox_Crouching_Top", 14000, "Hurtbox Top (Crouching)")
	AddCategory("Colliders/Hurtbox (Knockdown)")
	AddDefine("PHYSICS_StandardHurtbox_Knockdown_Width", 9000, "Hurtbox Width (Knockdown)")
	AddDefine("PHYSICS_StandardHurtbox_Knockdown_Bottom", 0, "Hurtbox Bottom (Knockdown)")
	AddDefine("PHYSICS_StandardHurtbox_Knockdown_Top", 5000, "Hurtbox Top (Knockdown)")
	AddCategory("Colliders/Colbox")
	AddDefine("PHYSICS_StandardColbox_Width", 4000, "Colbox Width")
	AddDefine("PHYSICS_StandardColbox_Bottom", 0, "Colbox Bottom")
	AddDefine("PHYSICS_StandardColbox_Top", 12000, "Colbox Top")
	
	AddCategory("Hitstun", false)
	AddDefine("MOVE_Hitstun_Friction_Ground", 100, "Hitstun Friction (Ground)")
	AddDefine("MOVE_Hitstun_Friction_Air", 2, "Hitstun Friction (Air)")
	AddDefine("MOVE_Hitstun_Gravity", -200, "Hitstun Friction (Gravity)")
	
	AddCategory("Blockstun", false)
	AddDefine("MOVE_Blockstun_Friction_Ground", 100, "Blockstun Friction (Ground)")
	AddDefine("MOVE_Blockstun_Friction_Air", 2, "Blockstun Friction (Air)")
	AddDefine("MOVE_Blockstun_Gravity", -200, "Blockstun Gravity")
	
	AddCategory("Throw Teching", false)
	AddDefine("MOVE_Teching_Ground_MomentumX", -2000, "Teching (Ground): Horizontal Momentum")
	AddDefine("MOVE_Teching_Ground_MomentumY", 0, "Teching (Ground): Vertical Momentum")
	AddDefine("MOVE_Teching_Ground_Time", 20, "Teching (Ground): Duration")
	AddDefine("MOVE_Teched_Ground_MomentumX", -2000, "Teched (Ground): Horizontal Momentum")
	AddDefine("MOVE_Teched_Ground_MomentumY", 0, "Teched (Ground): Vertical Momentum")
	AddDefine("MOVE_Teched_Ground_Time", 20, "Teched (Air): Duration")
	AddDefine("MOVE_Teching_Air_MomentumX", -1000, "Teching (Air): Horizontal Momentum")
	AddDefine("MOVE_Teching_Air_MomentumY", 1000, "Teching (Air): Vertical Momentum")
	AddDefine("MOVE_Teching_Air_Time", 20, "Teching (Air): Duration")
	AddDefine("MOVE_Teched_Air_MomentumX", -1000, "Teched (Air): Horizontal Momentum")
	AddDefine("MOVE_Teched_Air_MomentumY", 1000, "Teched (Air): Vertical Momentum")
	AddDefine("MOVE_Teched_Air_Time", 20, "Teched (Air): Duration")
	
	AddCategory("System", false)
	AddCategory("System/Facing")
	AddDefine("PHYSICS_FaceTargetAutomatically", true, "Face Target (Ground)")
	AddDefine("PHYSICS_FaceTargetAutomaticallyInAir", false, "Face Target (Air)")
	AddDefine("PHYSICS_FaceTargetAutomaticallyAtAttackStart", true, "Face Target (Ground Attack)")
	AddDefine("PHYSICS_FaceTargetAutomaticallyAtAirAttackStart", false, "Face Target (Air Attack)")
	AddDefine("PHYSICS_AllowFacingChangeAtAirAttackStart", true, "Allow Air Attack Turnaround")
	#AddDefine("MOVE_CanTurnaroundInAir", false, "")
	
	AddCategory("System/Dashes")
	AddDefine("MOVE_Dashes_DoubleTapTime", 12, "Dash Doubletap Time")
	AddDefine("MOVE_Dashes_HighjumpInputTime", 12, "Highjump Input Time")



func Gizmos(emodule, stateHandle):
	if(_specblockDefines["PHYSICS_StandardHurtbox_Use"]["Value"] and _categories["Colliders/Hurtbox (Standing)"]["Open"]):
		module.GizmoHurtbox(emodule, [
			_specblockDefines["PHYSICS_StandardHurtbox_Width"]["Value"],
			_specblockDefines["PHYSICS_StandardHurtbox_Bottom"]["Value"],
			_specblockDefines["PHYSICS_StandardHurtbox_Top"]["Value"]
		], false, stateHandle)
	if(_specblockDefines["PHYSICS_StandardHurtbox_Use"]["Value"] and _categories["Colliders/Hurtbox (Crouching)"]["Open"]):
		module.GizmoHurtbox(emodule, [
			_specblockDefines["PHYSICS_StandardHurtbox_Crouching_Width"]["Value"],
			_specblockDefines["PHYSICS_StandardHurtbox_Crouching_Bottom"]["Value"],
			_specblockDefines["PHYSICS_StandardHurtbox_Crouching_Top"]["Value"]
		], false, stateHandle)
	if(_specblockDefines["PHYSICS_StandardHurtbox_Use"]["Value"] and _categories["Colliders/Hurtbox (Knockdown)"]["Open"]):
		module.GizmoHurtbox(emodule, [
			_specblockDefines["PHYSICS_StandardHurtbox_Knockdown_Width"]["Value"],
			_specblockDefines["PHYSICS_StandardHurtbox_Knockdown_Bottom"]["Value"],
			_specblockDefines["PHYSICS_StandardHurtbox_Knockdown_Top"]["Value"]
		], false, stateHandle)
	if(_specblockDefines["PHYSICS_StandardColbox_Use"]["Value"] and _categories["Colliders/Colbox"]["Open"]):
		module.GizmoColbox(emodule, [
			_specblockDefines["PHYSICS_StandardColbox_Width"]["Value"],
			_specblockDefines["PHYSICS_StandardColbox_Bottom"]["Value"],
			_specblockDefines["PHYSICS_StandardColbox_Top"]["Value"]
		], false, stateHandle)
