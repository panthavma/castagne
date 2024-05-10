# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Physics - Movement (2D)")
	SetForMainEntitySubEntity(true, false)
	
	
	AddCategory("Base Physics")
	AddDefine("MOVE_Gravity", -200, "Gravity")
	AddDefine("MOVE_Friction_Ground", 100, "Friction (Ground)")
	AddDefine("MOVE_Friction_Air", 2, "Friction (Air)")
	AddDefine("MOVE_AirActionsMax", 0, "Air Actions")
	
	AddCategory("Base Physics/Transitional States")
	AddDefine("MOVE_TurnaroundStand_Time", 6, "Turnaround Time (Standing)")
	AddDefine("MOVE_TurnaroundCrouch_Time", 6, "Turnaround Time (Crouching)")
	AddDefine("MOVE_TurnaroundAirTime", 6, "Turnaround Time (Airborne)")
	AddDefine("MOVE_StandToCrouch_Time", 6, "Stand to Crouch Time")
	AddDefine("MOVE_CrouchToStand_Time", 6, "Crouch to Stand Time")
	AddDefine("MOVE_CanCancelStandToCrouch", true, "Can Cancel Stand to Crouch")
	AddDefine("MOVE_CanCancelCrouchToStand", true, "Can Cancel Crouch to Stand")
	
	
	AddCategory("Grounded Movement")
	AddDefine("MOVE_Walk_SpeedF", 1000, "Walk Speed (Forward)")
	AddDefine("MOVE_Walk_SpeedB", -800, "Walk Speed (Back)")
	
	AddDefine("MOVE_Crawl_SpeedF", 0, "Crawl Speed (Forward)")
	AddDefine("MOVE_Crawl_SpeedB", 0, "Crawl Speed (Back)")
	
	AddCategory("Jumping")
	AddDefine("MOVE_Jump_JumpsquatTime", 3, "Jumpsquat Duration")
	AddDefine("MOVE_Jump_JumpN_InitialMomentumX", 0, "Neutral Jump: Horizontal Momentum")
	AddDefine("MOVE_Jump_JumpN_InitialMomentumY", 3000, "Neutral Jump: Vertical Momentum")
	AddDefine("MOVE_Jump_JumpF_InitialMomentumX", 1200, "Forward Jump: Horizontal Momentum")
	AddDefine("MOVE_Jump_JumpF_InitialMomentumY", 3000, "Forward Jump: Vertical Momentum")
	AddDefine("MOVE_Jump_JumpB_InitialMomentumX", -1200, "Back Jump: Horizontal Momentum")
	AddDefine("MOVE_Jump_JumpB_InitialMomentumY", 3000, "Back Jump: Vertical Momentum")
	AddDefine("MOVE_Jump_CanJumpForward", true, "Can Jump Forward")
	AddDefine("MOVE_Jump_CanJumpBackward", true, "Can Jump Backward")
	AddDefine("MOVE_Landing_TimeEmpty", 6, "Landing Lag (Empty)")
	AddDefine("MOVE_Landing_TimeAttack", 6, "Landing Lag (Attack)")
	AddDefine("MOVE_Landing_RecoverCrouching", true, "Landing: Recover Crouching")
	
	AddCategory("Run", false)
	AddDefine("MOVE_Dashes_CanRun", false, "Can Run")
	AddDefine("MOVE_Run_StartTime", 15, "Run Start Duration")
	AddDefine("MOVE_Run_StopTime", 15, "Run Stop Duration")
	AddDefine("MOVE_Run_SpeedStart", 1900, "Run Speed (Start)")
	AddDefine("MOVE_Run_Speed", 1500, "Run Speed")
	AddDefine("MOVE_Run_SpeedStop", 500, "Run Speed (Stop)")

	AddCategory("Step Dash", false)
	AddDefine("MOVE_Dashes_CanStepDash", false, "Can Step Dash")
	AddDefine("MOVE_StepDash_Time", 20, "Step Dash Duration")
	AddDefine("MOVE_StepDash_Speed", 2000, "Step Dash Speed")

	AddCategory("Backdash", false)
	AddDefine("MOVE_Dashes_CanBackdash", false, "Can Backdash")
	AddDefine("MOVE_Backdash_Time", 18, "Backdash Duration")
	AddDefine("MOVE_Backdash_Speed", -1600, "Backdash Speed")

	AddCategory("Highjump", false)
	AddDefine("MOVE_Dashes_CanHighjump", false, "Can Highjump")
	AddDefine("MOVE_Highjump_JumpsquatTime", 3, "Jumpsquat Duration (Highjump)")
	AddDefine("MOVE_Highjump_HighjumpN_InitialMomentumX", 0, "Neutral Highjump: Horizontal Momentum")
	AddDefine("MOVE_Highjump_HighjumpN_InitialMomentumY", 5000, "Neutral Highjump: Vertical Momentum")
	AddDefine("MOVE_Highjump_HighjumpF_InitialMomentumX", 1200, "Forward Highjump: Horizontal Momentum")
	AddDefine("MOVE_Highjump_HighjumpF_InitialMomentumY", 5000, "Forward Highjump: Vertical Momentum")
	AddDefine("MOVE_Highjump_HighjumpB_InitialMomentumX", -1200, "Back Highjump: Horizontal Momentum")
	AddDefine("MOVE_Highjump_HighjumpB_InitialMomentumY", 5000, "Back Highjump: Vertical Momentum")

	AddCategory("Airjump", false)
	AddDefine("MOVE_Dashes_CanAirjump", false, "Can Airjump")
	AddDefine("MOVE_Airjump_AirjumpN_InitialMomentumX", 0, "Neutral Airjump: Horizontal Momentum")
	AddDefine("MOVE_Airjump_AirjumpN_InitialMomentumY", 2000, "Neutral Airjump: Vertical Momentum")
	AddDefine("MOVE_Airjump_AirjumpF_InitialMomentumX", 1200, "Forward Airjump: Horizontal Momentum")
	AddDefine("MOVE_Airjump_AirjumpF_InitialMomentumY", 2000, "Forward Airjump: Vertical Momentum")
	AddDefine("MOVE_Airjump_AirjumpB_InitialMomentumX", -1200, "Back Airjump: Horizontal Momentum")
	AddDefine("MOVE_Airjump_AirjumpB_InitialMomentumY", 2000, "Back Airjump: Vertical Momentum")

	AddCategory("Airdash", false)
	AddDefine("MOVE_Dashes_CanAirdashF", false, "Can Airdash Forward")
	AddDefine("MOVE_Airdash_AirdashF_SpeedX", 2500, "Airdash Forward: Horizontal Speed")
	AddDefine("MOVE_Airdash_AirdashF_SpeedY", 0, "Airdash Forward: Vertical Speed")
	AddDefine("MOVE_Airdash_AirdashF_Time", 30, "Airdash Forward: Duration")
	AddDefine("MOVE_Dashes_CanAirdashB", false, "Can Airdash Backward")
	AddDefine("MOVE_Airdash_AirdashB_SpeedX", -2500, "Airdash Back: Horizontal Speed")
	AddDefine("MOVE_Airdash_AirdashB_SpeedY", 0, "Airdash Back: Vertical Speed")
	AddDefine("MOVE_Airdash_AirdashB_Time", 30, "Airdash Back: Duration")


