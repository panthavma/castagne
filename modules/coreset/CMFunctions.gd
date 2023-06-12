extends "../CastagneModule.gd"


func ModuleSetup():
	# :TODO:Panthavma:20211230:Document the module
	# :TODO:Panthavma:20211230:Document the variables
	
	
	RegisterModule("Functions", null, {"Description":"Additional helper functions for the engine that don't fit in a dedicated module."})
	# :TODO:Panthavma:20220310:Can it support more than one ?
	
	RegisterCategory("Mathematics (Advanced)", {"Description":"More complex mathematical functions."})
	RegisterFunction("Cos", [2,3], null, {
		"Description": "Returns the cosine of an angle (in milliradians) multiplied by a variable.",
		"Arguments": ["Variable", "Angle", "(Optional) Destination Variable"]
	})
	RegisterFunction("Sin", [2,3], null, {
		"Description": "Returns the sine of an angle (in milliradians) multiplied by a variable.",
		"Arguments": ["Variable", "Angle", "(Optional) Destination Variable"]
	})
	RegisterFunction("CosD", [2,3], null, {
		"Description": "Returns the cosine of an angle (in tenths of degrees) multiplied by a variable.",
		"Arguments": ["Variable", "Angle", "(Optional) Destination Variable"]
	})
	RegisterFunction("SinD", [2,3], null, {
		"Description": "Returns the sine of an angle (in tenths of degrees) multiplied by a variable.",
		"Arguments": ["Variable", "Angle", "(Optional) Destination Variable"]
	})
	
	# :TODO:Panthavma:20220310:Lock the model position/facing (maybe physics module ?)
	# :TODO:Panthavma:20220310:Add sprite support
	
	RegisterCategory("Animations", {"Description":"Functions relating to the animation system. This will be moved later to graphics."})
	RegisterFunction("Anim", [1,2], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and starts at the first frame the function is called.",
		"Arguments": ["Animation Name", "(Optional) Offset"],
		})
	RegisterFunction("AnimFrame", [1,2], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and if not specified will use the amount of frames you were in that state..",
		"Arguments": ["Animation Name", "(Optional) The frame to display"],
		})
	RegisterFunction("AnimProgress", [0,1], null, {
		"Description": "Progresses an already playing animation. Can also be used to scroll.",
		"Arguments": ["(Optional) Amount of frames to progress"],
		})
	RegisterFunction("AnimLoop", [1, 2], null, {
		"Description": "Loops an animation around by setting it to the start point when reaching the specified frame.",
		"Arguments": ["Loop point (exclusive)", "(Optional) Start point of the loop."]
	})
	RegisterFunction("AnimReset", [0], null, {
		"Description": "Resets the animation variables.",
		"Arguments": [],
		})
	# :TODO:Panthavma:20220131:Add AnimFrame to set it directly, and an offset to anim. a way to loop ?
	# :TODO:Panthavma:20220216:Implement sound
	RegisterVariableEntity("_Anim", null, null, {"Description":"Currently playing animation."})
	RegisterVariableEntity("_AnimFrame", 0, null, {"Description":"Current frame of the animation to show."})
	RegisterVariableEntity("_AnimStartFrame", 0, null, {"Description":"Remembers when the animation started, for the Anim function"})
	RegisterVariableEntity("_AnimOffset", null, null, {"Description":"Remembers an offset for the Anim function"})
	
	#RegisterVariableEntity("_VVA", 0)
	#RegisterVariableEntity("_VVB", 0)
	#RegisterVariableEntity("_VVC", 0)
	#RegisterVariableEntity("_VVD", 0)
	


func UpdateGraphics(stateHandle):
	for eid in stateHandle.GlobalGet("_ActiveEntities"):
		stateHandle.PointToEntity(eid)
		var anim = stateHandle.EntityGet("_Anim")
		var animPlayer = stateHandle.IDEntityGet("AnimPlayer")
		if(anim != null and animPlayer != null):
			var animFrameID = stateHandle.EntityGet("_AnimFrame")
			if(animPlayer.has_animation(anim)):
				animPlayer.play(anim, 0.0, 0.0)
				animPlayer.seek(float(animFrameID-1)/60.0, true)
			else:
				ModuleError("Animation " + anim + " doesn't exist.", stateHandle)





func Cos(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, int(ArgInt(args, stateHandle, 0) * cos(ArgInt(args, stateHandle, 1)/1000.0)))
func Sin(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, int(ArgInt(args, stateHandle, 0) * sin(ArgInt(args, stateHandle, 1)/1000.0)))
func CosD(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, int(ArgInt(args, stateHandle, 0) * cos(deg2rad(ArgInt(args, stateHandle, 1)/10.0))))
func SinD(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 2, ArgVar(args, stateHandle, 0))
	stateHandle.EntitySet(destVar, int(ArgInt(args, stateHandle, 0) * sin(deg2rad(ArgInt(args, stateHandle, 1)/10.0))))



# :TODO:Panthavma:20220323:Not robust to state change
func Anim(args, stateHandle):
	var newAnim = ArgStr(args, stateHandle, 0)
	var offset = ArgInt(args, stateHandle, 1, 0)
	if(newAnim != stateHandle.EntityGet("_Anim") or offset != stateHandle.EntityGet("_AnimOffset")):
		var startFrame = stateHandle.EntityGet("_StateStartFrame") + stateHandle.EntityGet("_StateFrameID") - offset
		stateHandle.EntitySet("_AnimStartFrame", startFrame)
		stateHandle.EntitySet("_AnimOffset", offset)
	stateHandle.EntitySet("_Anim", newAnim)
	var frame = 1+stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_AnimStartFrame")
	
	stateHandle.EntitySet("_AnimFrame", frame)
func AnimFrame(args, stateHandle):
	stateHandle.EntitySet("_Anim", ArgStr(args, stateHandle, 0))
	stateHandle.EntitySet("_AnimFrame", ArgInt(args, stateHandle, 1, stateHandle.GlobalGet("_FrameID") - stateHandle.EntityGet("_StateStartFrame")))
	stateHandle.EntitySet("_AnimOffset", null)
func AnimProgress(args, stateHandle):
	stateHandle.EntityAdd("_AnimFrame", ArgInt(args, stateHandle, 0, 1))
func AnimLoop(args, stateHandle):
	var loopPointEnd = ArgInt(args, stateHandle, 0)
	var loopPointStart = ArgInt(args, stateHandle, 1, 0)
	var loopSpan = max(loopPointEnd - loopPointStart, 1)
	
	var frame = stateHandle.EntityGet("_AnimFrame")
	if(frame >= loopPointEnd):
		frame = ((frame - loopPointStart) % loopSpan) + loopPointStart
		stateHandle.EntitySet("_AnimFrame", frame)
func AnimReset(_args, stateHandle):
	stateHandle.EntitySet("_Anim", null)
	stateHandle.EntitySet("_AnimOffset", null)

func PlaySound(_args, _stateHandle):
	pass


