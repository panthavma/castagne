extends "../CastagneModule.gd"

var graphicsRoot = null
var POSITION_SCALE = 1.0
# :TODO:Panthavma:20220216:Apply Palette

func ModuleSetup():
	RegisterModule("Graphics Base", Castagne.MODULE_SLOTS_BASE.GRAPHICS)
	RegisterBaseCaspFile("res://castagne/modules/graphics/Base-Graphics.casp")
	RegisterCategory("Model")
	RegisterFunction("CreateModel", [1, 2], null, {
		"Description": "Creates a model for the current entity",
		"Arguments":["Model path", "(Optional) Animation player path"]
	})
	RegisterFunction("ModelScale", [1], null, {
		"Description": "Changes the model's scale uniformly.",
		"Arguments":["The scale in permil."]
	})
	RegisterFunction("ModelRotation", [1], null, {
		"Description": "Changes the model's rotation on the Z axis.",
		"Arguments":["The rotation in tenth of degrees."]
	})
	
	RegisterFunction("ModelMove", [1,2], null, {
		"Description": "Moves the model depending on facing.",
		"Arguments":["Horizontal Move", "(Optional) Vertical Move"]
	})
	RegisterFunction("ModelMoveAbsolute", [1,2], null, {
		"Description": "Moves the model independant of facing.",
		"Arguments":["Horizontal Move", "(Optional) Vertical Move"]
	})
	RegisterFunction("ModelSwitchFacing", [0], null, {
		"Description": "Changes the model's facing.",
		"Arguments":[]
	})
	
	RegisterVariableEntity("_ModelPositionX", 0)
	RegisterVariableEntity("_ModelPositionY", 0)
	RegisterVariableEntity("_ModelRotation", 0)
	RegisterVariableEntity("_ModelScale", 1000)
	RegisterVariableEntity("_ModelFacing", 1)
	RegisterFlag("ModelLockWorldPosition")
	RegisterFlag("ModelLockRelativePosition")
	RegisterFlag("ModelLockFacing")
	
	RegisterVariableGlobal("_GraphicsCamPos", Vector3()) # TEMP ?
	
	RegisterCategory("Sprites")
	RegisterFunction("Sprite", [1, 2], null, {
		"Description":"Display a previously set sprite frame. Will use the previously set animation if not specified.",
		"Arguments": ["(Optional) Anim/Spritesheet Name", "Frame ID"],
	})
	RegisterFunction("SpriteProgress", [0, 1], null, {
		"Description":"Advance on the spritesheet. Will use the current animation.",
		"Arguments": ["(Optional) Number of frames to advance"],
	})
	RegisterFunction("CreateSprite", [0, 1], ["Init"], {
		"Description": "Creates a sprite. Can either be empty, to use spritesheets, or have a link to a SpriteFrames ressource, depending on the interface you want to have."+
		"\n\nUsing spritesheets will require you to use RegisterSpritesheet later, ideally by overwriting the InitRegisterSpritesheets call in Base.casp. This will allow you to manage spritesheets from the Castagne Editor."+
		"\n\nOn the other end, using SpriteFrames will require you to set up every animation using Godot's editor. Please refer to the module documentation for more details.",
		"Arguments": ["(Optional) Spriteframes path"],
	})
	RegisterFunction("RegisterSpritesheet", [2, 3, 4, 5, 6, 7], ["Init"], {
		"Description": "Registers a new spritesheet to be used later and selects it. If not specified, the optional parameters are inherited from the currently selected spritesheet.",
		"Arguments": ["Spritesheet Name", "Spritesheet Path", "(Optional) Sprites X", "(Optional) Sprites Y", "(Optional) Origin X", "(Optional) Origin Y", "(Optional) Pixel Size"]
	})
	
	RegisterFunction("SpritesheetFrames", [2], ["Init"], {
		"Description": "Sets the number of frames for the currently selected spritesheet.",
		"Arguments":["Sprites X", "Sprites Y"],
	})
	RegisterFunction("SpriteOrigin", [2], ["Init"], {
		"Description": "Sets a sprite's origin in pixels for the currently selected spritesheet.",
		"Arguments":["Pos X", "Pos Y"],
	})
	RegisterFunction("SpritePixelSize", [1], ["Init"], {
		"Description": "Sets the size of a pixel in units for the currently selected spritesheet. 3D graphics only.",
		"Arguments":["PixelSize"],
	})
	RegisterFunction("SpriteOrder", [1, 2], null, {
		"Description": "Sets the draw order for sprites, higher being drawn on top of others.\n"+
		"The final value must be between "+str(VisualServer.CANVAS_ITEM_Z_MIN)+" and "+str(VisualServer.CANVAS_ITEM_Z_MAX)+".\n"+
		"The offset may be used to have more flexibility in its use, for instance by using it to put one character behind another without affecting the local sprite order changes.",
		"Arguments":["Sprite Order", "(Optional) Sprite Order Offset"],
	})
	RegisterFunction("SpriteOrderOffset", [1], null, {
		"Description": "Set the sprite order offset directly. See SpriteOrder for more information.",
		"Arguments":["Sprite Order Offset"],
	})
	
	RegisterVariableEntity("_SpriteFrame", 0)
	RegisterVariableEntity("_SpriteAnim", "Null")
	# TODO Reduce the amount needed as static
	RegisterVariableEntity("_SpriteUseSpritesheets", 0)
	RegisterVariableEntity("_SpriteOrder", 0)
	RegisterVariableEntity("_SpriteOrderOffset", 0)
	RegisterConfig("PositionScale", 0.0001)
	
	RegisterCategory("Camera")
	RegisterConfig("CameraOffsetX", 0)
	RegisterConfig("CameraOffsetY", 20000)
	RegisterConfig("CameraOffsetZ", 62000)
	
	RegisterConfig("CameraPosMinY", -1000000)
	RegisterConfig("CameraPosMaxY",  1000000)