var g_NbFramesSimul = 30
var g_NbFramesPerNotch = 10
var g_NbFramesSimulPrecision = 3
var g_NbNotches = 3
var g_NotchSize = 1400

func Gizmos(emodule, stateHandle):
	# Walk / basic ; dashes ; basic notch
	var colors = module._gizmoColors
	var lineWidthUnfocused = 4
	
	var showAirborne = stateHandle.EntityHasFlag("Airborne")
	var hasAirActions = _specblockDefines["MOVE_AirActionsMax"]["Value"] > 0
	
	var showGroundedMovement = !showAirborne and _categories["Grounded Movement"]["Open"]
	var showJumps = !showAirborne and _categories["Jumping"]["Open"]
	var showHighjump = !showAirborne and _categories["Highjump"]["Open"] and _specblockDefines["MOVE_Dashes_CanHighjump"]["Value"]
	var showRun = !showAirborne and _categories["Run"]["Open"] and _specblockDefines["MOVE_Dashes_CanRun"]["Value"]
	var showStepDash = !showAirborne and !showRun and _categories["Step Dash"]["Open"] and _specblockDefines["MOVE_Dashes_CanStepDash"]["Value"] and !_specblockDefines["MOVE_Dashes_CanRun"]["Value"]
	var showBackdash = !showAirborne and _categories["Backdash"]["Open"] and _specblockDefines["MOVE_Dashes_CanBackdash"]["Value"]
	var showAirdash = showAirborne and hasAirActions and _categories["Airdash"]["Open"]
	var showAirjump = showAirborne and hasAirActions and _categories["Airjump"]["Open"] and _specblockDefines["MOVE_Dashes_CanAirjump"]["Value"]
	
	
	var gravity = _specblockDefines["MOVE_Gravity"]["Value"]
	var airFriction = _specblockDefines["MOVE_Friction_Air"]["Value"]
	var dashOffset = Vector2(0,-2500)
	
	if(showGroundedMovement):
		var color = colors[0]
		var lineWidth = lineWidthUnfocused
		var crawlOffset = dashOffset*2
		GizmoStraight(emodule, Vector2(_specblockDefines["MOVE_Walk_SpeedF"]["Value"],0), color, lineWidth)
		GizmoStraight(emodule, Vector2(_specblockDefines["MOVE_Walk_SpeedB"]["Value"],0), color, lineWidth)
		if(_specblockDefines["MOVE_Crawl_SpeedF"]["Value"] != 0):
			GizmoStraight(emodule, Vector2(_specblockDefines["MOVE_Crawl_SpeedF"]["Value"],0), color, lineWidth, crawlOffset)
		if(_specblockDefines["MOVE_Crawl_SpeedB"]["Value"] != 0):
			GizmoStraight(emodule, Vector2(_specblockDefines["MOVE_Crawl_SpeedB"]["Value"],0), color, lineWidth, crawlOffset)
	
	if(showJumps):
		var color = colors[0]
		var lineWidth = lineWidthUnfocused
		var momentums = []
		momentums += [Vector2(_specblockDefines["MOVE_Jump_JumpN_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Jump_JumpN_InitialMomentumY"]["Value"])]
		if(_specblockDefines["MOVE_Jump_CanJumpForward"]["Value"]):
			momentums += [Vector2(_specblockDefines["MOVE_Jump_JumpF_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Jump_JumpF_InitialMomentumY"]["Value"])]
		if(_specblockDefines["MOVE_Jump_CanJumpBackward"]["Value"]):
			momentums += [Vector2(_specblockDefines["MOVE_Jump_JumpB_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Jump_JumpB_InitialMomentumY"]["Value"])]
		for m in momentums:
			GizmoJump(emodule, m, gravity, airFriction, color, lineWidth)
	
	if(showHighjump):
		var color = colors[1]
		var lineWidth = lineWidthUnfocused
		var momentums = []
		momentums += [Vector2(_specblockDefines["MOVE_Highjump_HighjumpN_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Highjump_HighjumpN_InitialMomentumY"]["Value"])]
		if(_specblockDefines["MOVE_Jump_CanJumpForward"]["Value"]):
			momentums += [Vector2(_specblockDefines["MOVE_Highjump_HighjumpF_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Highjump_HighjumpF_InitialMomentumY"]["Value"])]
		if(_specblockDefines["MOVE_Jump_CanJumpBackward"]["Value"]):
			momentums += [Vector2(_specblockDefines["MOVE_Highjump_HighjumpB_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Highjump_HighjumpB_InitialMomentumY"]["Value"])]

		for m in momentums:
			GizmoJump(emodule, m, gravity, airFriction, color, lineWidth)
	
	if(showBackdash):
		var color = colors[1]
		var lineWidth = lineWidthUnfocused
		GizmoStraight(emodule, Vector2(_specblockDefines["MOVE_Backdash_Speed"]["Value"],0), color, lineWidth, dashOffset, _specblockDefines["MOVE_Backdash_Time"]["Value"])
	if(showStepDash):
		var color = colors[1]
		var lineWidth = lineWidthUnfocused
		GizmoStraight(emodule, Vector2(_specblockDefines["MOVE_StepDash_Speed"]["Value"],0), color, lineWidth, dashOffset, _specblockDefines["MOVE_StepDash_Time"]["Value"])
	if(showRun):
		var color = colors[1]
		var lineWidth = lineWidthUnfocused
		var x = dashOffset.x
		var runStartDuration = _specblockDefines["MOVE_Run_StartTime"]["Value"]
		var runSpeedStart = _specblockDefines["MOVE_Run_SpeedStart"]["Value"]
		var runSpeed = _specblockDefines["MOVE_Run_Speed"]["Value"]
		for f in range(1,g_NbFramesSimul+1):
			if(f <= runStartDuration):
				x += runSpeedStart
			else:
				x += runSpeed
			if f % g_NbFramesPerNotch == 0:
				emodule.GizmoLine([x, -g_NotchSize+dashOffset.y, 0], [x,g_NotchSize+dashOffset.y,0], color, lineWidth)
		emodule.GizmoLine([dashOffset.x, dashOffset.y, 0], [x,dashOffset.y,0], color, lineWidth)
	
	if(showAirjump):
		var color = colors[1]
		var lineWidth = lineWidthUnfocused
		var momentums = [
			Vector2(_specblockDefines["MOVE_Airjump_AirjumpN_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Airjump_AirjumpN_InitialMomentumY"]["Value"]),
			Vector2(_specblockDefines["MOVE_Airjump_AirjumpF_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Airjump_AirjumpF_InitialMomentumY"]["Value"]),
			Vector2(_specblockDefines["MOVE_Airjump_AirjumpB_InitialMomentumX"]["Value"], _specblockDefines["MOVE_Airjump_AirjumpB_InitialMomentumY"]["Value"])
		]
		for m in momentums:
			GizmoJump(emodule, m, gravity, airFriction, color, lineWidth, false)
	
	if(showAirdash):
		var color = colors[1]
		var lineWidth = lineWidthUnfocused
		if(_specblockDefines["MOVE_Dashes_CanAirdashF"]["Value"]):
			GizmoStraight(emodule,
				Vector2(_specblockDefines["MOVE_Airdash_AirdashF_SpeedX"]["Value"], _specblockDefines["MOVE_Airdash_AirdashF_SpeedY"]["Value"]),
				color, lineWidth, Vector2(), _specblockDefines["MOVE_Airdash_AirdashF_Time"]["Value"])
		if(_specblockDefines["MOVE_Dashes_CanAirdashB"]["Value"]):
			GizmoStraight(emodule,
				Vector2(_specblockDefines["MOVE_Airdash_AirdashB_SpeedX"]["Value"], _specblockDefines["MOVE_Airdash_AirdashB_SpeedY"]["Value"]),
				color, lineWidth, Vector2(), _specblockDefines["MOVE_Airdash_AirdashB_Time"]["Value"])
	
	# Anchor
	if(showAirborne):
		var color = colors[2]
		var lineWidth = 4
		var anchorSize = 2000
		emodule.GizmoLine([-anchorSize,-anchorSize,0], [anchorSize,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([-anchorSize,anchorSize,0], [anchorSize,-anchorSize,0], color, lineWidth)
		emodule.GizmoLine([-anchorSize,-anchorSize,0], [anchorSize,-anchorSize,0], color, lineWidth)
		emodule.GizmoLine([-anchorSize,-anchorSize,0], [-anchorSize,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([anchorSize,anchorSize,0], [-anchorSize,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([anchorSize,anchorSize,0], [anchorSize,-anchorSize,0], color, lineWidth)
	else:
		var color = colors[2]
		var lineWidth = 4
		var anchorSize = 2000
		emodule.GizmoLine([-anchorSize,0,0], [anchorSize,0,0], color, lineWidth)
		emodule.GizmoLine([0,-anchorSize,0], [0,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([-anchorSize,0,0], [0,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([-anchorSize,0,0], [0,-anchorSize,0], color, lineWidth)
		emodule.GizmoLine([anchorSize,0,0], [0,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([anchorSize,0,0], [0,-anchorSize,0], color, lineWidth)

func GizmoStraight(emodule, speed, color, lineWidth, offset = Vector2(), nbFramesSimul = -1):
	if(nbFramesSimul < 0):
		nbFramesSimul = g_NbFramesSimul
	emodule.GizmoLine([offset.x, offset.y, 0], [offset.x+speed.x*nbFramesSimul, offset.y+speed.y*nbFramesSimul,0], color, lineWidth)
	var notchesFrames = []
	for i in range(1, g_NbNotches+1):
		var f = g_NbFramesPerNotch*i
		if f < nbFramesSimul:
			notchesFrames += [f]
	notchesFrames += [0, nbFramesSimul]
	for f in notchesFrames:
		var x = speed.x*f + offset.x
		var y = speed.y*f + offset.y
		emodule.GizmoLine([x, -g_NotchSize+offset.y, 0], [x,g_NotchSize+offset.y,0], color, lineWidth)

func GizmoJump(emodule, baseMomentum, gravity, airFriction, color, lineWidth, grounded=true):
	var p = Vector2()
	var o = Vector2()
	var m = baseMomentum
	for f in range(1, g_NbFramesSimul+1):
		m.x = move_toward(m.x, 0, airFriction)
		m.y += gravity
		p += m
		if(grounded and p.y <= 0):
			p.y = 0
			if(m.y <= 0):
				m = Vector2()
		
		if f % g_NbFramesPerNotch == 0:
			var d = (p - o).normalized()
			d = Vector2(d.y, -d.x)
			var a = p + d*g_NotchSize
			var b = p - d*g_NotchSize
			emodule.GizmoLine([a.x, a.y, 0], [b.x, b.y,0], color, lineWidth)
		
		
		if f % g_NbFramesSimulPrecision == 0:
			emodule.GizmoLine([o.x, o.y, 0], [p.x, p.y,0], color, lineWidth)
			o = p
