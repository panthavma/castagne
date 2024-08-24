extends Control

var editor = null
var toolFocused = false
var toolName = "No Name"
var toolDescription = "No Description"
var toolDocumentationPage = "/Editor"

func SetupTool():
	pass

func AddTool(rootSmallView, rootExpandedView):
	var smallView = Control.new()
	if(get_child_count() > 0):
		smallView = get_child(0)
		remove_child(smallView)
	
	smallView.show()
	self.show()
	
	smallView.set_anchors_preset(Control.PRESET_WIDE)
	set_anchors_preset(Control.PRESET_WIDE)
	
	rootSmallView.add_child(smallView)
	rootExpandedView.add_child(self)

func OnEngineRestarting(engine, battleInitData):
	pass

func OnEngineRestarted(engine):
	pass

func OnEngineInitError(engine):
	pass

func OnEngineTick(stateHandle):
	pass
