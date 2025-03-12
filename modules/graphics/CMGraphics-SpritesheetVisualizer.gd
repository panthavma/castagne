# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

var _specblock
var _variablePrefix

func InitDisplay(specblock, variablePrefix):
	_specblock = specblock
	_variablePrefix = variablePrefix
	
	UpdateDisplay()

func _GetStructValue(valueName, defaultValue, isIntValue = true):
	if(_specblock._extraValues.has(_variablePrefix+valueName)):
		var varValue = _specblock._extraValues[_variablePrefix+valueName]["Value"]
		if(isIntValue):
			if(str(varValue).is_valid_integer()):
				return int(varValue)
			else:
				return defaultValue
		return varValue
	return defaultValue

func UpdateDisplay():
	# var varFullName = prefix+varName
	var vPath = _GetStructValue("Path", "", false)
	var vSpritesX = _GetStructValue("SpritesX", 1)
	var vSpritesY = _GetStructValue("SpritesY", 1)
	var vOriginX = _GetStructValue("OriginX", 0)
	var vOriginY = _GetStructValue("OriginY", 1)
	var nSprite = $AspectRatio/Sprite
	
	var vTexturePacked = Castagne.Loader.Load(vPath)
	if(vTexturePacked == null):
		nSprite.set_texture(null)
	else:
		nSprite.set_texture(vTexturePacked)
	
	if(vSpritesX < 1):
		vSpritesX = 1
	if(vSpritesY < 1):
		vSpritesY = 1
	var nShader = nSprite.get_material()
	nShader.set_shader_param("spritesheetDimensions", [vSpritesX, vSpritesY])
	nShader.set_shader_param("spriteOrigin", [vOriginX, vOriginY])
		
	
	# set_shader_param("")	
