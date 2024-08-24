# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Widget that changes the icon based on a value

extends "../CUIWidget.gd"

var root

func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	if(root == null):
		root = get_node(".")
	
	if(caspData != null and root.get_child_count() == 0):
		for i in range(3):
			var key = "Asset"+str(i+1)
			if(_HasAsset(caspData, key)):
				var icon = _LoadAsset(caspData, key)
				AddIcon(icon) # Empty icon if null, expected behavior
	
	_FetchVariableNamesFromCASPData(caspData)

func WidgetUpdate(stateHandle):
	var v = _FetchValuesFromState(stateHandle)
	UpdateIcons(v["Main"])

func UpdateIcons(value):
	if(value < 0):
		value = 0
	if(value >= root.get_child_count()):
		value = root.get_child_count() - 1
	
	for i in range(root.get_child_count()):
		root.get_child(i).set_visible(i == value)

func AddIcon(icon):
	var tr = TextureRect.new()
	tr.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	tr.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	tr.set_texture(icon)
	root.add_child(tr)
	return tr
