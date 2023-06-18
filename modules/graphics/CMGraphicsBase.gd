extends "../CastagneModule.gd"

var graphicsRoot = null
var POSITION_SCALE = 1.0
# :TODO:Panthavma:20220216:Apply Palette

func ModuleSetup():
	RegisterModule("Graphics", Castagne.MODULE_SLOTS_BASE.GRAPHICS)
	RegisterBaseCaspFile("res://castagne/modules/graphics/Base-Graphics.casp")
	
	RegisterCategory("Model", {
		"Description":"""Functions relating to models. A model is a .tscn scene, which may come with an AnimationPlayer node.
Model functions affect the whole graphics side, so even sprites are affected here."""
		})
	RegisterFunction("CreateModel", [1, 2], null, {
		"Description": "Creates a model for the current entity. An AnimationPlayer may be set to enable Anim functions.",
		"Arguments":["Model path", "(Optional) Animation player path"],
		"Flags":["Intermediate"],
		"Types":["str", "str"],
	})
	RegisterFunction("ModelScale", [1], null, {
		"Description": "Changes the model's scale uniformly.",
		"Arguments":["The scale in permil."],
		"Flags":["Intermediate"],
		"Types":["int"],
	})
	RegisterFunction("ModelRotation", [1], null, {
		"Description": "Changes the model's rotation on the Z axis.",
		"Arguments":["The rotation in tenth of degrees."],
		"Flags":["Intermediate"],
		"Types":["int"],
	})
	
	RegisterFunction("ModelMove", [1,2], null, {
		"Description": "Moves the model depending on facing. You'll want to activate the ModelLockRelativePosition flag.",
		"Arguments":["Horizontal Move", "(Optional) Vertical Move"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("ModelMoveAbsolute", [1,2], null, {
		"Description": "Moves the model independant of facing. You'll want to activate the ModelLockRelativePosition flag.",
		"Arguments":["Horizontal Move", "(Optional) Vertical Move"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("ModelSwitchFacing", [0], null, {
		"Description": "Changes the model's facing. You'll want to activate the ModelLockFacing flag.",
		"Arguments":[],
		"Flags":["Advanced"],
	})
	
	RegisterVariableEntity("_ModelPositionX", 0)
	RegisterVariableEntity("_ModelPositionY", 0)
	RegisterVariableEntity("_ModelRotation", 0)
	RegisterVariableEntity("_ModelScale", 1000)
	#RegisterVariableEntity("_ModelFacing", 1)
	RegisterFlag("ModelLockWorldPosition")
	RegisterFlag("ModelLockRelativePosition")
	RegisterFlag("ModelLockFacing")
	
	RegisterVariableGlobal("_GraphicsCamPos", Vector3()) # TEMP ?
	
	RegisterCategory("Sprites", {
		"Descriptions":"""Sprite related functions. This is a work in progress."""
	})
	RegisterFunction("Sprite", [1, 2], null, {
		"Description":"Display a previously set sprite frame. Will use the previously set animation if not specified.",
		"Arguments": ["(Optional) Anim/Spritesheet Name", "Frame ID"],
		"Flags":["Basic"],
		"Types":["str", "int"],
	})
	RegisterFunction("SpriteProgress", [0, 1], null, {
		"Description":"Advance on the spritesheet. Will use the current animation.",
		"Arguments": ["(Optional) Number of frames to advance"],
		"Flags":["Intermediate"],
		"Types":["int"],
	})
	RegisterFunction("CreateSprite", [0, 1], ["Init"], {
		"Description": "Creates a sprite. Can either be empty, to use spritesheets, or have a link to a SpriteFrames ressource, depending on the interface you want to have."+
		"\n\nUsing spritesheets will require you to use RegisterSpritesheet later, ideally by overwriting the InitRegisterSpritesheets call in Base.casp. This will allow you to manage spritesheets from the Castagne Editor."+
		"\n\nOn the other end, using SpriteFrames will require you to set up every animation using Godot's editor. Please refer to the module documentation for more details.",
		"Arguments": ["(Optional) Spriteframes path"],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("RegisterSpritesheet", [2, 3, 4, 5, 6, 7], ["Init"], {
		"Description": "Registers a new spritesheet to be used later and selects it. If not specified, the optional parameters are inherited from the currently selected spritesheet.",
		"Arguments": ["Spritesheet Name", "Spritesheet Path", "(Optional) Sprites X", "(Optional) Sprites Y", "(Optional) Origin X", "(Optional) Origin Y", "(Optional) Pixel Size"],
		"Flags":["Intermediate"],
		"Types":["str", "str", "int", "int", "int", "int", "int"],
	})
	
	RegisterFunction("SpritesheetFrames", [2], ["Init"], {
		"Description": "Sets the number of frames for the currently selected spritesheet.",
		"Arguments":["Sprites X", "Sprites Y"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("SpriteOrigin", [2], ["Init"], {
		"Description": "Sets a sprite's origin in pixels for the currently selected spritesheet.",
		"Arguments":["Pos X", "Pos Y"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("SpritePixelSize", [1], ["Init"], {
		"Description": "Sets the size of a pixel in units for the currently selected spritesheet. 3D graphics only.",
		"Arguments":["PixelSize"],
		"Flags":["Advanced"],
		"Types":["int"],
	})
	RegisterFunction("SpriteOrder", [1, 2], null, {
		"Description": "Sets the draw order for sprites, higher being drawn on top of others.\n"+
		"The final value must be between "+str(VisualServer.CANVAS_ITEM_Z_MIN)+" and "+str(VisualServer.CANVAS_ITEM_Z_MAX)+".\n"+
		"The offset may be used to have more flexibility in its use, for instance by using it to put one character behind another without affecting the local sprite order changes.\n"+
		"Still in progress, 2D graphics only for now.",
		"Arguments":["Sprite Order", "(Optional) Sprite Order Offset"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("SpriteOrderOffset", [1], null, {
		"Description": "Set the sprite order offset directly. See SpriteOrder for more information.",
		"Arguments":["Sprite Order Offset"],
		"Flags":["Advanced"],
		"Types":["int"],
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
	RegisterConfig("CameraYBuffer", 30000)
	
	RegisterConfig("CameraPosMinX", -105000)
	RegisterConfig("CameraPosMaxX",  105000)
	RegisterConfig("CameraPosMinY", -1000000)
	RegisterConfig("CameraPosMaxY",  1000000)
	
	
	RegisterCategory("VFX Test")
	
	RegisterFunction("VFXPrepare", [4], null, {
		"Description":"Prepares a VFX to show. Must be created with VFXCreate once preparation is finished.",
		"Arguments":["Model path", "Time Active", "Pos X", "PosY"],
	})
	
	RegisterFunction("VFXPosition", [1, 2])
	RegisterFunction("VFXRotation", [1])
	RegisterFunction("VFXScale", [1])
	
	RegisterFunction("VFXAnimation", [0,1,2])
	
	RegisterFunction("VFXCreate", [0], null, {
		"Description":"Creates the prepared VFX.",
	})
	
	RegisterVariableEntity("_PreparingVFX", {})
	RegisterVariableGlobal("_VFXList", [])

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
	
	stateHandle.IDGlobalSet("VFXState", [])

func FrameStart(stateHandle):
	var vfxList = stateHandle.GlobalGet("_VFXList")
	var newVFXList = []
	for v in vfxList:
		var idData = stateHandle.IDGlobalGet("VFXState")[v["ID"]]
		v["Time"] -= 1
		if(v["Time"] <= 0):
			idData["Model"].queue_free()
		else:
			newVFXList.push_back(v)
	stateHandle.GlobalSet("_VFXList", newVFXList)

var lastRegisteredCamera = null
var cameraOffset = Vector3()
func UpdateGraphics(stateHandle):
	var camera = stateHandle.IDGlobalGet("Camera")
	
	var playerPosCenter = Vector3(stateHandle.GlobalGet("_CameraX"), stateHandle.GlobalGet("_CameraY") - stateHandle.ConfigData().Get("CameraYBuffer"), 0)
	if(playerPosCenter.y < 0):
		playerPosCenter.y = 0.0
	#IngameToGodotPos([stateHandle.GlobalGet("_CameraX"), stateHandle.GlobalGet("_CameraY"), 0])
	#Vector3(stateHandle.GlobalGet("_CameraX"), stateHandle.GlobalGet("_CameraY"), 0)
	var cameraPos = playerPosCenter + cameraOffset
	cameraPos.x = clamp(cameraPos.x, stateHandle.ConfigData().Get("CameraPosMinX"), stateHandle.ConfigData().Get("CameraPosMaxX"))
	cameraPos.y = clamp(cameraPos.y, stateHandle.ConfigData().Get("CameraPosMinY"), stateHandle.ConfigData().Get("CameraPosMaxY"))
	cameraPos = IngameToGodotPos(cameraPos)
	_UpdateCamera(stateHandle, camera, cameraPos)
	stateHandle.GlobalSet("_GraphicsCamPos", cameraPos)
	
	for eid in stateHandle.GlobalGet("_ActiveEntities"):
		stateHandle.PointToEntity(eid)
		var modelPosition = [stateHandle.EntityGet("_ModelPositionX"), stateHandle.EntityGet("_ModelPositionY"), 0]
		var modelRotation = stateHandle.EntityGet("_ModelRotation")
		var modelScale = stateHandle.EntityGet("_ModelScale")
		#var camPosHor = Vector3(cameraPos.x, modelPosition.y, cameraPos.z)
		
		var modelRoot = stateHandle.IDEntityGet("Root")
		if(modelRoot != null):
			_ModelApplyTransform(stateHandle, modelRoot, modelPosition, modelRotation, modelScale)
		
		var sprite = stateHandle.IDEntityGet("Sprite")
		if(sprite != null):
			_UpdateSprite(sprite, stateHandle)

func InitPhaseStartEntity(stateHandle):
	var spriteData = {
		"Null": _CreateSpriteData()
	}
	stateHandle.IDEntitySet("SpriteData", spriteData)

func InitPhaseEndEntity(stateHandle):
	SetPalette(stateHandle, stateHandle.GetPlayer())


func PhysicsPhaseStartEntity(stateHandle):
	if(!stateHandle.EntityHasFlag("ModelLockWorldPosition")):
		if(stateHandle.EntityHasFlag("ModelLockRelativePosition")):
			stateHandle.EntityAdd("_ModelPositionX", stateHandle.EntityGet("_MovementX"))
			stateHandle.EntityAdd("_ModelPositionY", stateHandle.EntityGet("_MovementY"))
		else:
			stateHandle.EntitySet("_ModelPositionX", stateHandle.EntityGet("_PositionX"))
			stateHandle.EntitySet("_ModelPositionY", stateHandle.EntityGet("_PositionY"))
	#if(!stateHandle.EntityHasFlag("ModelLockFacing")):
	#	stateHandle.EntitySet("_ModelFacing", stateHandle.EntityGet("_Facing"))

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
	stateHandle.EntityAdd("_ModelPositionX", stateHandle.EntityGet("_FacingHModel")*ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_ModelPositionY", ArgInt(args, stateHandle, 1, 0))
func ModelMoveAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_ModelPositionX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_ModelPositionY", ArgInt(args, stateHandle, 1, 0))
func ModelSwitchFacing(_args, stateHandle):
	return
	#stateHandle.EntitySet("_ModelFacing", stateHandle.EntityGet("_ModelFacing") * -1)


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
	stateHandle.EntityAdd("_SpriteFrame", ArgInt(args, stateHandle, 0, 1))

func CreateSprite(args, stateHandle):
	var spriteFramesPath = null
	if(args.size() == 1):
		spriteFramesPath = ArgStr(args, stateHandle, 0)
	
	stateHandle.EntitySet("_SpriteUseSpritesheets", (1 if spriteFramesPath == null else 0))
	var sprite = _CreateSprite_Instance(spriteFramesPath)
	
	
	_EnsureRootIsSet(stateHandle)
	stateHandle.IDEntityGet("Root").add_child(sprite)
	stateHandle.IDEntitySet("Sprite", sprite)

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
	spriteData["PixelSize"] = ArgInt(args, stateHandle, 6, spriteData["PixelSize"])/10000.0
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



func VFXPrepare(args, stateHandle):
	var vfxName = ArgStr(args, stateHandle, 0)
	var time = ArgInt(args, stateHandle, 1)
	var posX = ArgInt(args, stateHandle, 2)
	var posY = ArgInt(args, stateHandle, 3)
	
	var pos = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityToWorld([posX, posY], stateHandle)
	var facing = stateHandle.EntityGet("_FacingHPhysics")
	
	var data = {
		"Path":vfxName, "Time":time,
		"PosX": pos[0], "PosY": pos[1],
		"Facing": facing,
		"Scale": 1000, "Rotation": 0,
		"AnimationPlayer": null, "Animation":"default"
	}
	
	stateHandle.EntitySet("_PreparingVFX", data)

func VFXPosition(args, stateHandle):
	stateHandle.EntityGet("_PreparingVFX")["PosX"] = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_PreparingVFX")["PosY"] = ArgInt(args, stateHandle, 1)
func VFXRotation(args, stateHandle):
	var rotation = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_PreparingVFX")["Rotation"] = rotation
func VFXScale(args, stateHandle):
	var scale = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_PreparingVFX")["Scale"] = scale
func VFXAnimation(args, stateHandle):
	var animName = ArgStr(args, stateHandle, 0, "default")
	var animPlayer = ArgStr(args, stateHandle, 1, "AnimationPlayer")
	stateHandle.EntityGet("_PreparingVFX")["Animation"] = animName
	stateHandle.EntityGet("_PreparingVFX")["AnimationPlayer"] = animPlayer
	
func VFXCreate(args, stateHandle):
	var data = stateHandle.EntityGet("_PreparingVFX")
	var modelPS = Castagne.Loader.Load(data["Path"])
	var model = modelPS.instance()
	
	
	#model.set_translation(IngameToGodotPos([data["PosX"], data["PosY"], 0]))
	_ModelApplyTransformDirect(model, [data["PosX"], data["PosY"], 0], data["Rotation"], data["Scale"], data["Facing"])
	
	stateHandle.Engine().add_child(model)
	if(data["AnimationPlayer"] != null):
		var animPlayer = model.get_node(data["AnimationPlayer"])
		animPlayer.play(data["Animation"])
	
	data["ID"] = stateHandle.IDGlobalGet("VFXState").size()
	var idData = {"Model": model}
	
	stateHandle.IDGlobalAdd("VFXState", [idData])
	stateHandle.GlobalAdd("_VFXList", [data])
	























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
	var facingH = stateHandle.EntityGet("_FacingHModel")
	_ModelApplyTransformDirect(modelRoot, modelPosition, modelRotation, modelScale, facingH)

func _ModelApplyTransformDirect(modelRoot, modelPosition, modelRotation, modelScale, facingH):
	modelPosition = IngameToGodotPos(modelPosition)
	modelRotation *= 0.1
	modelScale /= 1000.0
	
	modelRoot.set_translation(modelPosition)
	modelRoot.set_rotation_degrees(Vector3(0, 90.0*facingH - 90.0, modelRotation))
	modelRoot.set_scale(Vector3(modelScale, modelScale, facingH * modelScale))

func _CreateRootNode():
	return Spatial.new()

func _CreateGraphicsRootNode(engine):
	var gr = _CreateRootNode()
	engine.add_child(gr)
	return gr

func IngameToGodotPos(ingamePosition):
	return Vector3(ingamePosition[0], ingamePosition[1], ingamePosition[2]) * POSITION_SCALE

func TranslateIngamePosToScreen(ingamePosition):
	if(lastRegisteredCamera != null):
		return lastRegisteredCamera.unproject_position(IngameToGodotPos(ingamePosition))
	return Vector2(0,0)
