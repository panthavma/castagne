extends "CMGraphicsBase.gd"


func ModuleSetup():
	RegisterModule("Graphics 3D", Castagne.MODULE_SLOTS_BASE.GRAPHICS)
	.ModuleSetup()


func _UpdateSprite(sprite, stateHandle):
	._UpdateSprite(sprite, stateHandle)
	var spriteData = _GetCurrentSpriteData(stateHandle)
	sprite.set_offset(Vector2(-spriteData["OriginX"], -spriteData["OriginY"]))
	sprite.set_pixel_size(spriteData["PixelSize"]/1000)
