# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

var gizmoDisplayScript = preload("res://castagne/modules/editor/CMEditor-GizmoDisplay.gd")
var gizmoDisplay = null

signal EngineTick_FramePreStart
signal EngineTick_FrameStart
signal EngineTick_FrameEnd
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
	
	# Find a better way ?
	var nbTutorials = 6
	for i in range(nbTutorials):
		RegisterConfig("LocalConfig-TutorialDone-"+str(i), false, {"Flags":["Advanced"]})

func BattleInit(stateHandle, _battleInitData):
	gizmoDisplay = Control.new()
	gizmoDisplay.set_script(gizmoDisplayScript)
	gizmoDisplay.emodule = self
	stateHandle._engine.add_child(gizmoDisplay)
	gizmoDisplay.set_anchors_and_margins_preset(Control.PRESET_WIDE)



var runStop = false
var runSlowmo = 0
func FramePreStart(stateHandle):
	emit_signal("EngineTick_FramePreStart", stateHandle)
	UpdateGizmos(stateHandle)
	
	if(runStop):
		stateHandle.GlobalSet("_SkipFrame", true)
	elif(runSlowmo > 1):
		stateHandle.GlobalSet("_SkipFrame", stateHandle.GlobalGet("_TrueFrameID") % runSlowmo > 0)

func FrameStart(stateHandle):
	emit_signal("EngineTick_FrameStart", stateHandle)
func FrameEnd(stateHandle):
	emit_signal("EngineTick_FrameEnd", stateHandle)

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
	
	if(gizmoDisplay != null):
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
func GizmoLineGlobal(startPoint, endPoint, color, width=3, referenceEID=null):
	gizmosDraw += [{"Type":GIZMO_TYPE.Line, "A":startPoint, "B":endPoint, "Color":color, "Width":width, "EID":referenceEID}]
func GizmoLine(startPoint, endPoint, color, width=3):
	GizmoLineGlobal(startPoint, endPoint, color, width, mainEID)

func GizmoBoxGlobal(corner1, corner2, color, width=3, referenceEID = null):
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

func GizmoRectGlobal(corner1, corner2, color, referenceEID = null):
	gizmosDraw += [{"Type":GIZMO_TYPE.Rect, "A":corner1, "B":corner2, "Color":color, "EID":referenceEID}]
func GizmoRect(corner1, corner2, color):
	GizmoRectGlobal(corner1, corner2, color, mainEID)

func GizmoFilledBoxGlobal(corner1, corner2, colorBack, colorBorder, width=3, referenceEID = null):
	GizmoBoxGlobal(corner1, corner2, colorBorder, width, referenceEID)
	GizmoRectGlobal(corner1, corner2, colorBack, referenceEID)
	gizmosDraw.push_front(gizmosDraw.pop_back())
func GizmoFilledBox(corner1, corner2, colorBack, colorBorder, width=3):
	GizmoFilledBoxGlobal(corner1, corner2, colorBack, colorBorder, width, mainEID)

func TranslatePointToDraw(point, stateHandle):
	point = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityToWorld(point, stateHandle)
	return stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.GRAPHICS).TranslateIngamePosToScreen(point)
