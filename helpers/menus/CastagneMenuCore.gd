# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

var _menuData
var _menuParams
export var MenuRootPath = "Menu"
var _configData

var _menuOptions
var _selectedOption

var _active = true


func InitMenu(menuData, menuParams):
	_menuData = menuData
	_menuParams = menuParams
	_menuOptions = []
	_selectedOption = null
	
	Setup(menuData, menuParams)

func Setup(menuData, menuParams):
	for o in menuData["Options"]:
		_menuOptions.push_back(AddToMenu(CreateMenuOption(o)))
	if(_menuOptions.empty()):
		Castagne.Error("No menu options ! Menu deactivated.")
		_active = false
		return
	
	var nbOptions = _menuOptions.size()
	for i in range(nbOptions):
		if(i > 0):
			_menuOptions[i].SetMenuAction("Up", funcref(self, "Select"), _menuOptions[i-1])
		if(i < nbOptions - 1):
			_menuOptions[i].SetMenuAction("Down", funcref(self, "Select"), _menuOptions[i+1])
	
	Select(_menuOptions[0])

func CreateMenuOption(optionData):
	var elementPS = null
	if(optionData["ScenePath"] != null):
		elementPS = Castagne.Loader.Load(optionData["ScenePath"])
		if elementPS == null:
			Castagne.Error("Menu: Couldn't load menu option with custom scene "+str(optionData["ScenePath"]))
	
	if(elementPS == null and _menuData["DefaultElements"].has(optionData["Type"])):
		elementPS = _menuData["DefaultElements"][optionData["Type"]]
	
	if(elementPS == null):
		Castagne.Error("Menu: Couldn't create menu option with type "+str(optionData["Type"]))
		return null
	
	var element = elementPS.instance()
	element.InitElement(optionData, self)
	return element

func AddToMenu(menuOption):
	get_node(MenuRootPath).add_child(menuOption)
	return menuOption

func Select(option):
	if(_selectedOption != null):
		_selectedOption.OnUnselect()
	_selectedOption = option
	_selectedOption.OnSelect()

func _process(_delta):
	if(_selectedOption == null or !_active):
		return
	
	var inputs = PollMenuNavigationInput()
	
	var inputPriority = ["Confirm", "Back", "Next", "Previous", "Right", "Left", "Down", "Up"]
	for i in inputPriority:
		if(inputs[i]):
			_selectedOption.UseMenuAction(i)
			break

func GetInput():
	return _configData.Input()

func PollMenuNavigationInput(devicesList = null):
	if(devicesList == null):
		devicesList = _configData.Input().GetDevicesList()
	for device in devicesList:
		var inputData = _configData.Input().PollDeviceMenu(device)
		for k in inputData:
			if(inputData[k]):
				return inputData
	return _configData.Input().PollDeviceMenu("empty")

func FindMenuCallback(mcb):
	if(typeof(mcb) == TYPE_STRING):
		if(has_method("MCB_"+mcb)):
			return funcref(self, "MCB_"+mcb)
		if(has_method(mcb)):
			return funcref(self, mcb)
	return Castagne.Menus.FindMenuCallback(mcb)
