extends "../CastagneModule.gd"

var graphicsRoot = null
var POSITION_SCALE = 1.0
# :TODO:Panthavma:20220216:Apply Palette

func ModuleSetup():
	RegisterModule("Graphics Base")
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
	
	RegisterVariableEntity("ModelPositionX", 0)
	RegisterVariableEntity("ModelPositionY", 0)
	RegisterVariableEntity("ModelRotation", 0)
	RegisterVariableEntity("ModelScale", 1000)
	RegisterVariableEntity("ModelFacing", 1)
	RegisterFlag("ModelLockWorldPosition")
	RegisterFlag("ModelLockRelativePosition")
	RegisterFlag("ModelLockFacing")
	
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
	
	RegisterVariableEntity("SpriteFrame", 0)
	RegisterVariableEntity("SpriteAnim", "Null")
	# TODO Reduce the amount needed as static
	RegisterVariableEntity("SpriteUseSpritesheets", 0)
	RegisterVariableEntity("SpriteOrder", 0)
	RegisterVariableEntity("SpriteOrderOffset", 0)
	RegisterConfig("PositionScale", 0.0001)
	
	RegisterCategory("Camera")
	RegisterConfig("CameraOffsetX", 0)
	RegisterConfig("CameraOffsetY", 20000)
	RegisterConfig("CameraOffsetZ", 62000)
	
	RegisterConfig("CameraPosMinY", -1000000)
	RegisterConfig("CameraPosMaxY",  1000000)

func BattleInit(state, data, battleInitData):
	graphicsRoot = _CreateGraphicsRootNode(engine)
	
	var camera = _InitCamera(state, data, battleInitData)
	graphicsRoot.add_child(camera)
	engine.graphicsModule = self
	
	POSITION_SCALE = Castagne.configData["PositionScale"]
	
	data["InstancedData"]["GraphicsRoot"] = graphicsRoot
	data["InstancedData"]["Camera"] = camera
	lastRegisteredCamera = camera
	
	cameraOffset = Vector3(Castagne.configData["CameraOffsetX"], Castagne.configData["CameraOffsetY"], Castagne.configData["CameraOffsetZ"])
	
	var prefabMap = engine.Load(Castagne.SplitStringToArray(Castagne.configData["StagePaths"])[battleInitData["map"]])
	var map = prefabMap.instance()
	graphicsRoot.add_child(map)
	engine.instancedData["map"] = map

var lastRegisteredCamera = null
var cameraOffset = Vector3()
func UpdateGraphics(state, data):
	var camera = data["InstancedData"]["Camera"]
	
	var playerPosCenter = Vector3(state["CameraX"], state["CameraY"], 0)
	var cameraPos = playerPosCenter + cameraOffset
	cameraPos.y = clamp(cameraPos.y, Castagne.configData["CameraPosMinY"], Castagne.configData["CameraPosMaxY"])
	cameraPos = IngameToWorldPos(cameraPos.x, cameraPos.y, cameraPos.z)
	_UpdateCamera(state, data, camera, cameraPos)
	state["GraphicsCamPos"] = cameraPos
	
	for eid in state["ActiveEntities"]:
		var eState = state[eid]
		var modelPosition = IngameToWorldPos(eState["ModelPositionX"], eState["ModelPositionY"], 0.0)
		var modelRotation = eState["ModelRotation"] * 0.1
		var modelScale = eState["ModelScale"] / 1000.0
		#var camPosHor = Vector3(cameraPos.x, modelPosition.y, cameraPos.z)
		
		var iData = data["InstancedData"]["Entities"][eid]
		
		var modelRoot = iData["Root"]
		if(modelRoot != null):
			_ModelApplyTransform(state, eState, data, modelRoot, modelPosition, modelRotation, modelScale)
		
		var sprite = iData["Sprite"]
		if(sprite != null):
			_UpdateSprite(sprite, eState, data)

func InitPhaseEndEntity(eState, data):
	SetPalette(eState, data, eState["Player"])


func PhysicsPhaseStartEntity(eState, _data):
	if(!HasFlag(eState, "ModelLockWorldPosition")):
		if(HasFlag(eState, "ModelLockRelativePosition")):
			eState["ModelPositionX"] += eState["MovementX"]
			eState["ModelPositionY"] += eState["MovementY"]
		else:
			eState["ModelPositionX"] = eState["PositionX"]
			eState["ModelPositionY"] = eState["PositionY"]
	if(!HasFlag(eState, "ModelLockFacing")):
		eState["ModelFacing"] = eState["Facing"]

