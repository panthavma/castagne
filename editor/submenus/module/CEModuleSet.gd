# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"


# Last one must be the custom one
var defaultModules = {
	"physics":{
		"physics2d": "2D",
		"physicsuser":"Custom",
	},
	"graphics":{
		"graphics2d": "2D",
		"graphics25d": "2.5D",
		"graphics3d": "3D",
		"graphicsuser":"Custom",
	},
	"flow":{
		"flowgeneric": "Generic",
		"flowfighting":"Fighting Game",
		"flowuser":"Custom"
	},
}

onready var coresetRoot = $ModulesSet/Base/Coreset/Modules
onready var moduleSetRoot = $ModulesSet/Standard
onready var usermoduleValue = $ModulesSet/Base/User/UserModules
var coresetModules = []

var prefabModuleUnit = preload("res://castagne/editor/submenus/module/CEModuleSetModule.tscn")

func Enter():
	.Enter()
	
	coresetModules = Castagne.SplitStringToArray(editor.configData.GetDefault("Modules-coreset"))
	
	TryLoadingModules(editor.configData.Get("Modules"))
	
	CreateModuleSetWindow()

func TryLoadingModules(modulesPath):
	var moduleList = Castagne.ParseFullModulesList(modulesPath)
	var errorLog = $CheckWindow/Log/Label
	var errorText = ""
	
	if(moduleList == null):
		errorText += "Error while parsing the module list! Please check the error log for details!\n"
		errorText += "(This is probably caused by a user module not ending in '.tscn' or '.gd')\n"
		moduleList = []
	
	var modulesNotFound = []
	var dir = Directory.new()
	
	var moduleListRoot = $CheckWindow/ModuleList
	moduleListRoot.clear()
	moduleListRoot.add_item(editor.configData.Get("Modules-core"))
	for path in moduleList:
		moduleListRoot.add_item(path)
		if(!dir.file_exists(path)):
			modulesNotFound += [path]
	
	if(!modulesNotFound.empty()):
		errorText += "Module Path refers to a missing file!\n"
		for path in modulesNotFound:
			errorText += "\t"+path+"\n"
	
	var hasErrors = !errorText.empty()
	if(!hasErrors):
		errorText = "Preliminary checks passed!\nModule List seems valid."
	
	errorLog.set_text(errorText)
	$DefaultWindowButtons/Confirm.set_disabled(hasErrors)
	return !hasErrors

func GetCurrentConfig():
	var config = {}
	var user = {}
	var testList = ""
	
	var coresetText = ""
	for cb in coresetRoot.get_children():
		var n = cb.get_name()
		if(cb.is_pressed()):
			if(!coresetText.empty()):
				coresetText += ", "
			coresetText += n
	config["coreset"] = coresetText
	testList = coresetText
	
	for ctl in moduleSetRoot.get_children():
		var cat = ctl.get_name()
		var optionsButton = ctl.get_node("HBox/OptionButton")
		var selID = optionsButton.get_selected()
		var selValue = ""
		var userValue = ctl.get_node("User").get_text()
		if(selID > 0):
			selValue = defaultModules[cat].keys()[selID-1]
			if(selID == optionsButton.get_item_count()-1):
				testList += ", " + userValue
			else:
				testList += ", " + selValue
		config[cat] = selValue
		user[cat] = userValue
	
	config["user"] = usermoduleValue.get_text()
	testList += ", " + config["user"]
	
	config["_uservalues"] = user
	config["_testlist"] = testList
	
	return config

func TryLoadingCurrentConfig():
	var currentConfig = GetCurrentConfig()
	var listToLoad = currentConfig["_testlist"]
	
	return TryLoadingModules(listToLoad)

func CreateModuleSetWindow():
	for c in coresetRoot.get_children():
		c.queue_free()
	
	var coresetChosen = Castagne.SplitStringToArray(editor.configData.Get("Modules-coreset"))
	for moduleName in coresetModules:
		var cb = CheckBox.new()
		cb.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		cb.set_name(moduleName)
		cb.set_text(moduleName)
		cb.set_pressed_no_signal(moduleName in coresetChosen)
		cb.connect("toggled", self, "_ModuleSet_ModuleChanged")
		coresetRoot.add_child(cb)
	
	for c in moduleSetRoot.get_children():
		c.queue_free()
	
	for moduleCategory in defaultModules:
		var moduleOptions = defaultModules[moduleCategory]
		
		var ctl = prefabModuleUnit.instance()
		ctl.set_name(moduleCategory)
		ctl.get_node("HBox/Label").set_text(moduleCategory)
		var options = ctl.get_node("HBox/OptionButton")
		options.clear()
		options.add_item("[Disabled]")
		
		var customModuleName = moduleOptions.keys().back()
		var customModuleValue = editor.configData.Get("Modules-"+customModuleName)
		if(customModuleValue == null):
			customModuleValue = ""
		var customUserEntry = ctl.get_node("User")
		customUserEntry.set_text(str(customModuleValue))
		customUserEntry.set_editable(false)
		customUserEntry.connect("text_changed", self, "_ModuleSet_ModuleChanged")
		
		for moduleOptionName in moduleOptions:
			var moduleOptionDisplayName = moduleOptions[moduleOptionName]
			options.add_item(moduleOptionDisplayName)
		options.connect("item_selected", self, "_ModuleSet_OptionChosen", [options, customUserEntry])
		
		var chosenModuleValue = editor.configData.Get("Modules-"+moduleCategory)
		var chosenModuleInList = moduleOptions.keys().find(chosenModuleValue)
		if(chosenModuleInList >= 0):
			options.select(chosenModuleInList+1)
			customUserEntry.set_editable(chosenModuleValue == customModuleName)
		
		usermoduleValue.set_text(editor.configData.Get("Modules-user"))
		
		moduleSetRoot.add_child(ctl)
	
	usermoduleValue.connect("text_changed", self, "_ModuleSet_ModuleChanged")


func _ModuleSet_OptionChosen(optionID, optionButton, userBox):
	userBox.set_editable(optionID == optionButton.get_item_count()-1)
	TryLoadingCurrentConfig()

func _ModuleSet_ModuleChanged(_texte = null):
	TryLoadingCurrentConfig()

func _on_ButtonReload_pressed():
	TryLoadingCurrentConfig()

func _on_Confirm_pressed():
	if(TryLoadingCurrentConfig()):
		var config = GetCurrentConfig()
		for k in config:
			if(k.begins_with("_")):
				continue
			editor.configData.Set("Modules-"+k, config[k])
		
		var userValues = config["_uservalues"]
		for cat in userValues:
			var moduleName = defaultModules[cat].keys().back()
			editor.configData.Set("Modules-"+moduleName, userValues[cat])
		
		Exit(OK)
