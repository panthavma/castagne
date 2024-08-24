# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Animations")
	SetForMainEntitySubEntity(true, false)
	
	AddDefine("ANIMS_UseStandardAnims", true, "Use Standard Animations")
	
	AddCategory("Movement")
	AddCategory("Movement/Basic")
	AddDefine("ANIM_Movement_Basic_Stand", "ANIM_Movement_Basic_Stand", "Standing")
	AddDefine("ANIM_Movement_Basic_Stand_Loop",  60, "Standing (Loop)")
	AddDefine("ANIM_Movement_Basic_WalkF", "ANIM_Movement_Basic_WalkF", "Walk Forward")
	AddDefine("ANIM_Movement_Basic_WalkF_Loop",  60, "Walk Forward (Loop)")
	AddDefine("ANIM_Movement_Basic_WalkB", "ANIM_Movement_Basic_WalkB", "Walk Back")
	AddDefine("ANIM_Movement_Basic_WalkB_Loop",  60, "Walk Back (Loop)")
	
	AddDefine("ANIM_Movement_Basic_Crouching", "ANIM_Movement_Basic_Crouching", "Crouching")
	AddDefine("ANIM_Movement_Basic_Crouching_Loop",  60, "Crouching (Loop)")
	AddDefine("ANIM_Movement_Basic_CrawlF", "ANIM_Movement_Basic_CrawlF", "Crawling Forward")
	AddDefine("ANIM_Movement_Basic_CrawlF_Loop",  60, "Crawling Forward (Loop)")
	AddDefine("ANIM_Movement_Basic_CrawlB", "ANIM_Movement_Basic_CrawlB", "Crawling Back")
	AddDefine("ANIM_Movement_Basic_CrawlB_Loop",  60, "Crawling Back (Loop)")
	
	AddDefine("ANIM_Movement_Basic_Turnaround", "ANIM_Movement_Basic_Turnaround", "Turnaround (Standing)")
	AddDefine("ANIM_Movement_Basic_TurnaroundCrouch", "ANIM_Movement_Basic_TurnaroundCrouch", "Turnaround (Crouching)")
	AddDefine("ANIM_Movement_Basic_TurnaroundAirborne", "ANIM_Movement_Basic_TurnaroundAirborne", "Turnaround (Airborne)")
	AddDefine("ANIM_Movement_Basic_StandToCrouch", "ANIM_Movement_Basic_StandToCrouch", "Stand to Crouch")
	AddDefine("ANIM_Movement_Basic_CrouchToStand", "ANIM_Movement_Basic_CrouchToStand", "Crouch to Stand")
	
	AddDefine("ANIM_Movement_Basic_Landing", "ANIM_Movement_Basic_Landing", "Landing")
	AddDefine("ANIM_Movement_Basic_Jumpsquat", "ANIM_Movement_Basic_Jumpsquat", "Jumpsquat")
	
	AddDefine("ANIM_Movement_Basic_AirIdle", "ANIM_Movement_Basic_AirIdle", "Airborne")
	AddDefine("ANIM_Movement_Basic_JumpN", "ANIM_Movement_Basic_JumpN", "Jumping (Neutral)")
	AddDefine("ANIM_Movement_Basic_JumpF", "ANIM_Movement_Basic_JumpF", "Jumping (Forward)")
	AddDefine("ANIM_Movement_Basic_JumpB", "ANIM_Movement_Basic_JumpB", "Jumping (Back)")
	
	AddCategory("Movement/Dashes")
	
	AddDefine("ANIM_Movement_Dashes_RunStart", "ANIM_Movement_Dashes_RunStart", "Running (Start)")
	AddDefine("ANIM_Movement_Dashes_Run", "ANIM_Movement_Dashes_Run", "Running")
	AddDefine("ANIM_Movement_Dashes_Run_Loop",  60, "Running (Loop)")
	AddDefine("ANIM_Movement_Dashes_RunStop", "ANIM_Movement_Dashes_RunStop", "Running (Stop)")
	AddDefine("ANIM_Movement_Dashes_TurnaroundRun", "ANIM_Movement_Dashes_TurnaroundRun", "Running (Turnaround)")
	AddDefine("ANIM_Movement_Dashes_StepDash", "ANIM_Movement_Dashes_StepDash", "Step Dash")
	AddDefine("ANIM_Movement_Dashes_Backdash", "ANIM_Movement_Dashes_Backdash", "Backdash")
	AddDefine("ANIM_Movement_Dashes_HighjumpN", "ANIM_Movement_Dashes_HighjumpN", "High Jump (Neutral)")
	AddDefine("ANIM_Movement_Dashes_HighjumpF", "ANIM_Movement_Dashes_HighjumpF", "High Jump (Forward)")
	AddDefine("ANIM_Movement_Dashes_HighjumpB", "ANIM_Movement_Dashes_HighjumpB", "High Jump (Back)")
	AddDefine("ANIM_Movement_Dashes_AirjumpN", "ANIM_Movement_Dashes_AirjumpN", "Air Jump (Neutral)")
	AddDefine("ANIM_Movement_Dashes_AirjumpF", "ANIM_Movement_Dashes_AirjumpF", "Air Jump (Forward)")
	AddDefine("ANIM_Movement_Dashes_AirjumpB", "ANIM_Movement_Dashes_AirjumpB", "Air Jump (Back)")
	AddDefine("ANIM_Movement_Dashes_AirdashF", "ANIM_Movement_Dashes_AirdashF", "Airdash (Forward)")
	AddDefine("ANIM_Movement_Dashes_AirdashB", "ANIM_Movement_Dashes_AirdashB", "Airdash (Back)")
	
	AddCategory("Reacts")
	AddCategory("Reacts/Hits")
	AddDefine("ANIM_Reacts_Hitstun_Standing", "ANIM_Reacts_Hitstun_Standing", "Hitstun (Standing)")
	AddDefine("ANIM_Reacts_Hitstun_Crouching", "ANIM_Reacts_Hitstun_Crouching", "Hitstun (Crouching)")
	AddDefine("ANIM_Reacts_Hitstun_Airborne", "ANIM_Reacts_Hitstun_Airborne", "Hitstun (Airborne)")
	
	AddDefine("ANIM_Reacts_Knockdown", "ANIM_Reacts_Knockdown", "Knockdown")
	
	AddDefine("ANIM_Reacts_Blockstun_Standing", "ANIM_Reacts_Blockstun_Standing", "Blockstun (Standing)")
	AddDefine("ANIM_Reacts_Blockstun_Crouching", "ANIM_Reacts_Blockstun_Crouching", "Blockstun (Crouching)")
	AddDefine("ANIM_Reacts_Blockstun_Airborne", "ANIM_Reacts_Blockstun_Airborne", "Blockstun (Airborne)")
	
	AddCategory("Reacts/Throw")
	AddDefine("ANIM_Reacts_Throw_Ground_Held", "ANIM_Reacts_Throw_Ground_Held", "Throw Held (Grounded)")
	AddDefine("ANIM_Reacts_Throw_Ground_Holding", "ANIM_Reacts_Throw_Ground_Holding", "Throw Holding (Grounded)")
	AddDefine("ANIM_Reacts_Throw_Ground_Teched", "ANIM_Reacts_Throw_Ground_Teched", "Throw Teched (Grounded)")
	AddDefine("ANIM_Reacts_Throw_Ground_Teching", "ANIM_Reacts_Throw_Ground_Teching", "Throw Teching (Grounded)")
	AddDefine("ANIM_Reacts_Throw_Air_Held", "ANIM_Reacts_Throw_Air_Held", "Throw Held (Airborne)")
	AddDefine("ANIM_Reacts_Throw_Air_Holding", "ANIM_Reacts_Throw_Air_Holding", "Throw Holding (Airborne)")
	AddDefine("ANIM_Reacts_Throw_Air_Teched", "ANIM_Reacts_Throw_Air_Teched", "Throw Teched (Airborne)")
	AddDefine("ANIM_Reacts_Throw_Air_Teching", "ANIM_Reacts_Throw_Air_Teching", "Throw Teching (Airborne)")
	
	AddCategory("Reacts/Recover")
	AddDefine("ANIM_Reacts_Tech_Grounded_Neutral", "ANIM_Reacts_Tech_Grounded_Neutral", "Recover In-Place (Grounded)")
	AddDefine("ANIM_Reacts_Tech_Grounded_Forward", "ANIM_Reacts_Tech_Grounded_Forward", "Recover Forward (Grounded)")
	AddDefine("ANIM_Reacts_Tech_Grounded_Backward", "ANIM_Reacts_Tech_Grounded_Backward", "Recover Backwards (Grounded)")
	AddDefine("ANIM_Reacts_Tech_Grounded_Up", "ANIM_Reacts_Tech_Grounded_Up", "Recover Up (Grounded)")
	AddDefine("ANIM_Reacts_Tech_Airborne_Neutral", "ANIM_Reacts_Tech_Airborne_Neutral", "Recover In-Place (Airborne)")
	AddDefine("ANIM_Reacts_Tech_Airborne_Forward", "ANIM_Reacts_Tech_Airborne_Forward", "Recover Forward (Airborne)")
	AddDefine("ANIM_Reacts_Tech_Airborne_Backward", "ANIM_Reacts_Tech_Airborne_Backward", "Recover Backwards (Airborne)")
	AddDefine("ANIM_Reacts_Tech_Airborne_Up", "ANIM_Reacts_Tech_Airborne_Up", "Recover Up (Airborne)")
	AddDefine("ANIM_Reacts_Tech_Airborne_Down", "ANIM_Reacts_Tech_Airborne_Down", "Recover Down (Airborne)")
	AddDefine("ANIM_Reacts_Tech_Knockdown_Neutral", "ANIM_Reacts_Tech_Knockdown_Neutral", "Recover In-Place (Knockdown)")
	AddDefine("ANIM_Reacts_Tech_Knockdown_Forward", "ANIM_Reacts_Tech_Knockdown_Forward", "Recover Forward (Knockdown)")
	AddDefine("ANIM_Reacts_Tech_Knockdown_Backward", "ANIM_Reacts_Tech_Knockdown_Backward", "Recover Backwards (Knockdown)")
	AddDefine("ANIM_Reacts_Tech_Knockdown_Up", "ANIM_Reacts_Tech_Knockdown_Up", "Recover Up (Knockdown)")
	
	
	
	
	
	AddStructure("SpriteAnimations", "GRAPHICS_SPRITE_ANIMATIONS_", "Sprite Animations")
	for i in range(10):
		AddStructureSeparator("Keyframe "+str(i+1))
		AddStructureDefine(str(i+1)+"_Duration", 0, "("+str(i+1)+") Duration")
		AddStructureDefine(str(i+1)+"_Spritesheet", "", "("+str(i+1)+") Spritesheet")
		AddStructureDefine(str(i+1)+"_Frame", 0, "("+str(i+1)+") Frame")
