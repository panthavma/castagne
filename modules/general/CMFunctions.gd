# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"


func ModuleSetup():
	RegisterModule("Functions", null, {"Description":"Additional helper functions for the engine that don't fit in a dedicated module."})
	
	RegisterCategory("Mathematics (Advanced)", {"Description":"More complex mathematical functions."})
	RegisterFunction("Abs", [1,2], null, {
		"Description": "Returns the absolute value.",
		"Arguments": ["Variable", "(Optional) Destination Variable"],
	})
	
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
	
	




func Abs(args, stateHandle):
	var destVar = ArgVar(args, stateHandle, 1, ArgVar(args, stateHandle, 0))
	var v = ArgInt(args, stateHandle, 0)
	stateHandle.EntitySet(destVar, (v if v >= 0 else -v))

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