func BattleInit(stateHandle, battleInitData):
	graphicsRoot = _CreateGraphicsRootNode(engine)
	
	var camera = _InitCamera(stateHandle, battleInitData)
	graphicsRoot.add_child(camera)
	engine.graphicsModule = self
	
	POSITION_SCALE = stateHandle.ConfigData().Get("PositionScale")
	
	stateHandle.IDGlobalSet("GraphicsRoot", graphicsRoot)
	stateHandle.IDGlobalSet("Camera", camera)
	lastRegisteredCamera = camera
	
	cameraOffset = Vector3(stateHandle.ConfigData().Get("CameraOffsetX"), stateHandle.ConfigData().Get("CameraOffsetY"), stateHandle.ConfigData().Get("CameraOffsetZ"))
	
	var prefabMap = Castagne.Loader.Load(Castagne.SplitStringToArray(stateHandle.ConfigData().Get("StagePaths"))[battleInitData["map"]])
	var map = prefabMap.instance()
	graphicsRoot.add_child(map)
	stateHandle.IDGlobalSet("map", map)

var lastRegisteredCamera = null
var cameraOffset = Vector3()
func UpdateGraphics(stateHandle):
	var camera = stateHandle.IDGlobalGet("Camera")
	
	var playerPosCenter = Vector3(stateHandle.GlobalGet("_CameraX"), stateHandle.GlobalGet("_CameraY"), 0)
	var cameraPos = playerPosCenter + cameraOffset
	cameraPos.y = clamp(cameraPos.y, stateHandle.ConfigData().Get("CameraPosMinY"), stateHandle.ConfigData().Get("CameraPosMaxY"))
	cameraPos = IngameToWorldPos(cameraPos.x, cameraPos.y, cameraPos.z)
	_UpdateCamera(stateHandle, camera, cameraPos)
	stateHandle.GlobalSet("_GraphicsCamPos", cameraPos)
	
	for eid in stateHandle.GlobalGet("_ActiveEntities"):
		stateHandle.PointToEntity(eid)
		var modelPosition = IngameToWorldPos(stateHandle.EntityGet("_ModelPositionX"), stateHandle.EntityGet("_ModelPositionY"), 0.0)
		var modelRotation = stateHandle.EntityGet("_ModelRotation") * 0.1
		var modelScale = stateHandle.EntityGet("_ModelScale") / 1000.0
		#var camPosHor = Vector3(cameraPos.x, modelPosition.y, cameraPos.z)
		
		var modelRoot = stateHandle.IDEntityGet("Root")
		if(modelRoot != null):
			_ModelApplyTransform(stateHandle, modelRoot, modelPosition, modelRotation, modelScale)
		
		var sprite = stateHandle.IDEntityGet("Sprite")
		if(sprite != null):
			_UpdateSprite(sprite, stateHandle)

func InitPhaseEndEntity(stateHandle):
	SetPalette(stateHandle, stateHandle.GetPlayer())


func PhysicsPhaseStartEntity(stateHandle):
	if(!stateHandle.EntityHasFlag("ModelLockWorldPosition")):
		if(stateHandle.EntityHasFlag("ModelLockRelativePosition")):
			stateHandle.EntityAdd("ModelPositionX", stateHandle.EntityGet("_MovementX"))
			stateHandle.EntityAdd("ModelPositionY", stateHandle.EntityGet("_MovementY"))
		else:
			stateHandle.EntitySet("_ModelPositionX", stateHandle.EntityGet("_PositionX"))
			stateHandle.EntitySet("_ModelPositionY", stateHandle.EntityGet("_PositionY"))
	if(!stateHandle.EntityHasFlag("ModelLockFacing")):
		stateHandle.EntitySet("_ModelFacing", stateHandle.EntityGet("_Facing"))

