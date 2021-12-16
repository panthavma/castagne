extends Spatial
var animPlayer
var engine
onready var fighterData = $Data
onready var states = $States
onready var modelRoot = $Model

func InitFighter(fightingEngine):
	engine = fightingEngine
	fighterData.SetMany({
		"InitialState": "Idle", "AnimPlayerPath":"AnimationPlayer",
		"Hitstun":0, "Blockstun":0,
		
		"HPMax": 10000,
		"WalkFSpeed": 100, "WalkBSpeed": 70,
		
		"JumpsquatFrames":4, "LandingLag":4,
		"JumpBoostStartup":6, "JumpNBoost":220,
		
		
		"Gravity": 40,
		"GroundFrictionHorAbs": 120, "GroundFrictionVerAbs": 0,
		"AirFrictionHorAbs": 4, "AirFrictionVerAbs": 4,
		
		"ColboxPos":{
			"Left":-4000, "Right":4000, "Down":0, "Up":15000
		},
		
	})
	states.InitStates(self)
	fighterData.Lock()
	
	animPlayer = get_node(fighterData.Get("AnimPlayerPath"))

func InitGameState():
	var data = fighterData.GetMany(["HPMax", "InitialState"])
	return {
		"HP":data["HPMax"],
		"State":data["InitialState"],
		"StateStartFrame":0,
		"Anim":"Stand",
		"Facing":1, "FacingTrue":1,
		"PositionHor":0, "PositionVer":0,
		"MomentumHor":0, "MomentumVer":0,
		"MovementHor":0, "MovementVer":0,
		"Hurtboxes":[], "CollisionBox":{}, "Hitboxes":[],
		"Colbox":fighterData.Get("ColboxPos"),
		"AttackHasHit":false, "BoostDirection":5,
		"Flags":{}, "Proration":1.0
	}

func GetState(stateName):
	return states.GetState(stateName)

func UpdateGraphics(charState, globalState):
	var playerPos = Vector3(charState["PositionHor"], charState["PositionVer"], 0.0)*engine.POSITION_SCALE
	set_translation(playerPos)
	modelRoot.set_scale(Vector3(charState["Facing"], 1.0, 1.0))
	var cameraPos = globalState["GraphicsCamPos"]
	var camPosHor = Vector3(cameraPos.x, playerPos.y, cameraPos.z)
	look_at(playerPos - (camPosHor - playerPos), Vector3.UP)
	
	animPlayer.play(charState["Anim"])
