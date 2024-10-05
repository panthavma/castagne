# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Holds the config for the Castagne engine, and manages it.
# It also holds the modules and functions for convinience.

extends Node

var _configData = {}
var _customConfigData = {}
var _defaultConfigData = {}
var _configFilePath = null
var _localConfigFilePath = null
var _functions = {}
var _modules = []
var _modulesSlots = {}
var _configSkeleton = null
var _input = null




# --------------------------------------------------------------------------------------------------
# [Base Interface]

func Get(keyName, default=null):
	if(_configData.has(keyName)):
		return _configData[keyName]
	if(_configSkeleton != null):
		return _configSkeleton.Get(keyName, default)
	if(default == null):
		Castagne.Error("Config Get: Key is undefined: " + str(keyName))
	return default

func Set(keyName, value, newValue = false):
	if(newValue or Has(keyName)):
		_configData[keyName] = value
	else:
		Castagne.Error("Config Set: Key doesn't already exist: " + str(keyName))

func Has(keyName, checkBase = true):
	var h = _configData.has(keyName)
	if(!h and checkBase and _configSkeleton != null):
		return _configSkeleton.Has(keyName, checkBase)
	return h

func GetConfigKeys():
	var keys = []
	if(_configSkeleton != null):
		keys = _configSkeleton.GetConfigKeys()
	for k in _configData:
		if not (k in keys):
			keys.push_back(k)
	return keys



# --------------------------------------------------------------------------------------------------
# [Config Skeleton]

func HasBaseOrDefault(keyName):
	if(_configSkeleton != null):
		return _configSkeleton.Has(keyName, true)
	return _defaultConfigData.has(keyName)
func GetBaseOrDefault(keyName):
	if(_configSkeleton != null):
		if(_configSkeleton.Has(keyName)):
			return _configSkeleton.Get(keyName)
	return _defaultConfigData[keyName]

func HasDefault(keyName):
	if(_configSkeleton != null):
		return _configSkeleton.HasDefault(keyName, true)
	return _defaultConfigData.has(keyName)
func GetDefault(keyName):
	if(_configSkeleton != null):
		if(_configSkeleton.HasDefault(keyName)):
			return _configSkeleton.GetDefault(keyName)
	return _defaultConfigData[keyName]

func GetConfigSkeleton():
	return _configSkeleton
func SetConfigSkeleton(configSkeleton):
	_configSkeleton = configSkeleton





# --------------------------------------------------------------------------------------------------
# [Save and Load]

func LoadFromConfigFile(configFilePath):
	_configFilePath = str(configFilePath)
	return _LoadFromConfigFile(configFilePath)

func LoadFromLocalConfigFile(localConfigFilePath):
	_localConfigFilePath = str(localConfigFilePath)
	return _LoadFromConfigFile(localConfigFilePath)

func _LoadFromConfigFile(configFilePath):
	var file = File.new()
	if(!file.file_exists(configFilePath)):
		Castagne.Error("File " + configFilePath + " does not exist.")
		return false
	file.open(configFilePath, File.READ)
	var fileText = file.get_as_text()
	file.close()
	
	_customConfigData = parse_json(fileText)
	Castagne.FuseDataOverwrite(_configData, _customConfigData)
	
	return true

func SaveConfigFile(configFilePath = null, localConfigFilePath = null):
	if(configFilePath == null):
		configFilePath = _configFilePath
	if(localConfigFilePath == null):
		localConfigFilePath = _localConfigFilePath
	
	var file = File.new()
	if(!file.file_exists(configFilePath)):
		Castagne.Error("File " + configFilePath + " does not exist.")
		return ERR_FILE_NOT_FOUND
	
	_defaultConfigData["Modules-core"] = Castagne.CONFIG_CORE_MODULE_PATH
	
	var savedData = {}
	var savedLocalData = {}
	for key in _configData:
		var save = false
		if(!HasBaseOrDefault(key)):
			save = true
		elif(Get(key) != GetBaseOrDefault(key)):
			if(typeof(_configData[key]) == TYPE_DICTIONARY):
				save = !Castagne.AreDictionariesEqual(Get(key), GetBaseOrDefault(key))
			elif(typeof(_configData[key]) == TYPE_ARRAY):
				save = !Castagne.AreArraysEqual(Get(key), GetBaseOrDefault(key))
			else:
				save = true
		
		if(save):
			if(localConfigFilePath != null and key.begins_with("LocalConfig-")):
				savedLocalData[key] = _configData[key]
			else:
				savedData[key] = _configData[key]
	
	var jsonData = to_json(savedData)
	file.open(configFilePath, File.WRITE)
	file.store_string(jsonData)
	file.close()
	
	if(localConfigFilePath != null):
		jsonData = to_json(savedLocalData)
		file.open(localConfigFilePath, File.WRITE)
		file.store_string(jsonData)
		file.close()
	
	return OK





# --------------------------------------------------------------------------------------------------
# [Module Management]

