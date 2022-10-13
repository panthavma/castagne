extends "CMGraphicsBase.gd"

var prefabVPC = preload("res://castagne/modules/graphics/Graphics2DRoot.tscn")
var pixelArtMode = false
var viewport
var viewportContainer

func ModuleSetup():
	RegisterModule("Graphics 2D")
	.ModuleSetup()
	
	RegisterConfig("2DScreenSizeX", 1920)
	RegisterConfig("2DScreenSizeY", 1080)
	RegisterConfig("2DFixedScreenSize", true)
	RegisterConfig("UnitsInScreen", 192000)
	
	RegisterConfig("PixelArtMode", true)

func BattleInit(state, data, battleInitData):
	.BattleInit(state, data, battleInitData)
	# Pixels per unit
	POSITION_SCALE = float(Castagne.configData["2DScreenSizeX"]) / Castagne.configData["UnitsInScreen"]
	pixelArtMode = Castagne.configData["PixelArtMode"]
	
	



func CreateModel(args, eState, data):
	ModuleError("CreateModel is not supported for 2D", eState)
	.CreateModel(args, eState, data)



func _UpdateSprite(sprite, eState, data):
	._UpdateSprite(sprite, eState, data)
	var spriteOrder = eState["SpriteOrder"] + eState["SpriteOrderOffset"]
	sprite.set_z_index(spriteOrder)
	
	var spriteData = _GetCurrentSpriteData(eState, data)
	var spriteSizeY = 0
	if(eState["SpriteUseSpritesheets"]):
		var texture = sprite.get_texture()
		if(texture != null):
			spriteSizeY = texture.get_size().y / sprite.get_vframes()
	else:
		var spriteFrames = sprite.get_sprite_frames()
		if(spriteFrames != null):
			var curFrame = spriteFrames.get_frame(eState["SpriteAnim"], eState["SpriteFrame"])
			if(curFrame != null):
				spriteSizeY = curFrame.get_size().y
	sprite.set_offset(Vector2(-spriteData["OriginX"], spriteData["OriginY"] - spriteSizeY))








func _InitCamera(_state, _data, _battleInitData):
	var cam = Camera2D.new()
	#cam.set_zoom(Vector2(0.5, 0.5))
	cam.make_current()
	return cam

func _CreateSprite_Instance(spriteframesPath):
	if(spriteframesPath == null):
		return Sprite.new()
	else:
		var s = AnimatedSprite.new()
		s.set_sprite_frames(Castagne.Loader.Load(spriteframesPath))
		return s


func _UpdateCamera(state, data, camera, cameraPos):
	# TODO Camera size isn't really consistent, needs design
	if(pixelArtMode):
		cameraPos = cameraPos.round()
	
	camera.set_position(cameraPos)

func _ModelApplyTransform(_state, eState, _data, modelRoot, modelPosition, modelRotation, modelScale):
	if(pixelArtMode):
		modelPosition = modelPosition.round()
	
	modelRoot.set_position(modelPosition)
	modelRoot.set_rotation_degrees(modelRotation)
	modelRoot.set_scale(Vector2(eState["ModelFacing"] * modelScale, modelScale))

func _CreateRootNode():
	return Node2D.new()

func _CreateGraphicsRootNode(engine):
	var mainRoot = Control.new()
	engine.add_child(mainRoot)
	var vpc = prefabVPC.instance()
	mainRoot.add_child(vpc)
	var vp = Viewport.new()
	vpc.add_child(vp)
	
	viewportContainer = vpc
	viewport = vp
	
	mainRoot.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	vp.set_size(Vector2(Castagne.configData["2DScreenSizeX"], Castagne.configData["2DScreenSizeY"]))
	vpc.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	vp.set_usage(Viewport.USAGE_2D)
	vp.set_update_mode(Viewport.UPDATE_ALWAYS)
	vp.set_handle_input_locally(false)
	
	if(pixelArtMode):
		vp.set_usage(Viewport.USAGE_2D_NO_SAMPLING)
		#vp.get_texture().flags ^= Texture.FLAG_FILTER
	
	vpc.get_material().set_shader_param("gameViewport", vp.get_texture())
	
	return vp

func IngameToWorldPos(ingamePositionX, ingamePositionY, _ingamePositionZ = 0):
	return Vector2(ingamePositionX, -ingamePositionY) * POSITION_SCALE

func TranslateIngamePosToScreen(ingamePositionX, ingamePositionY, _ingamePositionZ = 0):
	if(lastRegisteredCamera != null):
		var pos = IngameToWorldPos(ingamePositionX, ingamePositionY) - lastRegisteredCamera.get_position()
		# Apply the transform manually by finding where we are in the camera, and then put it in the viewport
		var screenPos = viewportContainer.get_global_position() + (pos / viewport.get_size() + Vector2(0.5, 0.5))* viewportContainer.get_size()
		return screenPos
	return Vector2(0,0)
