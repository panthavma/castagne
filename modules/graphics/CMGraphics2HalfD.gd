extends "../CastagneModule.gd"

var POSITION_SCALE = 1.0
# :TODO:Panthavma:20220216:Apply Palette

func ModuleSetup():
	RegisterModule("Graphics 2.5D")
	RegisterCategory("Model")
	RegisterFunction("CreateModel", [1, 2], null, {
		"Description": "Creates a model for the current entity",
		"Arguments":["Model path", "(Optional) Animation player path"]
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
	RegisterVariableEntity("ModelFacing", 1)
	RegisterFlag("ModelLockWorldPosition")
	RegisterFlag("ModelLockRelativePosition")
	RegisterFlag("ModelLockFacing")
	
	RegisterCategory("Sprites")
	RegisterFunction("CreateSprite", [1,2,3,4], null, {
		"Description": "Creates a 3D sprite from a sprite sheet.",
		"Arguments": ["Sprite sheet path", "(Optional) Sprites X", "(Optional) Sprites Y", "(Optional) Pixel Size"],
	})
	RegisterFunction("SpriteOrigin", [2], null, {
		"Description": "Sets a sprite's origin in pixels.",
		"Arguments":["Pos X", "Pos Y"],
	})
	
	RegisterVariableEntity("SpriteFrame", 0)

func BattleInit(state, data, battleInitData):
	var camera = InitCamera(state, data, battleInitData)
	engine.add_child(camera)
	engine.graphicsModule = self
	
	POSITION_SCALE = engine.POSITION_SCALE
	
	data["InstancedData"]["Camera"] = camera
	lastRegisteredCamera = camera
	POSITION_SCALE = engine.POSITION_SCALE

var lastRegisteredCamera = null
var cameraOffset = Vector3(0.0, 2.0, 6.2)
func UpdateGraphics(state, data):
	var camera = data["InstancedData"]["Camera"]
	
	var playerPosCenter = Vector3(state["CameraX"], state["CameraY"], 0) * POSITION_SCALE
	var cameraPos = playerPosCenter + cameraOffset
	camera.set_translation(cameraPos)
	state["GraphicsCamPos"] = cameraPos
	
	for eid in state["ActiveEntities"]:
		var eState = state[eid]
		var playerPos = Vector3(eState["ModelPositionX"], eState["ModelPositionY"], 0.0) * POSITION_SCALE
		var camPosHor = Vector3(cameraPos.x, playerPos.y, cameraPos.z)
		
		var iData = data["InstancedData"]["Entities"][eid]
		
		var modelRoot = iData["Root"]
		if(modelRoot != null):
			modelRoot.set_translation(playerPos)
			modelRoot.set_scale(Vector3(eState["ModelFacing"], 1.0, 1.0))
			#modelRoot.look_at(playerPos - (camPosHor - playerPos), Vector3.UP)
		
		var sprite = iData["Sprite"]
		if(sprite != null):
			sprite.set_frame(eState["SpriteFrame"])
		

func InitPhaseEndEntity(eState, data):
	SetPalette(eState, data, eState["Player"])

func InitCamera(_state, _data, _battleInitData):
	var cam = Camera.new()
	return cam

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
			m.set_surface_material(0, paletteMaterial)






func CreateModel(args, eState, data):
	_EnsureRootIsSet(eState["EID"], data)
	var animPath = (ArgStr(args, eState, 1) if args.size() > 1 else null)
	engine.InstanceModel(eState["EID"], ArgStr(args, eState, 0), animPath)
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


func CreateSprite(args, eState, data):
	var spritesheetPath = ArgStr(args, eState, 0)
	var spritesX = ArgInt(args, eState, 1, 1)
	var spritesY = ArgInt(args, eState, 2, 1)
	var pixelSize = ArgInt(args, eState, 3, 100)/10000.0
	
	var spritesheet = Castagne.Loader.Load(spritesheetPath)
	var sprite = _CreateSprite_Instance(args, eState, data)
	
	sprite.set_texture(spritesheet)
	sprite.set_hframes(spritesX)
	sprite.set_vframes(spritesY)
	sprite.set_pixel_size(pixelSize)
	sprite.set_centered(false)
	
	_EnsureRootIsSet(eState["EID"], data)
	data["InstancedData"]["Entities"][eState["EID"]]["Root"].add_child(sprite)
	data["InstancedData"]["Entities"][eState["EID"]]["Sprite"] = sprite
	
func _CreateSprite_Instance(_args, _eState, _data):
	return Sprite3D.new()

func SpriteOrigin(args, eState, data):
	var originX = ArgInt(args, eState, 0)
	var originY = ArgInt(args, eState, 1)
	var sprite = data["InstancedData"]["Entities"][eState["EID"]]["Sprite"]
	sprite.set_offset(Vector2(-originX, -originY))


func _EnsureRootIsSet(eid, data):
	if(data["InstancedData"]["Entities"][eid]["Root"] == null):
		var root = Spatial.new()
		data["InstancedData"]["Entities"][eid]["Root"] = root
		data["Engine"].add_child(root)


func IngameToWorldPos(ingamePositionX, ingamePositionY, ingamePositionZ = 0):
	return Vector3(ingamePositionX, ingamePositionY, ingamePositionZ) * POSITION_SCALE

func TranslateIngamePosToScreen(ingamePositionX, ingamePositionY, ingamePositionZ = 0):
	if(lastRegisteredCamera != null):
		return lastRegisteredCamera.unproject_position(IngameToWorldPos(ingamePositionX, ingamePositionY, ingamePositionZ))
	return Vector2(0,0)
