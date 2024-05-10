# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

# --- Callbacks

signal DefineValueChanged;

func SetupSpecblock(_argument):
	pass

func OnDisplay():
	for structType in _StructList_ListNodes:
		StructList_UpdateList(structType)
	if(_interfaceMain_StructEditor != null):
		StructEditorShow()

func TransformDefinedData(_defines):
	if(_structureDefinitions.empty()):
		return null
	
	var td = {}
	for sN in _structureDefinitions:
		var prefix = _structureDefinitions[sN]["Prefix"]
		var structInstances = {}
		
		for n in _defines:
			if(n.begins_with(prefix)):
				var instanceName = n.right(len(prefix))
				var sep = instanceName.find(_struct_namevar_separator)
				var varName = null
				var v = _defines[n]["Value"]
				if(sep >= 0):
					varName = instanceName.right(sep+len(_struct_namevar_separator))
					instanceName = instanceName.left(sep)
				if(!instanceName in structInstances):
					structInstances[instanceName] = {"InstanceName": instanceName}
					for defaultVar in _structureDefinitions[sN]["Variables"]:
						structInstances[instanceName][defaultVar["Name"]] = defaultVar["Default"]
				structInstances[instanceName][varName] = v
		
		td[sN] = structInstances
	
	return td

# --- External Interface


func GetDefinedValues():
	var defs = {}
	for dName in _specblockDefines:
		defs[dName] = _specblockDefines[dName]["Value"]
	for dName in _extraValues:
		defs[dName] = _extraValues[dName]["Value"]
	return defs

# --- Sandbox

var isUsedForMainEntity = true
var isUsedForSubEntity = true

var _specblockDefines = {}
var _extraValues = {} # Values present in the specblock but not defined. Stored and managed in order to prevent versioning issues
var _alteredValues = [] # List of names to save, reset on code load
var _customInterfaceCode = null
var _customInterfaceMain = null
var _displayName = null
var _specblockName = null
var _currentCategory = null
var _definesPerCategory = {null:[]}
var _categories = {}
var _focusedCategory = null
var _structureDefinitions = {}

func SetForMainEntitySubEntity(mainEntity = true, subEntity = true):
	isUsedForMainEntity = mainEntity
	isUsedForSubEntity = subEntity

func AddDefine(dName, dValue, displayName = null, data = {}):
	if(displayName == null):
		displayName = dName
	
	# Find category tree
	var catList = []
	if(_currentCategory != null):
		catList = _currentCategory.split("/")
	
	# Put inside category
	var catRoot = _definesPerCategory
	var catPartialName = ""
	for c in catList:
		if(!catPartialName.empty()):
			catPartialName += "/"
		catPartialName += c
		if not (catPartialName in catRoot):
			catRoot[catPartialName] = {null:[]}
		catRoot = catRoot[catPartialName]
	
	catRoot[null] += [dName]
	
	var defineType = Castagne.VARIABLE_TYPE.Str
	if(typeof(dValue) == TYPE_INT):
		defineType = Castagne.VARIABLE_TYPE.Int
	elif(typeof(dValue) == TYPE_BOOL):
		defineType = Castagne.VARIABLE_TYPE.Bool
	
	_specblockDefines[dName] = {
		"Name": dName, "Value": dValue,
		"Default": dValue, "DisplayName": displayName,
		"LowerLevelDefault": dValue,
		"Order":_specblockDefines.size(),
		"Category":_currentCategory,
		"Field": null, "OverwriteButton": null,
		"Type": defineType,
	}

func AddCategory(cName, openByDefault = true):
	_currentCategory = cName
	if !(cName in _categories):
		var splits = cName.split("/")
		var displayName = splits[splits.size()-1]
		_categories[cName] = {"Name": cName, "DisplayName":displayName, "Open":openByDefault}

var _lastDefinedStructName
func AddStructure(structName, prefix, displayName = null):
	_lastDefinedStructName = structName
	if(displayName == null):
		displayName = structName
	_structureDefinitions[structName] = {
		"Name": structName,
		"Prefix": prefix,
		"DisplayName": displayName,
		"Variables": [],
	}

