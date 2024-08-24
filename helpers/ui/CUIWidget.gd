# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

var isMirrored = false

export var VariableName_Main = ""
export var VariableName_Sub = ""
export var VariableName_Max = ""

# Interface

func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	pass
func WidgetUpdate(stateHandle):
	pass

# Helpers

func _FetchVariableNamesFromCASPData(caspData):
	if(caspData != null):
		if(caspData.has("Variable1") and caspData["Variable1"] != null and !caspData["Variable1"].empty()):
			VariableName_Main = caspData["Variable1"]
		if(caspData.has("Variable2") and caspData["Variable2"] != null and !caspData["Variable2"].empty()):
			VariableName_Sub = caspData["Variable2"]
		if(caspData.has("Variable3") and caspData["Variable3"] != null and !caspData["Variable3"].empty()):
			VariableName_Max = caspData["Variable3"]

func _FetchValuesFromState(stateHandle):
	return {
		"Main": _FetchSingleValueFromState(stateHandle, VariableName_Main),
		"Sub": _FetchSingleValueFromState(stateHandle, VariableName_Sub),
		"Max": _FetchSingleValueFromState(stateHandle, VariableName_Max, 1000),
	}
func _FetchSingleValueFromState(stateHandle, VariableName, defaultValue = 0):
	if(VariableName.empty()):
		return _FetchSingleValueFromState_PostProcess(defaultValue)
	if(stateHandle.EntityHas(VariableName)):
		return _FetchSingleValueFromState_PostProcess(stateHandle.EntityGet(VariableName))
	return _FetchSingleValueFromState_PostProcess(VariableName)
func _FetchSingleValueFromState_PostProcess(v):
	v = str(v)
	if(v.is_valid_integer()):
		return int(v)
	return 0

func _HasAsset(caspData, key):
	return caspData != null and caspData.has(key) and !caspData[key].empty()

func _LoadAsset(caspData, key, default = null, errorOnEmpty = true):
	var asset = null
	var hasAsset = _HasAsset(caspData, key)
	if(hasAsset):
		asset = Castagne.Loader.Load(caspData[key])
	
	if(asset != null):
		return asset
	elif(errorOnEmpty):
		Castagne.Error("Widget: Couldn't load asset "+str(key)+
			(" ("+str(caspData[key])+")" if hasAsset else "")+
			"!")
	return default


# Default Widget Helpers

var defaultColors = [
	"white", "red", "orange", "yellow", "green", "cyan", "blue", "purple", "pink", "gray", "black"
]
func _DefaultWidget_GetColor(caspData):
	if(caspData != null):
		if(caspData.has("DefaultColor")):
			var c = caspData["DefaultColor"]
			if(c >= 0 and c < defaultColors.size()):
				return defaultColors[c]
	return defaultColors[0]
var _defaultWidgetAssetRoot = "res://castagne/assets/ui/widgets/"
func _DefaultWidget_LoadPath(path):
	if(!path.begins_with("res://")):
		path = _defaultWidgetAssetRoot + path
	var texture = Castagne.Loader.Load(path)
	if(texture == null):
		Castagne.Error("Default UI Bar Widget: Can't find texture "+str(path))
	return texture
