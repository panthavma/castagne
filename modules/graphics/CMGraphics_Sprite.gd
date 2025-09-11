extends Node
# Sprite or Sprite3D
var sprite
var graphicsModule
var is2D
var paletteTexture = null
var spriteMaterial

var PALETTEMODE_NONE = 0
var PALETTEMODE_MANUAL = 1

func Initialize(stateHandle, _sprite):
	sprite = _sprite
	ApplyMaterial(stateHandle)
	_CreateSpriteAnims(stateHandle)

func UpdateSprite(stateHandle):
	var animName = stateHandle.EntityGet("_Anim")
	var animFrame = stateHandle.EntityGet("_AnimFrame")
	var a = HandleAnimation(animName, animFrame)
	if(a != null):
		stateHandle.EntitySet("_SpriteAnim", a[1])
		stateHandle.EntitySet("_SpriteFrame", a[2])
	
	var spriteData = graphicsModule._GetCurrentSpriteData(stateHandle)
	var displayData = {
		"SpriteFrame": stateHandle.EntityGet("_SpriteFrame"),
		"ZOrder": stateHandle.EntityGet("_ModelZOrder"),
	}
	
	UpdateSpriteFromData(spriteData, displayData)

func UpdateSpriteVFX(vfxData):
	var spriteFrame = 0
	var spritesheetName = null
	
	if(vfxData["Spritesheet"] == null):
		# Sprite Animation
		var animName = vfxData["Animation"]
		var animFrame = vfxData["TimeAlive"]
		var a = HandleAnimation(animName, animFrame)
		if(a != null):
			spritesheetName = a[1]
			spriteFrame = a[2]
	else:
		# Regular sprite set
		spritesheetName = vfxData["Spritesheet"]
		spriteFrame = vfxData["SpriteFrame"]
		
	if(spritesheetName == null or !(spritesheetName in vfxData["SpritesheetDataHolder"])):
		return
	var spritesheetData = vfxData["SpritesheetDataHolder"][spritesheetName]
	
	var displayData = {
		"SpriteFrame": spriteFrame,
		"ZOrder": vfxData["ZOrder"],
	}
	
	UpdateSpriteFromData(spritesheetData, displayData)

func UpdateSpriteFromData(spriteData, displayData):
	sprite.set_texture(spriteData["Spritesheet"])
	sprite.set_hframes(spriteData["SpritesX"])
	sprite.set_vframes(spriteData["SpritesY"])
	sprite.set_centered(false)
	sprite.set_frame(displayData["SpriteFrame"])
	spriteMaterial.set_shader_param("paletteMode", spriteData["PaletteMode"])
	
	if(is2D):
		sprite.set_z_index(displayData["ZOrder"])
		
		var spriteSizeY = 0
		var texture = spriteData["Spritesheet"]
		if(texture != null):
			spriteSizeY = texture.get_size().y / spriteData["SpritesY"]
		sprite.set_offset(Vector2(-spriteData["OriginX"], spriteData["OriginY"] - spriteSizeY))
	else:
		sprite.set_translation(Vector3.FORWARD*displayData["ZOrder"]*-0.0005)
		spriteMaterial.set_shader_param("spritesheet", spriteData["Spritesheet"])
		sprite.set_offset(Vector2(-spriteData["OriginX"], -spriteData["OriginY"]))
		sprite.set_pixel_size(spriteData["PixelSize"]/1000)
		#sprite.set_material_override(spriteMaterial)

var animations
func _CreateSpriteAnims(stateHandle):
	animations = {}
	var spriteIData = stateHandle.IDEntityGet("TD_Anims")
	var spriteAnims = spriteIData["SpriteAnimations"]
	for animName in spriteAnims:
		var animUserData = spriteAnims[animName]
		var i = 0
		var curFrameID = 0
		var curSheet = ""
		var animData = []
		
		while(animUserData.has(str(i+1)+"_Duration")):
			i += 1
			
			var newDuration = animUserData[str(i)+"_Duration"]
			var newSheet = animUserData[str(i)+"_Spritesheet"]
			var newSpriteID = animUserData[str(i)+"_Frame"]
			
			if(i == 1):
				newDuration += 1
			
			if(newDuration == 0):
				continue
			if(newSheet == null or newSheet.empty()):
				newSheet = curSheet
			curSheet = newSheet
			
			var a = [curFrameID, newSheet, newSpriteID]
			animData.push_back(a)
			
			curFrameID += newDuration
			
		animations[animName] = animData

var spriteShaderRessourceDefault = preload("res://castagne/modules/graphics/CastagneSpriteShader.gdshader")
var spriteShader3DRessourceDefault = preload("res://castagne/modules/graphics/CastagneSpriteShader3D.gdshader")
func ApplyMaterial(stateHandle, spriteShader = null):
	var paletteTexturePath = stateHandle.EntityGet("_SpritePalettePath")
	paletteTexture = Castagne.Loader.Load(paletteTexturePath)
	spriteMaterial = ShaderMaterial.new()
	if(spriteShader == null):
		spriteShader = (spriteShaderRessourceDefault if is2D else spriteShader3DRessourceDefault)
		var shaderPath = stateHandle.ConfigData().Get("SpriteShaderPath")
		if(!shaderPath.empty()):
			var shaderCustom = Castagne.Loader.Load(shaderPath)
			if(shaderCustom != null):
				spriteShader = shaderCustom
	spriteMaterial.set_shader(spriteShader)
	if(!is2D):
		var spriteData = graphicsModule._GetCurrentSpriteData(stateHandle)
		spriteMaterial.set_shader_param("spritesheet", spriteData["Spritesheet"])
	spriteMaterial.set_shader_param("paletteTexture", paletteTexture)
	if(is2D):
		sprite.set_material(spriteMaterial)
	else:
		sprite.set_material_override(spriteMaterial)

func HandleAnimation(animName, animFrame):
	#var animName = stateHandle.EntityGet("_Anim")
	if(animName != null):
		if(animName in animations):
			#var animFrame = stateHandle.EntityGet("_AnimFrame")
			var animData = animations[animName]
			var a = animData[0]
			for i in range(1, animData.size()):
				if(animFrame < animData[i][0]):
					break
				a = animData[i]
			#stateHandle.EntitySet("_SpriteAnim", a[1])
			#stateHandle.EntitySet("_SpriteFrame", a[2])
			return a
		else:
			graphicsModule.ModuleError("Sprite Animation "+str(animName)+" doesn't exist!")
	return null