func AddStructureDefine(dName, dValue, displayName = null, data = {}):
	if(displayName == null):
		displayName = dName
	
	_structureDefinitions[_lastDefinedStructName]["Variables"] += [{
		"Name": dName,
		"Default": dValue,
		"Type": Castagne.VariableTypeToCastagneType(typeof(dValue)),
		"DisplayName": displayName,
	}]

func SetDisplayName(n):
	_displayName = n

# --- Interface

var module
var interfaceCode
var interfaceMain
var characterEditor

func GetDisplayName():
	if(_displayName == null):
		return _specblockName
	return _displayName

func InitDefineValues(defineValuesList):
	_extraValues = {}
	

func CreateInterfaceCode():
	return _InterfaceCode_CreateDefault()

func _InterfaceCode_CreateDefault():
	var root = VBoxContainer.new()
	root.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var title = Label.new()
	title.set_text("--- " + GetDisplayName() + " ---")
	title.set_align(Label.ALIGN_CENTER)
	root.add_child(title)
	
	_InterfaceCode_CreateCategory(_definesPerCategory, root)
	
	for sN in _structureDefinitions:
		var sD = _structureDefinitions[sN]
		_InterfaceCode_CreateStructList(sD, root)
	
	return root

func _InterfaceCode_CreateCategory(category, root, categoryName = null):
	var fieldsRoot = root
	if(categoryName != null):
		var spacer = Control.new()
		spacer.set_custom_minimum_size(Vector2(16,16))
		root.add_child(spacer)
		var categoryTitle = HBoxContainer.new()
		
		var categoryOpenButton = Button.new()
		categoryTitle.add_child(categoryOpenButton)
		_categories[categoryName]["OpenButton"] = categoryOpenButton
		categoryOpenButton.connect("pressed", self, "_InterfaceCode_SetCategoryVisible", [categoryName])
		
		var labelCategoryName = Label.new()
		labelCategoryName.set_text(categoryName)
		categoryTitle.add_child(labelCategoryName)
		
		
		var fieldsPanel = HBoxContainer.new()
		fieldsPanel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		var fieldsSpacer = VSeparator.new()
		fieldsSpacer.set_custom_minimum_size(Vector2(16,16))
		
		fieldsRoot = VBoxContainer.new()
		fieldsRoot.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		fieldsPanel.add_child(fieldsSpacer)
		fieldsPanel.add_child(fieldsRoot)
		_categories[categoryName]["FieldsPanel"] = fieldsPanel
		
		root.add_child(categoryTitle)
		root.add_child(fieldsPanel)
		_InterfaceCode_SetCategoryVisible(categoryName, _categories[categoryName]["Open"])
	
	for dName in category[null]:
		var d = _specblockDefines[dName]
		fieldsRoot.add_child(_InterfaceCode_CreateField(d))
	
	# Child categories
	for cName in category:
		if(cName == null):
			continue
		_InterfaceCode_CreateCategory(category[cName], fieldsRoot, cName)

func _InterfaceCode_SetCategoryVisible(categoryName, visible = null):
	if(visible == null):
		visible = !_categories[categoryName]["Open"]
	var button = _categories[categoryName]["OpenButton"]
	var fields = _categories[categoryName]["FieldsPanel"]
	button.set_text("-" if visible else "+")
	fields.set_visible(visible)
	_categories[categoryName]["Open"] = visible

func _InterfaceCode_CreateFieldValue(defineName, defineType, defineValue):
	var callbackName = "_FieldChangeCallback"
	var fieldValue
	if(defineType == Castagne.VARIABLE_TYPE.Int):
		fieldValue = SpinBox.new()
		fieldValue.set_allow_greater(true)
		fieldValue.set_allow_lesser(true)
		fieldValue.set_value(defineValue)
		fieldValue.connect("value_changed", self, callbackName, [defineName])
	elif(defineType == Castagne.VARIABLE_TYPE.Str):
		fieldValue = LineEdit.new()
		fieldValue.set_text(str(defineValue))
		fieldValue.connect("text_changed", self, callbackName, [defineName])
	elif(defineType == Castagne.VARIABLE_TYPE.Bool):
		fieldValue = CheckBox.new()
		fieldValue.set_pressed_no_signal(defineValue)
		fieldValue.connect("toggled", self, callbackName, [defineName])
	else:
		fieldValue = Label.new()
		fieldValue.set_text("Define type not supported: " + str(defineType))
	fieldValue.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	return fieldValue

