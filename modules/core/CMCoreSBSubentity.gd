# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Subentity Parameters")
	SetForMainEntitySubEntity(false, true)
	
	AddCategory("Behavior")
	AddDefine("SUBENTITY_Move_X", 0)
	AddDefine("SUBENTITY_Move_Y", 0)
	AddDefine("SUBENTITY_TimeToLive", 0)
	
	AddDefine("SUBENTITY_DestroyOnGroundCollision", false)
	AddDefine("SUBENTITY_DestroyOnWallCollision", false)
	
	AddDefine("SUBENTITY_Anim_Use", false)
	AddDefine("SUBENTITY_Anim_Name", "AnimName")
	
	AddCategory("Attack")
	AddDefine("SUBENTITY_Attack_Damage", 1000)
	AddDefine("SUBENTITY_Attack_Hitstun", 60)
	AddDefine("SUBENTITY_Attack_Blockstun", 60)
	AddDefine("SUBENTITY_DestroyOnHit", true)
	AddDefine("SUBENTITY_DestroyOnBlock", true)
	AddDefine("SUBENTITY_DestroyWhenHit", true)
	
	
	AddCategory("Collisions", false)
	AddDefine("SUBENTITY_Colbox_Phantom", true)
	AddDefine("SUBENTITY_Colbox_Use", false)
	AddDefine("SUBENTITY_Colbox_Width", 2500)
	AddDefine("SUBENTITY_Colbox_Bottom", 0)
	AddDefine("SUBENTITY_Colbox_Top", 5000)
	
	
	AddCategory("Hitbox Hurtbox", false)
	AddDefine("SUBENTITY_Hitbox_Use", false)
	AddDefine("SUBENTITY_Hitbox_Back", -10000)
	AddDefine("SUBENTITY_Hitbox_Front", 10000)
	AddDefine("SUBENTITY_Hitbox_Bottom", -10000)
	AddDefine("SUBENTITY_Hitbox_Top", 10000)
	
	AddDefine("SUBENTITY_Hurtbox_Use", false)
	AddDefine("SUBENTITY_Hurtbox_Back", 0)
	AddDefine("SUBENTITY_Hurtbox_Front", 0)
	AddDefine("SUBENTITY_Hurtbox_Bottom", 0)
	AddDefine("SUBENTITY_Hurtbox_Top", 0)
	

func Gizmos(emodule, stateHandle):
	var colors = [Color(0.4, 0.4, 1.0), Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4)]
	var lineWidthUnfocused = 4
	
	var showMovement = _categories["Behavior"]["Open"]
	var showHitbox = _categories["Hitbox Hurtbox"]["Open"] and _specblockDefines["SUBENTITY_Hitbox_Use"]["Value"]
	var showHurtbox = _categories["Hitbox Hurtbox"]["Open"] and _specblockDefines["SUBENTITY_Hurtbox_Use"]["Value"]
	var showColbox = _categories["Collisions"]["Open"] and _specblockDefines["SUBENTITY_Colbox_Use"]["Value"]
	var showAnchor = true
	
	if(showAnchor):
		var color = colors[2]
		var lineWidth = 4
		var anchorSize = 2000
		emodule.GizmoLine([-anchorSize,0,0], [anchorSize,0,0], color, lineWidth)
		emodule.GizmoLine([0,-anchorSize,0], [0,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([-anchorSize,0,0], [0,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([-anchorSize,0,0], [0,-anchorSize,0], color, lineWidth)
		emodule.GizmoLine([anchorSize,0,0], [0,anchorSize,0], color, lineWidth)
		emodule.GizmoLine([anchorSize,0,0], [0,-anchorSize,0], color, lineWidth)
	
	if(showMovement):
		var color = colors[0]
		var lineWidth = lineWidthUnfocused
		GizmoStraight(emodule, Vector2(_specblockDefines["SUBENTITY_Move_X"]["Value"],_specblockDefines["SUBENTITY_Move_Y"]["Value"]), color, lineWidth)
	
	if(showHitbox):
		GizmoBox(emodule, [
				_specblockDefines["SUBENTITY_Hitbox_Back"]["Value"],
				_specblockDefines["SUBENTITY_Hitbox_Front"]["Value"],
				_specblockDefines["SUBENTITY_Hitbox_Bottom"]["Value"],
				_specblockDefines["SUBENTITY_Hitbox_Top"]["Value"]
			], false, stateHandle, 1)
	if(showHurtbox):
		GizmoBox(emodule, [
				_specblockDefines["SUBENTITY_Hurtbox_Back"]["Value"],
				_specblockDefines["SUBENTITY_Hurtbox_Front"]["Value"],
				_specblockDefines["SUBENTITY_Hurtbox_Bottom"]["Value"],
				_specblockDefines["SUBENTITY_Hurtbox_Top"]["Value"]
			], false, stateHandle, 0)
	if(showColbox):
		GizmoBox(emodule, [
				_specblockDefines["SUBENTITY_Colbox_Width"]["Value"],
				_specblockDefines["SUBENTITY_Colbox_Bottom"]["Value"],
				_specblockDefines["SUBENTITY_Colbox_Top"]["Value"]
			], false, stateHandle, 2)


# TODO: Most likely need to refactor gizmo use... later

var g_NbFramesSimul = 30
var g_NbFramesPerNotch = 10
var g_NbFramesSimulPrecision = 3
var g_NbNotches = 3
var g_NotchSize = 1400
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
		emodule.GizmoLine([x, y-g_NotchSize+offset.y, 0], [x,y+g_NotchSize+offset.y,0], color, lineWidth)

func GizmoBox(emodule, args, lineActive, _stateHandle, type):
	var color = [Color(0.4, 0.4, 1.0), Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4)][type]
	var colorBack = [Color(0.3, 0.3, 1.0, 0.45), Color(1.0, 0.3, 0.3, 0.45), Color(0.3, 1.0, 0.3, 0.45)][type]
	var widthActive = [6,6,6][type]
	var widthInactive = [2,2,2][type]
	var l = 0
	var r = 0
	var b = 0
	var t = 0
	if(args.size() > 3):
		l = module.ArgInt(args, null, 0, 0)
		r = module.ArgInt(args, null, 1, 0)
		b = module.ArgInt(args, null, 2, 0)
		t = module.ArgInt(args, null, 3, 0)
	elif(args.size() > 2):
		r = module.ArgInt(args, null, 0, 0)
		b = module.ArgInt(args, null, 1, 0)
		t = module.ArgInt(args, null, 2, 0)
		l = -r
	else:
		r = module.ArgInt(args, null, 0, 0)
		t = module.ArgInt(args, null, 1, 0)
		l = -r
		b = -t
	if(r < l):
		r = l
	if(t < b):
		t = b
	var hc = (l+r)/2
	var vc = (b+t)/2
	var drawRhombus = (type == 2)
	var width = (widthActive if lineActive else widthInactive)
	
	if(lineActive):
		emodule.GizmoFilledBox([l,t,0], [r,b,0], colorBack, color, width)
	else:
		emodule.GizmoBox([l,t,0], [r,b,0], color, width)
	
	if(drawRhombus):
		emodule.GizmoLine([l, vc,0], [hc, t,0], color, width)
		emodule.GizmoLine([hc, t,0], [r, vc,0], color, width)
		emodule.GizmoLine([r, vc,0], [hc, b,0], color, width)
		emodule.GizmoLine([hc, b,0], [l, vc,0], color, width)
