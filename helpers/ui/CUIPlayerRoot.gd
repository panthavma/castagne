# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

var _isMirrored = false
func UIInitialize(stateHandle, battleInitData, pid, mirror = false):
	_isMirrored = mirror
	if(mirror):
		ApplyMirror()

func AddWidget(widget, hookPoint):
	widget.isMirrored = _isMirrored
	if(has_node(hookPoint)):
		get_node(hookPoint).add_child(widget)
		return true
	else:
		Castagne.Error("Widget: Can't find player hook point at "+str(hookPoint))
		return false

var _applyMirror_Recursive = false
func ApplyMirror(node = null):
	var applyToChildren = (node == null) or _applyMirror_Recursive
	if(node != null):
		var anchorL = node.get_anchor(MARGIN_LEFT)
		var anchorR = node.get_anchor(MARGIN_RIGHT)
		var marginL = node.get_margin(MARGIN_LEFT)
		var marginR = node.get_margin(MARGIN_RIGHT)
		
		node.set_anchor_and_margin(MARGIN_LEFT, 1.0 - anchorR, -marginR, false)
		node.set_anchor_and_margin(MARGIN_RIGHT, 1.0 - anchorL, -marginL, false)
	else:
		node = self
	
	if(applyToChildren):
		for c in node.get_children():
			ApplyMirror(c)