func _InterfaceCode_CreateField(define):
	var root = HBoxContainer.new()
	var dName = Label.new()
	dName.set_text(define["DisplayName"])
	dName.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	dName.set_stretch_ratio(0.5)
	root.add_child(dName)
	
	var fieldValue = _InterfaceCode_CreateFieldValue(define["Name"], define["Type"], define["Value"])
	define["Field"] = fieldValue
	root.add_child(fieldValue)
	
	var overwriteButton = Button.new()
	overwriteButton.set_text("OW")
	overwriteButton.set_disabled(true)
	overwriteButton.set_tooltip("Overwritten variable. Press to remove the value.")
	overwriteButton.connect("pressed", self, "_FieldRemoveOverwrite", [define["Name"]])
	define["OverwriteButton"] = overwriteButton
	root.add_child(overwriteButton)
	
	return root


func CreateInterfaceMain():
	if(len(_structureDefinitions) == 0):
		return null
	
	var root = _CreateInterfaceMain_CreateStructEditor()
	return root

var _interfaceMain_StructEditor = null
func _CreateInterfaceMain_CreateStructEditor():
	#_interfaceMain_StructEditor = ScrollContainer.new()
	_interfaceMain_StructEditor = Control.new()
	#_interfaceMain_StructEditor.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	_interfaceMain_StructEditor.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	_interfaceMain_StructEditor.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	return _interfaceMain_StructEditor

func _CreateInterfaceMain_CreateSingleStructEdit(sd, root):
	var title = Label.new()
	title.set_text(sd["DisplayName"])
	
	root.add_child(title)

func _GizmosCallback(editorModule, _args, _lineActive, stateHandle):
	Gizmos(editorModule, stateHandle)
func Gizmos(_editorModule, _stateHandle):
	pass

# --- System


func GetDefaultDefines():
	var defs = {}
	for dName in _specblockDefines:
		var defaultValue = _specblockDefines[dName]["Default"]
		if(_specblockDefines[dName]["Type"] == Castagne.VARIABLE_TYPE.Bool):
			defaultValue = (1 if defaultValue else 0)
		defs[dName] = defaultValue
	return defs

var _skipFieldChangeCallback = false # needed for spinbox lol
func _FieldChangeCallback(defineValue, defineName):
	if(_skipFieldChangeCallback):
		return
	_SetDefineValue(defineName, defineValue)
	_UpdateCurrentStateCode()

func _UpdateCurrentStateCode():
	var newCode = ConvertValuesToCode()
	characterEditor.SetCurrentStateCode(newCode)
	# Temporary workaround: update the code values
	characterEditor.character[characterEditor.curFile]["States"][characterEditor.curState]["Variables"] = _GetDefinedValuesToSave()

func _FieldRemoveOverwrite(defineName):
	_SetDefineValue(defineName, _specblockDefines[defineName]["Default"], false)
	_alteredValues.erase(defineName)
	_specblockDefines[defineName]["OverwriteButton"].set_disabled(true)
	_UpdateCurrentStateCode()

func _SetDefineValue(defineName, defineValue, markAsAltered = true):
	if(_specblockDefines.has(defineName)):
		var d = _specblockDefines[defineName]
		d["Value"] = defineValue
		var field = d["Field"]
		var dType = d["Type"]
		if(dType == Castagne.VARIABLE_TYPE.Int):
			_skipFieldChangeCallback = true
			field.set_value(defineValue)
			_skipFieldChangeCallback = false
		elif(dType == Castagne.VARIABLE_TYPE.Str):
			field.set_text(defineValue)
		elif(dType == Castagne.VARIABLE_TYPE.Bool):
			field.set_pressed_no_signal(defineValue)
		if(markAsAltered and !(defineName in _alteredValues)):
			_alteredValues += [defineName]
			d["OverwriteButton"].set_disabled(false)
	else:
		if(!_extraValues.has(defineName)):
			_extraValues[defineName] = {"Name":defineName}
		if(typeof(defineValue) == TYPE_REAL):
			defineValue = int(defineValue)
		_extraValues[defineName]["Value"] = defineValue
		_extraValues[defineName]["Type"] = Castagne.VariableTypeToCastagneType(typeof(defineValue))
		#if(markAsAltered and !(defineName in _alteredValues)):
		#	_alteredValues += [defineName]
	emit_signal("DefineValueChanged", defineName, defineValue)

