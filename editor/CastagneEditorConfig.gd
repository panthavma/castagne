# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

var editor
var showAdvancedParams = false
var paramsToSave = {}
var saveReloadPower = 0
var backLocked = false
var SAVERELOAD_NONE = 0
var SAVERELOAD_RELOAD = 1
var SAVERELOAD_RESTART = 2

func EnterMenu(advancedMode = false):
	show()
	showAdvancedParams = advancedMode
	
	$Save.set_text("Save")
	$Save.set_disabled(true)
	paramsToSave = {}
	saveReloadPower = SAVERELOAD_NONE
	backLocked = false
	
	var tabs = $Tabs
	
	$Title.set_text("Configuration Editor"+(" - Advanced" if showAdvancedParams else "")+"\n"+editor.configData.Get("CastagneVersion"))
	
	for c in tabs.get_children():
		c.queue_free()
	
	var tabID = tabs.get_child_count()
	for module in editor.configData.GetModules():
		var page = CreateStandardPage(module)
		tabs.add_child(page)
		tabs.set_tab_title(tabID, module.moduleName)
		tabID += 1
	
	call_deferred("FitTabs")

func CreateStandardPage(module):
	var pageRoot = ScrollContainer.new()
	var root = VBoxContainer.new()
	pageRoot.add_child(root)
	pageRoot.set_name(module.moduleName)
	root.set_name("CategoryList")
	root.set_h_size_flags(SIZE_EXPAND_FILL)
	root.set_v_size_flags(SIZE_EXPAND_FILL)
	
	var createDescription = true
	if createDescription:
		var panel = CreateStandardPagePanel(module.moduleName)
		var categoryRoot = panel.get_child(0)
		root.add_child(panel)
		
		var moduleDescription = Label.new()
		moduleDescription.set_text(module.moduleDocumentation["Description"])
		moduleDescription.set_align(Label.ALIGN_FILL)
		moduleDescription.set_valign(Label.VALIGN_CENTER)
		categoryRoot.add_child(moduleDescription)
	
	var nbCategories = 0
	
	for categoryName in module.moduleDocumentationCategories:
		var category = module.moduleDocumentationCategories[categoryName]
		
		if(category["Config"].empty()):
			continue
		
		var panel = CreateStandardPagePanel(category["Name"])
		var categoryRoot = panel.get_child(0)
		
		var nbParams = 0
		for config in category["Config"]:
			if(config["Flags"].has("Hidden") or
				(!showAdvancedParams and (config["Flags"].has("Advanced") or config["Flags"].has("Expert")))):
				continue
			
			categoryRoot.add_child(CreateConfigOption(module, config))
			nbParams += 1
		
		if(nbParams > 0):
			nbCategories += 1
			root.add_child(panel)
	
	if(nbCategories == 0):
		var panel = CreateStandardPagePanel("This module has no configuration parameters.")
		var categoryRoot = panel.get_child(0)
		root.add_child(panel)
	
	return pageRoot

func CreateStandardPagePanel(title):
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_WIDE)
	panel.set_name(title)
	
	var categoryRoot = VBoxContainer.new()
	categoryRoot.set_name("ParamList")
	panel.add_child(categoryRoot)
	categoryRoot.set_h_size_flags(SIZE_EXPAND_FILL)
	categoryRoot.set_v_size_flags(SIZE_EXPAND_FILL)
	
	var panelTitle = Label.new()
	panelTitle.set_text("--- "+str(title)+" ---")
	panelTitle.set_align(Label.ALIGN_CENTER)
	panelTitle.set_valign(Label.VALIGN_CENTER)
	categoryRoot.add_child(panelTitle)
	
	return panel

var _customConfigCalled
func _ExecuteCustomConfig(config):
	_customConfigCalled = config
	editor.EnterSubmenu(config["SubmenuName"], funcref(self, "_ExecuteCustomConfigCallback"))
func _ExecuteCustomConfigCallback(idx = null):
	if(idx != null):
		ConfigHasChangedCallback(_customConfigCalled)
	editor.get_node(_customConfigCalled["SubmenuName"]).hide()
	show()

