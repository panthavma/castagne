# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

var gizmoDisplayScript = preload("res://castagne/modules/editor/CMEditor-GizmoDisplay.gd")
var gizmoDisplay = null

signal EngineTick_FramePreStart
signal EngineTick_FrameStart
signal EngineTick_FrameEnd
signal EngineTick_InitStart
signal EngineTick_InitStartEntity
signal EngineTick_InitEndEntity
signal EngineTick_InitEnd
signal EngineTick_AIStart
signal EngineTick_AIStartEntity
signal EngineTick_AIEndEntity
signal EngineTick_AIEnd
signal EngineTick_InputStart
signal EngineTick_InputStartEntity
signal EngineTick_InputEndEntity
signal EngineTick_InputEnd
signal EngineTick_ActionStart
signal EngineTick_ActionStartEntity
signal EngineTick_ActionEndEntity
signal EngineTick_ActionEnd
signal EngineTick_PhysicsStart
signal EngineTick_PhysicsStartEntity
signal EngineTick_PhysicsEndEntity
signal EngineTick_PhysicsEnd
signal EngineTick_ReactionStart
signal EngineTick_ReactionStartEntity
signal EngineTick_ReactionEndEntity
signal EngineTick_ReactionEnd
signal EngineTick_FreezeStart
signal EngineTick_FreezeStartEntity
signal EngineTick_FreezeEndEntity
signal EngineTick_FreezeEnd
signal EngineTick_UpdateGraphics

func ModuleSetup():
	RegisterModule("Editor", Castagne.MODULE_SLOTS_BASE.EDITOR, {
		"Description":"Castagne Editor related functions"
	})
	
	RegisterCategory("Castagne Editor")
	RegisterConfig("Editor-SelectedCharacter", 0, {"Flags":["Hidden"]})
	RegisterConfig("Editor-DocumentationFolders", "res://castagne/docs", {"Flags":["Advanced"]})
	RegisterConfig("Editor-Tools", "")
	RegisterConfig("Editor-ToolsCastagne",
		"res://castagne/editor/tools/compile/CETool-Compile.tscn,"+
		"res://castagne/editor/tools/inputs/CETool-Inputs.tscn,"+
		"res://castagne/editor/tools/perf/CETool-Perf.tscn,"+
		"res://castagne/editor/tools/sceneviewer/CETool-SceneViewer.tscn,"+
		"res://castagne/editor/tools/freecam/CETool-Freecam.tscn,"+
		"res://castagne/editor/tools/debugoptions/CETool-DebugOptions.tscn,", {"Flags":["Advanced"]})
	
	RegisterConfig("Editor-LockCastagneFiles", true, {"Flags":["Advanced"]})
	RegisterConfig("Editor-LockBaseSkeleton", false, {"Flags":["Advanced"]})
	RegisterConfig("Editor-OnlyAllowCustomEditors", false)
	RegisterConfig("Editor-FirstTimeFlowDone", false, {
		"Flags":["Advanced"],
		"Description":"Marker for if first time setup has been done for this project.",
		})
	RegisterConfig("LocalConfig-Editor-FirstTimeLaunchDone", false, {
		"Flags":["Advanced"],
		"Description":"Local marker for if this user has been through the first time launch, meaning the tutorial prompt.",
		})
	RegisterConfig("LocalConfig-Editor-LastSelectedTool", 0, {
		"Flags":["Advanced"],
		"Description":"Stores the last used tool in order to load it the next time the editor is started.",
	})
	RegisterConfig("LocalConfig-Editor-LastOpenedStatePerFile", {}, {
		"Flags":["Hidden"],
		"Description":"Stores the last opened state in each file, which is then read on startup."
	})
	
	RegisterConfig("Editor-AspectRatio", "16:9")
	
	RegisterConfig("Updater-CheckOnStartup", true)
	#RegisterConfig("Updater-BranchID", 0, {"Flags":["Hidden"]})
	#RegisterConfig("Updater-Branch", "Main", {"Flags":["Hidden"]})
	#RegisterConfig("Updater-LastUpdate", null, {"Flags":["Hidden"]})
	RegisterConfig("Updater-Source", "http://castagneengine.com/builds/", {"Flags":["Advanced"]})
	
	RegisterConfig("EditorCharacterOrder", [], {"Flags":["Hidden"]})
	
	RegisterCategory("Editor")
	RegisterFunction("_Category", [1], ["EditorOnly"])
	RegisterFunction("_Overridable", [0,1], ["EditorOnly"])
	RegisterFunction("_BaseState", [0], ["EditorOnly"])
	RegisterFunction("_StateFlag", [1], ["EditorOnly"])
	RegisterFunction("_Helper", [0], ["EditorOnly"])
	RegisterFunction("_Overriding", [0], ["EditorOnly"])
	
	RegisterStateFlag("Warning")
	RegisterStateFlag("Error")
	RegisterStateFlag("TODO")
	RegisterStateFlag("TODOVFX")
	RegisterStateFlag("TODOSOUND")
	RegisterStateFlag("TODOANIM")
	RegisterStateFlag("TODOBUG")
	RegisterStateFlag("TODOFRAMEDATA")
	RegisterStateFlag("TODOMOMENTUM")
	RegisterStateFlag("TODODESIGN")
	RegisterStateFlag("CASTTODO")
	RegisterStateFlag("Overridable")
	RegisterStateFlag("Overriding")
	RegisterStateFlag("CustomEditor")
	RegisterStateFlag("Marker1")
	RegisterStateFlag("Marker2")
	RegisterStateFlag("Marker3")
	
	RegisterConfig("Editor-TmpBackgroundColor1", [12, 15, 13], {"Flags":["Hidden"]})
	RegisterConfig("Editor-TmpBackgroundColor2", [14, 28, 19], {"Flags":["Hidden"]})
	
	# Find a better way ?
	var nbTutorials = 6
	for i in range(nbTutorials):
		RegisterConfig("LocalConfig-TutorialDone-"+str(i), false, {"Flags":["Advanced"]})
		
	
	RegisterCategory("Editor Helpers")
	
	RegisterFunction("_GizmoPoint", [0,1,2,3], ["NoFunc"], {
		"Description": "Displays a point in the editor itself",
		"Arguments": ["X", "Y", "Z"]
	})

