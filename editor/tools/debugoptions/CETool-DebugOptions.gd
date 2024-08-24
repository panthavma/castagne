# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var _engine
var buttons = []
func SetupTool():
	toolName = "Debug Switches"
	toolDescription = "Collection of debug tools to make some problems easier to solve."
	
	for b in $Small/Scroll/List.get_children():
		if(b.has_method("set_pressed_no_signal")):
			var bn = b.get_name()
			if(has_method(bn)):
				buttons.push_back(b)
				b.connect("toggled", self, bn, [true])

func OnEngineRestarting(engine, battleInitData):
	pass

func OnEngineRestarted(engine):
	_engine = engine
	for b in buttons:
		funcref(self, b.get_name()).call_func(b.is_pressed(), false)

func GetStateHandle():
	if(_engine == null):
		return null
	return _engine.CreateStateHandle(_engine._memory)


func GFX_UI_HideUI(active, _hotload):
	var stateHandle = GetStateHandle()
	if(stateHandle == null):
		return
	var uiRoot = stateHandle.IDGlobalGet("UIRoot")
	if(uiRoot == null):
		return
	
	uiRoot.set_visible(!active)


var _debugUIVisu_Nodes = []
var _debugUIVisu_PackedScene
var _debugUIVisu_PackedScene_Colors = [Color(1.0, 1.0, 1.0), Color(0.5, 0.5, 1.0), Color(1.0, 0.5, 0.5)]
func GFX_UI_Visu(active, _hotload):
	var stateHandle = GetStateHandle()
	if(stateHandle == null):
		return
	var uiRoot = stateHandle.IDGlobalGet("UIRoot")
	if(uiRoot == null):
		return
	
	for n in _debugUIVisu_Nodes:
		if(n != null):
			n.queue_free()
	_debugUIVisu_Nodes = []
	_debugUIVisu_PackedScene = Castagne.Loader.Load("res://castagne/helpers/ui/debug/DebugUIVisualize.tscn")
	
	if(active):
		GFX_UI_Visu_CreateNodes(uiRoot, uiRoot, null)
func GFX_UI_Visu_CreateNodes(uiRoot, node, pid):
	var playerRoot = uiRoot.get_node(uiRoot.PlayersPath)
	for c in node.get_children():
		if(c == playerRoot):
			for p in c.get_child_count():
				GFX_UI_Visu_CreateNodes(uiRoot, c.get_child(p), p)
		else:
			GFX_UI_Visu_CreateNodes(uiRoot, c, pid)
	
	if(node != uiRoot and node != playerRoot):
		var v = _debugUIVisu_PackedScene.instance()
		v.get_node("NodeName").set_text(node.get_name())
		var colorID = 0
		if(pid != null):
			colorID = 1 + (pid % (_debugUIVisu_PackedScene_Colors.size()-1))
		v.set_frame_color(_debugUIVisu_PackedScene_Colors[colorID])
		node.add_child(v)
		_debugUIVisu_Nodes += [v]
