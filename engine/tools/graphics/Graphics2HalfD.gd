extends "res://castagne/engine/functions/CastagneFunctions.gd"

var camera
var POSITION_SCALE = 1.0

func InitTool(engine, battleInitData):
	camera = Camera.new()
	engine.add_child(camera)
	POSITION_SCALE = engine.POSITION_SCALE

func UpdateGraphics(state, _engine):
	var playerPosCenter = Vector3(state["CameraHor"], state["CameraVer"], 0) * POSITION_SCALE
	var cameraPos = playerPosCenter + Vector3(0.0, 2.0, 3.7) + Vector3(0,0,1.5)
	camera.set_translation(cameraPos)
	state["GraphicsCamPos"] = cameraPos

func UpdatePlayerGraphics(pid, globalState, engine):
	var charState = globalState[pid]
	var modelRoot = engine.instances[pid]["Model"]
	#var animPlayer = engine.instances[pid]["Anim"]
	
	#var frameID = globalState[pid]["StateFrameID"]
	
	var playerPos = Vector3(charState["PositionHor"], charState["PositionVer"], 0.0)*POSITION_SCALE
	modelRoot.set_translation(playerPos)
	modelRoot.set_scale(Vector3(charState["Facing"], 1.0, 1.0))
	var cameraPos = globalState["GraphicsCamPos"]
	var camPosHor = Vector3(cameraPos.x, playerPos.y, cameraPos.z)
	modelRoot.look_at(playerPos - (camPosHor - playerPos), Vector3.UP)
	
	#animPlayer.play(charState["Anim"], 0.0, 0.0)
	#animPlayer.seek(float(frameID + globalState[pid]["AnimOffset"])/60.0, true)