func _GetDefinedValuesToSave():
	var defines = {}
	for alteredDefineName in _alteredValues:
		defines[alteredDefineName] = _specblockDefines[alteredDefineName]
	for evName in _extraValues:
		defines[evName] = _extraValues[evName]
	return defines

func ConvertValuesToCode():
	var code = ""
	var defines = _GetDefinedValuesToSave().values()
	
	for define in defines:
		var l = "def " + define["Name"] + " "
		var defineType = define["Type"]
		var value = define["Value"]
		if(defineType == Castagne.VARIABLE_TYPE.Int):
			l += "int()"
		elif(defineType == Castagne.VARIABLE_TYPE.Str):
			l += "str()"
		elif(defineType == Castagne.VARIABLE_TYPE.Bool):
			l += "bool()"
			value = (1 if value else 0)
		else:
			Castagne.Error("Specblock ConvertValuesToCode: can't convert type " + str(defineType))
			continue
		l += " = " + str(value)
		code += l + "\n"
	return code

func _ResetAltered():
	_alteredValues = []
	for d in _specblockDefines.values():
		d["OverwriteButton"].set_disabled(true)

func ConvertCodeVariablesToValues(variables, parentBlock = false):
	_extraValues = {}
	_ResetAltered()
	for v in variables.values():
		var isKnownVariable = v["Name"] in _specblockDefines
		var value = v["Value"]
		if(v["Type"] == Castagne.VARIABLE_TYPE.Bool):
			value = int(value) > 0
		_SetDefineValue(v["Name"], value, !parentBlock)
		if(!isKnownVariable):
			_extraValues[v["Name"]]["Type"] = v["Type"]




# --- Structs

const _struct_namevar_separator = "___"

func GetStructInstancesAndVariablesStored(structType):
	var prefix = _structureDefinitions[structType]["Prefix"]
	var structInstances = {}
	
	for n in _extraValues:
		if(n.begins_with(prefix)):
			var instanceName = n.right(len(prefix))
			var sep = instanceName.find(_struct_namevar_separator)
			var varName = null
			var v = _extraValues[n]
			if(sep >= 0):
				varName = instanceName.right(sep+len(_struct_namevar_separator))
				instanceName = instanceName.left(sep)
			if(!instanceName in structInstances):
				structInstances[instanceName] = {"InstanceName": instanceName}
			structInstances[instanceName][varName] = v
	
	return structInstances


var _StructList_ListNodes = {}
func _InterfaceCode_CreateStructList(sd, root):
	var header = HBoxContainer.new()
	var headerHide = Button.new()
	headerHide.set_text("+")
	headerHide.set_toggle_mode(true)
	headerHide.set_pressed_no_signal(true)
	headerHide.connect("toggled", self, "StructList_ToggleVisibility", [sd["Name"]])
	header.add_child(headerHide)
	
	var headerName = Label.new()
	headerName.set_text(sd["DisplayName"])
	headerName.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	header.add_child(headerName)
	
	var headerNew = Button.new()
	headerNew.set_text("New")
	headerNew.connect("pressed", self, "StructList_NewStruct", [sd["Name"]])
	header.add_child(headerNew)
	root.add_child(header)
	
	var list = VBoxContainer.new()
	_StructList_ListNodes[sd["Name"]] = list
	
	root.add_child(list)

func StructList_UpdateList(structType):
	var list = _StructList_ListNodes[structType]
	for c in list.get_children():
		c.queue_free()
	
	var structInstances = GetStructInstancesAndVariablesStored(structType)
	
	for siN in structInstances:
		var sinButton = Button.new()
		sinButton.set_text(siN)
		sinButton.connect("pressed", self, "StructEditorShow", [structType, structInstances[siN]])
		list.add_child(sinButton)

func StructList_ToggleVisibility(toggled, structType):
	var list = _StructList_ListNodes[structType]
	list.set_visible(toggled)

