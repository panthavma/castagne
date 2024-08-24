# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Bar widget, assumes it runs with TextureBar node by default

extends "../CUIWidget.gd"

var directions = [
	TextureProgress.FILL_LEFT_TO_RIGHT,
	TextureProgress.FILL_RIGHT_TO_LEFT,
	TextureProgress.FILL_BOTTOM_TO_TOP,
	TextureProgress.FILL_TOP_TO_BOTTOM,
	TextureProgress.FILL_BILINEAR_LEFT_AND_RIGHT,
	TextureProgress.FILL_BILINEAR_TOP_AND_BOTTOM,
]

var rootMain = null
var rootSub = null

func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	_FetchVariableNamesFromCASPData(caspData)
	
	var fillMode = null
	if(VariableName_Sub.empty()):
		if(rootMain == null):
			rootMain = get_node(".")
	else:
		if(rootMain == null):
			rootMain = get_child(0)
		if(rootSub == null):
			rootSub = get_node(".")
			fillMode = rootSub.get_fill_mode()
	if(fillMode == null):
		fillMode = rootMain.get_fill_mode()
	
	if(caspData != null):
		if(caspData.has("Direction")):
			var d = caspData["Direction"]
			if(d >= 0 and d < directions.size()):
				fillMode = directions[d]
				rootMain.set_fill_mode(fillMode)
				if(rootSub != null):
					rootSub.set_fill_mode(fillMode)
	
	if(_HasAsset(caspData, "Asset1")):
		var t = _LoadAsset(caspData, "Asset1")
		if(t != null):
			rootMain.set_progress_texture(t)
	if(_HasAsset(caspData, "Asset2") and rootSub != null):
		var t = _LoadAsset(caspData, "Asset2")
		if(t != null):
			rootSub.set_progress_texture(t)
	if(_HasAsset(caspData, "Asset3")):
		var t = _LoadAsset(caspData, "Asset3")
		if(t != null):
			if(rootSub == null):
				rootMain.set_under_texture(t)
			else:
				rootSub.set_under_texture(t)
	
	if(isMirrored):
		if(fillMode == TextureProgress.FILL_LEFT_TO_RIGHT):
			fillMode = TextureProgress.FILL_RIGHT_TO_LEFT
		elif(fillMode == TextureProgress.FILL_RIGHT_TO_LEFT):
			fillMode = TextureProgress.FILL_LEFT_TO_RIGHT
		elif(fillMode == TextureProgress.FILL_CLOCKWISE):
			fillMode = TextureProgress.FILL_COUNTER_CLOCKWISE
		elif(fillMode == TextureProgress.FILL_COUNTER_CLOCKWISE):
			fillMode = TextureProgress.FILL_CLOCKWISE
		rootMain.set_fill_mode(fillMode)
		if(rootSub != null):
			rootSub.set_fill_mode(fillMode)

func WidgetUpdate(stateHandle):
	var v = _FetchValuesFromState(stateHandle)
	UpdateBar(v["Main"], v["Max"], v["Sub"])

func UpdateBar(vValue, vMax, vSub = 0):
	rootMain.set_max(vMax)
	rootMain.set_value(vValue)
	if(rootSub != null):
		rootSub.set_max(vMax)
		rootSub.set_value(vSub)