func BattleInit(stateHandle, battleInitData):
	currentGizmos = []
	var useGizmos = battleInitData.has("editor") and battleInitData["editor"]
	
	if(useGizmos):
		gizmoDisplay = Control.new()
		gizmoDisplay.set_script(gizmoDisplayScript)
		gizmoDisplay.emodule = self
		stateHandle._engine.add_child(gizmoDisplay)
		gizmoDisplay.set_anchors_and_margins_preset(Control.PRESET_WIDE)



func UpdateGraphics(stateHandle):
	emit_signal("EngineTick_UpdateGraphics", stateHandle)
#	UpdateGizmos(stateHandle)

func FramePreStart(stateHandle):
	emit_signal("EngineTick_FramePreStart", stateHandle)
#	UpdateGizmos(stateHandle)

func FrameStart(stateHandle):
	emit_signal("EngineTick_FrameStart", stateHandle)
func FrameEnd(stateHandle):
	emit_signal("EngineTick_FrameEnd", stateHandle)

func InitPhaseStart(stateHandle):
	emit_signal("EngineTick_InitStart", stateHandle)
func InitPhaseStartEntity(stateHandle):
	emit_signal("EngineTick_InitStartEntity", stateHandle)
func InitPhaseEndEntity(stateHandle):
	emit_signal("EngineTick_InitEndEntity", stateHandle)
func InitPhaseEnd(stateHandle):
	emit_signal("EngineTick_InitEnd", stateHandle)
func AIPhaseStart(stateHandle):
	emit_signal("EngineTick_AIStart", stateHandle)
