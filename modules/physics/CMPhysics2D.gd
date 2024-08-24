# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

enum COLBOX_MODES {
	Default, OwnLayer, OtherLayers
}

enum ENVC_TYPES {
	AAPlane
}

enum ENVC_AAPLANE_DIR {
	Right, Up, Left, Down
}

enum ATTACK_CLASH_MODE {
	Disabled, TradePriority, ClashPriority
}

enum FACING_TYPE {
	Physics, Attack, Block, Model
}

var _physicsFlagList = []
var PHYSICS_FLAG_PREFIX = "PF_"

func ModuleSetup():
	RegisterModule("Physics 2D", Castagne.MODULE_SLOTS_BASE.PHYSICS, {
		"Description":"Physics module optimized for 2D fighting games."
	})
	RegisterBaseCaspFile("res://castagne/modules/physics/Base-Physics2D.casp")
	RegisterSpecblock("PhysicsMovement", "res://castagne/modules/physics/CMPhysicsSBMovement.gd")
	RegisterSpecblock("PhysicsTeching", "res://castagne/modules/physics/CMPhysicsSBTeching.gd")
	RegisterSpecblock("PhysicsSystem", "res://castagne/modules/physics/CMPhysicsSBSystem.gd")
	
	RegisterCategory("Position and Movement", {"Description":"These functions allow basic movement and positioning for entities."})
	RegisterFunction("Move", [1,2], null, {
		"Description": "Moves the entity this frame, depending on facing.",
		"Arguments": ["Horizontal move", "(Optional) Vertical move"],
		"Types": ["int", "int"],
		})
	RegisterFunction("MoveAbsolute", [1,2], null, {
		"Description": "Moves the entity this frame, independant of facing.",
		"Arguments": ["Horizontal move", "(Optional) Vertical move"],
		})
	
	# TODO CAST 54 Autotarget opponent
	RegisterFunction("SetPositionRelativeToTarget", [2], null, {
		"Description": "Sets the entity's position based on the target entity, dependant on its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	RegisterFunction("SetPositionRelativeToTargetAbsolute", [2], null, {
		"Description": "Sets the entity's position based on the target entity, independant of its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	RegisterFunction("SetTargetPosition", [2], null, {
		"Description": "Sets the target entity's position based on this entity, dependant of its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	RegisterFunction("SetTargetPositionAbsolute", [2], null, {
		"Description": "Sets the target entity's position based on this entity, independant of its physics facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
	})
	RegisterFunction("TargetGetRelativePosition", [2], null, {
		"Description": "Gets the position of the target in this entity's referential.",
		"Arguments": ["Variable name to store the X position", "Variable name to store the Y position"],
	})
	
	
	RegisterFunction("SetWorldPosition", [2], null, {
		"Description": "Sets the position relative to the world origin, depending on facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
		})
	RegisterFunction("SetWorldPositionX", [1], null, {
		"Description": "Sets the position relative to the world origin, depending on facing.",
		"Arguments": ["Horizontal position"],
		})
	RegisterFunction("SetWorldPositionY", [1], null, {
		"Description": "Sets the position relative to the world origin, depending on facing.",
		"Arguments": ["Vertical position"],
		})
	RegisterFunction("SetWorldPositionAbsolute", [2], null, {
		"Description": "Sets the position relative to the world origin, independant of facing.",
		"Arguments": ["Horizontal position", "Vertical position"],
		})
	RegisterFunction("SetWorldPositionAbsoluteX", [1], null, {
		"Description": "Sets the position relative to the world origin, independant of facing.",
		"Arguments": ["Horizontal position"],
		})
	
	RegisterVariableEntity("_PositionX", 0)
	RegisterVariableEntity("_PositionY", 0)
	RegisterVariableEntity("_PrevPositionX", 0)
	RegisterVariableEntity("_PrevPositionY", 0)
	RegisterVariableEntity("_MovementX", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_MovementY", 0, ["ResetEachFrame"])
	
	
	
	
	
	
	
	
	
	RegisterCategory("Momentum", {
		"Description":"Helper functions related to momentum, applies movement from frame to frame."})
	RegisterFunction("AddMomentum", [1,2], null, {
		"Description": "Adds to the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "(Optional) Vertical momentum"],
		})
	RegisterFunction("AddMomentumAbsolute", [1,2], null, {
		"Description": "Adds to the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "(Optional) Vertical momentum"],
		})
	
	RegisterFunction("SetMomentum", [2], null, {
		"Description": "Sets the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("SetMomentumAbsolute", [2], null, {
		"Description": "Sets the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("SetMomentumX", [1], null, {
		"Description": "Sets the momentum, depending on facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum"],
		})
	RegisterFunction("SetMomentumXAbsolute", [1], null, {
		"Description": "Sets the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Horizontal momentum"],
		})
	RegisterFunction("SetMomentumY", [1], null, {
		"Description": "Sets the momentum, independant of facing. This will move the entity every frame.",
		"Arguments": ["Vertical momentum"],
		})
	
	RegisterFunction("BreakMomentum", [1,2], null, {
		"Description": "Reduces the momentum by the amount given.",
		"Arguments": ["Horizontal momentum","(Optional) Vertical momentum"],
		})
	RegisterFunction("BreakMomentumX", [1,2,3], null, {
		"Description": "Reduces the horizontal momentum by the amount given.",
		"Arguments": ["Horizontal momentum break","(Optional) Horizontal momentum cap","(Optional) Horizontal momentum cap max"],
		})
	RegisterFunction("BreakMomentumY", [1,2,3], null, {
		"Description": "Reduces the vertical momentum by the amount given.",
		"Arguments": ["Vertical momentum break","(Optional) Vertical momentum cap","(Optional) Vertical momentum cap max"],
		})
	RegisterFunction("BreakMomentumXAbsolute", [1,2,3], null, {
		"Description": "Reduces the horizontal momentum by the amount given, independant of facing.",
		"Arguments": ["Horizontal momentum break","(Optional) Horizontal momentum cap","(Optional) Horizontal momentum cap max"],
		})
	
	RegisterFunction("CapMomentum", [2,4], null, {
		"Description": "Limits the momentum to those values.",
		"Arguments": ["Horizontal momentum", "(Optional) Horizontal Momentum Max","Vertical momentum", "(Optional) Vertical Momentum Max"],
		})
	RegisterFunction("CapMomentumX", [2], null, {
		"Description": "Limits the momentum to those values.",
		"Arguments": ["Horizontal momentum", "Horizontal Momentum Max"],
		})
	RegisterFunction("CapMomentumY", [2], null, {
		"Description": "Limits the momentum to those values.",
		"Arguments": ["Vertical momentum", "Vertical Momentum Max"],
		})
	RegisterFunction("CapMomentumAbsolute", [2,4], null, {
		"Description": "Limits the momentum to those values, independant of facing.",
		"Arguments": ["Horizontal momentum", "(Optional) Horizontal Momentum Max","Vertical momentum", "(Optional) Vertical Momentum Max"],
		})
	RegisterFunction("CapMomentumXAbsolute", [2], null, {
		"Description": "Limits the momentum to those values, independant of facing.",
		"Arguments": ["Horizontal momentum", "Horizontal Momentum Max"],
		})
	
	RegisterFunction("AddMomentumTurn", [2], null, {
		"Description": "Adds to the momentum, depending on facing. If momentum is going in the opposite direction, cancel it before applying.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	RegisterFunction("AddMomentumTurnAbsolute", [2], null, {
		"Description": "Adds to the momentum, independant of facing. If momentum is going in the opposite direction, cancel it before applying.",
		"Arguments": ["Horizontal momentum", "Vertical momentum"],
		})
	
	RegisterVariableEntity("_MomentumX", 0)
	RegisterVariableEntity("_MomentumY", 0)
	RegisterVariableEntity("_MomentumZ", 0)
	RegisterFlag("HaltMomentum")
	
	
	
	
	
	
	
	
	RegisterCategory("Facing", {
		"Description": "Functions relative to where the entity is facing, to handle forward / back / side directions.\n"+
		"Several types of facing are available for various purposes."
	})
	
	RegisterFunction("SetFacing", [1,2], null, {
		"Description": "Set an entity's physics facing directly.",
		"Arguments": ["Horizontal Facing", "(Optional) Vertical Facing"],
	})
	RegisterFunction("SetFacingWithType", [2,3], null, {
		"Description": "Set an entity's facing directly, for any type.",
		"Arguments": ["Type of facing to set", "Horizontal Facing", "(Optional) Vertical Facing"],
	})
	RegisterFunction("FlipFacing", [0,1,2], null, {
		"Description": "Flips the horizontal facing of an entity to make it face backwards.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: false)"],
	})
	RegisterFunction("FaceTowardsTarget", [0,1,2], null, {
		"Description": "Faces the entity towards the target.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: false)"],
	})
	RegisterFunction("TargetFaceTowardsSelf", [0,1,2], null, {
		"Description": "Faces the target entity towards this entity.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: false)"],
	})
	RegisterFunction("CopyTargetFacing", [0,1,2], null, {
		"Description": "Copy the facing of the target entity to this entity.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: true)"],
	})
	RegisterFunction("CopyFacingToTarget", [0,1,2], null, {
		"Description": "Copy this entity's facing to the target entity.",
		"Arguments": ["(Optional) Facing type (default: physics)", "(Optional) Also adjust vertical facing (default: true)"],
	})
	RegisterFunction("CopyFacingToOtherFacing", [1,2,3], null, {
		"Description": "Copy one facing type to another facing type.",
		"Arguments": ["Target facing type", "(Optional) Source facing type (default: physics)", "(Optional) Also adjust vertical facing (default: true)"],
	})
	
	RegisterFunction("TransformLocalXToWorld", [1, 2], null, {
		"Description": "Transforms a local X postion to a world position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformLocalYToWorld", [1, 2], null, {
		"Description": "Transforms a local Y postion to a world position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformLocalZToWorld", [1, 2], null, {
		"Description": "Transforms a local Z postion to a world position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformLocalXYToWorld", [2, 4], null, {
		"Description": "Transforms a local X and Y postion to a world position.",
		"Arguments": ["X position", "Y Position", "(Optional) X Destination variable", "(Optional) Y Destination variable"],
	})
	RegisterFunction("TransformLocalToWorld", [3, 6], null, {
		"Description": "Transforms a local XYZ postion to a world position.",
		"Arguments": ["X position", "Y Position", "Z Position", "(Optional) X Destination variable", "(Optional) Y Destination variable", "(Optional) Z Destination Variable"],
	})
	RegisterFunction("TransformWorldXToLocal", [1, 2], null, {
		"Description": "Transforms a world X postion to a local position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformWorldYToLocal", [1, 2], null, {
		"Description": "Transforms a world Y postion to a local position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformWorldYToLocal", [1, 2], null, {
		"Description": "Transforms a world Z postion to a local position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformWorldXYToLocal", [2, 4], null, {
		"Description": "Transforms a world X and Y postion to a local position.",
		"Arguments": ["X position", "Y Position", "(Optional) X Destination variable", "(Optional) Y Destination variable"],
	})
	RegisterFunction("TransformWorldToLocal", [3, 6], null, {
		"Description": "Transforms a world XYZ postion to a local position.",
		"Arguments": ["X position", "Y Position", "Z Position", "(Optional) X Destination variable", "(Optional) Y Destination variable", "(Optional) Z Destination Variable"],
	})
	
	RegisterFunction("TransformLocalXToAbsolute", [1, 2], null, {
		"Description": "Transforms a local X postion to an absolute position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformLocalYToAbsolute", [1, 2], null, {
		"Description": "Transforms a local Y postion to an absolute position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformLocalZToAbsolute", [1, 2], null, {
		"Description": "Transforms a local Z postion to an absolute position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformLocalXYToAbsolute", [2, 4], null, {
		"Description": "Transforms a local X and Y postion to a absolute position.",
		"Arguments": ["X position", "Y Position", "(Optional) X Destination variable", "(Optional) Y Destination variable"],
	})
	RegisterFunction("TransformLocalToAbsolute", [3, 6], null, {
		"Description": "Transforms a local XYZ postion to a absolute position.",
		"Arguments": ["X position", "Y Position", "Z Position", "(Optional) X Destination variable", "(Optional) Y Destination variable", "(Optional) Z Destination Variable"],
	})
	RegisterFunction("TransformAbsoluteXToLocal", [1, 2], null, {
		"Description": "Transforms a absolute X postion to a local position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformAbsoluteYToLocal", [1, 2], null, {
		"Description": "Transforms a absolute Y postion to a local position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformAbsoluteZToLocal", [1, 2], null, {
		"Description": "Transforms a absolute Z postion to a local position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformAbsoluteXYToLocal", [2, 4], null, {
		"Description": "Transforms a absolute X and Y postion to a local position.",
		"Arguments": ["X position", "Y Position", "(Optional) X Destination variable", "(Optional) Y Destination variable"],
	})
	RegisterFunction("TransformAbsoluteToLocal", [3, 6], null, {
		"Description": "Transforms a absolute XYZ postion to a local position.",
		"Arguments": ["X position", "Y Position", "Z Position", "(Optional) X Destination variable", "(Optional) Y Destination variable", "(Optional) Z Destination Variable"],
	})
	
	RegisterFunction("TransformAbsoluteXToWorld", [1, 2], null, {
		"Description": "Transforms an absolute X postion to a world position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformAbsoluteYToWorld", [1, 2], null, {
		"Description": "Transforms an absolute Y postion to a world position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformAbsoluteZToWorld", [1, 2], null, {
		"Description": "Transforms an absolute Z postion to a world position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformAbsoluteXYToWorld", [2, 4], null, {
		"Description": "Transforms a absolute X and Y postion to a world position.",
		"Arguments": ["X position", "Y Position", "(Optional) X Destination variable", "(Optional) Y Destination variable"],
	})
	RegisterFunction("TransformAbsoluteToWorld", [3, 6], null, {
		"Description": "Transforms a absolute XYZ postion to a world position.",
		"Arguments": ["X position", "Y Position", "Z Position", "(Optional) X Destination variable", "(Optional) Y Destination variable", "(Optional) Z Destination Variable"],
	})
	RegisterFunction("TransformWorldXToAbsolute", [1, 2], null, {
		"Description": "Transforms a world X postion to an absolute position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformWorldYToAbsolute", [1, 2], null, {
		"Description": "Transforms a world Y postion to an absolute position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformWorldZToAbsolute", [1, 2], null, {
		"Description": "Transforms a world Z postion to an absolute position.",
		"Arguments": ["Position to change", "(Optional) Destination variable if different"],
	})
	RegisterFunction("TransformWorldXYToAbsolute", [2, 4], null, {
		"Description": "Transforms a world X and Y postion to a absolute position.",
		"Arguments": ["X position", "Y Position", "(Optional) X Destination variable", "(Optional) Y Destination variable"],
	})
	RegisterFunction("TransformWorldToAbsolute", [3, 6], null, {
		"Description": "Transforms a world XYZ postion to a absolute position.",
		"Arguments": ["X position", "Y Position", "Z Position", "(Optional) X Destination variable", "(Optional) Y Destination variable", "(Optional) Z Destination Variable"],
	})
	
	RegisterConstant("FACING_PHYSICS", FACING_TYPE.Physics, {
		"Description":"Facing type constant for the physics facing. This is used for movement."})
	RegisterConstant("FACING_ATTACK", FACING_TYPE.Attack, {
		"Description":"Facing type constant for the attack facing. This is not used for now."})
	RegisterConstant("FACING_BLOCK", FACING_TYPE.Block, {
		"Description":"Facing type constant for the block facing. This is not used for now."})
	RegisterConstant("FACING_MODEL", FACING_TYPE.Model, {
		"Description":"Facing type constant for the model facing. This is used for graphics."})
	
	RegisterVariableEntity("_FacingHPhysics", 1, null, {"Description":"Horizontal physics facing."})
	RegisterVariableEntity("_FacingVPhysics", 0, null, {"Description":"Vertical physics facing. Not used."})
	RegisterVariableEntity("_FacingHAttack", 1, null, {"Description":"Horizontal attack facing. Not used."})
	RegisterVariableEntity("_FacingVAttack", 0, null, {"Description":"Vertical attack facing. Not used."})
	RegisterVariableEntity("_FacingHBlock", 1, null, {"Description":"Horizontal block facing. Not used."})
	RegisterVariableEntity("_FacingVBlock", 0, null, {"Description":"Vertical block facing. Not used."})
	RegisterVariableEntity("_FacingHModel", 1, null, {"Description":"Horizontal model facing."})
	RegisterVariableEntity("_FacingVModel", 0, null, {"Description":"Vertical model facing. Not used."})
	# Search for [TODO FACING V] for when its time to implement
	
	
	
	
	
	
	
	RegisterCategory("Collisions", {
		"Description":"Environment and Attack colliders setup."})
	RegisterFunction("Colbox", [2, 3, 4], null, {
		"Description": "Sets the collision box, which will push other entities.",
		"Arguments": ["Back bound (Optional)", "Front bound", "Down bound (Optional if only two parameters)", "Up bound"],
		})
	RegisterFunction("SetColboxMode", [0,1], null, {
		"Description": "Sets the mode of the Colbox for collisions using one of the COLBOXMODE_ constants.",
		"Arguments": ["(Optional) Colbox mode (default: Default)"]
	})
	RegisterFunction("SetColboxPhantom", [0,1], null, {
		"Description": "Marks the Colbox as Phantom, meaning it will only collide with the environment.",
		"Arguments": ["(Optional) If the colbox is phantom or not (default: true)"],
	})
	RegisterFunction("SetColboxLayer", [0,1], null, {
		"Description": "Sets the layer of this colbox. By default, the layer is equal to the PID+1.",
		"Arguments": ["(Optional) Layer to set (Default: PID+1)"],
	})
	
	
	RegisterFunction("Hurtbox", [2, 3, 4], null, {
		"Description": "Adds a hurtbox, that can be hit by hitboxes.",
		"Arguments": ["Back bound (Optional)", "Front bound", "Down bound (Optional if only two parameters)", "Up bound"],
		})
	RegisterFunction("Hitbox", [2, 3, 4], null, {
		"Description": "Adds a hitbox, that can hit hurtboxes. You need to set attack data beforehand, though the Attack function. This function does not reset the attack data, so you can add several hitboxes for the same attack data by calling Hitbox several times.",
		"Arguments": ["Back bound (Optional)", "Front bound", "Down bound (Optional if only two parameters)", "Up bound"],
		})
		
	RegisterFunction("HurtboxRequires", [0, 1], null, {
		"Description": "The next hurtboxes can't be hit unless the opposing attack has a specific flag. Call with no arguments to reset.",
		"Arguments": ["The attack flag"],
	})
	RegisterFunction("HurtboxAvoids", [0, 1], null, {
		"Description": "The next hurtboxes can't be hit if the opposing attack has a specific flag. Call with no arguments to reset.",
		"Arguments": ["The attack flag"],
	})
	RegisterFunction("HitboxRequires", [0, 1], null, {
		"Description": "The next hitboxes can't hit unless the opponent has a specific flag. Call with no arguments to reset.",
		"Arguments": ["The entity flag"],
	})
	RegisterFunction("HitboxAvoids", [0, 1], null, {
		"Description": "The next hitboxes can't hit if the opponent has a specific flag. Call with no arguments to reset.",
		"Arguments": ["The entity flag"],
	})
	RegisterVariableEntity("_HurtboxMustHaves", [], ["ResetEachFrame"])
	RegisterVariableEntity("_HurtboxMustNotHaves", [], ["ResetEachFrame"])
	RegisterVariableEntity("_HitboxMustHaves", [], ["ResetEachFrame"])
	RegisterVariableEntity("_HitboxMustNotHaves", [], ["ResetEachFrame"])
	
	
	RegisterFunction("ResetColbox", [0], null, {
		"Description": "Deletes the current colbox.",
		"Arguments": [],
	})
	RegisterFunction("ResetHurtboxes", [0], null, {
		"Description": "Deletes the current hurtboxes.",
		"Arguments": [],
	})
	RegisterFunction("ResetHitboxes", [0], null, {
		"Description": "Deletes the current hitboxes.",
		"Arguments": [],
	})
	
	RegisterVariableEntity("_ColboxPhantom", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_ColboxLayer", 0, ["ResetEachFrame"])
	RegisterVariableEntity("_ColboxMode", COLBOX_MODES.Default, ["ResetEachFrame"])
	RegisterConstant("COLBOXMODE_DEFAULT", COLBOX_MODES.Default)
	RegisterConstant("COLBOXMODE_OWNLAYER", COLBOX_MODES.OwnLayer)
	RegisterConstant("COLBOXMODE_OTHERLAYERS", COLBOX_MODES.OtherLayers)
	
	RegisterVariableEntity("_Colbox", null, ["ResetEachFrame"])
	RegisterVariableEntity("_Hitboxes", [], ["ResetEachFrame"])
	RegisterVariableEntity("_Hurtboxes", [], ["ResetEachFrame"])
	
	RegisterConfig("AttackClashMode", ATTACK_CLASH_MODE.TradePriority, {
		"Options":{
			ATTACK_CLASH_MODE.Disabled:"Disabled",
			ATTACK_CLASH_MODE.TradePriority:"Trade Priority (Default)",
			ATTACK_CLASH_MODE.ClashPriority:"Clash Priority"
		}
	})
	
	RegisterFunction("InflictAttack", [0], null, {
		"Description": "Bypasses collisions and the like to register the hit directly on the target. If redoing one for the same target, replaces it.",
	})
	RegisterVariableEntity("_InflictedAttacks", {}, ["ResetEachFrame"])
	
	
	RegisterVariableEntity("_PhysicsFlagBuffer", [], ["ResetEachFrame"])
	RegisterFlag(PHYSICS_FLAG_PREFIX + "Airborne")
	RegisterFlag(PHYSICS_FLAG_PREFIX + "Grounded")
	RegisterFlag(PHYSICS_FLAG_PREFIX + "Wall")
	RegisterFlag(PHYSICS_FLAG_PREFIX + "Ceiling")
	RegisterFlag(PHYSICS_FLAG_PREFIX + "Landing")
	_physicsFlagList = [
		PHYSICS_FLAG_PREFIX + "Airborne",
		PHYSICS_FLAG_PREFIX + "Grounded",
		PHYSICS_FLAG_PREFIX + "Wall",
		PHYSICS_FLAG_PREFIX + "Ceiling",
		PHYSICS_FLAG_PREFIX + "Landing"]
	
	
	
	
	
	
	
	RegisterCategory("Helpers")
	
	RegisterFunction("GetTargetPositionRelativeToSelf", [1,2], null, {
		"Description": "Computes the position of the Target entity in this entity's physics referential, and stores it in the variables given.",
		"Arguments": ["The variable in which to store the X position of the target", "(Optional) The variable in which to store the Y position of the target"],
	})
	
	RegisterFlag("IgnoreGravity")
	RegisterFlag("IgnoreFriction")
	RegisterFlag("NoHurtbox")
	RegisterFlag("NoColbox")
	RegisterFlag("NoHurtboxSet")
	RegisterFlag("NoHitboxSet")
	RegisterFlag("NoColboxSet")
	RegisterVariableEntity("_Gravity", 0)
	RegisterVariableEntity("_TerminalVelocity", -3000)
	RegisterVariableEntity("_FrictionGround", 0)
	RegisterVariableEntity("_FrictionAir", 0)
	
	RegisterStateFlag("Grounded")
	RegisterStateFlag("Airborne")
	
	RegisterVariableGlobal("_CameraX", 0)
	RegisterVariableGlobal("_CameraY", 0)
	
	
	
	
	RegisterConfig("AttacksCanHitOnLandingHitstunFrame", false, {
		"Description":"Allows attacks to hit on a landing frame. If active, must be handled manually to avoid weird behavior."
		})
	
	
	
	RegisterCategory("Arena", {
		"Description":"Arena setup for fighting games."
	})
	
	RegisterConfig("UseFightingArena", true)
	
	RegisterConfig("ArenaSize", 180000)
	RegisterConfig("ArenaMaxPlayerDistance", 75000)
	
	RegisterConfig("PhysicsNbBuckets", 1)

func ActionPhaseStartEntity(stateHandle):
	stateHandle.EntitySet("_ColboxLayer", stateHandle.EntityGet("_Player")+1)
	stateHandle.EntitySetFlag("NoHurtboxSet")
	stateHandle.EntitySetFlag("NoHitboxSet")
	stateHandle.EntitySetFlag("NoColboxSet")
	
func ActionPhaseEndEntity(stateHandle):
	if(!stateHandle.EntityHasFlag("HaltMomentum")):
		stateHandle.EntityAdd("_MovementX", stateHandle.EntityGet("_MomentumX"))
		stateHandle.EntityAdd("_MovementY", stateHandle.EntityGet("_MomentumY"))


func PhysicsPhaseStart(_stateHandle):
	pass
func PhysicsPhaseStartEntity(stateHandle):
	stateHandle.EntitySet("_PrevPositionX", stateHandle.EntityGet("_PositionX"))
	stateHandle.EntitySet("_PrevPositionY", stateHandle.EntityGet("_PositionY"))
	for pf in _physicsFlagList:
		if(stateHandle.EntityHasFlag(pf)):
			stateHandle.EntityAdd("_PhysicsFlagBuffer", [pf])
			stateHandle.EntitySetFlag(pf, false)
func PhysicsPhaseEndEntity(stateHandle):
	var prevPhysicsFlags = stateHandle.EntityGet("_PhysicsFlagBuffer")
	if(!stateHandle.EntityHasFlag(PHYSICS_FLAG_PREFIX + "Grounded")):
		stateHandle.EntitySetFlag(PHYSICS_FLAG_PREFIX + "Airborne")
	if(prevPhysicsFlags.has(PHYSICS_FLAG_PREFIX + "Airborne") and stateHandle.EntityHasFlag(PHYSICS_FLAG_PREFIX + "Grounded")):
		stateHandle.EntitySetFlag(PHYSICS_FLAG_PREFIX + "Landing")
	
	var coreModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.CORE)
	for pf in _physicsFlagList:
		if(stateHandle.EntityHasFlag(pf)):
			coreModule.FlagNext([pf], stateHandle)
func PhysicsPhaseEnd(stateHandle):
	var nbPlayers = 0
	var camX = 0
	var camY = -99999
	for pid in range(stateHandle.GlobalGet("_NbPlayers")):
		if(stateHandle.PointToPlayerMainEntity(pid)):
			nbPlayers += 1
			camX += stateHandle.EntityGet("_PositionX")
			var posY = stateHandle.EntityGet("_PositionY")
			if(camY < posY):
				camY = posY
	if(nbPlayers > 0):
		camX /= nbPlayers
	stateHandle.GlobalSet("_CameraX", camX)
	stateHandle.GlobalSet("_CameraY", camY)

func InputPhaseStartEntity(stateHandle):
	var castagneInput = stateHandle.Input()
	var inputSchema = castagneInput.GetInputSchema()
	var inputs = stateHandle.EntityGet("_Inputs").duplicate()
	var facing = stateHandle.EntityGet("_FacingHPhysics")
	
	if(inputs.empty()):
		return
	
	for derivedInputName in inputSchema["_InputListByType"][Castagne.GAMEINPUT_TYPES.DERIVED]:
		var derivedInput = inputSchema[derivedInputName]
		var diType = derivedInput["DerivedType"]
		var diValue = false
		
		if(diType == Castagne.GAMEINPUT_DERIVED_TYPES.DIRECTIONAL):
			var giNames = derivedInput["GINames"]
			var dirID = derivedInput["DirID"]
			
			if(dirID == castagneInput.STICK_DIRECTIONS.BACK):
				diValue = inputs[giNames[(castagneInput.STICK_DIRECTIONS.LEFT if facing > 0 else castagneInput.STICK_DIRECTIONS.RIGHT)]]
			elif(dirID == castagneInput.STICK_DIRECTIONS.FORWARD):
				diValue = inputs[giNames[(castagneInput.STICK_DIRECTIONS.RIGHT if facing > 0 else castagneInput.STICK_DIRECTIONS.LEFT)]]
		else:
			continue
		
		inputs[derivedInputName] = diValue
	
	stateHandle.EntitySet("_Inputs", inputs)























# --------------------------------------------------------------------------------------------------
# Functions



func Move(args, stateHandle):
	MoveAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, 0)], stateHandle)
func MoveAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_MovementX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_MovementY", ArgInt(args, stateHandle, 1, 0))

func SetPositionRelativeToTarget(args, stateHandle, useAbsolute=false):
	var pos = [ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1)]
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	if(useAbsolute):
		pos = TransformPosEntityAbsoluteToWorld(pos, stateHandle)
	else:
		pos = TransformPosEntityToWorld(pos, stateHandle)
	stateHandle.PointToEntity(selfEID)
	stateHandle.EntitySet("_PositionX", pos[0])
	stateHandle.EntitySet("_PositionY", pos[1])
func SetPositionRelativeToTargetAbsolute(args, stateHandle):
	SetPositionRelativeToTarget(args, stateHandle, true)
func SetTargetPosition(args, stateHandle, useAbsolute=false):
	var pos = [ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1)]
	if(useAbsolute):
		pos = TransformPosEntityAbsoluteToWorld(pos, stateHandle)
	else:
		pos = TransformPosEntityToWorld(pos, stateHandle)
	SetVariableInTarget(stateHandle, "_PositionX", pos[0])
	SetVariableInTarget(stateHandle, "_PositionY", pos[1])
func SetTargetPositionAbsolute(args, stateHandle):
	SetTargetPosition(args, stateHandle, true)

func GizmoSetTargetPosition(emodule, args, lineActive, stateHandle):
	if(args.size() >= 2):
		var color = Color(1.0, 0.4, 1.0)
		var pos = [int(args[0]),int(args[1]),0]
		GizmoPoint(emodule, pos, color, lineActive)

func TargetGetRelativePosition(args, stateHandle):
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	var pos = [stateHandle.EntityGet("_PositionX"), stateHandle.EntityGet("_PositionY")]
	stateHandle.PointToEntity(selfEID)
	pos = TransformWorldPosToEntity(pos, stateHandle)
	stateHandle.EntitySet(ArgVar(args, stateHandle, 0), pos[0])
	stateHandle.EntitySet(ArgVar(args, stateHandle, 1), pos[1])

func SetWorldPosition(args, stateHandle):
	SetWorldPositionAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetWorldPositionAbsolute(args, stateHandle):
	stateHandle.EntitySet("_PositionX", ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_PositionY", ArgInt(args, stateHandle, 1))
func SetWorldPositionX(args, stateHandle):
	SetWorldPositionAbsoluteX([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0)], stateHandle)
func SetWorldPositionAbsoluteX(args, stateHandle):
	stateHandle.EntityGet("_PositionX", ArgInt(args, stateHandle, 0))
func SetWorldPositionY(args, stateHandle):
	stateHandle.EntityGet("_PositionY", ArgInt(args, stateHandle, 0))















func AddMomentum(args, stateHandle):
	AddMomentumAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, 0)], stateHandle)
func AddMomentumAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_MomentumX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_MomentumY", ArgInt(args, stateHandle, 1, 0))
	
func SetMomentum(args, stateHandle):
	SetMomentumAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func SetMomentumAbsolute(args, stateHandle):
	stateHandle.EntitySet("_MomentumX", ArgInt(args, stateHandle, 0))
	stateHandle.EntitySet("_MomentumY", ArgInt(args, stateHandle, 1))
func SetMomentumX(args, stateHandle):
	SetMomentumAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0)], stateHandle)
func SetMomentumXAbsolute(args, stateHandle):
	stateHandle.EntitySet("_MomentumX", ArgInt(args, stateHandle, 0))
func SetMomentumY(args, stateHandle):
	stateHandle.EntitySet("_MomentumY", ArgInt(args, stateHandle, 0))
	
func AddMomentumTurn(args, stateHandle):
	AddMomentumTurnAbsolute([stateHandle.EntityGet("_FacingHPhysics")*ArgInt(args, stateHandle, 0), args[1]], stateHandle)
func AddMomentumTurnAbsolute(args, stateHandle):
	var h = ArgInt(args, stateHandle, 0)
	var v = ArgInt(args, stateHandle, 1)
	
	if(h != 0 and sign(h) != sign(stateHandle.EntityGet("_MomentumX"))):
		stateHandle.EntitySet("_MomentumX", 0)
	if(v != 0 and sign(v) != sign(stateHandle.EntityGet("_MomentumY"))):
		stateHandle.EntitySet("_MomentumY", 0)
	
	AddMomentumAbsolute(args, stateHandle)


func BreakMomentum(args, stateHandle):
	var h = min(ArgInt(args, stateHandle, 0), abs(stateHandle.EntityGet("_MomentumX")))
	var v = min(ArgInt(args, stateHandle, 1, 0), abs(stateHandle.EntityGet("_MomentumY")))
	stateHandle.EntityAdd("_MomentumX", -sign(stateHandle.EntityGet("_MomentumX")) * h)
	stateHandle.EntityAdd("_MomentumY", -sign(stateHandle.EntityGet("_MomentumY")) * v)
func BreakMomentumX(args, stateHandle):
	_BreakMomentumAxis(args, stateHandle, "_MomentumX", stateHandle.EntityGet("_FacingHPhysics"))
func BreakMomentumY(args, stateHandle):
	_BreakMomentumAxis(args, stateHandle, "_MomentumY")
func BreakMomentumXAbsolute(args, stateHandle):
	_BreakMomentumAxis(args, stateHandle, "_MomentumX")
func _BreakMomentumAxis(args, stateHandle, axis, facing=1.0):
	var m = stateHandle.EntityGet(axis)
	var mBreak = abs(ArgInt(args, stateHandle, 0))
	var mMin = ArgInt(args, stateHandle, 1, 0) * facing
	var mMax = ArgInt(args, stateHandle, 2, -mMin)
	
	if(mMin > mMax):
		var a = mMin
		mMin = mMax
		mMax = a
	
	if(m > mMax):
		var diff = m-mMax
		m -= int(min(diff, mBreak))
	elif(m < mMin):
		var diff = mMin-m
		m += int(min(diff, mBreak))
	stateHandle.EntitySet(axis, m)

func CapMomentum(args, stateHandle):
	CapMomentumAbsolute(args, stateHandle, stateHandle.EntityGet("_FacingHPhysics"))
func CapMomentumAbsolute(args, stateHandle, facing=1.0):
	var hMin
	var hMax
	var vMin
	var vMax
	if(args.size() > 2): # 4 args
		hMin = ArgInt(args, stateHandle, 0)
		hMax = ArgInt(args, stateHandle, 1)
		vMin = ArgInt(args, stateHandle, 2)
		vMax = ArgInt(args, stateHandle, 3)
		if(hMin > hMax or vMin > vMax):
			ModuleError("CapMomentum: Enveloppe has no volume", stateHandle)
		if(facing < 0):
			var a = hMin
			hMin = -hMax
			hMax = -a
	else: # 2 args
		hMax = abs(ArgInt(args, stateHandle, 0))
		vMax = abs(ArgInt(args, stateHandle, 1))
		hMin = -hMax
		vMin = -vMax
	
	stateHandle.EntitySet("_MomentumX", max(min(stateHandle.EntityGet("_MomentumX"), hMax), hMin))
	stateHandle.EntitySet("_MomentumY", max(min(stateHandle.EntityGet("_MomentumY"), vMax), vMin))
func CapMomentumX(args, stateHandle):
	_CapMomentmAxis(args, stateHandle, "_MomentumX", stateHandle.EntityGet("_FacingHPhysics"))
func CapMomentumY(args, stateHandle):
	_CapMomentmAxis(args, stateHandle, "_MomentumY")
func CapMomentumXAbsolute(args, stateHandle):
	_CapMomentmAxis(args, stateHandle, "_MomentumX")
func _CapMomentmAxis(args, stateHandle, axis, facing=1.0):
	var aMin = ArgInt(args, stateHandle, 0)
	var aMax = ArgInt(args, stateHandle, 1)
	if(aMin > aMax):
		ModuleError("CapMomentumAxis: Enveloppe has no volume", stateHandle)
	if(facing < 0):
		var a = aMin
		aMin = -aMax
		aMax = -a
	stateHandle.EntitySet(axis, max(min(stateHandle.EntityGet(axis), aMax), aMin))






















func SetFacing(args, stateHandle, facingType = FACING_TYPE.Physics):
	var facingH = ArgInt(args, stateHandle, 0)
	var facingV = ArgInt(args, stateHandle, 1, GetFacingHV(stateHandle, facingType)[1])
	SetFacingHV(stateHandle, facingH, facingV, facingType)
func SetFacingWithType(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0)
	var facingH = ArgInt(args, stateHandle, 1)
	var facingV = ArgInt(args, stateHandle, 2, GetFacingHV(stateHandle, facingType)[1])
	SetFacingHV(stateHandle, facingH, facingV, facingType)


func FlipFacing(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, false)
	var facing = GetFacingHV(stateHandle, facingType)
	
	facing[0] *= -1
	# [TODO FACING V]
	
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)

func FaceTowardsTarget(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, false)
	var selfPosX = stateHandle.EntityGet("_PositionX")
	var targetPosX = stateHandle.TargetEntityGet("_PositionX")
	# [TODO FACING V]
	if(selfPosX == targetPosX):
		return
	var facing = GetFacingHV(stateHandle, facingType)
	facing[0] = (1 if targetPosX > selfPosX else -1)
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
func TargetFaceTowardsSelf(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, false)
	var selfPosX = stateHandle.EntityGet("_PositionX")
	var targetPosX = stateHandle.TargetEntityGet("_PositionX")
	# [TODO FACING V]
	if(selfPosX == targetPosX):
		return
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	var facing = GetFacingHV(stateHandle, facingType)
	facing[0] = (-1 if targetPosX > selfPosX else 1)
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
	stateHandle.PointToEntity(selfEID)

func CopyTargetFacing(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, true)
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	var facing = GetFacingHV(stateHandle, facingType)
	stateHandle.PointToEntity(selfEID)
	if(!alsoAdjustV):
		facing[1] = GetFacingHV(stateHandle, facingType)[1]
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
func CopyFacingToTarget(args, stateHandle):
	var facingType = ArgInt(args, stateHandle, 0, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 1, true)
	var facing = GetFacingHV(stateHandle, facingType)
	var selfEID = stateHandle.PointToCurrentTargetEntity()
	if(!alsoAdjustV):
		facing[1] = GetFacingHV(stateHandle, facingType)[1]
	SetFacingHV(stateHandle, facing[0], facing[1], facingType)
	stateHandle.PointToEntity(selfEID)
func CopyFacingToOtherFacing(args, stateHandle):
	var targetFacingType = ArgInt(args, stateHandle, 0)
	var sourceFacingType = ArgInt(args, stateHandle, 1, FACING_TYPE.Physics)
	var alsoAdjustV = ArgBool(args, stateHandle, 2, true)
	var facing = GetFacingHV(stateHandle, sourceFacingType)
	if(!alsoAdjustV):
		facing[1] = GetFacingHV(stateHandle, targetFacingType)[1]
	SetFacingHV(stateHandle, facing[0], facing[1], targetFacingType)


onready var _TransformAxisFunctions = [
	funcref(self, "TransformPosEntityToWorld"),
	funcref(self, "TransformWorldPosToEntity"),
	funcref(self, "TransformPosEntityToAbsolute"),
	funcref(self, "TransformPosEntityAbsoluteToEntity"),
	funcref(self, "TransformPosEntityAbsoluteToWorld"),
	funcref(self, "TransformWorldPosToEntityAbsolute"),
	]
func _TransformAxisFunction(args, stateHandle, index, type, getArgID = 0, setArgID = 1):
	# More efficient ways exists, good enough for now
	if(index == 3):
		_TransformAxisFunction(args, stateHandle, 0, type, 0, 2)
		_TransformAxisFunction(args, stateHandle, 1, type, 1, 3)
	elif(index == 4):
		_TransformAxisFunction(args, stateHandle, 0, type, 0, 3)
		_TransformAxisFunction(args, stateHandle, 1, type, 1, 4)
		_TransformAxisFunction(args, stateHandle, 2, type, 2, 5)
	else:
		var destVar = ArgVar(args, stateHandle, setArgID, ArgVar(args, stateHandle, getArgID))
		var opos = [0, 0, 0]
		opos[index] = ArgInt(args, stateHandle, getArgID)
		var tpos = _TransformAxisFunctions[type].call_func(opos, stateHandle)
		stateHandle.EntitySet(destVar, tpos[index])
	
func _TransformLocalAxisToWorld(args, stateHandle, index):
	_TransformAxisFunction(args, stateHandle, index, 0)
func _TransformWorldAxisToLocal(args, stateHandle, index):
	_TransformAxisFunction(args, stateHandle, index, 1)
func _TransformLocalAxisToAbsolute(args, stateHandle, index):
	_TransformAxisFunction(args, stateHandle, index, 2)
func _TransformAbsoluteAxisToLocal(args, stateHandle, index):
	_TransformAxisFunction(args, stateHandle, index, 3)
func _TransformAbsoluteAxisToWorld(args, stateHandle, index):
	_TransformAxisFunction(args, stateHandle, index, 4)
func _TransformWorldAxisToAbsolute(args, stateHandle, index):
	_TransformAxisFunction(args, stateHandle, index, 5)

func TransformLocalXToWorld(args, stateHandle):
	_TransformLocalAxisToWorld(args, stateHandle, 0)
func TransformLocalYToWorld(args, stateHandle):
	_TransformLocalAxisToWorld(args, stateHandle, 1)
func TransformLocalZToWorld(args, stateHandle):
	_TransformLocalAxisToWorld(args, stateHandle, 2)
func TransformLocalXYToWorld(args, stateHandle):
	_TransformLocalAxisToWorld(args, stateHandle, 3)
func TransformLocalToWorld(args, stateHandle):
	_TransformLocalAxisToWorld(args, stateHandle, 4)
func TransformWorldXToLocal(args, stateHandle):
	_TransformWorldAxisToLocal(args, stateHandle, 0)
func TransformWorldYToLocal(args, stateHandle):
	_TransformWorldAxisToLocal(args, stateHandle, 1)
func TransformWorldZToLocal(args, stateHandle):
	_TransformWorldAxisToLocal(args, stateHandle, 2)
func TransformWorldXYToLocal(args, stateHandle):
	_TransformWorldAxisToLocal(args, stateHandle, 3)
func TransformWorldToLocal(args, stateHandle):
	_TransformWorldAxisToLocal(args, stateHandle, 4)
func TransformLocalXToAbsolute(args, stateHandle):
	_TransformLocalAxisToAbsolute(args, stateHandle, 0)
func TransformLocalYToAbsolute(args, stateHandle):
	_TransformLocalAxisToAbsolute(args, stateHandle, 1)
func TransformLocalZToAbsolute(args, stateHandle):
	_TransformLocalAxisToAbsolute(args, stateHandle, 2)
func TransformLocalXYToAbsolute(args, stateHandle):
	_TransformLocalAxisToAbsolute(args, stateHandle, 3)
func TransformLocalToAbsolute(args, stateHandle):
	_TransformLocalAxisToAbsolute(args, stateHandle, 4)
func TransformAbsoluteXToLocal(args, stateHandle):
	_TransformAbsoluteAxisToLocal(args, stateHandle, 0)
func TransformAbsoluteYToLocal(args, stateHandle):
	_TransformAbsoluteAxisToLocal(args, stateHandle, 1)
func TransformAbsoluteZToLocal(args, stateHandle):
	_TransformAbsoluteAxisToLocal(args, stateHandle, 2)
func TransformAbsoluteXYToLocal(args, stateHandle):
	_TransformAbsoluteAxisToLocal(args, stateHandle, 3)
func TransformAbsoluteToLocal(args, stateHandle):
	_TransformAbsoluteAxisToLocal(args, stateHandle, 4)
func TransformAbsoluteXToWorld(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 0)
func TransformAbsoluteYToWorld(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 1)
func TransformAbsoluteZToWorld(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 2)
func TransformAbsoluteXYToWorld(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 3)
func TransformAbsoluteToWorld(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 4)
func TransformWorldXToAbsolute(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 0)
func TransformWorldYToAbsolute(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 1)
func TransformWorldZToAbsolute(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 2)
func TransformWorldXYToAbsolute(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 3)
func TransformWorldToAbsolute(args, stateHandle):
	_TransformAbsoluteAxisToWorld(args, stateHandle, 4)



















func _BoxCreate(args, stateHandle):
	var box ={
		"Owner":stateHandle.EntityGet("_EID"),
	}
	if(args.size() > 3):
		box["Left"] = ArgInt(args, stateHandle, 0)
		box["Right"] = ArgInt(args, stateHandle, 1)
		box["Down"] = ArgInt(args, stateHandle, 2)
		box["Up"] = ArgInt(args, stateHandle, 3)
	elif(args.size() > 2):
		box["Right"] = ArgInt(args, stateHandle, 0)
		box["Down"] = ArgInt(args, stateHandle, 1)
		box["Up"] = ArgInt(args, stateHandle, 2)
		box["Left"] = -box["Right"]
	else:
		box["Right"] = ArgInt(args, stateHandle, 0)
		box["Up"] = ArgInt(args, stateHandle, 1)
		box["Down"] = -box["Up"]
		box["Left"] = -box["Right"]
	
	if(box["Down"] > box["Up"] || box["Left"] > box["Right"]):
		ModuleError("Box has negative volume. ("+str(box["Left"])+", "+str(box["Right"])+", "+str(box["Down"])+", "+str(box["Up"])+")", stateHandle)
	return box

func Colbox(args, stateHandle):
	var box = _BoxCreate(args, stateHandle)
	stateHandle.EntitySet("_Colbox", box)
	stateHandle.EntitySetFlag("NoColboxSet", false)

func Hurtbox(args, stateHandle):
	var box = _BoxCreate(args, stateHandle)
	box["Data"] = {}
	box["MustHave"] = stateHandle.EntityGet("_HurtboxMustHaves").duplicate()
	box["MustNotHave"] = stateHandle.EntityGet("_HurtboxMustNotHaves").duplicate()
	stateHandle.EntityGet("_Hurtboxes").append(box)
	stateHandle.EntitySetFlag("NoHurtboxSet", false)

func Hitbox(args, stateHandle):
	var box = _BoxCreate(args, stateHandle)
	box["AttackData"] = stateHandle.EntityGet("_AttackData").duplicate()
	box["MustHave"] = stateHandle.EntityGet("_HitboxMustHaves").duplicate()
	box["MustNotHave"] = stateHandle.EntityGet("_HitboxMustNotHaves").duplicate()
	stateHandle.EntityGet("_Hitboxes").append(box)
	stateHandle.EntitySetFlag("NoHitboxSet", false)


func _HitHurtboxMustHave(stateHandle, flag, array):
	if(flag == null):
		stateHandle.EntitySet(array, [])
	else:
		stateHandle.EntityAdd(array, [flag])
func HurtboxRequires(args, stateHandle):
	_HitHurtboxMustHave(stateHandle, ArgRaw(args, 0, null), "_HurtboxMustHaves")
func HurtboxAvoids(args, stateHandle):
	_HitHurtboxMustHave(stateHandle, ArgRaw(args, 0, null), "_HurtboxMustNotHaves")
func HitboxRequires(args, stateHandle):
	_HitHurtboxMustHave(stateHandle, ArgRaw(args, 0, null), "_HitboxMustHaves")
func HitboxAvoids(args, stateHandle):
	_HitHurtboxMustHave(stateHandle, ArgRaw(args, 0, null), "_HitboxMustNotHaves")

func GizmoBox(emodule, args, lineActive, _stateHandle, type):
	var color = [Color(0.4, 0.4, 1.0), Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4)][type]
	var colorBack = [Color(0.3, 0.3, 1.0, 0.45), Color(1.0, 0.3, 0.3, 0.45), Color(0.3, 1.0, 0.3, 0.45)][type]
	var widthActive = [6,6,6][type]
	var widthInactive = [2,2,2][type]
	var l = 0
	var r = 0
	var b = 0
	var t = 0
	if(args.size() > 3):
		l = ArgInt(args, null, 0, 0)
		r = ArgInt(args, null, 1, 0)
		b = ArgInt(args, null, 2, 0)
		t = ArgInt(args, null, 3, 0)
	elif(args.size() > 2):
		r = ArgInt(args, null, 0, 0)
		b = ArgInt(args, null, 1, 0)
		t = ArgInt(args, null, 2, 0)
		l = -r
	else:
		r = ArgInt(args, null, 0, 0)
		t = ArgInt(args, null, 1, 0)
		l = -r
		b = -t
	if(r < l):
		r = l
	if(t < b):
		t = b
	var hc = (l+r)/2
	var vc = (b+t)/2
	var drawRhombus = (type == 2)
	var width = (widthActive if lineActive else widthInactive)
	
	if(lineActive):
		emodule.GizmoFilledBox([l,t,0], [r,b,0], colorBack, color, width)
	else:
		emodule.GizmoBox([l,t,0], [r,b,0], color, width)
	
	if(drawRhombus):
		emodule.GizmoLine([l, vc,0], [hc, t,0], color, width)
		emodule.GizmoLine([hc, t,0], [r, vc,0], color, width)
		emodule.GizmoLine([r, vc,0], [hc, b,0], color, width)
		emodule.GizmoLine([hc, b,0], [l, vc,0], color, width)

func GizmoPoint(emodule, pos, color, lineActive):
	var lineWidth = (4 if lineActive else 2)
	var anchorSize = 2000
	emodule.GizmoLine([pos[0]-anchorSize,pos[1],pos[2]], [pos[0]+anchorSize,pos[1],pos[2]], color, lineWidth)
	emodule.GizmoLine([pos[0],pos[1]-anchorSize,pos[2]], [pos[0],pos[1]+anchorSize,pos[2]], color, lineWidth)
	emodule.GizmoLine([pos[0]-anchorSize,pos[1],pos[2]], [pos[0],pos[1]+anchorSize,pos[2]], color, lineWidth)
	emodule.GizmoLine([pos[0]-anchorSize,pos[1],pos[2]], [pos[0],pos[1]-anchorSize,pos[2]], color, lineWidth)
	emodule.GizmoLine([pos[0]+anchorSize,pos[1],pos[2]], [pos[0],pos[1]+anchorSize,pos[2]], color, lineWidth)
	emodule.GizmoLine([pos[0]+anchorSize,pos[1],pos[2]], [pos[0],pos[1]-anchorSize,pos[2]], color, lineWidth)

func GizmoHurtbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 0)
func GizmoHitbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 1)
func GizmoColbox(emodule, args, lineActive, stateHandle):
	GizmoBox(emodule, args, lineActive, stateHandle, 2)

var _gizmoColors = [Color(0.4, 0.4, 1.0), Color(1.0, 0.4, 0.4), Color(0.4, 1.0, 0.4)]
func GizmoMoveLine(emodule, args, lineActive, _stateHandle, type):
	var color = _gizmoColors[type]
	var widthActive = [6,6,6][type]
	var widthInactive = [2,2,2][type]
	var width = (widthActive if lineActive else widthInactive)
	
	var h = ArgInt(args, null, 0, 0)
	var v = ArgInt(args, null, 1, 0)
	
	emodule.GizmoLine([0,0,0], [h,v,0], color, width)

func GizmoMove(emodule, args, lineActive, stateHandle):
	return
	GizmoMoveLine(emodule, args, lineActive, stateHandle, 0)



func SetColboxMode(args, stateHandle):
	var colboxMode = ArgInt(args, stateHandle, 0, COLBOX_MODES.Default)
	stateHandle.EntitySet("_ColboxMode", colboxMode)
func SetColboxPhantom(args, stateHandle):
	var phantom = ArgBool(args, stateHandle, 0, true)
	stateHandle.EntitySet("_ColboxPhantom", phantom)
func SetColboxLayer(args, stateHandle):
	var layer = ArgInt(args, stateHandle, 0, stateHandle.EntityGet("_Player")+1)
	stateHandle.EntitySet("_ColboxLayer", layer)

func ResetColbox(args, stateHandle):
	stateHandle.EntitySet("_Colbox", null)
	stateHandle.EntitySetFlag("NoColboxSet")
func ResetHurtboxes(args, stateHandle):
	stateHandle.EntitySet("_Hurtboxes", [])
	stateHandle.EntitySetFlag("NoHurtboxSet")
func ResetHitboxes(args, stateHandle):
	stateHandle.EntitySet("_Hitboxes", [])
	stateHandle.EntitySetFlag("NoHitboxSet")




func InflictAttack(_args, stateHandle):
	var attackData = stateHandle.EntityGet("_AttackData").duplicate(true)
	var ia = stateHandle.EntityGet("_InflictedAttacks")
	var targetEID = stateHandle.GetTargetEID()
	ia[targetEID] = attackData
	stateHandle.EntitySet("_InflictedAttacks", ia)









func GetTargetPositionRelativeToSelf(args, stateHandle):
	var posXName = ArgVar(args, stateHandle, 0)
	var posYName = ArgVar(args, stateHandle, 1, "")
	
	var targetPosX = stateHandle.TargetEntityGet("_PositionX")
	var targetPosY = stateHandle.TargetEntityGet("_PositionY")
	
	var pos = TransformWorldPosToEntity([targetPosX, targetPosY], stateHandle)
	
	stateHandle.EntitySet(posXName, pos[0])
	if(posYName != ""):
		stateHandle.EntitySet(posYName, pos[1])
















# --------------------------------------------------------------------------------------------------
# Physics code

var _castProfiling_PhysicsStart = -1
var _castProfiling_PhysicsSetupDone = -1
var _castProfiling_Env_SetupDone = -1
var _castProfiling_EnvColEnd = -1
var _castProfiling_Atk_SetupDone = -1
var _castProfiling_PhysicsEnd = -1

func PhysicsPhase(stateHandle, activeEIDs):
	_castProfiling_PhysicsStart = OS.get_ticks_usec()
	
	# 1. Setup data needed
	PhysicsPhaseSetup(stateHandle, activeEIDs)
	_castProfiling_PhysicsSetupDone = OS.get_ticks_usec()
	
	# 2. Colbox and Environment Collisions
	PhysicsPhaseEnvironment(stateHandle, activeEIDs)
	_castProfiling_EnvColEnd = OS.get_ticks_usec()
	
	# 3. Attack collisions
	PhysicsPhaseAttack(stateHandle, activeEIDs)
	_castProfiling_PhysicsEnd = OS.get_ticks_usec()

var ppAttackModule
var ppStateHandlesByEID
func PhysicsPhaseSetup(stateHandle, activeEIDs):
	ppAttackModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.ATTACKS)
	ppStateHandlesByEID = {}
	for eid in activeEIDs:
		stateHandle.PointToEntity(eid)
		var entityStateHandle = stateHandle.CloneStateHandle()
		ppStateHandlesByEID[eid] = entityStateHandle

func PhysicsPhaseEnvironment(stateHandle, activeEIDs):
	# Checks environment collisions for each entity separately
	
	var nbBuckets = stateHandle.ConfigData().Get("PhysicsNbBuckets")
	
	# Gather colboxes and env constraints
	var envConstraints = GetEnvironmentConstraints(stateHandle)
	var colboxes = []
	for eid in activeEIDs:
		var entityStateHandle = ppStateHandlesByEID[eid]
		var c = entityStateHandle.EntityGet("_Colbox")
		if(c == null):
			continue
		c = c.duplicate()
		c["Phantom"] = entityStateHandle.EntityGet("_ColboxPhantom")
		c["Mode"] = entityStateHandle.EntityGet("_ColboxMode")
		c["Layer"] = entityStateHandle.EntityGet("_ColboxLayer")
		colboxes.push_back(c)
	
	var nbColboxes = colboxes.size()
	var nbEnvConstraints = envConstraints.size()
	
	# Check who can collide with others based on layers
	var validColboxCollisions = []
	var validEnvironmentCollisions = []
	
	for i in range(nbColboxes-1):
		for j in range(i+1, nbColboxes):
			var colboxA = colboxes[i]
			var colboxB = colboxes[j]
			if(colboxA["Phantom"] or colboxB["Phantom"]):
				continue
			if(PhysicsEnv_CanLayersCollide(colboxA, colboxB)):
				validColboxCollisions.push_back([i,j])
	
	for i in range(nbColboxes):
		for j in range(nbEnvConstraints):
			var colbox = colboxes[i]
			var envc = envConstraints[j]
			if(PhysicsEnv_CanLayersCollide(colbox, envc)):
				validEnvironmentCollisions.push_back([i,j])
	
	# Create Movement Buckets
	var movementBuckets = {}
	
	for eid in activeEIDs:
		var entityStateHandle = ppStateHandlesByEID[eid]
		if(entityStateHandle.EntityHasFlag("Frozen")):
			continue
		var movement = [entityStateHandle.EntityGet("_MovementX"), entityStateHandle.EntityGet("_MovementY")]
		var bucketMovement = [movement[0]/nbBuckets, movement[1]/nbBuckets]
		var buckets = []
		for i in range(nbBuckets):
			buckets.push_back(bucketMovement.duplicate())
		buckets[0][0] += movement[0]%nbBuckets
		buckets[0][1] += movement[1]%nbBuckets
		movementBuckets[eid] = buckets
	
	_castProfiling_Env_SetupDone = OS.get_ticks_usec()
	
	# Main Loop
	for loopID in nbBuckets:
		# Apply movement
		for eid in activeEIDs:
			var entityStateHandle = ppStateHandlesByEID[eid]
			if(entityStateHandle.EntityHasFlag("Frozen")):
				continue
			var movement = movementBuckets[eid][loopID]
			entityStateHandle.EntityAdd("_PositionX", movement[0])
			entityStateHandle.EntityAdd("_PositionY", movement[1])
		
		# Do colbox interactions
		for colboxCol in validColboxCollisions:
			var colboxA = colboxes[colboxCol[0]]
			var colboxB = colboxes[colboxCol[1]]
			PhysicsEnv_ColboxColbox(colboxA, colboxB)
		
		# Do environment constraints
		for envCol in validEnvironmentCollisions:
			var colbox = colboxes[envCol[0]]
			var envConstraint = envConstraints[envCol[1]]
			var movement = PhysicsEnv_ApplyEnvConstraint(colbox, envConstraint)

func PhysicsEnv_ApplyEnvConstraint(colbox, envc):
	var movement = [0,0]
	var envcType = envc["Type"]
	
	var entityStateHandle = ppStateHandlesByEID[colbox["Owner"]]
	var colpos = GetBoxPosition(entityStateHandle, colbox)
	
	if(envcType == ENVC_TYPES.AAPlane):
		var envcDir = envc["Dir"]
		var envcPos = envc["Position"]
		var envcStopMomentum = envc["StopMomentum"]
		
		var colboxPos = 0
		var moveXMult = 0
		var moveYMult = 0
		var invertAxis = 1
		var flag = null
		
		if(envcDir == ENVC_AAPLANE_DIR.Right):
			colboxPos = colpos[0]
			moveXMult = -1
			flag = PHYSICS_FLAG_PREFIX + "Wall"
		elif(envcDir == ENVC_AAPLANE_DIR.Up):
			colboxPos = colpos[2]
			moveYMult = -1
			flag = PHYSICS_FLAG_PREFIX + "Grounded"
		elif(envcDir == ENVC_AAPLANE_DIR.Left):
			colboxPos = colpos[1]
			moveXMult = 1
			invertAxis = -1
			flag = PHYSICS_FLAG_PREFIX + "Wall"
		elif(envcDir == ENVC_AAPLANE_DIR.Down):
			colboxPos = colpos[3]
			moveYMult = 1
			invertAxis = -1
			flag = PHYSICS_FLAG_PREFIX + "Ceiling"
		else:
			ModuleError("PhysicsEnv: Direction "+str(envcDir) + " not valid for AAPlanes")
			return
		
		var diff = (colboxPos - envcPos) * invertAxis
		var margin = 10 # TODO CAST 56 Config
		if(diff <= margin):
			EntitySetFlag(entityStateHandle, flag)
		
		if(diff < 0):
			entityStateHandle.EntityAdd("_PositionX", diff * moveXMult)
			entityStateHandle.EntityAdd("_PositionY", diff * moveYMult)
			if(envcStopMomentum):
				if(moveYMult != 0):
					entityStateHandle.EntitySet("_MomentumY", max(entityStateHandle.EntityGet("_MomentumY")*invertAxis, 0)*invertAxis)
	else:
		ModuleError("PhysicsEnv: Env Constraint of unknown type: "+ str(envcType))

func PhysicsEnv_ColboxColbox(colboxA, colboxB):
	var entityStateHandleA = ppStateHandlesByEID[colboxA["Owner"]]
	var colposA = GetBoxPosition(entityStateHandleA, colboxA)
	var prevXA = entityStateHandleA.EntityGet("_PrevPositionX")
	
	var entityStateHandleB = ppStateHandlesByEID[colboxB["Owner"]]
	var colposB = GetBoxPosition(entityStateHandleB, colboxB)
	var prevXB = entityStateHandleB.EntityGet("_PrevPositionX")
	
	# Check collision
	if(!AreBoxesOverlapping(colposA, colposB)):
		return
	
	var overlap = 0
	if(colposA[0] < colposB[0]):
		overlap = colposA[1] - colposB[0]
	else:
		overlap = colposB[1] - colposA[0]
	
	var centerHA = (colposA[1] + colposA[0])/2
	var centerVA = (colposA[3] + colposA[2])/2
	var centerHB = (colposB[1] + colposB[0])/2
	var centerVB = (colposB[3] + colposB[2])/2
	
	var pushbackDirA = (-1 if prevXB > prevXA else 1)
	if(prevXA == prevXB):
		pushbackDirA = (-1 if centerHB > centerHA else 1)
	# TODO Take facing into account and other heuristics
	
	entityStateHandleA.EntityAdd("_PositionX", pushbackDirA*overlap/2)
	entityStateHandleB.EntityAdd("_PositionX", -pushbackDirA*overlap/2)
	

func PhysicsEnv_CanLayersCollide(a, b):
	var layerA = a["Layer"]
	var modeA = a["Mode"]
	var layerB = b["Layer"]
	var modeB = b["Mode"]
	
	var commonLayerA = (modeA == COLBOX_MODES.Default or layerA == 0)
	var commonLayerB = (modeB == COLBOX_MODES.Default or layerB == 0)
	if(commonLayerA and commonLayerB):
		return true
	
	var sameLayer = (layerA == layerB)
	var noColSameLayer = (modeA == COLBOX_MODES.OtherLayers or modeB == COLBOX_MODES.OtherLayers)
	if(noColSameLayer and !sameLayer):
		return true
	if(!noColSameLayer and sameLayer):
		return true
	return false

func PhysicsPhaseAttack(stateHandle, activeEIDs):
	var clashMode = stateHandle.ConfigData().Get("AttackClashMode")
	
	var hurtboxes = {}
	var hitboxes = {}
	var friendlyFireHitboxes = {}
	var aaBoxes = {} # [hurtbox, hitbox, friendlyfire], if null ignore collision
	
	# Build EID List
	var posKeys = ["Left", "Right", "Down", "Up"]
	for eid in activeEIDs:
		var entityStateHandle = ppStateHandlesByEID[eid]
		
		var hurt = []
		var hurtboxAA = null
		var entityHurtboxList = entityStateHandle.EntityGet("_Hurtboxes")
		
		# :HACK: Bit hacky but I don't really see how to do it in a non hacky way
		# If we are in hitstun AND landing we don't gather any hurtbox, manual intangibility
		# It's hard to do otherwise because we don't know the info in time for the hit.
		# Could be fixed another day
		var prevPhysicsFlags = entityStateHandle.EntityGet("_PhysicsFlagBuffer")
		if(stateHandle.ConfigData().Get("AttacksCanHitOnLandingHitstunFrame") or
			!(entityStateHandle.EntityHasFlag("Hitstun")) or
			!(prevPhysicsFlags.has(PHYSICS_FLAG_PREFIX + "Airborne") and entityStateHandle.EntityHasFlag(PHYSICS_FLAG_PREFIX + "Grounded"))):
			
			for hurtboxOriginal in entityHurtboxList:
				var h = hurtboxOriginal.duplicate()
				var pos = GetBoxPosition(entityStateHandle, hurtboxOriginal)
				
				if(hurtboxAA == null):
					hurtboxAA = pos
				else:
					ExpandAABox(hurtboxAA, pos)
				
				for i in range(4):
					h[i] = pos[i]
				h["Hitbox"] = false
				hurt.push_back(h)
				
		
		var hit = []
		var ffHit = []
		var hitboxAA = null
		var ffHitboxAA = null
		var entityHitboxList = entityStateHandle.EntityGet("_Hitboxes")
		for hitboxOriginal in entityHitboxList:
			var h = hitboxOriginal.duplicate()
			var pos = GetBoxPosition(entityStateHandle, hitboxOriginal)
			
			if(hitboxAA == null):
				hitboxAA = pos
			else:
				ExpandAABox(hitboxAA, pos)
			
			for i in range(4):
				h[i] = pos[i]
			h["Hitbox"] = true
			
			var hitboxFriendlyFire = h["AttackData"]["_Flags"].has("FriendlyFire")
			if(hitboxFriendlyFire):
				if(ffHitboxAA == null):
					hitboxFriendlyFire = pos
				else:
					ExpandAABox(ffHitboxAA, pos)
				ffHit.push_back(h)
			hit.push_back(h)
		
		if(clashMode == ATTACK_CLASH_MODE.TradePriority):
			for hitbox in hit:
				hurt.push_back(hitbox)
		elif(clashMode == ATTACK_CLASH_MODE.ClashPriority):
			var h = hit.duplicate()
			for hurtbox in hurt:
				h.push_back(hurtbox)
			hurt = h
		
		if(hitboxAA != null and clashMode != ATTACK_CLASH_MODE.Disabled):
			if(hurtboxAA == null):
				hurtboxAA = hitboxAA
			else:
				ExpandAABox(hurtboxAA, hitboxAA)
		
		# TODO Clash happens on friendly fire ? too complex and niche i think
		
		aaBoxes[eid] = [hurtboxAA, hitboxAA, ffHitboxAA]
		hurtboxes[eid] = hurt
		hitboxes[eid] = hit
		friendlyFireHitboxes[eid] = ffHit
	
	_castProfiling_Atk_SetupDone = OS.get_ticks_usec()
	
	# Gather potential character collisions
	for eidAID in range(activeEIDs.size()-1):
		var eidA = activeEIDs[eidAID]
		var aaBoxesA = aaBoxes[eidA]
		var handleA = ppStateHandlesByEID[eidA]
		var pidA = handleA.EntityGet("_Player")
		var inflictedAttacksA = handleA.EntityGet("_InflictedAttacks")
		for eidBID in range(1, activeEIDs.size()):
			var eidB = activeEIDs[eidBID]
			var aaBoxesB = aaBoxes[eidB]
			var handleB = ppStateHandlesByEID[eidB]
			var pidB = handleB.EntityGet("_Player")
			var inflictedAttacksB = handleB.EntityGet("_InflictedAttacks")
			
			var sameTeam = (pidA == pidB)
			var aaHitboxID = (2 if sameTeam else 1)
			
			# Use the AA box to weed out unnecessary checks, or use the inflicted attack
			# A attacker, B defender
			if(eidB in inflictedAttacksA):
				var phantomHitbox = _BoxCreate([0, 1, 0, 1], handleA)
				var phantomHurtbox = _BoxCreate([0, 1, 0, 1], handleB)
				phantomHitbox["AttackData"] = inflictedAttacksA[eidB]
				phantomHitbox["Hitbox"] = true
				phantomHurtbox["Hitbox"] = false
				ppAttackModule.HandleHit(handleA, handleB, phantomHitbox, phantomHurtbox)
			elif(aaBoxesB[0] != null and aaBoxesA[aaHitboxID] != null and AreBoxesOverlapping(aaBoxesB[0], aaBoxesA[aaHitboxID])):
				var atkH = (friendlyFireHitboxes[eidA] if sameTeam else hitboxes[eidA])
				PhysicsAtk_HandleAttackDefend(handleA, handleB, atkH, hurtboxes[eidB])
			# B attacker, A defender
			if(eidA in inflictedAttacksB):
				var phantomHitbox = _BoxCreate([0, 1, 0, 1], handleB)
				var phantomHurtbox = _BoxCreate([0, 1, 0, 1], handleA)
				phantomHitbox["AttackData"] = inflictedAttacksB[eidA]
				phantomHitbox["Hitbox"] = true
				phantomHurtbox["Hitbox"] = false
				ppAttackModule.HandleHit(handleB, handleA, phantomHitbox, phantomHurtbox)
			elif(aaBoxesA[0] != null and aaBoxesB[aaHitboxID] != null and AreBoxesOverlapping(aaBoxesA[0], aaBoxesB[aaHitboxID])):
				var atkH = (friendlyFireHitboxes[eidB] if sameTeam else hitboxes[eidB])
				PhysicsAtk_HandleAttackDefend(handleB, handleA, atkH, hurtboxes[eidA])

func PhysicsAtk_HandleAttackDefend(attackerHandle, defenderHandle, attackerHitboxes, defenderHurtboxes):
	for hitbox in attackerHitboxes:
		for hurtbox in defenderHurtboxes:
			if(AreBoxesOverlapping(hitbox, hurtbox) and PhysicsAtk_ShouldBoxesConnect(defenderHandle, hitbox, hurtbox)):
				if(ppAttackModule.HandleHit(attackerHandle, defenderHandle, hitbox, hurtbox)):
					return true
	return false

func PhysicsAtk_ShouldBoxesConnect(defenderHandle, hitbox, hurtbox):
	var attackFlags = hitbox["AttackData"]["_Flags"]
	for f in hurtbox["MustHave"]:
		if not (f in attackFlags):
			return false
	for f in hurtbox["MustNotHave"]:
		if (f in attackFlags):
			return false
	for f in hitbox["MustHave"]:
		if(!defenderHandle.EntityHasFlag(f)):
			return false
	for f in hitbox["MustNotHave"]:
		if(defenderHandle.EntityHasFlag(f)):
			return false
	return true

func GetEnvironmentConstraints(stateHandle):
	if(stateHandle.ConfigData().Get("UseFightingArena")):
		return CreateFightingArena(stateHandle)
	return []

func CreateFightingArena(stateHandle):
	# Ground
	# If two player: special walls and camera
	# If other count: normal walls
	var nbPlayers = stateHandle.GlobalGet("_NbPlayers")
	var arenaSize = stateHandle.ConfigData().Get("ArenaSize")
	var cameraSize = stateHandle.ConfigData().Get("ArenaMaxPlayerDistance")
	
	var envConstraints = [
		{"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Up, "Position":0, "StopMomentum":true, "Layer":0, "Mode":COLBOX_MODES.OwnLayer},
	]
	
	# TODO CAST 54 Corner steal
	if(nbPlayers == 2):
		stateHandle.PointToPlayer(0)
		var eid1 = stateHandle.PlayerGet("MainEntity")
		stateHandle.PointToEntity(eid1)
		var p1Pos = stateHandle.EntityGet("_PositionX")
		var p1OldPos = stateHandle.EntityGet("_PrevPositionX")
		
		stateHandle.PointToPlayer(1)
		var eid2 = stateHandle.PlayerGet("MainEntity")
		stateHandle.PointToEntity(eid2)
		var p2Pos = stateHandle.EntityGet("_PositionX")
		var p2OldPos = stateHandle.EntityGet("_PrevPositionX")
		
		var centerPos = (p1Pos+p2Pos)/2
		var p1Left = (p1Pos <= p2Pos)
		
		# TODO Investigate: This works when both players have the same colbox, but might not in other cases.
		# Just giving priority to the player below would be janky too
		
		if(p1Pos == p2Pos):
			p1Left = (p1OldPos <= p2OldPos)
		
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":-arenaSize + (0 if p1Left else 1),
		"StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":arenaSize - (1 if p1Left else 0),
		"StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":-arenaSize + (1 if p1Left else 0),
		"StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":arenaSize - (0 if p1Left else 1),
		"StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
		# Center pos
		
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":centerPos-cameraSize, "StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":centerPos+cameraSize, "StopMomentum":true, "Layer":1, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
		"Position":centerPos-cameraSize, "StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
		envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
		"Position":centerPos+cameraSize, "StopMomentum":true, "Layer":2, "Mode":COLBOX_MODES.OwnLayer})
	
	envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Right,
	"Position":-arenaSize, "StopMomentum":true, "Layer":0, "Mode":COLBOX_MODES.OwnLayer})
	envConstraints.push_back({"Type":ENVC_TYPES.AAPlane, "Dir":ENVC_AAPLANE_DIR.Left,
	"Position":arenaSize, "StopMomentum":true, "Layer":0, "Mode":COLBOX_MODES.OwnLayer})
	
	return envConstraints

