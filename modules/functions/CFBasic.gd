extends "../CastagneModule.gd"


func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	
	RegisterModule("CF Basic")
	RegisterCategory("Graphics")
	
	RegisterFunction("CreateModel", [1, 2], null, {
		"Description": "Creates a model for the current entity",
		"Arguments":["Model path", "(Optional) Animation player path"]
	})
	# :TODO:Panthavma:20220310:Can it support more than one ?
	
	# :TODO:Panthavma:20220310:Lock the model position/facing (maybe physics module ?)
	# :TODO:Panthavma:20220310:Add sprite support
	RegisterFunction("Anim", [1], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and follows the same frames as the state.",
		"Arguments": ["Animation Name", "(Optional) Offset"],
		})
	# :TODO:Panthavma:20220131:Add AnimFrame to set it directly, and an offset to anim. a way to loop ?
	# :TODO:Panthavma:20220216:Implement sound
	RegisterVariableEntity("Anim", null)
	RegisterVariableEntity("AnimFrame", 0)


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





func CreateModel(args, eState, _data):
	engine.InstanceModel(eState["EID"], ArgStr(args, eState, 0), ArgStr(args, eState, 1, null))


func Anim(args, eState, data):
	eState["Anim"] = ArgStr(args, eState, 0)
	eState["AnimFrame"] = data["State"]["FrameID"] - eState["StateStartFrame"]

func PlaySound(_args, _eState, _data):
	pass

