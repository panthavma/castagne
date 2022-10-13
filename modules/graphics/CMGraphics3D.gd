extends "CMGraphicsBase.gd"


func ModuleSetup():
	RegisterModule("Graphics 3D")
	.ModuleSetup()


func _UpdateSprite(sprite, eState, data):
	._UpdateSprite(sprite, eState, data)
	var spriteData = _GetCurrentSpriteData(eState, data)
	sprite.set_offset(Vector2(-spriteData["OriginX"], -spriteData["OriginY"]))
	sprite.set_pixel_size(spriteData["PixelSize"])