func CreateConfigOption(module, config):
	var root = HBoxContainer.new()
	root.set_name(str(config["Name"]))
	
	if(config["Flags"].has("Custom")):
		var button = Button.new()
		button.connect("pressed", self, "_ExecuteCustomConfig", [config])
		button.set_text(str(config["Name"]))
		button.set_name("Button")
		button.set_custom_minimum_size(Vector2(200,32))
		button.set_h_size_flags(SIZE_EXPAND_FILL)
		root.add_child(button)
		return root
	
	var title = Label.new()
	title.set_name("Title")
	title.set_text(str(config["Name"]))
	root.add_child(title)
	
	var param = null
	var paramSignalName = null
	var paramKey = config["Key"]
	var defaultValue = config["Default"]
	var currentValue = editor.configData.Get(paramKey)
	var paramValueChangeFunction = null
	var type = typeof(defaultValue)
	if(config.has("Options")):
		param = OptionButton.new()
		var options = config["Options"]
		for oKey in options:
			param.add_item(options[oKey])
		var selectedOption = options.keys().find(currentValue)
		if(selectedOption >= 0):
			param.select(selectedOption)
		param.connect("item_selected", self, "FieldChangedCallback", [config])
	elif(type == TYPE_STRING):
		param = LineEdit.new()
		param.set_text(currentValue)
		param.connect("text_changed", self, "FieldChangedCallback", [config])
		paramValueChangeFunction = "set_text"
	elif(type == TYPE_INT):
		param = SpinBox.new()
		param.set_allow_greater(true)
		param.set_allow_lesser(true)
		param.set_value(currentValue)
		param.connect("value_changed", self, "FieldChangedCallback", [config])
		paramValueChangeFunction = "set_value"
	elif(type == TYPE_BOOL):
		param = CheckButton.new()
		param.set_pressed(currentValue)
		param.connect("toggled", self, "FieldChangedCallback", [config])
		paramValueChangeFunction = "set_pressed"
	else:
		param = Label.new()
		param.set_text("Unsupported param type ("+str(type)+")")
		param.set_align(Label.ALIGN_CENTER)
	param.set_custom_minimum_size(Vector2(200,16))
	param.set_h_size_flags(SIZE_EXPAND_FILL)
	param.set_name("Param")
	root.add_child(param)
	
	var resetButton = Button.new()
	resetButton.set_text("Reset")
	resetButton.set_name("Reset")
	resetButton.connect("pressed", self, "ResetFieldValue", [param, config, paramValueChangeFunction])
	root.add_child(resetButton)
	
	return root

func _on_BackButton_pressed():
	hide()
	$"..".EnterMenu()


func _on_Docs_pressed():
	$"..".OpenDocumentation("/modules")


func FitTabs():
	var tabs = $Tabs
	for sc in tabs.get_children():
		var vbox = sc.get_child(0)
		for p in vbox.get_children():
			var pvb = p.get_child(0)
			var panelSizeFull = pvb.get_combined_minimum_size()
			var offset = Vector2(16,16)
			pvb.set_custom_minimum_size(panelSizeFull - offset)
			p.set_custom_minimum_size(panelSizeFull + offset)
			p.set_anchors_preset(Control.PRESET_WIDE, true)
			pvb.set_anchors_preset(Control.PRESET_WIDE, true)
			pvb.set_margin(MARGIN_LEFT,    offset.x/2)
			pvb.set_margin(MARGIN_RIGHT,  -offset.x/2)
			pvb.set_margin(MARGIN_TOP,     offset.y/2)
			pvb.set_margin(MARGIN_BOTTOM, -offset.y/2)
		var tabSizeFull = sc.get_combined_minimum_size()
		vbox.set_custom_minimum_size(tabSizeFull)
		sc.set_custom_minimum_size(tabSizeFull)


func _on_Save_pressed():
	$Save.set_text("Save")
	$Save.set_disabled(true)
	
	for p in paramsToSave:
		editor.configData.Set(p, paramsToSave[p])
	editor.configData.SaveConfigFile()
	
	if(saveReloadPower == SAVERELOAD_RELOAD):
		_on_BackButton_pressed()
		$"..".call_deferred("_on_Config_pressed", showAdvancedParams)
	elif(saveReloadPower == SAVERELOAD_RESTART):
		get_tree().quit()
	
	backLocked = false
	UpdateBackButton()

func ConfigHasChangedCallback(config):
	$Save.set_disabled(false)
	var reload = SAVERELOAD_NONE
	var saveText = "Save"
	if(config["Flags"].has("ReloadFull")):
		reload = SAVERELOAD_RESTART
		saveText += " (Restart)"
	elif(config["Flags"].has("Reload")):
		reload = SAVERELOAD_RELOAD
		saveText += " (Reload)"
	
	$Save.set_text(saveText)
	if(reload > saveReloadPower):
		saveReloadPower = reload
	
	if(config["Flags"].has("LockBack")):
		backLocked = true
	UpdateBackButton()

func UpdateBackButton():
	var backText = "Back without saving"
	if(backLocked):
		backText = "Quit to cancel"
	$BackButton.set_disabled(backLocked)
	$BackButton.set_text(backText)

func FieldChangedCallback(value, config):
	var paramName = config["Key"]
	if(config.has("Options")):
		value = config["Options"].keys()[value]
	ConfigHasChangedCallback(config)
	paramsToSave[paramName] = value

func ResetFieldValue(field, config, functionName = null):
	if(functionName != null):
		var defaultValue = editor.configData.GetBaseOrDefault(config["Name"])
		var f = funcref(field, functionName)
		f.call_func(defaultValue)
		FieldChangedCallback(defaultValue, config)
		