func GetBoxPosition(stateHandle, box):
	var cornerTL = TransformPosEntityToWorld([box["Left"], box["Up"],0], stateHandle)
	var cornerBR = TransformPosEntityToWorld([box["Right"], box["Down"],0], stateHandle)
	var facingHV = GetFacingHV(stateHandle)
	if(facingHV[0] >= 0):
		return [cornerTL[0],cornerBR[0],cornerBR[1],cornerTL[1]]
	else:
		return [cornerBR[0],cornerTL[0],cornerBR[1],cornerTL[1]]

func AreBoxesOverlapping(boxA, boxB):
	return (boxA[1] > boxB[0]
		and boxA[0] < boxB[1]
		and boxA[3] > boxB[2]
		and boxA[2] < boxB[3])

func ExpandAABox(aabox, newBox):
	aabox[0] = min(aabox[0], newBox[0])
	aabox[1] = max(aabox[1], newBox[1])
	aabox[2] = min(aabox[2], newBox[2])
	aabox[3] = max(aabox[3], newBox[3])

func GetFacingHV(stateHandle, facingType = FACING_TYPE.Physics):
	var facings = ["Physics", "Attack", "Block", "Model"]
	var hv = [stateHandle.EntityGet("_FacingH"+facings[facingType]), stateHandle.EntityGet("_FacingV"+facings[facingType])]
	if(hv[0] == null):
		hv[0] = 1
	if(hv[1] == null):
		hv[1] = 0
	return hv

