# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Handles player

extends Node

var device
var borrowedDeviceFrom
var lendingDevice = false
var pid
var css
var selectedNode
var selectedCharacter
var _isReady
var DEFAULT_TIMEOUT = 0.1
var _timeout

# Callback to override
func Setup():
	pass

func OnCharacterChange():
	pass


# ----

func InitPlayerSlot(_css, _device, _pid, defaultSelectedCharacter):
	css = _css
	device = _device
	pid = _pid
	_timeout = DEFAULT_TIMEOUT
	Setup()
	SelectCharacter(defaultSelectedCharacter)

func SelectCharacter(c):
	if(selectedNode != null):
		selectedNode.SetSelect(pid, false)
	selectedCharacter = c
	selectedNode = c["CSS"]["Node"]
	selectedNode.SetSelect(pid, true)
	OnCharacterChange()

func IsReady():
	return _isReady

func GetAdvanceData():
	return {
		"Characters": [selectedCharacter]
	}

func _process(delta):
	if(lendingDevice):
		return
	
	if(device == null and borrowedDeviceFrom == null):
		borrowedDeviceFrom = css.FindLendableDevicePlayerSlot()
		if(borrowedDeviceFrom != null):
			borrowedDeviceFrom.lendingDevice = true
			device = borrowedDeviceFrom.device
			_timeout = DEFAULT_TIMEOUT
		else:
			return
	
	if(_timeout > 0):
		_timeout -= delta
		return
	
	var i = css.GetInput().PollDeviceMenu(device)
	
	if(_isReady):
		if(i["Back"]):
			_isReady = false
	else:
		if(i["Confirm"]):
			_isReady = true
			css.TryAdvance()
		elif(i["Back"]):
			if(borrowedDeviceFrom != null):
				borrowedDeviceFrom.lendingDevice = false
				borrowedDeviceFrom._timeout = DEFAULT_TIMEOUT
				borrowedDeviceFrom._isReady = false
				device = null
				borrowedDeviceFrom = null
			else:
				css.GoBack()
		else:
			for dir in ["Left", "Right", "Up", "Down"]:
				if(i[dir]):
					var c = selectedNode.GetNeighboor(dir)
					if(c != null):
						SelectCharacter(c)
		