func SetPalette(eState, data, paletteID):
	var paletteKey = "Palette"+str(paletteID+1)
	var fighterMetadata = data["InstancedData"]["ParsedFighters"][eState["FighterID"]]["Character"]
	if(!fighterMetadata.has(paletteKey)):
		return
	# :TODO:Panthavma:20220217:Do it better, maybe simply charge different models ?
	var palettePath = fighterMetadata[paletteKey]
	var paletteMaterial = Castagne.Loader.Load(palettePath)
	var modelRoot = data["InstancedData"]["Entities"][eState["EID"]]["Model"]
	if(modelRoot == null):
		return
	var modelSearch = [modelRoot]
	while(!modelSearch.empty()):
		var m = modelSearch.pop_back()
		modelSearch.append_array(m.get_children())
		if(m.has_method("set_surface_material")):
			for i in range(m.get_surface_material_count()):
				m.set_surface_material(i, paletteMaterial)















func CreateModel(args, eState, data):
	_EnsureRootIsSet(eState["EID"], data)
	var animPath = (ArgStr(args, eState, 1) if args.size() > 1 else null)
	engine.InstanceModel(eState["EID"], ArgStr(args, eState, 0), animPath)
func ModelScale(args, eState, _data):
	eState["ModelScale"] = ArgInt(args, eState, 0)
func ModelRotation(args, eState, _data):
	eState["ModelRotation"] = ArgInt(args, eState, 0)
func ModelMove(args, eState, _data):
	eState["ModelPositionX"] += eState["Facing"]*ArgInt(args, eState, 0)
	eState["ModelPositionY"] += ArgInt(args, eState, 1, 0)
func ModelMoveAbsolute(args, eState, _data):
	eState["ModelPositionX"] += ArgInt(args, eState, 0)
	eState["ModelPositionY"] += ArgInt(args, eState, 1, 0)
func ModelSwitchFacing(args, eState, _data):
	eState["ModelFacing"] *= -1


# :TODO:Panthavma:20220417:Make the root separate from the model (and move it back here)
# :TODO:Panthavma:20220417:Make the model move functions move the root instead
# :TODO:Panthavma:20220417:Allow sprite size change
# :TODO:Panthavma:20220417:Change sprite origin


func Sprite(args, eState, _data):
	if(args.size() == 1):
		eState["SpriteFrame"] = ArgInt(args, eState, 0)
	else:
		eState["SpriteAnim"] = ArgStr(args, eState, 0)
		eState["SpriteFrame"] = ArgInt(args, eState, 1)
func SpriteProgress(args, eState, _data):
	eState["SpriteFrame"] += ArgInt(args, eState, 0, 1)

func CreateSprite(args, eState, data):
	var spriteFramesPath = null
	if(args.size() == 1):
		spriteFramesPath = ArgStr(args, eState, 0)
	
	eState["SpriteUseSpritesheets"] = (1 if spriteFramesPath == null else 0)
	var sprite = _CreateSprite_Instance(spriteFramesPath)
	
	var spriteData = {
		"Null": _CreateSpriteData()
	}
	
	_EnsureRootIsSet(eState["EID"], data)
	data["InstancedData"]["Entities"][eState["EID"]]["Root"].add_child(sprite)
	data["InstancedData"]["Entities"][eState["EID"]]["Sprite"] = sprite
	data["InstancedData"]["Entities"][eState["EID"]]["SpriteData"] = spriteData

func _CreateSpriteData():
	return {
		"Name":"Null",
		"SpritesheetPath":"null",
		"Spritesheet":null,
		"SpritesX":1, "SpritesY":1,
		"OriginX":1, "OriginY":1,
		"PixelSize":100
	}

func _GetCurrentSpriteData(eState, data):
	var spriteDataHolder = data["InstancedData"]["Entities"][eState["EID"]]["SpriteData"]
	var spriteData = null
	var spriteAnim = eState["SpriteAnim"]
	if(!eState["SpriteUseSpritesheets"]):
		spriteAnim = "Null"
	
	if(spriteDataHolder.has(spriteAnim)):
		spriteData = spriteDataHolder[spriteAnim]
	else:
		spriteData = _CreateSpriteData()
	return spriteData

func RegisterSpritesheet(args, eState, data):
	var spriteData = _GetCurrentSpriteData(eState, data).duplicate()
	spriteData["Name"] = ArgStr(args, eState, 0)
	spriteData["SpritesheetPath"] = ArgStr(args, eState, 1)
	spriteData["SpritesX"] = ArgInt(args, eState, 2, spriteData["SpritesX"])
	spriteData["SpritesY"] = ArgInt(args, eState, 3, spriteData["SpritesY"])
	spriteData["OriginX"] = ArgInt(args, eState, 4, spriteData["OriginX"])
	spriteData["OriginY"] = ArgInt(args, eState, 5, spriteData["OriginY"])
	spriteData["PixelSize"] = ArgInt(args, eState, 6, spriteData["PixelSize"])#/10000.0
	spriteData["Spritesheet"] = Castagne.Loader.Load(spriteData["SpritesheetPath"])
	data["InstancedData"]["Entities"][eState["EID"]]["SpriteData"][spriteData["Name"]] = spriteData
	eState["SpriteAnim"] = spriteData["Name"]
	eState["SpriteFrame"] = 0

