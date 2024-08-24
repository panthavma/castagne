# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Widget that changes the icon based on a value

extends "../CUIWidget.gd"

var root

func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	if(root == null):
		root = get_node(".")
	
	if(caspData != null and caspData.has("Direction")):
		var d = caspData["Direction"]
		if(d == 0):
			root.set_align(Label.ALIGN_LEFT)
		elif(d == 1):
			root.set_align(Label.ALIGN_RIGHT)
		else:
			root.set_align(Label.ALIGN_CENTER)
	
	# :TODO: Font in labels
	#if(_HasAsset(caspData, "Asset1")):
	#	
	
	if(isMirrored):
		var a = root.get_align()
		if(a == Label.ALIGN_LEFT):
			root.set_align(Label.ALIGN_RIGHT)
		elif(a == Label.ALIGN_RIGHT):
			root.set_align(Label.ALIGN_LEFT)
	
	_FetchVariableNamesFromCASPData(caspData)

func WidgetUpdate(stateHandle):
	var v = _FetchValuesFromState(stateHandle)
	UpdateText(v["Main"])

func UpdateText(t):
	root.set_text(t)
func _FetchSingleValueFromState_PostProcess(v):
	return str(v)
