# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

var graphicsRoot = null
var POSITION_SCALE = 1.0
var IS_2D = false

func ModuleSetup():
	RegisterModule("Graphics", Castagne.MODULE_SLOTS_BASE.GRAPHICS)
	RegisterBaseCaspFile("res://castagne/modules/graphics/Base-Graphics.casp")
	RegisterSpecblock("Graphics", "res://castagne/modules/graphics/CMGraphicsSBGraphics.gd")
	RegisterSpecblock("Anims", "res://castagne/modules/graphics/CMGraphicsSBAnims.gd")
	RegisterSpecblock("UI", "res://castagne/modules/graphics/CMGraphicsSBUI.gd")
	
	
	# -[CTG_MODEL]----------------------------------------------------------------------------------
	RegisterCategory("Model", {
		"Description":"""Functions relating to models. A model is a .tscn scene, which may come with an AnimationPlayer node.
Model functions affect the whole graphics side, so even sprites are affected here."""
		})
	RegisterFunction("ModelCreate", [1, 2], null, {
		"Description": "Creates a model for the current entity. An AnimationPlayer may be set to enable Anim functions.",
		"Arguments":["Model path", "(Optional) Animation player path"],
		"Flags":["Intermediate"],
		"Types":["str", "str"],
	})
	RegisterFunction("ModelScale", [1], null, {
		"Description": "Changes the model's scale uniformly.",
		"Arguments":["The scale in permil."],
		"Flags":["Intermediate"],
		"Types":["int"],
	})
	RegisterFunction("ModelRotation", [1], null, {
		"Description": "Changes the model's rotation on the Z axis.",
		"Arguments":["The rotation in tenths of degrees."],
		"Flags":["Intermediate"],
		"Types":["int"],
	})
	
	RegisterFunction("ModelMove", [1,2], null, {
		"Description": "Moves the model depending on facing. You'll want to activate the ModelLockRelativePosition flag.",
		"Arguments":["Horizontal Move", "(Optional) Vertical Move"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("ModelMoveAbsolute", [1,2], null, {
		"Description": "Moves the model independant of facing. You'll want to activate the ModelLockRelativePosition flag.",
		"Arguments":["Horizontal Move", "(Optional) Vertical Move"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("ModelSwitchFacing", [0], null, {
		"Description": "Changes the model's facing. You'll want to activate the ModelLockFacing flag.",
		"Arguments":[],
		"Flags":["Advanced"],
	})
	
	RegisterFunction("ModelZOrder", [1,2], null, {
		"Description": "Sets the draw order for sprites, higher being drawn on top of others.\n"+
		"Coarse order acts like a layer, while fine will order within the same layer.",
		"Arguments":["Coarse Z Order in [-39, 39]", "(Optional) Fine Z Order in [-49, 50]. Unchanged if not specified."],
		"Flags":["Advanced"],
	})
	RegisterFunction("ModelZOrderFine", [1], null, {
		"Description": "Set the draw order for sprites, higher being drawn on top of others.\n"+
		"This function allows to set the fine Z order directly.",
		"Arguments":["Fine Z Order in [-49, 50]"],
		"Flags":["Advanced"],
	})
	
	RegisterFunction("ModelShaderParamI", [2, 3, 4, 5], null, {
		"Description": "Sets a shader parameter for the model. Specify as many parameters as needed.",
		"Arguments":["Parameter Name", "Value 1", "(Optional) Value 2", "(Optional) Value 3", "(Optional) Value 4"],
		
	})
	RegisterFunction("ModelShaderParamF", [2, 3, 4, 5], null, {
		"Description": "Sets a shader parameter for the model. Specify as many parameters as needed. All values are in permil.",
		"Arguments":["Parameter Name", "Value 1", "(Optional) Value 2", "(Optional) Value 3", "(Optional) Value 4"],
	})
	
	RegisterFunction("ModelVisibility", [1], null, {
		"Description": "Sets if the model should be fully visible or not. This does not affect subnodes.",
		"Arguments":["If the model should be visible"]
	})
	RegisterFunction("ModelVisibilityPath", [2], null, {
		"Description": "Sets if a model part should be visible or not. Activates or deactivates a node given by a path.",
		"Arguments":["The name of the node", "If the node should be visible or not"]
	})
	RegisterFunction("ModelVisibilityPattern", [2], null, {
		"Description": "Sets if a model part should be visible or not. Activates or deactivates nodes whose name matches a pattern (case sensitive).",
		"Arguments":["Substring to search", "If the nodes should be visible or not"]
	})
	
	RegisterVariableEntity("_ModelPositionX", 0)
	RegisterVariableEntity("_ModelPositionY", 0)
	RegisterVariableEntity("_ModelRotation", 0)
	RegisterVariableEntity("_ModelScale", 1000)
	RegisterVariableEntity("_ModelZOrder", 0)
	#RegisterVariableEntity("_ModelFacing", 1)
	RegisterFlag("ModelLockWorldPosition")
	RegisterFlag("ModelLockRelativePosition")
	RegisterFlag("ModelLockFacing")
	
	RegisterVariableGlobal("_GraphicsCamPos", Vector3()) # TEMP ?
	
	
	
	
	# -[CTG_SPRITES]--------------------------------------------------------------------------------
	RegisterCategory("Sprites", {
		"Descriptions":"""Sprite related functions. This is a work in progress."""
	})
	RegisterFunction("Sprite", [1, 2], null, {
		"Description":"Display a previously set sprite frame. Will use the previously set animation if not specified.",
		"Arguments": ["(Optional) Anim/Spritesheet Name", "Frame ID"],
		"Flags":["Basic"],
		"Types":["str", "int"],
	})
	RegisterFunction("SpriteProgress", [0, 1], null, {
		"Description":"Advance on the spritesheet. Will use the current animation.",
		"Arguments": ["(Optional) Number of frames to advance"],
		"Flags":["Intermediate"],
		"Types":["int"],
	})
	RegisterFunction("SpriteCreate", [0], ["Init"], {
		"Description": "Creates a sprite. Can either be empty, to use spritesheets, or have a link to a SpriteFrames ressource, depending on the interface you want to have."+
		"\n\nUsing spritesheets will require you to use SpritesheetRegister later, ideally by using the specblocks interface. This will allow you to manage spritesheets from the Castagne Editor."+
		"\n\nOn the other end, using SpriteFrames will require you to set up every animation using Godot's editor. Please refer to the module documentation for more details.",
		"Arguments": [],
		"Flags":["Intermediate"],
		"Types":["str"],
	})
	RegisterFunction("SpritesheetRegister", [2, 3, 4, 5, 6, 7], ["Init"], {
		"Description": "Registers a new spritesheet to be used later and selects it. If not specified, the optional parameters are inherited from the currently selected spritesheet.",
		"Arguments": ["Spritesheet Name", "Spritesheet Path", "(Optional) Sprites X", "(Optional) Sprites Y", "(Optional) Origin X", "(Optional) Origin Y", "(Optional) Pixel Size"],
		"Flags":["Intermediate"],
		"Types":["str", "str", "int", "int", "int", "int", "int"],
	})
	
	RegisterFunction("SpritesheetFrames", [2], ["Init"], {
		"Description": "Sets the number of frames for the currently selected spritesheet.",
		"Arguments":["Sprites X", "Sprites Y"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("SpriteOrigin", [2], ["Init"], {
		"Description": "Sets a sprite's origin in pixels for the currently selected spritesheet.",
		"Arguments":["Pos X", "Pos Y"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("SpritePixelSize", [1], ["Init"], {
		"Description": "Sets the size of a pixel in units for the currently selected spritesheet. 3D graphics only.",
		"Arguments":["PixelSize"],
		"Flags":["Advanced"],
		"Types":["int"],
	})
	
	RegisterVariableEntity("_SpriteFrame", 0)
	RegisterVariableEntity("_SpriteAnim", "Null")
	# TODO Reduce the amount needed as static
	RegisterConfig("PositionScale", 100)
	#RegisterVariableEntity("_SpritePaletteID", 0, ["InheritToSubentity"])
	RegisterConfig("SpriteScriptPath", "res://castagne/modules/graphics/CMGraphics_Sprite.gd")
	RegisterConfig("SpriteShaderPath", "")
	
	
	# -[CTG_ANIMS]----------------------------------------------------------------------------------
	RegisterCategory("Animations", {"Description":"Functions relating to the animation system. This will be moved later to graphics."})
	RegisterFunction("Anim", [1,2], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and starts at the first frame the function is called. Resets on state change.",
		"Arguments": ["Animation Name", "(Optional) Offset"],
		})
	RegisterFunction("AnimFrame", [2], null, {
		"Description": "Plays an animation frame by frame. The animation updates only when this function is called, and if not specified will use the amount of frames you were in that state..",
		"Arguments": ["Animation Name", "The frame to display"],
		})
	RegisterFunction("AnimProgress", [0,1], null, {
		"Description": "Progresses an already playing animation. Can also be used to scroll.",
		"Arguments": ["(Optional) Amount of frames to progress"],
		})
	RegisterFunction("AnimLoop", [1, 2], null, {
		"Description": "Loops an animation around by setting it to the start point when reaching the specified frame.",
		"Arguments": ["Loop point (exclusive)", "(Optional) Start point of the loop. (Default: 1)"]
	})
	RegisterVariableEntity("_Anim", null, null, {"Description":"Currently playing animation."})
	RegisterVariableEntity("_AnimFrame", 0, null, {"Description":"Current frame of the animation to show."})
	RegisterVariableEntity("_AnimFuncName", "", null, {"Description":"Remembers when the animation started, for the Anim function"})
	RegisterVariableEntity("_AnimFuncOffset", null, null, {"Description":"Remembers an offset for the Anim function"})
	
	
	# -[CTG_CAMERA]---------------------------------------------------------------------------------
	RegisterCategory("Camera")
	
	RegisterFunction("CameraOverrideLookAt", [6, 7, 8, 9], null, {
		"Description": "Sets up a camera override for this frame using the camera position and a target point in space.",
		"Arguments":[
			"Position X", "Position Y", "Position Z",
			"Look At Point X", "Look At Point Y", "Look At Point Z",
			"Roll (Optional)", "FOV (Optional, hundredth of degree)", "Strength (Optional)"
			]
	})
	RegisterFunction("CameraOverrideDirection", [6, 7, 8, 9], null, {
		"Description": "Sets up a camera override for this frame using the camera position and a direction.",
		"Arguments":[
			"Position X", "Position Y", "Position Z",
			"Direction X", "Direction Y", "Direction Z",
			"Roll (Optional)", "FOV (Optional, hundredth of degree)", "Strength (Optional)"
			]
	})
	RegisterFunction("CameraOverrideFixed", [3, 4, 5, 6], null, {
		"Description": "Sets up a camera override for this frame using the camera position. The camera will keep looking forward.",
		"Arguments":[
			"Position X", "Position Y", "Position Z",
			"Roll (Optional, hundredth of degree)", "FOV (Optional, hundredth of degree)", "Strength (Optional, permil)"
			]
	})
	RegisterFunction("CameraOverrideLookAtWorld", [6, 7, 8, 9], null, {
		"Description": "Sets up a camera override for this frame using the camera position in world space and a target point in space.",
		"Arguments":[
			"Position X", "Position Y", "Position Z",
			"Look At Point X", "Look At Point Y", "Look At Point Z",
			"Roll (Optional)", "FOV (Optional)", "Strength (Optional)"
			]
	})
	RegisterFunction("CameraOverrideDirectionWorld", [6, 7, 8, 9], null, {
		"Description": "Sets up a camera override for this frame using the camera position in world space and a direction.",
		"Arguments":[
			"Position X", "Position Y", "Position Z",
			"Direction X", "Direction Y", "Direction Z",
			"Roll (Optional)", "FOV (Optional)", "Strength (Optional)"
			]
	})
	RegisterFunction("CameraOverrideFixedWorld", [3, 4, 5, 6], null, {
		"Description": "Sets up a camera override for this frame using the camera position in world space. The camera will keep looking forward.",
		"Arguments":[
			"Position X", "Position Y", "Position Z",
			"Roll (Optional, hundredth of degree)", "FOV (Optional, hundredth of degree)", "Strength (Optional, permil)"
			]
	})
	RegisterFunction("CameraOverride2D", [2,3,4], null, {
		"Description": "Sets up a camera override for this frame using the camera position. This is a helper that works better for 2D.",
		"Arguments":[
			"Position X", "Position Y",
			"Zoom (Optional, permil)", "Strength (Optional, permil)"
			]
	})
	RegisterFunction("CameraOverride2DWorld", [2,3,4], null, {
		"Description": "Sets up a camera override for this frame using the camera position in world space. This is a helper that works better for 2D.",
		"Arguments":[
			"Position X", "Position Y",
			"Zoom (Optional, permil)", "Strength (Optional, permil)"
			]
	})
	RegisterFunction("CameraOverrideRoll", [1], null, {
		"Description": "Sets a camera override's roll.", "Arguments": ["Roll (hundedth of degree)"]
	})
	RegisterFunction("CameraOverrideFOV", [1], null, {
		"Description": "Sets a camera override's FOV.", "Arguments": ["FOV (hundedth of degree)"]
	})
	RegisterFunction("CameraOverrideZoom", [1], null, {
		"Description": "Sets a camera override's Zoom in 2D.", "Arguments": ["Zoom (permil)"]
	})
	RegisterFunction("CameraOverrideStrength", [1], null, {
		"Description": "Sets a camera override's interpolation strength.", "Arguments": ["Strength (permil)"]
	})
	RegisterFunction("CameraOverridePriority", [1], null, {
		"Description": "Sets the priority for the override, for when several overrides are active at once. Higher will be processed later."
		 + " If two overrides are of the same priority, lower Entity ID will apply last.",
		"Arguments": ["Priority"]
	})
	RegisterFunction("CameraOverrideStop", [0], null, {
		"Description": "Removes a previously set camera override. Camera overrides only stay for one frame."
	})
	
	RegisterFunction("CameraShake", [0,1,2,3], null, {
		"Description": "Shakes the camera for a small amount of time. Still updates during Freeze / Halt.",
		"Arguments":["Strength of shake (Optional)", "Time of shake (Optional)", "Shake Decay Speed (Optional)"]
	})
	
	RegisterVariableEntity("_CameraOverride_PositionX", 0, ["ResetEachFrame"], {"Description":"Camera Position X for Camera Override"})
	RegisterVariableEntity("_CameraOverride_PositionY", 0, ["ResetEachFrame"], {"Description":"Camera Position Y for Camera Override"})
	RegisterVariableEntity("_CameraOverride_PositionZ", 0, ["ResetEachFrame"], {"Description":"Camera Position Z for Camera Override"})
	RegisterVariableEntity("_CameraOverride_LookAtX", 0, ["ResetEachFrame"], {"Description":"Look At Position X for Camera Override"})
	RegisterVariableEntity("_CameraOverride_LookAtY", 0, ["ResetEachFrame"], {"Description":"Look At Position Y for Camera Override"})
	RegisterVariableEntity("_CameraOverride_LookAtZ", 0, ["ResetEachFrame"], {"Description":"Look At Position Z for Camera Override"})
	RegisterVariableEntity("_CameraOverride_Roll", 0, ["ResetEachFrame"], {"Description":"Camera Roll for Camera Override"})
	RegisterVariableEntity("_CameraOverride_FOV", 0, ["ResetEachFrame"], {"Description":"Camera FOV for Camera Override"})
	RegisterVariableEntity("_CameraOverride_Priority", 0, ["ResetEachFrame"], {"Description":"Camera interpolation order priority for Camera Override"})
	RegisterVariableEntity("_CameraOverride_Strength", 0, ["ResetEachFrame"], {"Description":"Interpolation strength for Camera Override"})
	
	RegisterVariableEntity("_CameraShake_StartFrame", 0, null, {"Description":"First frame in camera shake"})
	RegisterVariableEntity("_CameraShake_TotalFrames", 0, null, {"Description":"Frames in camera shake"})
	RegisterVariableEntity("_CameraShake_Strength", 0, null, {"Description":"Strength of camera shake at start"})
	RegisterVariableEntity("_CameraShake_Decay", 0, null, {"Description":"Amount of strength lost per frame in camera shake"})
	
	
	
	RegisterConfig("CameraOffsetX", 0)
	RegisterConfig("CameraOffsetY", 20000)
	RegisterConfig("CameraOffsetZ", 62000)
	RegisterConfig("CameraFOV",  7000)
	
	RegisterConfig("CameraOffsetXClose", 0)
	RegisterConfig("CameraOffsetYClose", 20000)
	RegisterConfig("CameraOffsetZClose", 62000)
	RegisterConfig("CameraFOVClose",  7000)
	
	RegisterConfig("CameraThresholdClose", 20000)
	RegisterConfig("CameraThresholdFar", 50000)
	
	RegisterConfig("CameraYBuffer", 30000)
	
	RegisterConfig("CameraPosMinX", -105000)
	RegisterConfig("CameraPosMaxX",  105000)
	RegisterConfig("CameraPosMinY", -1000000)
	RegisterConfig("CameraPosMaxY",  1000000)
	
	RegisterConfig("CameraFOV_ZoomBase",  7000)
	
	
	RegisterConfig("CameraShake_BaseStrength",  800)
	RegisterConfig("CameraShake_DefaultDuration",  6)
	
	
	# -[CTG_VFX]------------------------------------------------------------------------------------
	RegisterCategory("VFX Test")
	
	RegisterFunction("VFXReset", [0], null, {
		"Description": "Resets the VFX data to a void VFX.",
		"Arguments":[],
	})
	RegisterFunction("VFXModel", [1], null, {
		"Description": "Prepares a VFX model to be shown.",
		"Arguments":["The scene to spawn"],
	})
	RegisterFunction("VFXSprite", [1, 2], null, {
		"Description": "Prepares a VFX model to show a sprite.",
		"Arguments": ["Sprite Animation / Spritesheet", "(Optional) Sprite ID if using spritesheet"],
	})
	RegisterFunction("VFXSpriteCreate", [4, 5], null, {
		"Description":"Helper function to quickly create a simple sprite VFX.",
		"Arguments":["Sprite Animation / Spritesheet", "(Optional) Sprite ID if using spritesheet",
				"Time (frames)", "Position X", "Position Y"],
		})
	RegisterFunction("VFXModelCreate", [4], null, {
		"Description":"Helper function to quickly create a simple sprite VFX.",
		"Arguments":["Model Scene", "Time (frames)", "Position X", "Position Y"],
		})
	
	RegisterFunction("VFXTime", [1], null, {
		"Description": "Sets the amount of time the VFX will be alive.",
		"Arguments": ["Time to exist in frames."],
	})
	RegisterFunction("VFXPerpetual", [0], null, {
		"Description": "Makes the VFX not expire until its parent entity does.",
	})
	RegisterFunction("VFXPosition", [2,3], null, {
		"Description": "Sets the VFX's position.",
		"Arguments": ["Position X", "Position Y", "Position Z (Optional)"],
	})
	RegisterFunction("VFXPositionAbsolute", [2,3], null, {
		"Description": "Sets the VFX's position in absolute space.",
		"Arguments": ["Position X", "Position Y", "Position Z (Optional)"],
	})
	RegisterFunction("VFXPositionWorld", [2,3], null, {
		"Description": "Sets the VFX's position in world space.",
		"Arguments": ["Position X", "Position Y", "Position Z (Optional)"],
	})
	RegisterFunction("VFXMove", [2,3], null, {
		"Description": "Moves the VFX linearly.",
		"Arguments": ["Speed X", "Speed Y", "Speed Z (Optional)"],
	})
	RegisterFunction("VFXMoveAbsolute", [2,3], null, {
		"Description": "Moves the VFX linearly in absolute space.",
		"Arguments": ["Speed X", "Speed Y", "Speed Z (Optional)"],
	})
	RegisterFunction("VFXAccel", [2,3], null, {
		"Description": "Moves the VFX quadratically.",
		"Arguments": ["Acceleration X", "Acceleration Y", "Acceleration Z (Optional)"],
	})
	RegisterFunction("VFXAccelAbsolute", [2,3], null, {
		"Description": "Moves the VFX quadratically in absolute space.",
		"Arguments": ["Acceleration X", "Acceleration Y", "Acceleration Z (Optional)"],
	})
	RegisterFunction("VFXRotation", [1], null, {
		"Description": "Sets the VFX's rotation.",
		"Arguments": ["The rotation in tenths of degrees."],
	})
	RegisterFunction("VFXScale", [1], null, {
		"Description": "Sets the VFX's scale.",
		"Arguments": ["Scale in permil."],
	})
	RegisterFunction("VFXZOrder", [1], null, {
		"Description": "Sets the Z Order of the VFX.",
		"Arguments": ["Coarse Z Order in [-39, 39]", "(Optional) Fine Z Order in [-49 ; 50]"],
	})
	RegisterFunction("VFXZOrderFine", [1], null, {
		"Description": "Sets the fine Z Order of the VFX.",
		"Arguments": ["Fine Z Order in [-49 ; 50]"],
	})
	RegisterFunction("VFXAnimation", [1,2], null, {
		"Description": "Sets the animation of the VFX.",
		"Arguments": ["Animation Name", "(Optional) Path to animation player"],
	})
	RegisterFunction("VFXFacing", [0,1], null, {
		"Description": "Sets the facing of the VFX relative to the character.",
		"Arguments": ["Facing relative to the character (Default: 1)"],
	})
	RegisterFunction("VFXFacingAbsolute", [0, 1], null, {
		"Description": "Sets the facing of the VFX relative to the world.",
		"Arguments": ["Facing (Default: 1)"],
	})
	RegisterFunction("VFXFlipFacing", [0], null, {
		"Description": "Flips the horizontal facing of the VFX.",
	})
	RegisterFunction("VFXLockToEntity", [0,1], null, {
		"Description": "Makes the VFX locked to the entity. Use the argument to reverse.",
		"Arguments": ["Should lock to the entity (default: 1)"],
	})
	RegisterFunction("VFXUnlockFromEntity", [0], null, {
		"Description": "Unlocks the VFX from the entity.",
	})
	
	RegisterFunction("VFXParam", [2,3,4], null, {
		"Description": "Sets a parameter function of the form c+bt+at², with t as the number of frames since spawning.",
		"Arguments": ["Parameter Name", "C, constant part", "(Optional) B, linear part", "(Optional) A, squared part"]
	})
	RegisterFunction("VFXOverride", [2], null, {
		"Description": "Copies a variable every frame from the entity to the VFX.",
		"Arguments": ["Entity Variable Name", "VFX Parameter Name"],
	})
	
	RegisterFunction("VFXCreate", [0], null, {
		"Description":"Creates the prepared VFX.",
	})
	
	RegisterVariableEntity("_PreparingVFX", {})
	RegisterVariableGlobal("_VFXList", [])
	
	
	# -[CTG_PALETTES]-------------------------------------------------------------------------------
	RegisterCategory("Palettes")
	
	RegisterFunction("PaletteApply", [0, 1], null, {
		"Description":"Sets the variables to the values given by the palette settings.",
		"Args":["(Optional) Palette ID to apply (default: selected palette)"],
	})
	
	RegisterFunction("PaletteSprite", [1], null, {
		"Description":"Changes the active sprite palette to the one given.",
		"Args":["The path to the palette lookup texture."],
	})
	
	RegisterVariableEntity("_PaletteID", 0, ["InheritToSubentity"], {"Description":"Current palette ID."})
	RegisterVariableEntity("_SpritePalettePath", "res://castagne/assets/helpers/palette/PaletteManual01.png", ["InheritToSubentity"],{
		"Description":"Path to the sprite palette lookup texture.",
	})
	RegisterVariableEntity("_ModelPath", "res://castagne/assets/fighters/castagneur/CastagneurModel.tscn", ["InheritToSubentity"], {
		"Description":"Path to the model to spawn, set by the palette",
	})
	RegisterVariableEntity("_PaletteExtra", 0, ["InheritToSubentity"], {"Description":"Extra palette parameter."})
	RegisterVariableEntity("_Tmp_DefaultSpritePalettePath", "res://castagne/assets/helpers/palette/PaletteManual01.png", ["InheritToSubentity"])
	RegisterVariableEntity("_Tmp_DefaultModelPath", "res://castagne/assets/fighters/castagneur/CastagneurModel.tscn", ["InheritToSubentity"])
	
	
	
	# -[CTG_UI]-------------------------------------------------------------------------------------
	RegisterCategory("UI")
	
	RegisterConfig("UIGlobalRootScene", "res://castagne/helpers/ui/roots/CUIGlobalRoot-Fighting.tscn")
	RegisterConfig("UIPlayerRootScene", "res://castagne/helpers/ui/roots/CUIPlayerRoot-Fighting.tscn")
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Player, "uiplayerroot-path", null)
	RegisterBattleInitData(Castagne.MEMORY_STACKS.Player, "uiplayerroot-use", true)
	RegisterConfig("UIDefaultWidget_Bar", "res://castagne/helpers/ui/widgets/default/DefaultWidgetBar.tscn")
	RegisterConfig("UIDefaultWidget_Icons", "res://castagne/helpers/ui/widgets/default/DefaultWidgetIcons.tscn")
	RegisterConfig("UIDefaultWidget_IconSwitch", "res://castagne/helpers/ui/widgets/default/DefaultWidgetIconSwitch.tscn")
	RegisterConfig("UIDefaultWidget_Text", "res://castagne/helpers/ui/widgets/default/DefaultWidgetText.tscn")
	
	# -[CTG_INTERNALS]------------------------------------------------------------------------------

func BattleInit(stateHandle, battleInitData):
	graphicsRoot = _CreateGraphicsRootNode(engine)
	var config = stateHandle.ConfigData()
	
	var camera = _InitCamera(stateHandle, battleInitData)
	graphicsRoot.add_child(camera)
	#engine.graphicsModule = self
	
	POSITION_SCALE = config.Get("PositionScale") / 1000000.0
	
	stateHandle.IDGlobalSet("GraphicsRoot", graphicsRoot)
	stateHandle.IDGlobalSet("Camera", camera)
	lastRegisteredCamera = camera
	
	cameraOffsetFar = Vector3(config.Get("CameraOffsetX"), config.Get("CameraOffsetY"), config.Get("CameraOffsetZ"))
	cameraOffsetClose = Vector3(config.Get("CameraOffsetXClose"), config.Get("CameraOffsetYClose"), config.Get("CameraOffsetZClose"))
	cameraThresholdFar = config.Get("CameraThresholdFar")
	cameraThresholdClose = config.Get("CameraThresholdClose")
	
	var prefabMap = Castagne.Loader.Load(Castagne.SplitStringToArray(config.Get("StagePaths"))[battleInitData["map"]])
	var map = prefabMap.instance()
	graphicsRoot.add_child(map)
	stateHandle.IDGlobalSet("map", map)
	
	stateHandle.IDGlobalSet("VFXState", [])
	
	var uiRoot = null
	var uiRootScenePath = config.Get("UIGlobalRootScene")
	if(!uiRootScenePath.empty()):
		var uiRootScenePacked = Castagne.Loader.Load(uiRootScenePath)
		if(uiRootScenePacked != null):
			uiRoot = uiRootScenePacked.instance()
			stateHandle.Engine().add_child(uiRoot)
			uiRoot.UIInitialize(stateHandle, battleInitData)
		else:
			ModuleError("Graphics: Can't instance UI Root at path "+str(uiRootScenePath))
	stateHandle.IDGlobalSet("UIRoot", uiRoot)

func FrameStart(stateHandle):
	var vfxList = stateHandle.GlobalGet("_VFXList")
	var newVFXList = []
	for v in vfxList:
		var newV = _VFXUpdate_FrameStart(stateHandle, v)
		if(newV != null):
			newVFXList.push_back(newV)
	stateHandle.GlobalSet("_VFXList", newVFXList)


func OnStateTransitionEntity(stateHandle, _previousStateName, _newStateName):
	stateHandle.EntitySet("_AnimFuncName", "")
	stateHandle.EntitySet("_AnimFuncOffset", 0)


func InitPhaseStartEntity(stateHandle):
	var spriteData = {
		"Null": _CreateSpriteData()
	}
	stateHandle.IDEntitySet("SpriteData", spriteData)
	
	# Spritesheets
	var spriteIData = stateHandle.IDEntityGet("TD_Graphics")
	var spritesheetData = spriteIData["Spritesheets"]
	for spritesheetName in spritesheetData:
		var s = spritesheetData[spritesheetName]
		SpritesheetRegister([
			spritesheetName, s["Path"],
			s["SpritesX"], s["SpritesY"],
			s["OriginX"], s["OriginY"],
			s["PixelSize"], s["PaletteMode"]
		], stateHandle)
	
	# UI
	var uiData = stateHandle.IDEntityGet("TD_UI")
	var entityName = stateHandle.EntityGet("_Entity")
	if(uiData["Defines"]["UI_UseWidgets"] and entityName == null):
		var widgetsData = uiData["Widgets"]
		for wName in widgetsData:
			var w = widgetsData[wName]
			if(!w["UseWidget"]):
				continue
			UI_SpawnWidgetFromData(stateHandle, w)
	
	VFXReset([], stateHandle)


func ActionPhaseStartEntity(stateHandle):
	_ResetVFXData(stateHandle)


func PhysicsPhaseStartEntity(stateHandle):
	if(!stateHandle.EntityHasFlag("ModelLockWorldPosition")):
		if(stateHandle.EntityHasFlag("ModelLockRelativePosition")):
			stateHandle.EntityAdd("_ModelPositionX", stateHandle.EntityGet("_MovementX"))
			stateHandle.EntityAdd("_ModelPositionY", stateHandle.EntityGet("_MovementY"))
		else:
			stateHandle.EntitySet("_ModelPositionX", stateHandle.EntityGet("_PositionX"))
			stateHandle.EntitySet("_ModelPositionY", stateHandle.EntityGet("_PositionY"))


var lastRegisteredCamera = null
var cameraOffsetClose = Vector3()
var cameraOffsetFar = Vector3()
var cameraThresholdClose = 0
var cameraThresholdFar = 0
var _CAMERA_DIRECTION_LOOKAT_DISTANCE = 1000
func UpdateGraphics(stateHandle):
	var cameraOverrideStack = []
	var cameraShakeStrength = 0
	var currentFrame = stateHandle.GlobalGet("_FrameID")
	
	# Update entities
	for eid in stateHandle.GlobalGet("_ActiveEntities"):
		stateHandle.PointToEntity(eid)
		
		# Camera information gathering
		var co = _CameraOverrides_GatherOverrides(stateHandle)
		if(co != null):
			cameraOverrideStack.push_back(co)
		var cameraShakeStartFrame = stateHandle.EntityGet("_CameraShake_StartFrame")
		var cameraShakeTotalFrames = stateHandle.EntityGet("_CameraShake_TotalFrames")
		if(cameraShakeStartFrame+cameraShakeTotalFrames > currentFrame):
			var camShake = stateHandle.EntityGet("_CameraShake_Strength") - stateHandle.EntityGet("_CameraShake_Decay") * (currentFrame - cameraShakeStartFrame)
			if(camShake > cameraShakeStrength):
				cameraShakeStrength = camShake
		
		# Sprite update
		var sprite = stateHandle.IDEntityGet("Sprite")
		if(sprite != null):
			_UpdateSprite(sprite, stateHandle)
		
		# Animation update
		var anim = stateHandle.EntityGet("_Anim")
		var animPlayer = stateHandle.IDEntityGet("AnimPlayer")
		if(anim != null and animPlayer != null):
			var animFrameID = stateHandle.EntityGet("_AnimFrame")
			if(animPlayer.has_animation(anim)):
				animPlayer.play(anim, 0.0, 0.0)
				animPlayer.seek(float(animFrameID-1)/60.0, true)
			else:
				ModuleError("Animation " + anim + " doesn't exist.", stateHandle)
		
		# Model update
		var modelPosition = [stateHandle.EntityGet("_ModelPositionX"), stateHandle.EntityGet("_ModelPositionY"), 0]
		var modelRotation = stateHandle.EntityGet("_ModelRotation")
		var modelScale = stateHandle.EntityGet("_ModelScale")
		
		var modelRoot = stateHandle.IDEntityGet("Root")
		if(modelRoot != null):
			_ModelApplyTransform(stateHandle, modelRoot, modelPosition, modelRotation, modelScale)
	
	
	# Compute camera position
	var camera = stateHandle.IDGlobalGet("Camera")
	var playerPosCenter = Vector3(stateHandle.GlobalGet("_CameraX"), stateHandle.GlobalGet("_CameraY") - stateHandle.ConfigData().Get("CameraYBuffer"), 0)
	var playerDist = 0
	if(stateHandle.GlobalGet("_NbPlayers") >= 2):
		stateHandle.PointToPlayerMainEntity(0)
		var p1X = stateHandle.EntityGet("_PositionX")
		stateHandle.PointToPlayerMainEntity(1)
		var p2X = stateHandle.EntityGet("_PositionX")
		playerDist = abs(p1X - p2X)
	
	if(playerPosCenter.y < 0):
		playerPosCenter.y = 0.0
	
	var cameraOffsetT = clamp((playerDist - cameraThresholdClose)/max(1, cameraThresholdFar-cameraThresholdClose), 0, 1)
	var cameraOffset = cameraOffsetClose.linear_interpolate(cameraOffsetFar, cameraOffsetT)
	var cameraFOV = float(stateHandle.ConfigData().Get("CameraFOV")) / 100.0
	var cameraFOVClose = float(stateHandle.ConfigData().Get("CameraFOVClose")) / 100.0
	cameraFOV = lerp(cameraFOVClose, cameraFOV, cameraOffsetT)
	
	var cameraPosRegular = playerPosCenter
	cameraPosRegular.x = clamp(cameraPosRegular.x, stateHandle.ConfigData().Get("CameraPosMinX"), stateHandle.ConfigData().Get("CameraPosMaxX"))
	cameraPosRegular.y = clamp(cameraPosRegular.y, stateHandle.ConfigData().Get("CameraPosMinY"), stateHandle.ConfigData().Get("CameraPosMaxY"))
	cameraPosRegular += cameraOffset
	cameraPosRegular = IngameToGodotPos(cameraPosRegular)
	
	
	cameraOverrideStack.sort_custom(self, "_CameraOverrides_Sort")
	var cameraPos = cameraPosRegular
	var cameraLookAtPoint = cameraPosRegular
	if(!IS_2D):
		cameraLookAtPoint -= Vector3(0,0,_CAMERA_DIRECTION_LOOKAT_DISTANCE*POSITION_SCALE)
	var cameraRoll = 0.0
	var cameraExtra = null
	
	for co in cameraOverrideStack:
		var coStrength = co[0] / 1000.0
		var coPos = IngameToGodotPos([co[3], co[4], co[5]])
		var coLookAt = IngameToGodotPos([co[6], co[7], co[8]])
		var coFOV = float(co[9]) / 100.0
		var coRoll = deg2rad(float(co[10]) / 100.0)
		cameraPos = lerp(cameraPos, coPos, coStrength)
		cameraLookAtPoint = lerp(cameraLookAtPoint, coLookAt, coStrength)
		cameraFOV = lerp(cameraFOV, coFOV, coStrength)
		cameraRoll = lerp_angle(cameraRoll, coRoll, coStrength)
		cameraExtra = _CameraOverrides_OverrideMergeExtra(cameraExtra, co)
		
	if(!IS_2D and (cameraPos-cameraLookAtPoint).length_squared() <= 2.0*POSITION_SCALE):
		cameraLookAtPoint = cameraPos - Vector3(0,0,_CAMERA_DIRECTION_LOOKAT_DISTANCE*POSITION_SCALE)
	
	_UpdateCamera(stateHandle, camera, cameraPos, cameraLookAtPoint, cameraFOV, cameraRoll, cameraShakeStrength, cameraExtra)
	stateHandle.GlobalSet("_GraphicsCamPos", cameraPos)
	
	
	
	# Update VFX and UI
	for vfx in stateHandle.GlobalGet("_VFXList"):
		_VFXUpdate_UpdateGraphics(stateHandle, vfx)
	
	var uiRoot = stateHandle.IDGlobalGet("UIRoot")
	if(uiRoot != null):
		uiRoot.UIUpdate(stateHandle)
	
func _CameraOverrides_Sort(a, b):
	if(a[1] != b[1]): # Priority: highest at the end
		return a[1] < b[1]
	return a[2] >= b[2] # EID: lowest at the end
func _CameraOverrides_GatherOverrides(stateHandle):
	var camOverrideStrength = stateHandle.EntityGet("_CameraOverride_Strength")
	if(camOverrideStrength <= 0):
		return null
	return [
		camOverrideStrength, stateHandle.EntityGet("_CameraOverride_Priority"), stateHandle.EntityGet("_EID"),
		stateHandle.EntityGet("_CameraOverride_PositionX"), stateHandle.EntityGet("_CameraOverride_PositionY"), stateHandle.EntityGet("_CameraOverride_PositionZ"),
		stateHandle.EntityGet("_CameraOverride_LookAtX"), stateHandle.EntityGet("_CameraOverride_LookAtY"), stateHandle.EntityGet("_CameraOverride_LookAtZ"),
		stateHandle.EntityGet("_CameraOverride_FOV"), stateHandle.EntityGet("_CameraOverride_Roll")
	]
func _CameraOverrides_OverrideMergeExtra(cameraExtra, _cameraOverride):
	return cameraExtra










# -[CTG_MODEL]--------------------------------------------------------------------------------------
func ModelCreate(args, stateHandle):
	_EnsureRootIsSet(stateHandle)
	var animPath = (ArgStr(args, stateHandle, 1) if args.size() > 1 else null)
	engine.InstanceModel(stateHandle.EntityGet("_EID"), ArgStr(args, stateHandle, 0), animPath) # TODO Needs a new system here I think
func ModelScale(args, stateHandle):
	stateHandle.EntitySet("_ModelScale", ArgInt(args, stateHandle, 0))
func ModelRotation(args, stateHandle):
	stateHandle.EntitySet("_ModelRotation", ArgInt(args, stateHandle, 0))
func ModelMove(args, stateHandle):
	stateHandle.EntityAdd("_ModelPositionX", stateHandle.EntityGet("_FacingHModel")*ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_ModelPositionY", ArgInt(args, stateHandle, 1, 0))
func ModelMoveAbsolute(args, stateHandle):
	stateHandle.EntityAdd("_ModelPositionX", ArgInt(args, stateHandle, 0))
	stateHandle.EntityAdd("_ModelPositionY", ArgInt(args, stateHandle, 1, 0))
#func ModelSwitchFacing(_args, stateHandle):
#	stateHandle.EntitySet("_ModelFacing") # In physics maybe ?

func ModelZOrder(args, stateHandle):
	var zOrderCoarse = ArgInt(args, stateHandle, 0)
	var zOrderFine = null
	if(args.size() >= 2):
		zOrderFine = ArgInt(args, stateHandle, 1)
	_ModelZOrderSet(stateHandle, zOrderCoarse, zOrderFine)
func ModelZOrderFine(args, stateHandle):
	_ModelZOrderSet(stateHandle, null, ArgInt(args, stateHandle, 0))
func _ModelZOrderSet(stateHandle, zOrderCoarse = null, zOrderFine = null):
	if(zOrderCoarse == null or zOrderFine == null):
		var zOrderInitial = stateHandle.EntityGet("_ModelZOrder")
		zOrderInitial += 49
		if(zOrderCoarse == null):
			zOrderCoarse = zOrderInitial / 100
		if(zOrderFine == null):
			zOrderFine = (zOrderInitial % 100) - 49
	
	var zOrder = zOrderCoarse * 100 + zOrderFine
	stateHandle.EntitySet("_ModelZOrder", zOrder)
	if(zOrder < VisualServer.CANVAS_ITEM_Z_MIN or zOrder > VisualServer.CANVAS_ITEM_Z_MAX):
		ModuleError("Sprite order out of bounds: " + str(zOrder) + " is outside of ["+str(VisualServer.CANVAS_ITEM_Z_MIN)+", "+str(VisualServer.CANVAS_ITEM_Z_MAX)+"]!", stateHandle)

func ModelShaderParamI(args, stateHandle):
	var paramName = ArgRaw(args, 0)
	var value = _ModelSetShaderParam_GetParams(args, stateHandle)
	_ModelSetShaderParam(stateHandle, paramName, value)
func ModelShaderParamF(args, stateHandle):
	var paramName = ArgRaw(args, 0)
	var values = _ModelSetShaderParam_GetParams(args, stateHandle, 0.001)
	_ModelSetShaderParam(stateHandle, paramName, values)
func _ModelSetShaderParam_GetParams(args, stateHandle, multiplier = 1):
	var nbArgs = args.size() - 1
	var value1 = ArgInt(args, stateHandle, 1, 0) * multiplier
	var value2 = ArgInt(args, stateHandle, 2, 0) * multiplier
	var value3 = ArgInt(args, stateHandle, 3, 0) * multiplier
	var value4 = ArgInt(args, stateHandle, 4, 0) * multiplier
	
	if(nbArgs == 2):
		return Vector2(value1, value2)
	if(nbArgs == 3):
		return Vector3(value1, value2, value3)
	if(nbArgs == 4):
		return Rect2(value1, value2, value3, value4) # No Vector4 at the moment
	return value1
func _ModelSetShaderParam(stateHandle, paramName, value, modelRoot = null):
	if(modelRoot == null):
		modelRoot = stateHandle.IDEntityGet("Root")
	if(modelRoot == null):
		ModuleError("ModelSetShaderParam: Can't find model root.", stateHandle)
		return
	
	for c in modelRoot.get_children():
		_ModelSetShaderParam(stateHandle, paramName, value, c)
	
	var material = null
	if(modelRoot.has_method("get_material_override")):
		material = modelRoot.get_material_override()
	if(material == null and modelRoot.has_method("get_material")):
		material = modelRoot.get_material()
		
	
	if(material == null):
		#ModuleError("ModelSetShaderParam: Can't get material.", stateHandle)
		return
	material.set_shader_param(paramName, value)
	
	if(modelRoot.has_method("set_material")):
		modelRoot.set_material(material)

func ModelVisibility(args, stateHandle):
	var visible = ArgBool(args, stateHandle, 0)
	var modelRoot = stateHandle.IDEntityGet("Root")
	if(modelRoot.has_method("set_visible")):
		modelRoot.set_visible(visible)
func ModelVisibilityPath(args, stateHandle):
	var path = ArgStr(args, stateHandle, 0)
	var visible = ArgBool(args, stateHandle, 1)
	var modelRoot = stateHandle.IDEntityGet("Root")
	if(modelRoot.has_node(path)):
		var node = modelRoot.get_node(path)
		if(node.has_method("set_visible")):
			node.set_visible(visible)
	else:
		ModuleError("ModelVisibilityPart: Can't find node "+str(path), stateHandle)
func ModelVisibilityPattern(args, stateHandle):
	var pattern = ArgStr(args, stateHandle, 0)
	var visible = ArgBool(args, stateHandle, 1)
	var modelRoot = stateHandle.IDEntityGet("Root")
	_ModelVisibilityPattern_Recursive(pattern, visible, modelRoot)
func _ModelVisibilityPattern_Recursive(pattern, visible, root):
	for node in root.get_children():
		var nodeName = node.get_name()
		if(pattern in nodeName):
			if(node.has_method("set_visible")):
				node.set_visible(visible)
		_ModelVisibilityPattern_Recursive(pattern, visible, node)


# -[CTG_SPRITES]------------------------------------------------------------------------------------
func Sprite(args, stateHandle):
	stateHandle.EntitySet("_Anim", null)
	if(args.size() == 1):
		stateHandle.EntitySet("_SpriteFrame", ArgInt(args, stateHandle, 0))
	else:
		stateHandle.EntitySet("_SpriteAnim", ArgStr(args, stateHandle, 0))
		stateHandle.EntitySet("_SpriteFrame", ArgInt(args, stateHandle, 1))
func SpriteProgress(args, stateHandle):
	stateHandle.EntitySet("_Anim", null)
	stateHandle.EntityAdd("_SpriteFrame", ArgInt(args, stateHandle, 0, 1))

func SpriteCreate(_args, stateHandle):
	var sprite = _CreateSprite_Instance(stateHandle)
	sprite.Initialize(stateHandle, sprite)
	
	_EnsureRootIsSet(stateHandle)
	stateHandle.IDEntityGet("Root").add_child(sprite)
	stateHandle.IDEntitySet("Sprite", sprite)
	if(sprite.has_node("AnimationPlayer")):
		var animPlayer = sprite.get_node("AnimationPlayer")
		stateHandle.IDEntitySet("AnimPlayer", animPlayer)
		#_CreateSpriteAnims(stateHandle, sprite, animPlayer)

func _CreateSpriteData():
	return {
		"Name":"Null",
		"SpritesheetPath":"null",
		"Spritesheet":null,
		"SpritesX":1, "SpritesY":1,
		"OriginX":1, "OriginY":1,
		"PixelSize":100000, "PaletteMode": 0,
	}

func _GetCurrentSpriteData(stateHandle):
	var spriteDataHolder = stateHandle.IDEntityGet("SpriteData")
	var spriteData = null
	var spriteAnim = stateHandle.EntityGet("_SpriteAnim")
	
	if(spriteDataHolder.has(spriteAnim)):
		spriteData = spriteDataHolder[spriteAnim]
	else:
		spriteData = _CreateSpriteData()
	return spriteData

func SpritesheetRegister(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle).duplicate()
	spriteData["Name"] = ArgStr(args, stateHandle, 0)
	spriteData["SpritesheetPath"] = ArgStr(args, stateHandle, 1)
	spriteData["SpritesX"] = ArgInt(args, stateHandle, 2, spriteData["SpritesX"])
	spriteData["SpritesY"] = ArgInt(args, stateHandle, 3, spriteData["SpritesY"])
	spriteData["OriginX"] = ArgInt(args, stateHandle, 4, spriteData["OriginX"])
	spriteData["OriginY"] = ArgInt(args, stateHandle, 5, spriteData["OriginY"])
	spriteData["PixelSize"] = ArgInt(args, stateHandle, 6, spriteData["PixelSize"])/10000.0
	spriteData["PaletteMode"] = ArgInt(args, stateHandle, 7, spriteData["PaletteMode"])
	spriteData["Spritesheet"] = Castagne.Loader.Load(spriteData["SpritesheetPath"])
	stateHandle.IDEntityGet("SpriteData")[spriteData["Name"]] = spriteData
	stateHandle.EntitySet("_SpriteAnim", spriteData["Name"])
	stateHandle.EntitySet("_SpriteFrame", 0)

func SpritesheetFrames(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle)
	spriteData["SpritesX"] = ArgInt(args, stateHandle, 0)
	spriteData["SpritesY"] = ArgInt(args, stateHandle, 1)

func SpriteOrigin(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle)
	spriteData["OriginX"] = ArgInt(args, stateHandle, 0)
	spriteData["OriginY"] = ArgInt(args, stateHandle, 1)

func SpritePixelSize(args, stateHandle):
	var spriteData = _GetCurrentSpriteData(stateHandle)
	spriteData["PixelSize"] = ArgInt(args, stateHandle, 0)






# -[CTG_ANIMS]--------------------------------------------------------------------------------------
func Anim(args, stateHandle):
	var newAnim = ArgStr(args, stateHandle, 0)
	var offset = ArgInt(args, stateHandle, 1, 0)
	
	# Check if its the same animation as last call (reset on transition)
	if(newAnim == stateHandle.EntityGet("_AnimFuncName") and offset == stateHandle.EntityGet("_AnimFuncOffset")):
		stateHandle.EntityAdd("_AnimFrame", 1)
	else:
		stateHandle.EntitySet("_AnimFuncName", newAnim)
		stateHandle.EntitySet("_AnimFuncOffset", offset)
		stateHandle.EntitySet("_Anim", newAnim)
		stateHandle.EntitySet("_AnimFrame", stateHandle.EntityGet("_StateFrameID") - offset)
func AnimFrame(args, stateHandle):
	stateHandle.EntitySet("_Anim", ArgStr(args, stateHandle, 0))
	stateHandle.EntitySet("_AnimFrame", ArgInt(args, stateHandle, 1))
	stateHandle.EntitySet("_AnimFuncName", "")
	stateHandle.EntitySet("_AnimFuncOffset", 0)
func AnimProgress(args, stateHandle):
	stateHandle.EntityAdd("_AnimFrame", ArgInt(args, stateHandle, 0, 1))
func AnimLoop(args, stateHandle):
	var loopPointEnd = ArgInt(args, stateHandle, 0)
	var loopPointStart = ArgInt(args, stateHandle, 1, 1)
	var loopSpan = max(loopPointEnd - loopPointStart, 1)
	
	var frame = stateHandle.EntityGet("_AnimFrame")
	if(frame >= loopPointEnd):
		frame = ((frame - loopPointStart) % loopSpan) + loopPointStart
		stateHandle.EntitySet("_AnimFrame", frame)










# -[CTG_CAMERA]-------------------------------------------------------------------------------------

func CameraOverrideLookAt(args, stateHandle, useEntitySpace = true):
	_CameraOverrideCommon(args, stateHandle, useEntitySpace)
	var lookAtPos = [ArgInt(args, stateHandle, 3), ArgInt(args, stateHandle, 4), ArgInt(args, stateHandle, 5)]
	if(useEntitySpace):
		var physicsModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS)
		lookAtPos = physicsModule.TransformPosEntityToWorld(lookAtPos, stateHandle)
	stateHandle.EntitySet("_CameraOverride_LookAtX", lookAtPos[0])
	stateHandle.EntitySet("_CameraOverride_LookAtY", lookAtPos[1])
	stateHandle.EntitySet("_CameraOverride_LookAtZ", lookAtPos[2])
func CameraOverrideLookAtWorld(args, stateHandle):
	CameraOverrideLookAt(args, stateHandle, false)
func CameraOverrideDirection(args, stateHandle, useEntitySpace = true):
	_CameraOverrideCommon(args, stateHandle, useEntitySpace)
	
	# Not deterministic maybe ? but only graphics so it's okay
	var direction = Vector3(ArgInt(args, stateHandle, 3),ArgInt(args, stateHandle, 4),ArgInt(args, stateHandle, 5))
	direction = direction.normalized() * _CAMERA_DIRECTION_LOOKAT_DISTANCE
	direction = [int(direction[0]), int(direction[1]), int(direction[2])]
	
	if(useEntitySpace):
		var physicsModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS)
		direction = physicsModule.TransformPosEntityToAbsolute(direction, stateHandle)
	
	stateHandle.EntitySet("_CameraOverride_LookAtX", stateHandle.EntityGet("_CameraOverride_PositionX")+direction[0])
	stateHandle.EntitySet("_CameraOverride_LookAtY", stateHandle.EntityGet("_CameraOverride_PositionY")+direction[1])
	stateHandle.EntitySet("_CameraOverride_LookAtZ", stateHandle.EntityGet("_CameraOverride_PositionZ")+direction[2])
func CameraOverrideDirectionWorld(args, stateHandle):
	CameraOverrideDirection(args, stateHandle, false)
func CameraOverrideFixed(args, stateHandle, useEntitySpace = true):
	_CameraOverrideCommon(args, stateHandle, useEntitySpace, 3)
	stateHandle.EntitySet("_CameraOverride_LookAtX", stateHandle.EntityGet("_CameraOverride_PositionX"))
	stateHandle.EntitySet("_CameraOverride_LookAtY", stateHandle.EntityGet("_CameraOverride_PositionY"))
	stateHandle.EntitySet("_CameraOverride_LookAtZ", stateHandle.EntityGet("_CameraOverride_PositionZ")-_CAMERA_DIRECTION_LOOKAT_DISTANCE)
func CameraOverrideFixedWorld(args, stateHandle):
	CameraOverrideFixed(args, stateHandle, false)
func CameraOverride2D(args, stateHandle, useEntitySpace = true):
	var physicsModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS)
	var pos = [ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1), 0]
	if(useEntitySpace):
		pos = physicsModule.TransformPosEntityToWorld(pos, stateHandle)
	stateHandle.EntitySet("_CameraOverride_PositionX", pos[0])
	stateHandle.EntitySet("_CameraOverride_PositionY", pos[1])
	stateHandle.EntitySet("_CameraOverride_Strength", ArgInt(args, stateHandle, 3, 1000))
	var zoom = ArgInt(args, stateHandle, 2, 1000)
	zoom = (zoom * stateHandle.ConfigData().Get("CameraFOV_ZoomBase")) / 1000
	stateHandle.EntitySet("_CameraOverride_FOV", zoom)
func CameraOverride2DWorld(args, stateHandle):
	CameraOverride2D(args, stateHandle, false)

func _CameraOverrideCommon(args, stateHandle, useEntitySpace=true, lastParamsStart = 6):
	var physicsModule = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS)
	var pos = [ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1), ArgInt(args, stateHandle, 2)]
	if(useEntitySpace):
		pos = physicsModule.TransformPosEntityToWorld(pos, stateHandle)
	stateHandle.EntitySet("_CameraOverride_PositionX", pos[0])
	stateHandle.EntitySet("_CameraOverride_PositionY", pos[1])
	stateHandle.EntitySet("_CameraOverride_PositionZ", pos[2])
	stateHandle.EntitySet("_CameraOverride_Roll", ArgInt(args, stateHandle, lastParamsStart+0, 0))
	stateHandle.EntitySet("_CameraOverride_FOV", ArgInt(args, stateHandle, lastParamsStart+1, 0))
	stateHandle.EntitySet("_CameraOverride_Strength", ArgInt(args, stateHandle, lastParamsStart+2, 1000))

func CameraOverrideRoll(args, stateHandle):
	stateHandle.EntitySet("_CameraOverride_Roll", ArgInt(args, stateHandle, 0))
func CameraOverrideFOV(args, stateHandle):
	stateHandle.EntitySet("_CameraOverride_FOV", ArgInt(args, stateHandle, 0))
func CameraOverrideZoom(args, stateHandle):
	stateHandle.EntitySet("_CameraOverride_FOV", (ArgInt(args, stateHandle, 0) * stateHandle.ConfigData().Get("CameraFOV_ZoomBase")) / 1000)
func CameraOverridePriority(args, stateHandle):
	stateHandle.EntitySet("_CameraOverride_Priority", ArgInt(args, stateHandle, 0))
func CameraOverrideStrength(args, stateHandle):
	stateHandle.EntitySet("_CameraOverride_Strength", ArgInt(args, stateHandle, 0))
func CameraOverrideStop(_args, stateHandle):
	stateHandle.EntitySet("_CameraOverride_Strength", 0)

func CameraShake(args, stateHandle):
	var shakeStrength = ArgInt(args, stateHandle, 0, 1000)
	var shakeTime = ArgInt(args, stateHandle, 1, stateHandle.ConfigData().Get("CameraShake_DefaultDuration"))
	if(shakeTime <= 0):
		shakeTime = 1
	var shakeDefaultDecay = shakeStrength / shakeTime
	stateHandle.EntitySet("_CameraShake_StartFrame", stateHandle.GlobalGet("_FrameID"))
	stateHandle.EntitySet("_CameraShake_TotalFrames", shakeTime)
	stateHandle.EntitySet("_CameraShake_Strength", shakeStrength)
	stateHandle.EntitySet("_CameraShake_Decay", ArgInt(args, stateHandle, 2, shakeDefaultDecay))









# -[CTG_VFX]----------------------------------------------------------------------------------------
func VFXReset(_args, stateHandle):
	_ResetVFXData(stateHandle)

func VFXModel(args, stateHandle):
	var vfxName = ArgStr(args, stateHandle, 0)
	_VFXSetSingle(stateHandle, "ScenePath", vfxName)
	_VFXSetSingle(stateHandle, "IsSprite", false)
func VFXSprite(args, stateHandle):
	_VFXSetSingle(stateHandle, "ScenePath", null)
	_VFXSetSingle(stateHandle, "IsSprite", true)
	var spriteFrame = 0
	var spriteSheet = null
	var spriteAnim = null
	if(args.size() == 1):
		spriteAnim = ArgStr(args, stateHandle, 0)
	else:
		spriteSheet = ArgStr(args, stateHandle, 0)
		spriteFrame = ArgInt(args, stateHandle, 1)
	_VFXSetSingle(stateHandle, "SpriteFrame", spriteFrame)
	_VFXSetSingle(stateHandle, "Spritesheet", spriteSheet)
	_VFXSetSingle(stateHandle, "Animation", spriteAnim)


func VFXTime(args, stateHandle):
	var time = ArgInt(args, stateHandle, 0)
	_VFXSetSingle(stateHandle, "TimeRemaining", time)
func VFXPerpetual(_args, stateHandle):
	_VFXSetSingle(stateHandle, "TimeRemaining", null)
func _VFXPosFunction(args, stateHandle, polynomialDegree, physicsSpace):
	var x = ArgInt(args, stateHandle, 0)
	var y = ArgInt(args, stateHandle, 1)
	var z = ArgInt(args, stateHandle, 2, 0)
	var pos = [x, y, z]
	if(polynomialDegree == 0):
		if(physicsSpace == Castagne.PHYSICS_SPACES.ENTITY):
			pos = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityToWorld(pos, stateHandle)
		if(physicsSpace == Castagne.PHYSICS_SPACES.ABSOLUTE):
			pos = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityAbsoluteToWorld(pos, stateHandle)
	else:
		if(physicsSpace == Castagne.PHYSICS_SPACES.ENTITY):
			pos = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityToAbsolute(pos, stateHandle)
	_VFXSetFuncSingle(stateHandle, "_PosX", pos[0], polynomialDegree)
	_VFXSetFuncSingle(stateHandle, "_PosY", pos[1], polynomialDegree)
	_VFXSetFuncSingle(stateHandle, "_PosZ", pos[2], polynomialDegree)
func VFXPosition(args, stateHandle):
	_VFXPosFunction(args, stateHandle, 0, Castagne.PHYSICS_SPACES.ENTITY)
func VFXPositionAbsolute(args, stateHandle):
	_VFXPosFunction(args, stateHandle, 0, Castagne.PHYSICS_SPACES.ABSOLUTE)
func VFXPositionWorld(args, stateHandle):
	_VFXPosFunction(args, stateHandle, 0, Castagne.PHYSICS_SPACES.WORLD)
func GizmoVFXPosition(emodule, args, lineActive, _stateHandle):
	if(args.size() >= 2):
		var pos = [int(args[0]),int(args[1]),0]
		if(args.size() >= 3):
			pos[2] = int(args[2])
		if(lineActive):
			emodule.GizmoCrosshair(pos, "Pink", 4)
		else:
			emodule.GizmoPoint(pos, "Pink", 2)
func VFXMove(args, stateHandle):
	_VFXPosFunction(args, stateHandle, 1, Castagne.PHYSICS_SPACES.ENTITY)
func VFXMoveAbsolute(args, stateHandle):
	_VFXPosFunction(args, stateHandle, 1, Castagne.PHYSICS_SPACES.ABSOLUTE)
func VFXAccel(args, stateHandle):
	_VFXPosFunction(args, stateHandle, 2, Castagne.PHYSICS_SPACES.ENTITY)
func VFXAccelAbsolute(args, stateHandle):
	_VFXPosFunction(args, stateHandle, 2, Castagne.PHYSICS_SPACES.ABSOLUTE)
func VFXRotation(args, stateHandle):
	var rotation = ArgInt(args, stateHandle, 0)
	_VFXSetFunc(stateHandle, "_Rotation", rotation, 0, 0)
func VFXScale(args, stateHandle):
	var scale = ArgInt(args, stateHandle, 0)
	_VFXSetFunc(stateHandle, "_Scale", scale, 0, 0)
func VFXAnimation(args, stateHandle):
	var animName = ArgStr(args, stateHandle, 0, "default")
	var animPlayer = ArgStr(args, stateHandle, 1, "AnimationPlayer")
	_VFXSetSingle(stateHandle, "Animation", animName)
	_VFXSetSingle(stateHandle, "AnimationPlayer", animPlayer)
func VFXZOrder(args, stateHandle):
	_VFXSetFunc(stateHandle, "_ZOrderCoarse", ArgInt(args, stateHandle, 0), 0, 0)
	if(args.size() > 1):
		_VFXSetFunc(stateHandle, "_ZOrderFine", ArgInt(args, stateHandle, 1), 0, 0)
func VFXZOrderFine(args, stateHandle):
	_VFXSetFunc(stateHandle, "_ZOrderFine", ArgInt(args, stateHandle, 0), 0, 0)
func VFXFacing(args, stateHandle):
	var f = (1 if ArgBool(args, stateHandle, 0, true) else -1)
	_VFXSetSingle(stateHandle, "Facing", stateHandle.EntityGet("_FacingHPhysics") * f)
func VFXFacingAbsolute(args, stateHandle):
	var f = (1 if ArgBool(args, stateHandle, 0, true) else -1)
	_VFXSetSingle(stateHandle, "Facing", f)
func VFXFlipFacing(_args, stateHandle):
	_VFXSetSingle(stateHandle, "Facing", -stateHandle.EntityGet("_PreparingVFX")["Facing"])
func VFXLockToEntity(args, stateHandle):
	_VFXSetSingle(stateHandle, "LockToEntity", ArgBool(args, stateHandle, 0, true))
func VFXUnlockFromEntity(_args, stateHandle):
	_VFXSetSingle(stateHandle, "LockToEntity", false)

func VFXParam(args, stateHandle):
	_VFXSetFunc(stateHandle, "_"+ArgRaw(args, 0), ArgInt(args, stateHandle, 1, 0), ArgInt(args, stateHandle, 2, 0), ArgInt(args, stateHandle, 3, 0))
func VFXOverride(args, stateHandle):
	# TODO: verification ? more for compile time if rewriting later
	var variableName = ArgRaw(args, 0)
	var paramName = ArgRaw(args, 1)
	stateHandle.EntityGet("_PreparingVFX")["Overrides"] += [[paramName, variableName]] 

func VFXSpriteCreate(args, stateHandle):
	var paramsStart = 1
	if(args.size() == 5):
		paramsStart = 2 
		VFXSprite([args[0], args[1]], stateHandle)
	else:
		VFXSprite([args[0]], stateHandle)
	
	VFXTime([args[paramsStart]], stateHandle)
	VFXPosition([args[paramsStart+1], args[paramsStart+2]], stateHandle)
	VFXCreate(null, stateHandle)
func GizmoVFXSpriteCreate(emodule, args, lineActive, stateHandle):
	if(args.size() == 4):
		var argsPos = [args[2], args[3]]
		GizmoVFXPosition(emodule, argsPos, lineActive, stateHandle)
	elif(args.size() >= 5):
		var argsPos = [args[3], args[4]]
		GizmoVFXPosition(emodule, argsPos, lineActive, stateHandle)
func VFXModelCreate(args, stateHandle):
	var paramsStart = 1
	if(args.size() == 5):
		paramsStart = 2 
		VFXModel([args[0], args[1]], stateHandle)
	else:
		VFXModel([args[0]], stateHandle)
	
	VFXTime([args[paramsStart]], stateHandle)
	VFXPosition([args[paramsStart+1], args[paramsStart+2]], stateHandle)
	VFXCreate(null, stateHandle)
func GizmoVFXModelCreate(emodule, args, lineActive, stateHandle):
	if(args.size() >= 4):
		var argsPos = [args[2], args[3]]
		GizmoVFXPosition(emodule, argsPos, lineActive, stateHandle)
func VFXCreate(_args, stateHandle):
	var vfxData = stateHandle.EntityGet("_PreparingVFX").duplicate(true)
	
	var isSprite = (vfxData["IsSprite"])
	var vfxNode = null
	
	if(vfxData["ScenePath"] == null):
		vfxNode = _CreateSprite_Instance(stateHandle)
	else:
		var modelPS = Castagne.Loader.Load(vfxData["ScenePath"])
		vfxNode = modelPS.instance()
	
	if(isSprite):
		vfxNode.Initialize(stateHandle, vfxNode)
		vfxData["SpritesheetDataHolder"] = stateHandle.IDEntityGet("SpriteData")
	
	vfxData["EntityInitialPos"] = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityAbsoluteToWorld([0,0,0], stateHandle)
	
	graphicsRoot.add_child(vfxNode)
	if(vfxData["AnimationPlayer"] != null):
		var animPlayer = vfxNode.get_node(vfxData["AnimationPlayer"])
		if(animPlayer == null):
			ModuleError("VFXCreate: Animation player path is wrong! ("+str(vfxData["AnimationPlayer"])+")")
		else:
			animPlayer.play(vfxData["Animation"], -1, 0.0)
	
	vfxData["ID"] = stateHandle.IDGlobalGet("VFXState").size()
	var idData = {"VFXNode": vfxNode, "IsSprite": isSprite}
	
	stateHandle.IDGlobalAdd("VFXState", [idData])
	stateHandle.GlobalAdd("_VFXList", [vfxData])
	
	if(vfxNode.has_method("VFXCreate")):
		vfxNode.VFXCreate(vfxData)
	
	_VFXUpdate_UpdateGraphics(stateHandle, vfxData)

# Internal helper to set VFX values in VFX functions
func _VFXSetSingle(stateHandle, field, value):
	stateHandle.EntityGet("_PreparingVFX")[field] = value
func _VFXSetFunc(stateHandle, field, valueA, valueB, valueC):
	stateHandle.EntityGet("_PreparingVFX")[field] = [valueA, valueB, valueC]
func _VFXSetFuncSingle(stateHandle, field, value, id):
	stateHandle.EntityGet("_PreparingVFX")[field][id] = value
func _VFXHas(stateHandle, field):
	return stateHandle.EntityGet("_PreparingVFX").has(field)

var VFXDATA_FUNCTION = ["PosX", "PosY", "PosZ", "Rotation", "Scale", "ZOrderFine", "ZOrderCoarse"]
func _ResetVFXData(stateHandle):
	var defaultVFXData = {
		"ScenePath":null, "IsSprite":false,
		"TimeRemaining":60, "TimeAlive": 0,
		"_PosX": [0,0,0], "_PosY": [0,0,0], "_PosZ": [0,0,0],
		"Facing": stateHandle.EntityGet("_FacingHPhysics"),
		"_Scale": [1000, 0, 0], "_Rotation": [0,0,0],
		"AnimationPlayer": null, "Animation":null,
		"SpriteFrame": 0, "Spritesheet": null,
		"SpritesheetDataHolder": null,
		"_ZOrderFine": [((stateHandle.EntityGet("_ModelZOrder")+49)%100)-49, 0, 0],
		"_ZOrderCoarse": [((stateHandle.EntityGet("_ModelZOrder")+49)/100), 0, 0],
		"ZOrder": stateHandle.EntityGet("_ModelZOrder"),
		"LockToEntity":true,
		"EntityInitialPos":[0,0,0],
		"Overrides":[],
		"ParentEID": stateHandle.EntityGet("_EID"),
	}
	for p in VFXDATA_FUNCTION:
		defaultVFXData[p] = defaultVFXData["_"+p][2]
	stateHandle.EntitySet("_PreparingVFX", defaultVFXData)

func _VFXUpdate_FrameStart(stateHandle, vfxData):
	var idData = stateHandle.IDGlobalGet("VFXState")[vfxData["ID"]]
	
	var deleteVFX = false
	
	var timeScale = 1
	var parentAlive = stateHandle.PointToEntity(vfxData["ParentEID"])
	if(!parentAlive):
		deleteVFX = true
	else:
		if(stateHandle.EntityHasFlag("VFXPause")):
			timeScale = 0
	
	vfxData["TimeAlive"] += 1 * timeScale
	
	if(vfxData["TimeRemaining"] != null):
		vfxData["TimeRemaining"] -= 1 * timeScale
		if(vfxData["TimeRemaining"] <= 0):
			deleteVFX = true
	
	if(deleteVFX):
		var vfxNode = idData["VFXNode"]
		vfxNode.queue_free()
		if(vfxNode.has_method("VFXDestroy")):
			vfxNode.VFXDestroy(vfxData)
		return null
	
	return vfxData
	
func _VFXUpdate_UpdateGraphics(stateHandle, vfxData):
	var idData = stateHandle.IDGlobalGet("VFXState")[vfxData["ID"]]
	var isSprite = (vfxData["IsSprite"])
	var vfxNode = idData["VFXNode"]
	_VFXUpdate_UpdateVFXData(stateHandle, vfxData)
	var parentAlive = stateHandle.PointToEntity(vfxData["ParentEID"])
	
	
	if(isSprite):
		vfxNode.UpdateSpriteVFX(vfxData)
	
	if(vfxData["AnimationPlayer"] != null):
		var animPlayer = vfxNode.get_node(vfxData["AnimationPlayer"])
		if(animPlayer != null):
			animPlayer.seek((vfxData["TimeAlive"]+1.0)/60.0, true)
	
	var vfxPos = [vfxData["PosX"], vfxData["PosY"], vfxData["PosZ"]]
	if(parentAlive and vfxData["LockToEntity"]):
		var initPos = vfxData["EntityInitialPos"]
		var curPos = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityAbsoluteToWorld([0,0,0], stateHandle)
		vfxPos[0] += curPos[0] - initPos[0]
		vfxPos[1] += curPos[1] - initPos[1]
		vfxPos[2] += curPos[2] - initPos[2]
	
	_ModelApplyTransformDirect(vfxNode, vfxPos, vfxData["Rotation"], vfxData["Scale"], vfxData["Facing"])
	if(vfxNode.has_method("VFXUpdate")):
		vfxNode.VFXUpdate(vfxData)
	
func _VFXUpdate_UpdateVFXData(stateHandle, vfxData):
	var dataToUpdate = VFXDATA_FUNCTION # TODO: seems like it's not generic for generic parameters
	var t = vfxData["TimeAlive"]
	var parentAlive = stateHandle.PointToEntity(vfxData["ParentEID"])
	
	for p in dataToUpdate:
		var f = vfxData["_"+p]
		vfxData[p] = f[2]*t*t + f[1]*t + f[0]
	
	vfxData["ZOrder"] = vfxData["ZOrderCoarse"]*100+vfxData["ZOrderFine"]
	
	if(parentAlive):
		for o in vfxData["Overrides"]:
			var entityVariableName = o[1]
			var vfxParamName = o[0]
			if(vfxParamName in vfxData):
				if(stateHandle.EntityHas(entityVariableName)):
					vfxData[vfxParamName] = stateHandle.EntityGet(entityVariableName)
				else:
					ModuleError("VFXOverride: Entity Variable "+str(entityVariableName)+" doesn't exist!")
			else:
				ModuleError("VFXOverride: VFX Parameter "+str(vfxParamName)+" doesn't exist!")
			# TODO: Verification of data ?




# -[CTG_PALETTES]-----------------------------------------------------------------------------------
func PaletteApply(args, stateHandle):
	var paletteID = ArgInt(args, stateHandle, 0, stateHandle.EntityGet("_PaletteID"))
	paletteID -= 1 # Palette 0 is the default, paletteData only holds the second palette and up
	var palettesData = stateHandle.IDEntityGet("TD_Graphics")["Palettes"]
	
	# :TODO:v0.7 Get the defaults in a better way
	var spritePalettePath = stateHandle.EntityGet("_Tmp_DefaultSpritePalettePath")
	var modelPath = stateHandle.EntityGet("_Tmp_DefaultModelPath")
	var paletteExtra = 0
	
	if(paletteID >= 0 and paletteID < palettesData.size()):
		var paletteName = palettesData.keys()[paletteID]
		spritePalettePath = palettesData[paletteName]["SpritePalettePath"]
		modelPath = palettesData[paletteName]["ModelPath"]
		paletteExtra = palettesData[paletteName]["Extra"]
	elif(paletteID != -1):
		ModuleError("Palette ID "+str(paletteID+1)+" is not in range!", stateHandle)
	
	stateHandle.EntitySet("_SpritePalettePath", spritePalettePath)
	stateHandle.EntitySet("_ModelPath", modelPath)
	stateHandle.EntitySet("_PaletteExtra", paletteExtra)

func PaletteSprite(args, stateHandle):
	var palettePath = ArgStr(args, stateHandle, 0)
	stateHandle.EntitySet("_SpritePalettePath", palettePath)
	var sprite = stateHandle.IDEntityGet("Sprite")
	if(sprite != null):
		sprite.ApplyMaterial(stateHandle)










# -[CTG_UI]----------------------------------------------------------------------------------
var _UI_DefaultWidgetTypes = [
	"UIDefaultWidget_Bar", "UIDefaultWidget_Icons",
	"UIDefaultWidget_IconSwitch", "UIDefaultWidget_Text",
]
func UI_SpawnWidgetFromData(stateHandle, widgetData):
	var scenePath = widgetData["ScenePath"]
	var hookPoint = widgetData["HookPoint"]
	var type = widgetData["Type"]
	
	var uiRoot = stateHandle.IDGlobalGet("UIRoot")
	if(uiRoot == null):
		Castagne.Error("Can't spawn UI Widget without UI Root.")
		return
	
	if(type > 0 and type <= _UI_DefaultWidgetTypes.size()):
		scenePath = stateHandle.ConfigData().Get(_UI_DefaultWidgetTypes[type-1])
	
	var packedScene = Castagne.Loader.Load(scenePath)
	if(packedScene == null):
		Castagne.Error("Couldn't spawn UI Widget at path " + str(scenePath))
		return
	
	var widget = packedScene.instance()
	
	if(uiRoot.AddPlayerWidget(stateHandle.GetPlayer(), widget, hookPoint)):
		widget.WidgetInitialize(stateHandle, null, widgetData)
	else:
		widget.queue_free()









# -[CTG_INTERNALS]----------------------------------------------------------------------------------
func _EnsureRootIsSet(stateHandle):
	if(stateHandle.IDEntityGet("Root") == null):
		var root = _CreateRootNode()
		stateHandle.IDEntitySet("Root", root)
		graphicsRoot.add_child(root)

func _InitCamera(_stateHandle, _battleInitData):
	var cam = Camera.new()
	return cam

func _CreateSprite_Instance(stateHandle):
	var s3D = Sprite3D.new()
	var scriptPath = stateHandle.ConfigData().Get("SpriteScriptPath")
	s3D.set_script(Castagne.Loader.Load(scriptPath))
	s3D.is2D = false
	s3D.graphicsModule = self
	return s3D


func _UpdateSprite(sprite, stateHandle):
	sprite.UpdateSprite(stateHandle)

func _UpdateCamera(stateHandle, camera, cameraPos, cameraLookAt, cameraFOV, cameraRoll, cameraShake, _cameraExtra):
	#camera.set_translation(cameraPos)
	#var fwd = (cameraPos - cameraLookAt).normalized()
	#var up = Vector3(0,1,0)
	#if(abs(fwd.dot(up)) > 0.999):
	#	up = Vector3(1,0,0)
	#var right = fwd.cross(up).normalized()
	#up = right.cross(fwd).normalized()
	
	camera.look_at_from_position(cameraPos, cameraLookAt, Vector3(0,1,0))
	camera.rotate_z(cameraRoll)
	if(cameraFOV >= 1 and cameraFOV <= 179):
		camera.set_fov(cameraFOV)
	
	var cameraShakeBase = stateHandle.ConfigData().Get("CameraShake_BaseStrength") * POSITION_SCALE
	cameraShake = (cameraShake / 1000.0) * cameraShakeBase
	
	var randomAngle = deg2rad(stateHandle.GlobalGet("_FrameID") * 67)
	camera.translate(Vector3(cos(randomAngle), sin(randomAngle), 0) * cameraShake)

func _ModelApplyTransform(stateHandle, modelRoot, modelPosition, modelRotation, modelScale):
	var facingH = stateHandle.EntityGet("_FacingHModel")
	_ModelApplyTransformDirect(modelRoot, modelPosition, modelRotation, modelScale, facingH)

func _ModelApplyTransformDirect(modelRoot, modelPosition, modelRotation, modelScale, facingH):
	modelPosition = IngameToGodotPos(modelPosition)
	modelRotation *= 0.1
	modelScale /= 1000.0
	
	modelRoot.set_translation(modelPosition)
	modelRoot.set_rotation_degrees(Vector3(0, 90.0*facingH - 90.0, modelRotation))
	modelRoot.set_scale(Vector3(modelScale, modelScale, facingH * modelScale))

func _CreateRootNode():
	return Spatial.new()

func _CreateGraphicsRootNode(engine):
	var gr = _CreateRootNode()
	engine.add_child(gr)
	return gr

func IngameToGodotPos(ingamePosition):
	return Vector3(ingamePosition[0], ingamePosition[1], ingamePosition[2]) * POSITION_SCALE
func GodotToIngamePos(godotPos): # Loss of precision / nondeterministic
	var ingamePos = Vector3(godotPos[0], godotPos[1], godotPos[2]) / POSITION_SCALE
	return [int(ingamePos[0]), int(ingamePos[1]), int(ingamePos[2])]

func TranslateIngamePosToScreen(ingamePosition):
	if(lastRegisteredCamera != null):
		return lastRegisteredCamera.unproject_position(IngameToGodotPos(ingamePosition))
	return Vector2(0,0)
