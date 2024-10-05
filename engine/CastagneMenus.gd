# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# General manager / spawner for menus

extends Node

var _menuOptions = {}

var _configData

func _ready():
	pass
	#AddMenuOption_Action("LocalBattle", "MainMenu", null)
	#AddMenuOption_Action("Training", "MainMenu", funcref(self, "MCB_CharacterSelect"))
	#AddMenuOption_Submenu("Options", "MainMenu", "Options")
	#AddMenuOption_Action("Quit", "MainMenu", funcref(self, "MCB_QuitGame"))

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

func InstanceMenu(menuName, menuParams = null, configData = null):
	if(configData == null):
		configData = Castagne.baseConfigData
	var configKeyScene = "MenuScene-"+menuName
	var configKeyData = "MenuData-"+menuName
	if(!configData.Has(configKeyScene) or !configData.Has(configKeyData)):
		Castagne.Error("InstanceMenu: Menu "+str(menuName)+" doesn't exist!")
		return null
	
	
	var menuData = configData.Get(configKeyData).duplicate(true)
	menuData["DefaultElements"] = {
			Castagne.MENUS_ELEMENT_TYPES.ACTION: Castagne.Loader.Load("res://castagne/helpers/menus/elements/default/CMED-Action.tscn"),
			Castagne.MENUS_ELEMENT_TYPES.LIST: Castagne.Loader.Load("res://castagne/helpers/menus/elements/default/CMED-List.tscn"),
		}
	
	return InstanceCustomMenu(configData.Get(configKeyScene), menuData, menuParams, configData)
	
	
	#var menu = TMP_sceneMainMenu.instance()
	#for optionName in _menuOptions:
	#	menu.AddOption(_menuOptions[optionName])
	#_selectedOption = null
	#_currentMenu = menu
	#SelectOption(menu.GetFirstOption())
	#return menu

func InstanceCustomMenu(scenePath, menuData, menuParams = null, configData = null):
	if(configData == null):
		configData = Castagne.baseConfigData
	var menuPS = Castagne.Loader.Load(scenePath)
	if(menuPS == null):
		Castagne.Error("InstanceCustomMenu: Scene "+str(menuPS)+" can't be loaded!")
		return null
	
	var menu = menuPS.instance()
	menu._configData = configData
	menu.InitMenu(menuData, menuParams)
	return menu

# --------------------------------------------------------------------------------------------------
# Menu callbacks
func FindMenuCallback(mcbName):
	var nodes = [self]
	for n in nodes:
		if(n.has_method("MCB_"+mcbName)):
			return funcref(n, "MCB_"+mcbName)
		if(n.has_method(mcbName)):
			return funcref(n, mcbName)
	return null

func MCB_QuitGame(_args):
	get_tree().quit()

func MCB_BackToMainMenu(args):
	if(args == null):
		args = [null, null]
	get_tree().get_root().add_child(InstanceMenu("MainMenu", args[0], args[1]))


func MCB_StartMatchFromCSS(args):
	var bid = args["ConfigData"].GetModuleSlot(Castagne.MODULE_SLOTS_BASE.FLOW).GetBattleInitDataFromCSS(args)
	bid["mode"] = args["CallbackParams"]["Mode"]
	var e = Castagne.InstanceCastagneEngine(bid, args["ConfigData"])
	get_tree().get_root().add_child(e)