func AIPhaseStartEntity(stateHandle):
	emit_signal("EngineTick_AIStartEntity", stateHandle)
func AIPhaseEndEntity(stateHandle):
	emit_signal("EngineTick_AIEndEntity", stateHandle)
func AIPhaseEnd(stateHandle):
	emit_signal("EngineTick_AIEnd", stateHandle)
func InputPhaseStart(stateHandle):
	emit_signal("EngineTick_InputStart", stateHandle)
func InputPhaseStartEntity(stateHandle):
	emit_signal("EngineTick_InputStartEntity", stateHandle)
func InputPhaseEndEntity(stateHandle):
	emit_signal("EngineTick_InputEndEntity", stateHandle)
func InputPhaseEnd(stateHandle):
	emit_signal("EngineTick_InputEnd", stateHandle)
func ActionPhaseStart(stateHandle):
	emit_signal("EngineTick_ActionStart", stateHandle)
func ActionPhaseStartEntity(stateHandle):
	emit_signal("EngineTick_ActionStartEntity", stateHandle)
func ActionPhaseEndEntity(stateHandle):
	emit_signal("EngineTick_ActionEndEntity", stateHandle)
func ActionPhaseEnd(stateHandle):
	emit_signal("EngineTick_ActionEnd", stateHandle)
func PhysicsPhaseStart(stateHandle):
	emit_signal("EngineTick_PhysicsStart", stateHandle)
func PhysicsPhaseStartEntity(stateHandle):
	emit_signal("EngineTick_PhysicsStartEntity", stateHandle)
func PhysicsPhaseEndEntity(stateHandle):
	emit_signal("EngineTick_PhysicsEndEntity", stateHandle)
func PhysicsPhaseEnd(stateHandle):
	emit_signal("EngineTick_PhysicsEnd", stateHandle)
func ReactionPhaseStart(stateHandle):
	emit_signal("EngineTick_ReactionStart", stateHandle)
func ReactionPhaseStartEntity(stateHandle):
	emit_signal("EngineTick_ReactionStartEntity", stateHandle)
func ReactionPhaseEndEntity(stateHandle):
	emit_signal("EngineTick_ReactionEndEntity", stateHandle)
func ReactionPhaseEnd(stateHandle):
	emit_signal("EngineTick_ReactionEnd", stateHandle)
func FreezePhaseStart(stateHandle):
	emit_signal("EngineTick_FreezeStart", stateHandle)
func FreezePhaseStartEntity(stateHandle):
	emit_signal("EngineTick_FreezeStartEntity", stateHandle)
func FreezePhaseEndEntity(stateHandle):
	emit_signal("EngineTick_FreezeEndEntity", stateHandle)
func FreezePhaseEnd(stateHandle):
	emit_signal("EngineTick_FreezeEnd", stateHandle)


var currentGizmos = []
var currentLine = 0
var mainEID = null
var gizmosDraw = []
func UpdateGizmos(stateHandle):
	if(gizmoDisplay == null):
		return
	
	mainEID = null
	if(stateHandle.GlobalHas("_ActiveEntities")):
		stateHandle.PointToPlayer(0)
		if(!stateHandle.PointToEntity(stateHandle.PlayerGet("MainEntity"))):
			return
		# :TODO:Panthavma:20220501:Add some way of saying "init is done"
		if(!stateHandle.EntityHas("_PositionX") or !stateHandle.EntityHas("_PositionY")):
			return
	else:
		gizmoDisplay.drawList = []
		gizmoDisplay.update()
		return
	
	gizmosDraw = []
	for g in currentGizmos:
		var f = g["Func"]
		var lineActive = currentLine == g["Line"]
		f.call_func(self, g["Args"], lineActive, stateHandle)
	
	var drawList = []
	for g in gizmosDraw:
		var d = g.duplicate(true)
		if(g["Type"] == GIZMO_TYPE.Line || g["Type"] == GIZMO_TYPE.Rect):
			d["A"] = TranslatePointToDraw(d["A"], stateHandle)
			d["B"] = TranslatePointToDraw(d["B"], stateHandle)
		drawList += [d]
	gizmoDisplay.drawList = drawList
	gizmoDisplay.update()

