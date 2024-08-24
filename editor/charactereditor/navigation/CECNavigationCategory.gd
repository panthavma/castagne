# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends PanelContainer

var editor
var _categoryData
var _specialOrder

func InitFromCategory(categoryData, specialOrder = null):
	editor = categoryData["Editor"]
	_categoryData = categoryData
	_specialOrder = specialOrder
	var displayName = categoryData["Name"]
	
	if(specialOrder != null):
		if(specialOrder.has("DisplayName")):
			displayName = specialOrder["DisplayName"]
		if(specialOrder.has("IconPath")):
			var icon = Castagne.Loader.Load(specialOrder["IconPath"])
			if(icon != null):
				$Contents/Header/SpecialIcon.set_texture(icon)
				$Contents/Header/SpecialIcon.show()
	
	$Contents/Header/CategoryName.set_text(displayName)
	if(categoryData["Open"]):
		Expand()
	else:
		Reduce()

func AddItem(state):
	$Contents/States/StateList.add_child(state)


func _on_ButtonExpand_pressed():
	if($Contents/States.is_visible()):
		Reduce()
	else:
		Expand()


func Expand():
	$Contents/Header/ButtonExpand.set_text("-")
	$Contents/States.show()
	editor.categoriesStatus[_categoryData["FullName"]] = true

func Reduce():
	$Contents/Header/ButtonExpand.set_text("+")
	$Contents/States.hide()
	editor.categoriesStatus[_categoryData["FullName"]] = false
