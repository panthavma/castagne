# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# CastagneMenu is the base script for a menu, and handles
# - Setting up the menu
# - Gathering menu input
# - Handling menu logic

extends Node

var _menuData

func CreateMenu(menuData):
	_menuData = menuData
	