func SpritesheetFrames(args, eState, data):
	var spriteData = _GetCurrentSpriteData(eState, data)
	spriteData["SpritesX"] = ArgInt(args, eState, 0)
	spriteData["SpritesY"] = ArgInt(args, eState, 1)

func SpriteOrigin(args, eState, data):
	var spriteData = _GetCurrentSpriteData(eState, data)
	spriteData["OriginX"] = ArgInt(args, eState, 0)
	spriteData["OriginY"] = ArgInt(args, eState, 1)

func SpritePixelSize(args, eState, data):
	var spriteData = _GetCurrentSpriteData(eState, data)
	spriteData["PixelSize"] = ArgInt(args, eState, 0)

func SpriteOrder(args, eState, _data):
	_SpriteOrderSet(eState, ArgInt(args, eState, 0), ArgInt(args, eState, 1, eState["SpriteOrderOffset"]))
func SpriteOrderOffset(args, eState, _data):
	_SpriteOrderSet(eState, eState["SpriteOrder"], ArgInt(args, eState, 0))
func _SpriteOrderSet(eState, order, orderOffset):
	eState["SpriteOrder"] = order
	eState["SpriteOrderOffset"] = orderOffset
	var finalOrder = order + orderOffset
	if(finalOrder < VisualServer.CANVAS_ITEM_Z_MIN or finalOrder > VisualServer.CANVAS_ITEM_Z_MAX):
		ModuleError("Sprite order out of bounds: " + str(finalOrder) + " ("+str(order)+"+"+str(orderOffset)+") is outside of ["+str(VisualServer.CANVAS_ITEM_Z_MIN)+", "+str(VisualServer.CANVAS_ITEM_Z_MAX)+"]!", eState)














func _EnsureRootIsSet(eid, data):
	if(data["InstancedData"]["Entities"][eid]["Root"] == null):
		var root = _CreateRootNode()
		data["InstancedData"]["Entities"][eid]["Root"] = root
		graphicsRoot.add_child(root)

func _InitCamera(_state, _data, _battleInitData):
	var cam = Camera.new()
	return cam

func _CreateSprite_Instance(spriteframesPath):
	if(spriteframesPath == null):
		return Sprite3D.new()
	else:
		var s = AnimatedSprite3D.new()
		s.set_sprite_frames(Castagne.Loader.Load(spriteframesPath))
		return s

func _UpdateSprite(sprite, eState, data):
	var spriteData = _GetCurrentSpriteData(eState, data)
	if(eState["SpriteUseSpritesheets"]):
		sprite.set_texture(spriteData["Spritesheet"])
		sprite.set_hframes(spriteData["SpritesX"])
		sprite.set_vframes(spriteData["SpritesY"])
	else:
		sprite.set_animation(eState["SpriteAnim"])
	sprite.set_centered(false)
	sprite.set_frame(eState["SpriteFrame"])

func _UpdateCamera(state, data, camera, cameraPos):
	camera.set_translation(cameraPos)

func _ModelApplyTransform(_state, eState, _data, modelRoot, modelPosition, modelRotation, modelScale):
	modelRoot.set_translation(modelPosition)
	modelRoot.set_rotation_degrees(Vector3(0, 90.0*eState["ModelFacing"] - 90.0, modelRotation))
	modelRoot.set_scale(Vector3(modelScale, modelScale, eState["ModelFacing"] * modelScale))

func _CreateRootNode():
	return Spatial.new()

func _CreateGraphicsRootNode(engine):
	var graphicsRoot = _CreateRootNode()
	engine.add_child(graphicsRoot)
	return graphicsRoot

func IngameToWorldPos(ingamePositionX, ingamePositionY, ingamePositionZ = 0):
	return Vector3(ingamePositionX, ingamePositionY, ingamePositionZ) * POSITION_SCALE

func TranslateIngamePosToScreen(ingamePositionX, ingamePositionY, ingamePositionZ = 0):
	if(lastRegisteredCamera != null):
		return lastRegisteredCamera.unproject_position(IngameToWorldPos(ingamePositionX, ingamePositionY, ingamePositionZ))
	return Vector2(0,0)