enum GIZMO_TYPE {
	Line, Rect
}
func GizmoGetColor(colorName, context = "Standard"):
	var standardColors = {
		"White": Color(1.0, 1.0, 1.0),
		"Red": Color(1.0, 0.4, 0.4),
		"Green": Color(0.4, 1.0, 0.4),
		"Blue": Color(0.4, 0.4, 1.0),
		"Pink": Color(1.0, 0.4, 1.0),
		"Yellow": Color(1.0, 1.0, 0.4),
	}
	var backgroundColors = {
		"White": Color(1.0, 1.0, 1.0, 0.45),
		"Red": Color(1.0, 0.3, 0.3, 0.45),
		"Green": Color(0.3, 1.0, 0.3, 0.45),
		"Blue": Color(0.3, 0.3, 1.0, 0.45),
		"Pink": Color(1.0, 0.3, 1.0, 0.45),
		"Yellow": Color(1.0, 1.0, 0.3, 0.45),
	}
	var d = {"Standard": standardColors, "Background": backgroundColors}
	if (context in d) and (colorName in d[context]):
		return d[context][colorName]
	return standardColors["White"]
func _GizmoSolveColor(c, context = "Standard"):
	if(typeof(c) == TYPE_STRING):
		return GizmoGetColor(c, context)
	return c
	
func GizmoLineGlobal(startPoint, endPoint, color, width=3, referenceEID=null):
	color = _GizmoSolveColor(color)
	gizmosDraw += [{"Type":GIZMO_TYPE.Line, "A":startPoint, "B":endPoint, "Color":color, "Width":width, "EID":referenceEID}]
func GizmoLine(startPoint, endPoint, color, width=3):
	GizmoLineGlobal(startPoint, endPoint, color, width, mainEID)

func GizmoBoxGlobal(corner1, corner2, color, width=3, referenceEID = null):
	color = _GizmoSolveColor(color)
	var tl = [corner1[0], corner1[1], 0]
	var tr = [corner2[0], corner1[1], 0]
	var br = [corner2[0], corner2[1], 0]
	var bl = [corner1[0], corner2[1], 0]
	
	GizmoLineGlobal(tl, tr, color, width, referenceEID)
	GizmoLineGlobal(tr, br, color, width, referenceEID)
	GizmoLineGlobal(br, bl, color, width, referenceEID)
	GizmoLineGlobal(bl, tl, color, width, referenceEID)
func GizmoBox(corner1, corner2, color, width=3, _referenceEID = null):
	GizmoBoxGlobal(corner1, corner2, color, width, mainEID)
func GizmoRhombusGlobal(corner1, corner2, color, width = 3, referenceEID = null):
	color = _GizmoSolveColor(color)
	var hc = 0.5 * (corner1[0] + corner2[0])
	var vc = 0.5 * (corner1[1] + corner2[1])
	var l = [corner1[0], vc, 0]
	var r = [corner2[0], vc, 0]
	var t = [hc, corner1[1], 0]
	var b = [hc, corner2[1], 0]
	
	GizmoLineGlobal(l, t, color, width, referenceEID)
	GizmoLineGlobal(t, r, color, width, referenceEID)
	GizmoLineGlobal(r, b, color, width, referenceEID)
	GizmoLineGlobal(b, l, color, width, referenceEID)
func GizmoRhombus(corner1, corner2, color, width = 3):
	GizmoRhombusGlobal(corner1, corner2, color, width, mainEID)

func GizmoRectGlobal(corner1, corner2, color, referenceEID = null):
	color = _GizmoSolveColor(color, "Background")
	gizmosDraw += [{"Type":GIZMO_TYPE.Rect, "A":corner1, "B":corner2, "Color":color, "EID":referenceEID}]