func RegisterModule(module):
	Castagne.FuseDataOverwrite(_functions, module._moduleFunctions)
	if(module.moduleSlot != null):
		if(_modulesSlots.has(module.moduleSlot)):
			Castagne.Error("ConfigData.RegisterModule: slot "+str(module.moduleSlot)+" is already registered!")
		_modulesSlots[module.moduleSlot] = module
	_modules += [module]
	module.OnModuleRegistration(self)

func GetModules():
	return _modules

func GetModuleSpecblocks():
	var specblocks = {}
	for m in GetModules():
		for sbName in m.moduleSpecblocks:
			var sb = m.moduleSpecblocks[sbName]
			specblocks[sbName] = sb
	return specblocks
func GetModuleSpecblocksMainEntity():
	var specblocks = {}
	for m in GetModules():
		for sbName in m.moduleSpecblocks:
			var sb = m.moduleSpecblocks[sbName]
			if(sb.isUsedForMainEntity):
				specblocks[sbName] = sb
	return specblocks
func GetModuleSpecblocksSubEntity():
	var specblocks = {}
	for m in GetModules():
		for sbName in m.moduleSpecblocks:
			var sb = m.moduleSpecblocks[sbName]
			if(sb.isUsedForSubEntity):
				specblocks[sbName] = sb
	return specblocks

func GetModuleSlot(slot):
	if(_modulesSlots.has(slot)):
		return _modulesSlots[slot]
	Castagne.Error("ConfigData.GetModuleSlot: Slot "+str(slot)+" isn't registered!")
	return null





# --------------------------------------------------------------------------------------------------
# [Castagne Functions]

func LoadDefaultValuesFromModule(module):
	Castagne.FuseDataNoOverwrite(_defaultConfigData, module.configDefault.duplicate(true))
	Castagne.FuseDataNoOverwrite(_configData, module.configDefault.duplicate(true))

func GetModuleFunctions():
	return _functions

func GetModuleStateFlags():
	var f = []
	for m in _modules:
		f.append_array(m._moduleStateFlags.keys())
	return f

func GetBaseCaspFilePaths():
	var bcfp = []
	for m in _modules:
		if(m.baseCaspFilePath != null and !m.baseCaspFilePath in bcfp):
			var c = m.baseCaspFilePath.duplicate(true)
			c[2] = bcfp.size()
			bcfp += [c]
	bcfp.sort_custom(self, "_BaseCaspFilePathsSort")
	var paths = []
	for b in bcfp:
		paths.append_array(b[0])
	return paths
func _BaseCaspFilePathsSort(a, b):
	if(a[1] == b[1]):
		return a[2] < b[2]
	return a[1] < b[1]

func GetBaseBattleInitData():
	return GetModuleSlot(Castagne.MODULE_SLOTS_BASE.FLOW).GetBaseBattleInitData(self)

func GetGameCharacterList(includeHiddenCharacters = false):
	var charPaths = Castagne.SplitStringToArray(Get("CharacterPaths"))
	var characters = []
	for path in charPaths:
		var c = Castagne.Parser.GetCharacterInfo(path, self)
		if(c == null):
			continue
		if(!includeHiddenCharacters and c["TransformedData"]["MenuData"]["Defines"]["MENU_Hidden"] == 1):
			continue
		characters.push_back(c)
	return characters

func GetEditorCharacterList(sortByEditorOrder = false):
	var charPaths = Castagne.SplitStringToArray(Get("CharacterPaths"))
	var editorOrders = Get("EditorCharacterOrder")
	var characters = []
	var maxEditorOrder = 0
	for i in range(charPaths.size()):
		var path = charPaths[i]
		var c = GetEditorCharacterData(path)
		if(c == null):
			Castagne.Error("Character path invalid: " + str(path))
			continue
		c["ID"] = characters.size()
		if(editorOrders.size() > i):
			c["EditorOrder"] = editorOrders[i]
			maxEditorOrder = max(maxEditorOrder, editorOrders[i])
		characters.push_back(c)
	for c in characters:
		if(c["EditorOrder"] == null):
			maxEditorOrder += 100
			c["EditorOrder"] = maxEditorOrder
	
	if(sortByEditorOrder):
		characters.sort_custom(self, "_GetEditorCharacterList_SortByEditorOrder")
	
	return characters

func _GetEditorCharacterList_SortByEditorOrder(a, b):
	var key = "EditorOrder"
	if(a[key] == b[key]):
		return a["ID"] < b["ID"]
	return a[key] < b[key]

func GetEditorCharacterData(path):
	var c = {
		"Name": path, "ID": null, "EditorOrder": null, "Path": path,
		"Data":{},
	}
	var data = Castagne.Parser.GetCharacterMetadata(path, self)
	c["Data"] = data
	
	if(data == null):
		return null
	
	if(data.has("Name")):
		c["Name"] = data["Name"]
	if(data.has("EditorName")):
		c["Name"] = data["EditorName"]
	return c

func Input():
	return _input