func StructList_NewStruct(structType):
	var existingNames = GetStructInstancesAndVariablesStored(structType).keys()
	var sD = _structureDefinitions[structType]
	
	var newStructName_base = "New_" + sD["Name"]
	var newStructName_i = 0
	var newStructName = newStructName_base
	while newStructName in existingNames:
		newStructName_i += 1
		newStructName = newStructName_base + "_"+str(newStructName_i)
	
	_SetDefineValue(sD["Prefix"]+newStructName, 0)
	
	StructList_UpdateList(structType)
	StructEditorShow(structType, {"InstanceName": newStructName})
	_UpdateCurrentStateCode()


func StructEditorShow(structType = null, structInstance = null):
	for c in _interfaceMain_StructEditor.get_children():
		c.queue_free()
	
	var root = VBoxContainer.new()
	root.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	root.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	root.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	_interfaceMain_StructEditor.add_child(root)
	var title = Label.new()
	title.set_align(Label.ALIGN_CENTER)
	title.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	root.add_child(title)
	
	if(structType == null or structInstance == null):
		title.set_text("Please select an instance to edit.")
		return
	
	var sD = _structureDefinitions[structType]
	title.set_text("-- "+sD["DisplayName"]+" --")
	
	var renameLabel = Label.new()
	renameLabel.set_text("Instance Name")
	
	var renameBox = LineEdit.new()
	renameBox.set_text(structInstance["InstanceName"])
	renameBox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var renameButton = Button.new()
	renameButton.set_text("Rename")
	renameButton.connect("pressed", self, "StructEditor_Rename", [structType, structInstance["InstanceName"], renameBox])
	
	var renameDelete = Button.new()
	renameDelete.set_text("Delete")
	renameDelete.connect("pressed", self, "StructEditor_Delete", [structType, structInstance["InstanceName"]])
	
	var renameHBox = HBoxContainer.new()
	renameHBox.add_child(renameLabel)
	renameHBox.add_child(renameBox)
	renameHBox.add_child(renameButton)
	renameHBox.add_child(renameDelete)
	root.add_child(renameHBox)
	root.add_child(HSeparator.new())
	
	var prefix = sD["Prefix"] + structInstance["InstanceName"] + _struct_namevar_separator
	for v in sD["Variables"]:
		var varName = v["Name"]
		var varFullName = prefix+varName
		var varValue = v["Default"]
		var varType = v["Type"]
		if(_extraValues.has(varFullName)):
			varValue = _extraValues[varFullName]["Value"]
		else:
			_SetDefineValue(varFullName, varValue)
		
		var varLabel = Label.new()
		varLabel.set_text(varName)
		varLabel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		var varField = _InterfaceCode_CreateFieldValue(varFullName, varType, varValue)
		varField.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		varField.set_stretch_ratio(2.0)
		
		var varRoot = HBoxContainer.new()
		varRoot.add_child(varLabel)
		varRoot.add_child(varField)
		root.add_child(varRoot)

func StructEditor_Rename(structType, structInstance, renameBox):
	var newStructName = renameBox.get_text()
	if(newStructName.empty()):
		return
	var instances = GetStructInstancesAndVariablesStored(structType)
	var existingNames = instances.keys()
	if(newStructName in existingNames):
		return
	
	var prefix = _structureDefinitions[structType]["Prefix"]
	var prefixPlusName = prefix+structInstance
	var _evkeys = _extraValues.keys()
	for n in _evkeys:
		if(n.begins_with(prefixPlusName)):
			var v = _extraValues[n]
			var rightPart = n.right(len(prefixPlusName))
			_extraValues.erase(n)
			#_extraValues[prefix+newStructName+rightPart] = v
			_SetDefineValue(prefix+newStructName+rightPart, v["Value"])
	
	_UpdateCurrentStateCode()
	StructList_UpdateList(structType)
	StructEditorShow(structType, GetStructInstancesAndVariablesStored(structType)[newStructName])

func StructEditor_Delete(structType, structInstance):
	var prefix = _structureDefinitions[structType]["Prefix"]
	var prefixPlusName = prefix+structInstance
	var _evkeys = _extraValues.keys()
	for n in _evkeys:
		if(n.begins_with(prefixPlusName)):
			_extraValues.erase(n)
	_UpdateCurrentStateCode()
	StructList_UpdateList(structType)
	StructEditorShow()