func SetPalette(stateHandle, paletteID):
	var paletteKey = "Palette"+str(paletteID+1)
	var fighterMetadata = stateHandle.IDGlobalGet("ParsedFighters")[stateHandle.EntityGet("_FighterID")]["Character"]
	if(!fighterMetadata.has(paletteKey)):
		return
	# :TODO:Panthavma:20220217:Do it better, maybe simply charge different models ?
	var palettePath = fighterMetadata[paletteKey]
	var paletteMaterial = Castagne.Loader.Load(palettePath)
	var modelRoot = stateHandle.IDEntityGet("Model")
	if(modelRoot == null):
		return
	var modelSearch = [modelRoot]
	while(!modelSearch.empty()):
		var m = modelSearch.pop_back()
		modelSearch.append_array(m.get_children())
		if(m.has_method("set_surface_material")):
			for i in range(m.get_surface_material_count()):
				m.set_surface_material(i, paletteMaterial)















func CreateModel(args, stateHandle):
	_EnsureRootIsSet(stateHandle)
	var animPath = (ArgStr(args, stateHandle, 1) if args.size() > 1 else null)
	engine.InstanceModel(stateHandle.EntityGet("_EID"), ArgStr(args, stateHandle, 0), animPath) # TODO Needs a new system here I think
func ModelScale(args, stateHandle):
	stateHandle.EntitySet("_ModelScale", ArgInt(args, stateHandle, 0))
func ModelRotation(args, stateHandle):
	stateHandle.EntitySet("_ModelRotation", ArgInt(args, stateHandle, 0))
