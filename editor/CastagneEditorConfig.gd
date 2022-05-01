extends Control

# :TODO:Panthavma:20220417:Prevent going back if didn't save
# :TODO:Panthavma:20220417:Open documentation on the correct page
# :TODO:Panthavma:20220417:Description tooltip
# :TODO:Panthavma:20220417:Default value tooltip


var showAdvancedParams = false
var paramsToSave = {}
var saveReloadPower = 0
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
	
	var tabs = $Tabs
	
	$Title.set_text("Configuration Editor"+(" - Advanced" if showAdvancedParams else "")+"\n"+Castagne.configData["CastagneVersion"])
	
	for c in tabs.get_children():
		c.queue_free()
	
	var tabID = tabs.get_child_count()
	for module in Castagne.modules:
		var page = CreateStandardPage(module)
		tabs.add_child(page)
		tabs.set_tab_title(tabID, module.moduleName)
		tabID += 1
	
	call_deferred("FitTabs")

func CreateStandardPage(module):
	var pageRoot = ScrollContainer.new()
	var root = VBoxContainer.new()
	pageRoot.add_child(root)
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
				(!showAdvancedParams and config["Flags"].has("Advanced"))):
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
	
	var categoryRoot = VBoxContainer.new()
	panel.add_child(categoryRoot)
	categoryRoot.set_h_size_flags(SIZE_EXPAND_FILL)
	categoryRoot.set_v_size_flags(SIZE_EXPAND_FILL)
	
	var panelTitle = Label.new()
	panelTitle.set_text("--- "+str(title)+" ---")
	panelTitle.set_align(Label.ALIGN_CENTER)
	panelTitle.set_valign(Label.VALIGN_CENTER)
	categoryRoot.add_child(panelTitle)
	
	return panel

func CreateConfigOption(module, config):
	var root = HBoxContainer.new()
	
	var title = Label.new()
	title.set_text(str(config["Name"]))
	root.add_child(title)
	
	var param = null
	var paramSignalName = null
	var paramKey = config["Key"]
	var defaultValue = config["Default"]
	var currentValue = Castagne.configData[paramKey]
	var paramValueChangeFunction = null
	var type = typeof(defaultValue)
	if(type == TYPE_STRING):
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
	root.add_child(param)
	
	var resetButton = Button.new()
	resetButton.set_text("Reset")
	resetButton.connect("pressed", self, "ResetFieldValue", [param, config, paramValueChangeFunction])
	root.add_child(resetButton)
	
	return root

func _on_BackButton_pressed():
	hide()
	$"..".EnterMenu()


func _on_Docs_pressed():
	$"..".OpenDocumentation("/Modules")


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
		Castagne.configData[p] = paramsToSave[p]
	Castagne.SaveConfigFile()
	
	if(saveReloadPower == SAVERELOAD_RELOAD):
		_on_BackButton_pressed()
		$"..".call_deferred("_on_Config_pressed", showAdvancedParams)
	elif(saveReloadPower == SAVERELOAD_RESTART):
		get_tree().quit()

func FieldChangedCallback(value, config):
	var paramName = config["Key"]
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
	paramsToSave[paramName] = value

func ResetFieldValue(field, config, functionName = null):
	if(functionName != null):
		var defaultValue = config["Default"]
		var f = funcref(field, functionName)
		f.call_func(defaultValue)
		FieldChangedCallback(defaultValue, config)
		
