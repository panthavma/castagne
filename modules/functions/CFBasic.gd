extends "../CastagneModule.gd"


func ModuleSetup():
	
	# :TODO:Panthavma:20211230:Move some functions to graphics/physics/other/fightinggame
	
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the functions
	# :TODO:Panthavma:20211230:Document the variables
	
	
	RegisterModule("CF Basic")
	RegisterCategory("Basic Module")
	
	# To move ?
	RegisterFunction("Anim", [1], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and follows the same frames as the state.",
		"Arguments": ["Animation Name", "(Optional) Offset"],
		})
	# :TODO:Panthavma:20220131:Add AnimFrame to set it directly, and an offset to anim. a way to loop ?
	#RegisterFunction("SwitchFacing", [0])
	# :TODO:Panthavma:20220216:Remove this for now
	#RegisterFunction("PlaySound", [1], ["Transition"])
	RegisterVariableEntity("Anim", null)
	RegisterVariableEntity("AnimFrame", 0)
	
	
	RegisterVariableEntity("HP", 10000)
	# :TODO:Panthavma:20220131:Set HP from HPMax once the game starts
	RegisterVariableEntity("HPMax", 10000)
	RegisterVariableEntity("Meter", 0)
	
	RegisterVariableGlobal("Timer", 6000)
	RegisterVariableGlobal("CameraHor", 0)
	RegisterVariableGlobal("CameraVer", 0)
	RegisterVariableGlobal("PlayerOnTheLeft", 0)
	RegisterVariableGlobal("WhoHasWon", 0)
	
	RegisterVariableEntity("Facing", 1)
	RegisterVariableEntity("FacingTrue", 0)
	RegisterVariableEntity("PositionHor", 0)
	RegisterVariableEntity("PositionVer", 0)


func UpdateGraphics(state, data):
	for eid in state["ActiveEntities"]:
		var eState = state[eid]
		var anim = eState["Anim"]
		var animPlayer = data["InstancedData"]["Entities"][eid]["AnimPlayer"]
		if(anim != null and animPlayer != null):
			var animFrameID = eState["AnimFrame"]
			if(animPlayer.has_animation(anim)):
				animPlayer.play(anim, 0.0, 0.0)
				animPlayer.seek(float(animFrameID)/60.0, true)
			else:
				ModuleError("Animation " + anim + " doesn't exist.", eState)








func Anim(args, eState, data):
	eState["Anim"] = ArgStr(args, eState, 0)
	eState["AnimFrame"] = data["State"]["FrameID"] - eState["StateStartFrame"]

func PlaySound(_args, _eState, _data):
	pass