func GizmoRect(corner1, corner2, color):
	GizmoRectGlobal(corner1, corner2, color, mainEID)

func GizmoPointGlobal(point, color, width = 3, radius = 2000, referenceEID = null):
	color = _GizmoSolveColor(color)
	GizmoLineGlobal([point[0]-radius, point[1], point[2]], [point[0]+radius, point[1], point[2]], color, width, referenceEID)
	GizmoLineGlobal([point[0], point[1]-radius, point[2]], [point[0], point[1]+radius, point[2]], color, width, referenceEID)
func GizmoPoint(point, color, width = 3, radius = 2000):
	GizmoPointGlobal(point, color, width, radius, mainEID)

func GizmoCircleGlobal(point, color, width = 3, radius = 2000, circlePoints = 8, circleOffset = 0.0, referenceEID = null):
	color = _GizmoSolveColor(color)
	var p = []
	var angle = 2*PI/float(circlePoints)
	for i in range(circlePoints):
		var a = angle*i + circleOffset
		p += [[point[0] + int(cos(a) * radius), point[1]+int(sin(a) * radius), point[2]]]
		if(i >= 1):
			GizmoLineGlobal(p[i-1], p[i], color, width, referenceEID)
	GizmoLineGlobal(p[circlePoints-1], p[0], color, width, referenceEID)
func GizmoCircle(point, color, width = 3, radius = 2000, circlePoints = 8, circleOffset = 0.0):
	GizmoCircleGlobal(point, color, width, radius, circlePoints, circleOffset, mainEID)

func GizmoCrosshairGlobal(point, color, width = 3, innerRadius = 2000, outerRadius = 3500, circlePoints = 4, circleOffset = 0.0, referenceEID = null):
	color = _GizmoSolveColor(color)
	GizmoPointGlobal(point, color, width, innerRadius, referenceEID)
	GizmoCircleGlobal(point, color, width, outerRadius, circlePoints, circleOffset, referenceEID)
func GizmoCrosshair(point, color, width = 3, innerRadius = 2000, outerRadius = 3500, circlePoints = 4, circleOffset = 0.0):
	GizmoCrosshairGlobal(point, color, width, innerRadius, outerRadius, circlePoints, circleOffset, mainEID)

func GizmoFilledBoxGlobal(corner1, corner2, colorBack, colorBorder, width=3, referenceEID = null):
	GizmoBoxGlobal(corner1, corner2, colorBorder, width, referenceEID)
	GizmoRectGlobal(corner1, corner2, colorBack, referenceEID)
	gizmosDraw.push_front(gizmosDraw.pop_back())
func GizmoFilledBox(corner1, corner2, colorBack, colorBorder, width=3):
	GizmoFilledBoxGlobal(corner1, corner2, colorBack, colorBorder, width, mainEID)

func TranslatePointToDraw(point, stateHandle):
	point = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityToWorld(point, stateHandle)
	return stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.GRAPHICS).TranslateIngamePosToScreen(point)


var GIZMO_MANUAL_COLOR = "Yellow"
var GIZMO_MANUAL_LINEWIDTH_INACTIVE = 2
var GIZMO_MANUAL_LINEWIDTH_ACTIVE = 4
func Gizmo_GizmoPoint(emodule, args, lineActive, stateHandle):
	var pos = [
		ArgInt(args, stateHandle, 0, 0),
		ArgInt(args, stateHandle, 1, 0),
		ArgInt(args, stateHandle, 2, 0),
	]
	var lineWidth = GIZMO_MANUAL_LINEWIDTH_ACTIVE if lineActive else GIZMO_MANUAL_LINEWIDTH_INACTIVE
	emodule.GizmoCircle(pos, GIZMO_MANUAL_COLOR, lineWidth)
	emodule.GizmoPoint(pos, GIZMO_MANUAL_COLOR, lineWidth)
