extends "res://castagne/modules/graphics/ui/CUIWidget.gd"


export var VariableName = "CUIWidget_IconList_VariableName"

func WidgetUpdate(stateHandle):
	var value = stateHandle.EntityGet(VariableName)
	for i in range(get_child_count()):
		get_child(i).set_visible(value > i)
