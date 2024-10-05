# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CMenu-CSS-Icon.gd"

export var PathIcon = "Icon"
export var PathSelect = "Select"

func Setup():
	if(character == null):
		for c in get_node(".").get_children():
			c.hide()
		return
	
	get_node(PathIcon).set_texture(Castagne.Loader.Load(character["CSS"]["Data"]["MENU_CSSIconPath"]))
	for c in get_node(PathSelect).get_children():
		c.hide()

func SetSelect(pid, isSelected):
	get_node(PathSelect).get_child(pid).set_visible(isSelected)
