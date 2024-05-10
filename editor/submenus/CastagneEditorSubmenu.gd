# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control


var callbackFunction
var dataPassthrough
onready var editor = $".."

func Enter():
	show()

func Exit(param = null):
	callbackFunction.call_func(param)


func _on_Cancel_pressed():
	Exit()

func _on_Confirm_pressed():
	Exit(OK)
