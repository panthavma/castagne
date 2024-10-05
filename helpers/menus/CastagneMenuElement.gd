# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node


var optionData
var menu
var _menuActions = {}

# Callback to override
func Setup():
	pass

func OnSelect():
	pass

func OnUnselect():
	pass



func InitElement(_optionData, _menu):
	optionData = _optionData
	menu = _menu
	
	if(optionData.has("TrainingAction") and optionData.has("TrainingParams")):
		var a = FindMenuCallback(optionData["TrainingAction"])
		if(a != null):
			SetMenuAction("Training", a, optionData["TrainingParams"])
	
	Setup()
func GetMenuAction(actionType):
	if(actionType in _menuActions):
		return _menuActions[actionType]
	return null
func SetMenuAction(actionType, callback, argument = null):
	_menuActions[actionType] = [callback, argument]
func UseMenuAction(actionType, extraData = null):
	var menuAction = GetMenuAction(actionType)
	if(menuAction != null):
		if(extraData != null):
			menuAction[0].call_func(menuAction[1], extraData)
		else:
			menuAction[0].call_func(menuAction[1])
func FindMenuCallback(mcb):
	var t = typeof(mcb)
	if(t != TYPE_STRING):
		return mcb # funcref
	if(has_method(mcb)):
		return funcref(self, mcb)
	if(has_method("MCB_"+mcb)):
		return funcref(self, "MCB_"+mcb)
	return menu.FindMenuCallback(mcb)