func ModelMove(args, stateHandle):
	stateHandle.EntityAdd("ModelPositionX", stateHandle.EntityGet("_Facing")*ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("ModelPositionY", ArgInt(args, stateHandle, 1, 0))
func ModelMoveAbsolute(args, stateHandle):
	stateHandle.EntityAdd("ModelPositionX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("ModelPositionY", ArgInt(args, stateHandle, 1, 0))
func ModelSwitchFacing(_args, stateHandle):
	stateHandle.EntitySet("_ModelFacing", stateHandle.EntityGet("_ModelFacing") * -1)


# :TODO:Panthavma:20220417:Make the root separate from the model (and move it back here)
# :TODO:Panthavma:20220417:Make the model move functions move the root instead
# :TODO:Panthavma:20220417:Allow sprite size change
# :TODO:Panthavma:20220417:Change sprite origin


func Sprite(args, stateHandle):
	if(args.size() == 1):
		stateHandle.EntitySet("_SpriteFrame", ArgInt(args, stateHandle, 0))
	else:
		stateHandle.EntitySet("_SpriteAnim", ArgStr(args, stateHandle, 0))
		stateHandle.EntitySet("_SpriteFrame", ArgInt(args, stateHandle, 1))
func SpriteProgress(args, stateHandle):
	stateHandle.EntityAdd("SpriteFrame", ArgInt(args, stateHandle, 0, 1))

func CreateSprite(args, stateHandle):
	var spriteFramesPath = null
	if(args.size() == 1):
		spriteFramesPath = ArgStr(args, stateHandle, 0)
	
	stateHandle.EntitySet("_SpriteUseSpritesheets", (1 if spriteFramesPath == null else 0))
	var sprite = _CreateSprite_Instance(spriteFramesPath)
	
	var spriteData = {
		"Null": _CreateSpriteData()
	}
	
	_EnsureRootIsSet(stateHandle)
	stateHandle.IDEntityGet("Root").add_child(sprite)
	stateHandle.IDEntitySet("Sprite", sprite)
	stateHandle.IDEntitySet("SpriteData", spriteData)

func _CreateSpriteData():
	return {
		"Name":"Null",
		"SpritesheetPath":"null",
		"Spritesheet":null,
		"SpritesX":1, "SpritesY":1,
		"OriginX":1, "OriginY":1,
		"PixelSize":100
	}

func _GetCurrentSpriteData(stateHandle):
	var spriteDataHolder = stateHandle.IDEntityGet("SpriteData")
	var spriteData = null
	var spriteAnim = stateHandle.EntityGet("_SpriteAnim")
	if(!stateHandle.EntityGet("_SpriteUseSpritesheets")):
		spriteAnim = "Null"
	
	if(spriteDataHolder.has(spriteAnim)):
		spriteData = spriteDataHolder[spriteAnim]
	else:
		spriteData = _CreateSpriteData()
	return spriteData

func RegisterSpritesheet(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle).duplicate()
	spriteData["Name"] = ArgStr(args, stateHandle, 0)
	spriteData["SpritesheetPath"] = ArgStr(args, stateHandle, 1)
	spriteData["SpritesX"] = ArgInt(args, stateHandle, 2, spriteData["SpritesX"])
	spriteData["SpritesY"] = ArgInt(args, stateHandle, 3, spriteData["SpritesY"])
	spriteData["OriginX"] = ArgInt(args, stateHandle, 4, spriteData["OriginX"])
	spriteData["OriginY"] = ArgInt(args, stateHandle, 5, spriteData["OriginY"])
	spriteData["PixelSize"] = ArgInt(args, stateHandle, 6, spriteData["PixelSize"])#/10000.0
	spriteData["Spritesheet"] = Castagne.Loader.Load(spriteData["SpritesheetPath"])
	stateHandle.IDEntityGet("SpriteData")[spriteData["Name"]] = spriteData
	stateHandle.EntitySet("_SpriteAnim", spriteData["Name"])
	stateHandle.EntitySet("_SpriteFrame", 0)

func SpritesheetFrames(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle)
	spriteData["SpritesX"] = ArgInt(args, stateHandle, 0)
	spriteData["SpritesY"] = ArgInt(args, stateHandle, 1)

func SpriteOrigin(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle)
	spriteData["OriginX"] = ArgInt(args, stateHandle, 0)
	spriteData["OriginY"] = ArgInt(args, stateHandle, 1)

func SpritePixelSize(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle)
	spriteData["PixelSize"] = ArgInt(args, stateHandle, 0)

func SpriteOrder(args, stateHandle):
	_SpriteOrderSet(stateHandle, ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, stateHandle.EntityGet("_SpriteOrderOffset")))
func SpriteOrderOffset(args, stateHandle):
	_SpriteOrderSet(stateHandle, stateHandle.EntityGet("_SpriteOrder"), ArgInt(args, stateHandle, 0))
func _SpriteOrderSet(stateHandle, order, orderOffset):
	stateHandle.EntitySet("_SpriteOrder", order)
	stateHandle.EntitySet("_SpriteOrderOffset", orderOffset)
	var finalOrder = order + orderOffset
	if(finalOrder < VisualServer.CANVAS_ITEM_Z_MIN or finalOrder > VisualServer.CANVAS_ITEM_Z_MAX):
		ModuleError("Sprite order out of bounds: " + str(finalOrder) + " ("+str(order)+"+"+str(orderOffset)+") is outside of ["+str(VisualServer.CANVAS_ITEM_Z_MIN)+", "+str(VisualServer.CANVAS_ITEM_Z_MAX)+"]!", stateHandle)














func _EnsureRootIsSet(stateHandle):
	if(stateHandle.IDEntityGet("Root") == null):
		var root = _CreateRootNode()
		stateHandle.IDEntitySet("Root", root)
		graphicsRoot.add_child(root)

func _InitCamera(_stateHandle, _battleInitData):
	var cam = Camera.new()
	return cam

func _CreateSprite_Instance(spriteframesPath):
	if(spriteframesPath == null):
		return Sprite3D.new()
	else:
		var s = AnimatedSprite3D.new()
		s.set_sprite_frames(Castagne.Loader.Load(spriteframesPath))
		return s

func _UpdateSprite(sprite, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle)
	if(stateHandle.EntityGet("_SpriteUseSpritesheets")):
		sprite.set_texture(spriteData["Spritesheet"])
		sprite.set_hframes(spriteData["SpritesX"])
		sprite.set_vframes(spriteData["SpritesY"])
	else:
		sprite.set_animation(stateHandle.EntityGet("_SpriteAnim"))
	sprite.set_centered(false)
	sprite.set_frame(stateHandle.EntityGet("_SpriteFrame"))

func _UpdateCamera(_stateHandle, camera, cameraPos):
	camera.set_translation(cameraPos)

func _ModelApplyTransform(stateHandle, modelRoot, modelPosition, modelRotation, modelScale):
	modelRoot.set_translation(modelPosition)
	modelRoot.set_rotation_degrees(Vector3(0, 90.0*stateHandle.EntityGet("_ModelFacing") - 90.0, modelRotation))
	modelRoot.set_scale(Vector3(modelScale, modelScale, stateHandle.EntityGet("_ModelFacing") * modelScale))

func _CreateRootNode():
	return Spatial.new()

func _CreateGraphicsRootNode(engine):
	var gr = _CreateRootNode()
	engine.add_child(gr)
	return gr

func IngameToWorldPos(ingamePositionX, ingamePositionY, ingamePositionZ = 0):
	return Vector3(ingamePositionX, ingamePositionY, ingamePositionZ) * POSITION_SCALE

func TranslateIngamePosToScreen(ingamePositionX, ingamePositionY, ingamePositionZ = 0):
	if(lastRegisteredCamera != null):
		return lastRegisteredCamera.unproject_position(IngameToWorldPos(ingamePositionX, ingamePositionY, ingamePositionZ))
	return Vector2(0,0)
