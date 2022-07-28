extends "../CastagneModule.gd"

var gizmoDisplayScript = preload("res://castagne/modules/castagne/CMEditor-GizmoDisplay.gd")
var gizmoDisplay = null
func ModuleSetup():
	RegisterModule("Editor", {"Description":"Castagne Editor related functions"})
	
	RegisterCategory("Castagne Editor")
	RegisterConfig("Editor-SelectedCharacter", 0, {"Flags":["Hidden"]})
	RegisterConfig("Editor-DocumentationFolders", "res://castagne/docs", {"Flags":["Advanced"]})
	RegisterConfig("Editor-Tools", "res://castagne/editor/tools/CETool-Compile.tscn", {"Flags":["Advanced"]})
	RegisterConfig("Editor-LockCastagneFiles", true, {"Flags":["Advanced"]})
	RegisterConfig("Editor-LockBaseSkeleton", false, {"Flags":["Advanced"]})
	
	RegisterBattleInitData("editor", false)

func BattleInit(_state, data, _battleInitData):
	data["Engine"].editorModule = self
	gizmoDisplay = Control.new()
	gizmoDisplay.set_script(gizmoDisplayScript)
	gizmoDisplay.emodule = self
	data["Engine"].add_child(gizmoDisplay)
	gizmoDisplay.set_anchors_and_margins_preset(Control.PRESET_WIDE)



var runStop = false
var runSlowmo = 0
func FrameStart(state, data):
	UpdateGizmos(state, data)
	
	if(runStop):
		state["SkipFrame"] = true
	elif(runSlowmo > 1):
		state["SkipFrame"] = state["TrueFrameID"] % runSlowmo > 0



var currentGizmos = []
var currentLine = 0
var mainEID = null
var gizmosDraw = []
func UpdateGizmos(state, data):
	mainEID = null
	var eState = null
	if(state.has("Players")):
		mainEID = state["Players"][0]["MainEntity"]
		if(!state.has(mainEID)):
			return
		eState = state[mainEID]
		# :TODO:Panthavma:20220501:Add some way of saying "init is done"
		if(!eState.has("PositionX")):
			eState = null
	
	gizmosDraw = []
	var gizmoData = {"Engine":engine, "State":state, "Data":data, "EID":mainEID}
	for g in currentGizmos:
		var f = g["Func"]
		var lineActive = currentLine == g["Line"]
		f.call_func(self, g["Args"], lineActive, gizmoData)
	
	if(gizmoDisplay != null):
		var drawList = []
		for g in gizmosDraw:
			var d = g.duplicate(true)
			if(g["Type"] == GIZMO_TYPE.Line || g["Type"] == GIZMO_TYPE.Rect):
				d["A"] = TranslatePointToDraw(d["A"], eState)
				d["B"] = TranslatePointToDraw(d["B"], eState)
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
	var tl = corner1
	var tr = Vector2(corner2.x, corner1.y)
	var br = corner2
	var bl = Vector2(corner1.x, corner2.y)
	
	GizmoLineGlobal(tl, tr, color, width, referenceEID)
	GizmoLineGlobal(tr, br, color, width, referenceEID)
	GizmoLineGlobal(br, bl, color, width, referenceEID)
	GizmoLineGlobal(bl, tl, color, width, referenceEID)
func GizmoBox(corner1, corner2, color, width=3, referenceEID = null):
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

func TranslatePointToDraw(point, eState = null):
	if(eState != null):
		point = engine.physicsModule.TranslatePosEntityToGlobal(point, eState)
	return engine.graphicsModule.TranslateIngamePosToScreen(point.x, point.y)
