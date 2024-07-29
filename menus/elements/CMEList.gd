# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

export var Path_OptionsRoot = "Options"


var TMP_sceneOption = preload("res://ui/menus/MenuOption.tscn")
func AddOption(option):
	var n = TMP_sceneOption.instance()
	var optionsRoot = get_node(Path_OptionsRoot)
	
	var childID = optionsRoot.get_child_count()
	optionsRoot.add_child(n)
	if(childID > 0):
		var prev = optionsRoot.get_child(childID - 1)
		prev._functions["Down"] = [funcref(Castagne.Menus, "MCB_SelectOption"), [n]]
		n._functions["Up"] = [funcref(Castagne.Menus, "MCB_SelectOption"), [prev]]
	
	n.set_position(Vector2(0, 20*childID))
	n.Internal_InitFromOption(option)

func GetFirstOption():
	return get_node(Path_OptionsRoot).get_child(0)
