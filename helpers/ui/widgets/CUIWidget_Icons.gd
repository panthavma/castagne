# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Widget to fit several icons in a row or column

extends "../CUIWidget.gd"

export var Manual_Horizontal = true
export var Manual_IconTexturePath = "res://"

var root

var iconTexture
var iconStretchMode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	var direction = -1
	var directionHorizontal = false
	var directionAlignment = BoxContainer.ALIGN_BEGIN
	if(caspData != null and caspData.has("Direction")):
		direction = caspData["Direction"]
		if(direction == 0):
			directionHorizontal = true
			directionAlignment = BoxContainer.ALIGN_BEGIN
		elif(direction == 1):
			directionHorizontal = true
			directionAlignment = BoxContainer.ALIGN_END
		elif(direction == 2):
			directionHorizontal = false
			directionAlignment = BoxContainer.ALIGN_BEGIN
		elif(direction == 3):
			directionHorizontal = false
			directionAlignment = BoxContainer.ALIGN_END
		elif(direction == 4):
			directionHorizontal = true
			directionAlignment = BoxContainer.ALIGN_CENTER
		elif(direction == 5):
			directionHorizontal = false
			directionAlignment = BoxContainer.ALIGN_CENTER
	
	if(root == null):
		if(direction == -1):
			root = get_child(0 if Manual_Horizontal else 1)
		else:
			root = get_child(0 if directionHorizontal else 1)
	
	if(direction != -1):
		root.set_alignment(directionAlignment)
	
	if(isMirrored):
		var a = root.get_alignment()
		if(a == BoxContainer.ALIGN_BEGIN):
			root.set_alignment(BoxContainer.ALIGN_END)
		elif(a == BoxContainer.ALIGN_END):
			root.set_alignment(BoxContainer.ALIGN_BEGIN)
	
	if(iconTexture == null):
		if(_HasAsset(caspData, "Asset1")):
			iconTexture = _LoadAsset(caspData, "Asset1")
		else:
			iconTexture = Castagne.Loader.Load(Manual_IconTexturePath)
		
		if(iconTexture == null):
			iconTexture = Castagne.Loader.Load("res://castagne/assets/ui/widgets/widgetpoints-main-white.png")
			Castagne.Error("Widget Icons: No icon texture set! Using default.")
	
	_FetchVariableNamesFromCASPData(caspData)

func WidgetUpdate(stateHandle):
	var v = _FetchValuesFromState(stateHandle)
	UpdateIcons(v["Main"], v["Sub"])

func UpdateIcons(value, sub = 0):
	while(root.get_child_count() < value):
		AddNewIcon()
	
	for i in range(root.get_child_count()):
		UpdateSingleIcon(root.get_child(i), i, value, sub)

func AddNewIcon():
	root.add_child(CreateIconNode())

func CreateIconNode():
	var i = TextureRect.new()
	i.set_texture(iconTexture)
	i.set_stretch_mode(iconStretchMode)
	return i

func UpdateSingleIcon(icon, iconID, value, sub = 0):
	icon.set_visible(value > iconID)
