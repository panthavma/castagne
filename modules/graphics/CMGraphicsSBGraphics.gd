# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Graphics Settings")
	SetForMainEntitySubEntity(true, true)
	
	AddDefine("GRAPHICS_Scale", 1000, "Scale")
	
	AddCategory("Models")
	AddDefine("GRAPHICS_UseModel", true)
	AddDefine("GRAPHICS_ModelPath", "res://castagne/assets/fighters/castagneur/CastagneurModel.tscn")
	AddDefine("GRAPHICS_ModelPath_AnimPlayer", "AnimationPlayer")
	
	
	AddCategory("Sprites")
	AddDefine("GRAPHICS_UseSprites", false)
	
	AddStructure("Spritesheets", "GRAPHICS_SPRITESHEET_")
	AddStructureDefine("Path", "res://")
	AddStructureDefine("SpritesX", 1, "Sprites X")
	AddStructureDefine("SpritesY", 1, "Sprites Y")
	AddStructureDefine("OriginX", 0, "Origin X")
	AddStructureDefine("OriginY", 0, "Origin Y")
	AddStructureDefine("PixelSize", 100, "Pixel Size")
	AddStructureDefine("PaletteMode", 0, "Palette Mode")
	
	AddStructure("SpriteAnimations", "GRAPHICS_SPRITE_ANIMATIONS_", "Animations")
	#AddStructureDefine("Path", "res://")
	# Frame, Sprite, 
	for i in range(10):
		AddStructureDefine(str(i+1)+"_Duration", 0)
		AddStructureDefine(str(i+1)+"_Spritesheet", "")
		AddStructureDefine(str(i+1)+"_Frame", 0)
	
	AddStructure("SpritePalettes", "GRAPHICS_SPRITE_PALETTE_", "Palettes")
	AddStructureDefine("Path", "res://castagne/assets/helpers/palette/PaletteManual01.png")

