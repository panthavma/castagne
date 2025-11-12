# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

var _postBattle

var _device
var _isWinner
var _castagneInput

var wantsRematch = false
var chosenOption = 0

func InitPlayer(postBattle, _pid, device, winner, menuParams):
	_postBattle = postBattle
	_device = device
	_isWinner = winner
	_castagneInput = menuParams["StateHandle"].Input()
	
	var isNullDevice = _castagneInput.IsNullDeviceType(_castagneInput.GetDevice(_device)["Type"])
	
	if(isNullDevice):
		wantsRematch = true
	
	UpdateDisplay()
	
	if(isNullDevice):
		_postBattle.TryRematch()



func UpdateDisplay():
	pass



var _timeout = 0.4
func _process(delta):
	if(_timeout > 0):
		_timeout -= delta
		return
	
	var i = _castagneInput.PollDeviceMenu(_device)
	
	if(wantsRematch):
		if(i["Back"]):
			wantsRematch = false
			UpdateDisplay()
	else:
		if(i["Confirm"]):
			if(chosenOption == 0):
				wantsRematch = true
				UpdateDisplay()
				_postBattle.TryRematch()
			else:
				_postBattle.GoToMainMenu()
		elif(i["Up"]):
			chosenOption = 0
			UpdateDisplay()
		elif(i["Down"]):
			chosenOption = 1
			UpdateDisplay()
