# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

onready var inputConfig = $".."

var _kbrGIID = -1
var _kbrLI = -1
var _kbrBI = -1
var _kbrBinding = null
func KeyboardRebindStart(gameInputID, layoutID, bindingID):
	_kbrGIID = gameInputID
	_kbrLI = layoutID
	_kbrBI = bindingID
	var physicalInput = inputConfig.layout[inputConfig.inputID]
	SetBinding(inputConfig.editor.configData.Input().PhysicalInputGetKeyboardBindings(physicalInput)[_kbrGIID][_kbrLI][_kbrBI])
	show()

func _input(event):
	if event is InputEventKey: 
		SetBinding(event.scancode)

func SetBinding(b):
	_kbrBinding = b
	var label = $Panel/VBox/Text
	var t = "Press a key to bind it:\n"
	if(_kbrBinding == null):
		t += "None"
	else:
		t += OS.get_scancode_string(_kbrBinding)
	label.set_text(t)

func _on_KBRConfirm_pressed():
	var physicalInput = inputConfig.layout[inputConfig.inputID]
	var bindings = inputConfig.editor.configData.Input().PhysicalInputGetKeyboardBindings(physicalInput)
	
	bindings[_kbrGIID][_kbrLI][_kbrBI] = _kbrBinding
	inputConfig.layout[inputConfig.inputID]["KeyboardInputs"] = bindings
	
	inputConfig.ShowConfigPanel()


func _on_KBRCancel_pressed():
	hide()
