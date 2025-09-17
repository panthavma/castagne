# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("AI", Castagne.MODULE_SLOTS_BASE.AI, {"Description":"Specialized module to help with making AIs."})
	RegisterBaseCaspFile("res://castagne/modules/general/Base-AI.casp", 5000)
	
	# [F_STATES] -----------------------------------------------------------------------------------
	RegisterCategory("AI States")
	RegisterFunction("AITransition", [1], ["AI"], {
		"Description":"Make the AI state machine transition to another state.",
		"Arguments":["State name"],
	})
	RegisterFunction("AITransitionHere", [0], null, {
		"Description":"Brings the AI state machine to the current entity state.",
	})
	
	RegisterVariableEntity("_AIState", "Init")
	RegisterVariableEntity("_AIStateStartFrame", -1)
	RegisterVariableEntity("_AIStateFrameID", -1)
	# Quick hacky fix: change the state variables with the AI ones
	RegisterVariableEntity("_AIState_Buffer", "Init")
	RegisterVariableEntity("_AIStateStartFrame_Buffer", -1)
	RegisterVariableEntity("_AIStateFrameID_Buffer", -1)
	
	
	# [F_ACTIONS] ----------------------------------------------------------------------------------
	RegisterCategory("AI Actions")
	#RegisterFunction("AIPress", [1], ["AI", "NoAction"], {
	#	"Description":"Press AI",
	#	"Arguments":["Type", "(Optional) Notation"],
	#})
	RegisterFunction("AIInputTransition", [1], ["AI"], {
		"Description": "Tries to do the specified input transition",
		"Arguments": ["Input Transition to try"],
	})
	RegisterFunction("AIAttackCancelOnHit", [1], ["AI"], {
		"Description": "Helper that tries to do the specified input transition on hit only.",
		"Arguments": ["Attack cancel to try"],
	})
	RegisterFunction("AIAttackCancelOnBlock", [1], ["AI"], {
		"Description": "Helper that tries to do the specified input transition on block only.",
		"Arguments": ["Attack cancel to try"],
	})
	RegisterFunction("AIAttackCancelOnTouch", [1], ["AI"], {
		"Description": "Helper that tries to do the specified input transition on hit and block.",
		"Arguments": ["Attack cancel to try"],
	})
	
	RegisterVariableEntity("_AIAttackCancelWhiff", null)
	RegisterVariableEntity("_AIAttackCancelBlock", null)
	RegisterVariableEntity("_AIAttackCancelHit", null)
	RegisterVariableEntity("_AIAttackCancelNeutral", null)


func AIPhaseStartEntity(stateHandle):
	stateHandle.EntityAdd("_AIStateFrameID", 1)
	
	stateHandle.EntitySet("_AIState_Buffer", stateHandle.EntityGet("_State"))
	stateHandle.EntitySet("_AIStateStartFrame_Buffer", stateHandle.EntityGet("_StateStartFrame"))
	stateHandle.EntitySet("_AIStateFrameID_Buffer", stateHandle.EntityGet("_StateFrameID"))
	stateHandle.EntitySet("_State", stateHandle.EntityGet("_AIState"))
	stateHandle.EntitySet("_StateStartFrame", stateHandle.EntityGet("_AIStateStartFrame"))
	stateHandle.EntitySet("_StateFrameID", stateHandle.EntityGet("_AIStateFrameID"))
func AIPhaseEndEntity(stateHandle):
	stateHandle.EntitySet("_State", stateHandle.EntityGet("_AIState_Buffer"))
	stateHandle.EntitySet("_StateStartFrame", stateHandle.EntityGet("_AIStateStartFrame_Buffer"))
	stateHandle.EntitySet("_StateFrameID", stateHandle.EntityGet("_AIStateFrameID_Buffer"))

func PhysicsPhaseEndEntity(stateHandle):
	var manualTransitions = {}
	
	for l in ["Whiff", "Block", "Hit", "Neutral"]:
		manualTransitions[l] = stateHandle.EntityGet("_AIAttackCancel"+l)
		stateHandle.EntitySet("_AIAttackCancel"+l, null)
	
	var listToUse = "Neutral"
	if(stateHandle.EntityHasFlag("Attacking")):
		listToUse = stateHandle.EntityGet("_AttackHitconfirm_State")
		if(listToUse == null):
			return
	var manualTransition = manualTransitions[listToUse]
	if(manualTransition != null):
		stateHandle.EntitySet("_InputTransitionManual", manualTransition)

func AITransition(args, stateHandle):
	stateHandle.EntitySet("_AIState", ArgStr(args, stateHandle, 0))
	stateHandle.EntitySet("_AIStateStartFrame", stateHandle.GlobalGet("_FrameID"))
	stateHandle.EntitySet("_AIStateFrameID", 0)
func AITransitionHere(_args, stateHandle):
	AITransition([stateHandle.EntityGet("_State")], stateHandle)


func AIAttackCancelOnHit(args, stateHandle):
	stateHandle.EntitySet("_AIAttackCancelHit", ArgStr(args, stateHandle, 0))
func AIAttackCancelOnBlock(args, stateHandle):
	stateHandle.EntitySet("_AIAttackCancelBlock", ArgStr(args, stateHandle, 0))
func AIAttackCancelOnTouch(args, stateHandle):
	stateHandle.EntitySet("_AIAttackCancelHit", ArgStr(args, stateHandle, 0))
	stateHandle.EntitySet("_AIAttackCancelBlock", ArgStr(args, stateHandle, 0))
