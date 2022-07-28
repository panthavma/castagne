extends Control

var drawList = []
var emodule

func _ready():
	var canvasRID = self.get_canvas_item()
	VisualServer.canvas_item_set_draw_index(canvasRID, 1000)
	VisualServer.canvas_item_set_z_index(canvasRID, 1000)

func _draw():
	for d in drawList:
		if(d["Type"] == emodule.GIZMO_TYPE.Line):
			draw_line(d["A"], d["B"], d["Color"], d["Width"], true)
		if(d["Type"] == emodule.GIZMO_TYPE.Rect):
			draw_rect(Rect2(d["A"], d["B"] - d["A"]), d["Color"])
