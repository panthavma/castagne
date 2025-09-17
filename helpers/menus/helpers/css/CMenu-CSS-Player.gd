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
var selectedPalette
var _isReady
var DEFAULT_TIMEOUT = 0.1
var _timeout
var menuState = 0
enum MENUSTATE {CHARACTER, PALETTE, READY, STAGE}

# Callback to override
func Setup():
	pass

func UpdateDisplay():
	pass


# ----

func InitPlayerSlot(_css, _device, _pid, defaultSelectedCharacter):
	css = _css
	device = _device
	pid = _pid
	_timeout = DEFAULT_TIMEOUT
	selectedPalette = 0
	menuState = MENUSTATE.CHARACTER
	_isReady = false
	Setup()
	SelectCharacter(defaultSelectedCharacter)

func SelectCharacter(c):
	if(selectedNode != null):
		selectedNode.SetSelect(pid, false)
	selectedCharacter = c
	selectedNode = c["CSS"]["Node"]
	selectedNode.SetSelect(pid, true)
	UpdateDisplay()

func IsReady():
	return _isReady

func GetAdvanceData():
	return {
		"Characters": [selectedCharacter],
		"Palettes": [selectedPalette]
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
			UpdateDisplay()
		else:
			return
	
	if(_timeout > 0):
		_timeout -= delta
		return
	
	var i = css.GetInput().PollDeviceMenu(device)
	
	if(menuState == MENUSTATE.READY):
		if(i["Back"]):
			_isReady = false
			if(css.stageSelectPlayer == self):
				menuState = MENUSTATE.STAGE
			else:
				menuState = MENUSTATE.PALETTE
			UpdateDisplay()
	elif(menuState == MENUSTATE.STAGE):
		if(i["Confirm"]):
			_isReady = true
			menuState = MENUSTATE.READY
			UpdateDisplay()
			css.TryAdvance()
		elif(i["Back"]):
			menuState = MENUSTATE.PALETTE
			css.stageSelectPlayer = null
			UpdateDisplay()
		else:
			if(i["Left"]):
				css.stageSelected -= 1
				if(css.stageSelected < 0):
					css.stageSelected = 0
				UpdateDisplay()
			if(i["Right"]):
				css.stageSelected += 1
				if(css.stageSelected >= css.nbStages):
					css.stageSelected = css.nbStages-1
				UpdateDisplay()
	elif(menuState == MENUSTATE.PALETTE):
		if(i["Confirm"]):
			if(css.stageSelectPlayer == null):
				css.stageSelectPlayer = self
				menuState = MENUSTATE.STAGE
				UpdateDisplay()
			else:
				_isReady = true
				menuState = MENUSTATE.READY
				UpdateDisplay()
				css.TryAdvance()
		elif(i["Back"]):
			menuState = MENUSTATE.CHARACTER
			UpdateDisplay()
		else:
			if(i["Left"]):
				selectedPalette -= 1
				if(selectedPalette < 0):
					selectedPalette = 0
				UpdateDisplay()
			if(i["Right"]):
				selectedPalette += 1
				UpdateDisplay()
			
	elif(menuState == MENUSTATE.CHARACTER):
		if(i["Confirm"]):
			menuState = MENUSTATE.PALETTE
			UpdateDisplay()
		elif(i["Back"]):
			if(borrowedDeviceFrom != null):
				borrowedDeviceFrom.lendingDevice = false
				borrowedDeviceFrom._timeout = DEFAULT_TIMEOUT
				borrowedDeviceFrom._isReady = false
				device = null
				borrowedDeviceFrom = null
			else:
				css.GoBack()
			UpdateDisplay()
		else:
			for dir in ["Left", "Right", "Up", "Down"]:
				if(i[dir]):
					var c = selectedNode.GetNeighboor(dir)
					if(c != null):
						SelectCharacter(c)
		
