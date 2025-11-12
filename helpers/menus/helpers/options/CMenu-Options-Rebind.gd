# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../../CastagneMenuCore.gd"

var rebindingDevice
var castagneInput
var _rememberMenuData

func InitMenu(menuData, menuParams):
	if menuData == null:
		menuData = _rememberMenuData
	else:
		_rememberMenuData = menuData
	
	for c in $RebindMenu.get_children():
		c.queue_free()
	.InitMenu(menuData, menuParams)

func Setup(menuData, menuParams):
	_tmpInputCooldown = 0.4
	var options = []
	
	# :TODO: Ajouter chaque option de rebind, avec bouton. Scène custom
	# :TODO: Gérer quel menu est actif avec _active dans CMenu-Options
	# :TODO: Ajouter un bouton pour retourner en arrière manuellement
	# :TODO: Rajouter player config dans config data (peut être schlag), et la charger dans le Castagne Starter (full schlag). Pas oublier l'editor override
	
	castagneInput = _configData.Input()
	var layout = _configData.Get("InputLayout")
	var layoutMenu = _configData.Get("InputLayoutMenu")
	#var schema = castagneInput.CreateInputSchemaFromInputLayout(_configData.Get("InputLayout"))
	
	# CEInputConfig.gd
	rebindingDevice = castagneInput.GetDevice(menuParams)
	var actionNamePrefix = rebindingDevice["DeviceActionPrefix"]
	
	for physicalInput in layout:
		if physicalInput.has("Bindable") and !physicalInput["Bindable"]:
			continue
		var bindableInputs = _configData.Input().PhysicalInputGetBindableGameInputNames(physicalInput)
		
		for bi in bindableInputs:
			var actionName = actionNamePrefix + bi
			options.push_back({
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":"res://castagne/helpers/menus/helpers/options/CME-RebindAction.tscn",
				"GameInput":bi, "GodotAction":actionName,
				"Action":"StartRebind", "ActionParams":null,
			})
	for physicalInput in layoutMenu:
		if physicalInput.has("Bindable") and !physicalInput["Bindable"]:
			continue
		var bindableInputs = _configData.Input().PhysicalInputGetBindableGameInputNames(physicalInput)
		
		for bi in bindableInputs:
			var actionName = actionNamePrefix + bi
			options.push_back({
				"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":"res://castagne/helpers/menus/helpers/options/CME-RebindAction.tscn",
				"GameInput":bi, "GodotAction":actionName,
				"Action":"StartRebind", "ActionParams":null,
			})
	
	options.push_back({
		"Type":Castagne.MENUS_ELEMENT_TYPES.ACTION, "ScenePath":null, "DisplayName":"Return",
		"Action":"RMReturn", "ActionParams":null,
	})
	
	menuData["Options"] = options
	
	var titleLabel = Label.new()
	titleLabel.set_text("Rebinding "+str(menuParams))
	$RebindMenu.add_child(titleLabel)
	.Setup(menuData, menuParams)

var _tmpInputCooldown = 0.0
func _process(delta):
	if _tmpInputCooldown > 0:
		_tmpInputCooldown -= delta

func MCB_RMReturn(_args):
	if _tmpInputCooldown > 0:
		return
	_active = false
	get_node(".").hide()
	$"../Menu".show()
	$".."._active = true
