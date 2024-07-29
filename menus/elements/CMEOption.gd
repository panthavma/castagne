# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

var _functions = {
	"Confirm": null,
	"Cancel": null,
	"Up": null,
	"Down": null,
	"Left": null,
	"Right": null,
}

func OnSelect():
	pass

func OnUnselect():
	pass

func Internal_InitFromOption(option):
	if(option["Type"] == "Action" and option["Action"] != null):
		_functions["Confirm"] = [option["Action"], option["ActionParams"]]
	InitFromOption(option)
	OnUnselect()

func InitFromOption(_option):
	pass

func GetFunction(actionName):
	if(actionName in _functions):
		return _functions[actionName]
	return null
