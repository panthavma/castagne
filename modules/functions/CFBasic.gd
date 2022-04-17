extends "../CastagneModule.gd"


func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	
	RegisterModule("CF Basic")
	# :TODO:Panthavma:20220310:Can it support more than one ?
	
	# :TODO:Panthavma:20220310:Lock the model position/facing (maybe physics module ?)
	# :TODO:Panthavma:20220310:Add sprite support
	
	RegisterCategory("Animations")
	RegisterFunction("Anim", [1,2,3], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and starts at the first frame the function is called.",
		"Arguments": ["Animation Name", "(Optional) Offset", "(Optional) Loop"],
		})
	RegisterFunction("AnimFrame", [1,2], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and if not specified will use the amount of frames you were in that state..",
		"Arguments": ["Animation Name", "(Optional) The frame to display"],
		})
	RegisterFunction("AnimProgress", [0,1], null, {
		"Description": "Progresses an already playing animation. Can also be used to scroll.",
		"Arguments": ["(Optional) Amount of frames to progress"],
		})
	RegisterFunction("AnimReset", [0], null, {
		"Description": "Resets the animation variables.",
		"Arguments": [],
		})
	# :TODO:Panthavma:20220131:Add AnimFrame to set it directly, and an offset to anim. a way to loop ?
	# :TODO:Panthavma:20220216:Implement sound
	RegisterVariableEntity("Anim", null)
	RegisterVariableEntity("AnimFrame", 0)
	RegisterVariableEntity("AnimStartFrame", 0)
	RegisterVariableEntity("AnimOffset", null)
	
	RegisterCategory("Sprites")
	RegisterFunction("Sprite", [1], null, {
		"Description":"Display a previously set sprite frame",
		"Arguments": ["Frame ID", "(Optional) Frame Position Y"],
	})


func UpdateGraphics(state, data):
	for eid in state["ActiveEntities"]:
		var eState = state[eid]
		var anim = eState["Anim"]
		var animPlayer = data["InstancedData"]["Entities"][eid]["AnimPlayer"]
		if(anim != null and animPlayer != null):
			var animFrameID = eState["AnimFrame"]
			if(animPlayer.has_animation(anim)):
				animPlayer.play(anim, 0.0, 0.0)
				animPlayer.seek(float(animFrameID-1)/60.0, true)
			else:
				ModuleError("Animation " + anim + " doesn't exist.", eState)







# :TODO:Panthavma:20220323:Not robust to state change
func Anim(args, eState, data):
	var newAnim = ArgStr(args, eState, 0)
	var offset = ArgInt(args, eState, 1, 0)
	var loop = ArgInt(args, eState, 2, 0)
	if(newAnim != eState["Anim"] or offset != eState["AnimOffset"]):
		eState["AnimStartFrame"] = (eState["StateStartFrame"] - offset)+1
		eState["AnimOffset"] = offset
	eState["Anim"] = newAnim
	var frame = 1+data["State"]["FrameID"] - eState["AnimStartFrame"]
	if(loop > 0):
		frame %= loop
	
	eState["AnimFrame"] = frame
func AnimFrame(args, eState, data):
	eState["Anim"] = ArgStr(args, eState, 0)
	eState["AnimFrame"] = ArgInt(args, eState, 1, data["State"]["FrameID"] - eState["StateStartFrame"])
	eState["AnimOffset"] = null
func AnimProgress(args, eState, _data):
	eState["AnimFrame"] += ArgStr(args, eState, 0, 1)
func AnimReset(_args, eState, _data):
	eState["Anim"] = null
	eState["AnimOffset"] = null

func PlaySound(_args, _eState, _data):
	pass


func Sprite(args, eState, _data):
	eState["SpriteFrame"] = ArgInt(args, eState, 0)
