# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

var _menuOptions = {}

var _selectedOption = null
var _currentMenu = null

func SelectOption(o):
	if(_selectedOption != null):
		_selectedOption.OnUnselect()
	_selectedOption = o
	_selectedOption.OnSelect()

func _ready():
	#AddMenuOption_Action("LocalBattle", "MainMenu", null)
	AddMenuOption_Action("Training", "MainMenu", funcref(self, "MCB_CharacterSelect"))
	AddMenuOption_Submenu("Options", "MainMenu", "Options")
	AddMenuOption_Action("Quit", "MainMenu", funcref(self, "MCB_QuitGame"))

func _MODefault(data, field, default):
	if(!data.has(field)):
		data[field] = default
func _AddMenuOptionInternal(optionName, defaultMenu, data):
	_MODefault(data, "DisplayName", optionName)
	_menuOptions[optionName] = data

func AddMenuOption_Action(optionName, defaultMenu, actionFunction, actionParams = [], additionalData = {}):
	additionalData["Type"] = "Action"
	additionalData["Action"] = actionFunction
	additionalData["ActionParams"] = actionParams
	_AddMenuOptionInternal(optionName, defaultMenu, additionalData)

func AddMenuOption_Submenu(optionName, defaultMenu, submenu, additionalData = {}):
	additionalData["Type"] = "Submenu"
	additionalData["Submenu"] = submenu
	_AddMenuOptionInternal(optionName, defaultMenu, additionalData)


#var TMP_sceneMainMenu = preload("res://ui/menus/MWMainMenu.tscn")
var TMP_sceneMainMenu = null
func InstanceMenu(menuName):
	var menu = TMP_sceneMainMenu.instance()
	for optionName in _menuOptions:
		menu.AddOption(_menuOptions[optionName])
	_selectedOption = null
	_currentMenu = menu
	SelectOption(menu.GetFirstOption())
	return menu



func _process(delta):
	if(_selectedOption == null):
		return
	
	var action = null
	var potentialActions = {
		"ui_accept": "Confirm",
		"ui_up": "Up",
		"ui_down": "Down",
	}
	
	for a in potentialActions:
		if(Input.is_action_just_pressed(a)):
			action = potentialActions[a]
			break
	
	if(action != null):
		var f = _selectedOption.GetFunction(action)
		if(f != null):
			f[0].call_func(f[1])

# Menu callbacks
func MCB_SelectOption(args):
	SelectOption(args[0])

func MCB_QuitGame(_args):
	get_tree().quit()

#var TMP_sceneCSS = preload("res://ui/menus/MWCSSTemp.tscn")
var TMP_sceneCSS = null
func MCB_CharacterSelect(args):
	_selectedOption = null
	_currentMenu.queue_free()
	_currentMenu = null
	
	var css = TMP_sceneCSS.instance()
	get_tree().get_root().add_child(css)


var TMP_MW_CharP1 = 0
var TMP_MW_CharP2 = 0
var TMP_MW_PaletteP1 = 1
var TMP_MW_PaletteP2 = 1
var TMP_MW_InputP1 = 1
var TMP_MW_InputP2 = 0
var TMP_MW_Map = 1
var TMP_MW_ReturnToCSS = false