func SetFacingHV(stateHandle, facingH, facingV, facingType = FACING_TYPE.Physics):
	var facings = ["Physics", "Attack", "Block", "Model"]
	stateHandle.EntitySet("_FacingH"+facings[facingType], facingH)
	stateHandle.EntitySet("_FacingV"+facings[facingType], facingV)

func TransformPosEntityToAbsolute(pos, stateHandle, facingType = FACING_TYPE.Physics):
	var facingHV = GetFacingHV(stateHandle, facingType)
	return [pos[0] * (1 if facingHV[0] > 0 else -1), pos[1], 0]

func TransformPosEntityToWorld(pos, stateHandle, facingType = FACING_TYPE.Physics):
	var absolutePos = TransformPosEntityToAbsolute(pos, stateHandle, facingType)
	return TransformPosEntityAbsoluteToWorld(absolutePos, stateHandle, facingType)

func TransformPosEntityAbsoluteToWorld(absolutePos, stateHandle, facingType = FACING_TYPE.Physics):
	var x = stateHandle.EntityGet("_PositionX")
	var y = stateHandle.EntityGet("_PositionY")
	if(x == null):
		x = 0
	if(y == null):
		y = 0
	
	return [x + absolutePos[0], y + absolutePos[1], 0]

func TransformWorldPosToEntityAbsolute(pos, stateHandle):
	var x = stateHandle.EntityGet("_PositionX")
	var y = stateHandle.EntityGet("_PositionY")
	return [pos[0] - x, pos[1] - y, 0]

func TransformWorldPosToEntity(pos, stateHandle, facingType = FACING_TYPE.Physics):
	var absolutePos = TransformWorldPosToEntityAbsolute(pos, stateHandle)
	return TransformPosEntityAbsoluteToEntity(absolutePos, stateHandle, facingType)

func TransformPosEntityAbsoluteToEntity(absolutePos, stateHandle, facingType = FACING_TYPE.Physics):
	var facingHV = GetFacingHV(stateHandle, facingType)
	return [absolutePos[0] * (1 if facingHV[0] > 0 else -1), absolutePos[1]]

