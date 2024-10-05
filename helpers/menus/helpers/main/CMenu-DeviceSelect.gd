# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

var _callbackConfirm
var _callbackBack
var _menu
var _active = false
var _timeout = 0.0

var _mustBeFullToAdvance = false
var _mustBeEmptyToGoBack = false
var _canUseQuickSelect = true
var _quickSelectInputs = ["Left", "Right"]

var devices = []

func _ready():
	get_node(".").hide()

func Start(menu, callbackConfirm, callbackBack):
	_menu = menu
	_callbackConfirm = callbackConfirm
	_callbackBack = callbackBack
	# :TODO:Number of players, multiple players
	devices = [null, null]
	Resume()
	Tmp_UpdateText()

func Back():
	_active = false
	get_node(".").hide()
	if(_callbackBack != null):
		_callbackBack.call_func()

func Advance():
	_active = false
	get_node(".").hide()
	if(_callbackConfirm != null):
		_callbackConfirm.call_func(devices)

func Resume():
	_active = true
	_timeout = 0.3
	Tmp_UpdateText()
	get_node(".").show()

func _process(delta):
	if(!_active):
		return
	if(_timeout > 0):
		_timeout -= delta
		return
	
	var cInput = _menu.GetInput()
	
	for d in cInput.GetConnectedDevices():
		var i = cInput.PollDeviceMenu(d)
		var s = devices.find(d)
		
		if(s == -1):
			if(i["Confirm"]):
				# Enter the first empty slot
				for j in range(devices.size()):
					if(devices[j] == null):
						devices[j] = d
						Tmp_UpdateText()
						break
			elif(i["Back"]):
				# Go back if possible
				var canGoBack = true
				if(_mustBeEmptyToGoBack):
					for j in devices:
						if(j != null):
							canGoBack = false
							break
				if(canGoBack):
					Back()
			elif(_canUseQuickSelect):
				# Go to the associated button
				for j in range(_quickSelectInputs.size()):
					if(i[_quickSelectInputs[j]] and devices[j] == null):
						devices[j] = d
						Tmp_UpdateText()
						break
		else:
			if(i["Confirm"]):
				var canAdvance = true
				if(_mustBeFullToAdvance):
					for j in devices:
						if(j == null):
							canAdvance = false
							break
				if(canAdvance):
					Advance()
			elif(i["Back"]):
				devices[s] = null
				Tmp_UpdateText()
			elif(_canUseQuickSelect):
				for j in range(_quickSelectInputs.size()):
					if(j == s):
						continue
					if(i[_quickSelectInputs[j]]):
						devices[s] = null
						Tmp_UpdateText()
						break

func Tmp_UpdateText():
	var t = "Device Select\nPress to enter\n---\nP1\n"
	if(devices[0] != null):
		t += str(devices[0])
	t += "\n---\nP2\n"
	if(devices[1] != null):
		t += str(devices[1])
	t += "\n---\n"
	for c in _menu._configData.Input().GetConnectedDevices():
		if !(c in devices):
			t += str(c)+" "
	
	$Label.set_text(t)
