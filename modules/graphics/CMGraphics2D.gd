# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "CMGraphicsBase.gd"

var prefabVPC = preload("res://castagne/modules/graphics/Graphics2DRoot.tscn")
var pixelArtMode = false
var viewport
var viewportContainer

func ModuleSetup():
	RegisterModule("Graphics 2D", Castagne.MODULE_SLOTS_BASE.GRAPHICS)
	.ModuleSetup()
	
	RegisterCategory("2D Specific")
	RegisterConfig("2DScreenSizeX", 1920)
	RegisterConfig("2DScreenSizeY", 1080)
	RegisterConfig("2DFixedScreenSize", true)
	RegisterConfig("UnitsInScreen", 192000)
	
	RegisterConfig("PixelArtMode", true)

func BattleInit(stateHandle, battleInitData):
	.BattleInit(stateHandle, battleInitData)
	# Pixels per unit
	POSITION_SCALE = float(stateHandle.ConfigData().Get("2DScreenSizeX")) / stateHandle.ConfigData().Get("UnitsInScreen")
	pixelArtMode = stateHandle.ConfigData().Get("PixelArtMode")
	
	



func CreateModel(args, stateHandle):
	ModuleError("CreateModel is not supported for 2D", stateHandle)
	.CreateModel(args, stateHandle)










func _InitCamera(_stateHandle, _battleInitData):
	var cam = Camera2D.new()
	cam.make_current()
	return cam

func _CreateSprite_Instance():
	var s2D = Sprite.new()
	s2D.set_script(Castagne.Loader.Load("res://castagne/modules/graphics/CMGraphics_Sprite.gd"))
	s2D.is2D = true
	s2D.graphicsModule = self
	return s2D

func _UpdateCamera(_stateHandle, camera, cameraPos):
	# TODO Camera size isn't really consistent, needs design
	if(pixelArtMode):
		cameraPos = cameraPos.round()
	
	camera.set_position(cameraPos)

func _ModelApplyTransformDirect(modelRoot, modelPosition, modelRotation, modelScale, facingH):
	modelPosition = IngameToGodotPos(modelPosition)
	modelRotation *= 0.1
	modelScale /= 1000.0
	
	if(pixelArtMode):
		modelPosition = modelPosition.round()
	
	if(!modelRoot.has_method("set_position")):
		ModuleError("Graphics2D: Trying to set the position of a 3D asset!")
		return
	
	modelRoot.set_position(modelPosition)
	modelRoot.set_rotation_degrees(modelRotation)
	modelRoot.set_scale(Vector2(facingH * modelScale, modelScale))

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
	vp.set_size(Vector2(engine.configData.Get("2DScreenSizeX"), engine.configData.Get("2DScreenSizeY")))
	vpc.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	vp.set_usage(Viewport.USAGE_2D)
	vp.set_update_mode(Viewport.UPDATE_ALWAYS)
	vp.set_handle_input_locally(false)
	
	if(pixelArtMode):
		vp.set_usage(Viewport.USAGE_2D_NO_SAMPLING)
		#vp.get_texture().flags ^= Texture.FLAG_FILTER
	
	vpc.get_material().set_shader_param("gameViewport", vp.get_texture())
	
	return vp

func IngameToGodotPos(ingamePosition):
	return Vector2(ingamePosition[0], -ingamePosition[1]) * POSITION_SCALE

func TranslateIngamePosToScreen(ingamePosition):
	if(lastRegisteredCamera != null):
		var pos = IngameToGodotPos(ingamePosition) - lastRegisteredCamera.get_position()
		# Apply the transform manually by finding where we are in the camera, and then put it in the viewport
		var screenPos = viewportContainer.get_global_position() + (pos / viewport.get_size() + Vector2(0.5, 0.5))* viewportContainer.get_size()
		return screenPos
	return Vector2(0,0)
