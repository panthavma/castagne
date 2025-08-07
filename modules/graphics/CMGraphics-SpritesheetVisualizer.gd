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
	var vPaletteMode = _GetStructValue("PaletteMode", 0)
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
	
	var nbSprites = vSpritesX * vSpritesY
	$Controls/SpriteID.set_max(nbSprites - 1)
	var spriteID = int($Controls/SpriteID.get_value())
	if(spriteID < 0):
		spriteID = 0
	if(spriteID >= nbSprites):
		spriteID = nbSprites - 1
	
	var nShader = nSprite.get_material()
	if($Controls/UsePalette.is_pressed() && vPaletteMode > 0):
		#var paletteID = int($Controls/PaletteID.get_value())
		var palettePath = _specblock._specblockDefines["GRAPHICS_SpritePalette"]["Value"]
		var paletteTexturePacked = Castagne.Loader.Load(palettePath)
		if(paletteTexturePacked == null):
			nShader.set_shader_param("paletteTexture", null)
			vPaletteMode = 0
		else:
			nShader.set_shader_param("paletteTexture", paletteTexturePacked)
	else:
		vPaletteMode = 0
	
	nShader.set_shader_param("spritesheetDimensions", [vSpritesX, vSpritesY])
	nShader.set_shader_param("spriteOrigin", [vOriginX, vOriginY])
	nShader.set_shader_param("spriteIDToShow", spriteID)
	nShader.set_shader_param("paletteMode", vPaletteMode)

func _on_PaletteID_value_changed(_value):
	UpdateDisplay()
func _on_SpriteID_value_changed(_value):
	UpdateDisplay()
func _on_UsePalette_toggled(_button_pressed):
	UpdateDisplay()
