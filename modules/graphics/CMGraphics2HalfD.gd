extends "../CastagneModule.gd"

var POSITION_SCALE = 1.0

# :TODO:Panthavma:20220216:Apply Palette

func ModuleSetup():
	RegisterModule("Graphics 2.5D")

func BattleInit(state, data, battleInitData):
	var camera = InitCamera(state, data, battleInitData)
	engine.add_child(camera)
	
	POSITION_SCALE = engine.POSITION_SCALE
	
	data["InstancedData"]["Camera"] = camera
	POSITION_SCALE = engine.POSITION_SCALE

func UpdateGraphics(state, data):
	var camera = data["InstancedData"]["Camera"]
	
	var playerPosCenter = Vector3(state["CameraHor"], state["CameraVer"], 0) * POSITION_SCALE
	var cameraPos = playerPosCenter + Vector3(0.0, 2.0, 3.7) + Vector3(0,0,1.5)
	camera.set_translation(cameraPos)
	state["GraphicsCamPos"] = cameraPos
	
	for eid in state["ActiveEntities"]:
		var eState = state[eid]
		var modelRoot = data["InstancedData"]["Entities"][eid]["Model"]
		
		var playerPos = Vector3(eState["PositionHor"], eState["PositionVer"], 0.0) * POSITION_SCALE
		modelRoot.set_translation(playerPos)
		modelRoot.set_scale(Vector3(eState["Facing"], 1.0, 1.0))
		
		var camPosHor = Vector3(cameraPos.x, playerPos.y, cameraPos.z)
		modelRoot.look_at(playerPos - (camPosHor - playerPos), Vector3.UP)

func InitPhaseEndEntity(eState, data):
	SetPalette(eState, data, eState["Player"])

func InitCamera(_state, _data, _battleInitData):
	return Camera.new()

func SetPalette(eState, data, paletteID):
	var paletteKey = "Palette"+str(paletteID+1)
	var fighterMetadata = data["InstancedData"]["ParsedFighters"][eState["FighterID"]]["Character"]
	if(!fighterMetadata.has(paletteKey)):
		return
	# :TODO:Panthavma:20220217:Do it better, maybe simply charge different models ?
	var palettePath = fighterMetadata[paletteKey]
	var paletteMaterial = load(palettePath)
	var modelRoot = data["InstancedData"]["Entities"][eState["EID"]]["Model"]
	var modelSearch = [modelRoot]
	while(!modelSearch.empty()):
		var m = modelSearch.pop_back()
		modelSearch.append_array(m.get_children())
		if(m.has_method("set_surface_material")):
			m.set_surface_material(0, paletteMaterial)
