# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

var graphicsRoot = null
var POSITION_SCALE = 1.0

func ModuleSetup():
	RegisterModule("Graphics", Castagne.MODULE_SLOTS_BASE.GRAPHICS)
	RegisterBaseCaspFile("res://castagne/modules/graphics/Base-Graphics.casp")
	RegisterSpecblock("Graphics", "res://castagne/modules/graphics/CMGraphicsSBGraphics.gd")
	RegisterSpecblock("Anims", "res://castagne/modules/graphics/CMGraphicsSBAnims.gd")
	
	
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
		"Arguments":["The rotation in tenth of degrees."],
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
	
	RegisterVariableEntity("_ModelPositionX", 0)
	RegisterVariableEntity("_ModelPositionY", 0)
	RegisterVariableEntity("_ModelRotation", 0)
	RegisterVariableEntity("_ModelScale", 1000)
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
	RegisterFunction("SpriteOrder", [1, 2], null, {
		"Description": "Sets the draw order for sprites, higher being drawn on top of others.\n"+
		"The final value must be between "+str(VisualServer.CANVAS_ITEM_Z_MIN)+" and "+str(VisualServer.CANVAS_ITEM_Z_MAX)+".\n"+
		"The offset may be used to have more flexibility in its use, for instance by using it to put one character behind another without affecting the local sprite order changes.\n"+
		"Still in progress, 2D graphics only for now.",
		"Arguments":["Sprite Order", "(Optional) Sprite Order Offset"],
		"Flags":["Advanced"],
		"Types":["int", "int"],
	})
	RegisterFunction("SpriteOrderOffset", [1], null, {
		"Description": "Set the sprite order offset directly. See SpriteOrder for more information.",
		"Arguments":["Sprite Order Offset"],
		"Flags":["Advanced"],
		"Types":["int"],
	})
	
	RegisterVariableEntity("_SpriteFrame", 0)
	RegisterVariableEntity("_SpriteAnim", "Null")
	# TODO Reduce the amount needed as static
	RegisterVariableEntity("_SpriteOrder", 0)
	RegisterVariableEntity("_SpriteOrderOffset", 0)
	RegisterConfig("PositionScale", 0.0001)
	#RegisterVariableEntity("_SpritePaletteID", 0, ["InheritToSubentity"])
	
	
	
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
		"Arguments": ["Loop point (exclusive)", "(Optional) Start point of the loop."]
	})
	RegisterVariableEntity("_Anim", null, null, {"Description":"Currently playing animation."})
	RegisterVariableEntity("_AnimFrame", 0, null, {"Description":"Current frame of the animation to show."})
	RegisterVariableEntity("_AnimFuncName", "", null, {"Description":"Remembers when the animation started, for the Anim function"})
	RegisterVariableEntity("_AnimFuncOffset", null, null, {"Description":"Remembers an offset for the Anim function"})
	
	
	# -[CTG_CAMERA]---------------------------------------------------------------------------------
	RegisterCategory("Camera")
	RegisterConfig("CameraOffsetX", 0)
	RegisterConfig("CameraOffsetY", 20000)
	RegisterConfig("CameraOffsetZ", 62000)
	RegisterConfig("CameraYBuffer", 30000)
	
	RegisterConfig("CameraPosMinX", -105000)
	RegisterConfig("CameraPosMaxX",  105000)
	RegisterConfig("CameraPosMinY", -1000000)
	RegisterConfig("CameraPosMaxY",  1000000)
	
	
	# -[CTG_VFX]------------------------------------------------------------------------------------
	RegisterCategory("VFX Test")
	
	#RegisterFunction("VFXPrepare", [3], null, {
	#	"Description":"Prepares a VFX to show. Must be created with VFXCreate once preparation is finished.",
	#	"Arguments":["Time Active", "Pos X", "PosY"],
	#})
	
	RegisterFunction("VFXReset", [0])
	RegisterFunction("VFXModel", [1])
	RegisterFunction("VFXSprite", [1, 2])
	RegisterFunction("VFXSpriteCreate", [4, 5], null, {
		"Description":"Helper function to quickly create a simple sprite VFX.",
		"Args":["Sprite Animation / Spritesheet", "(Optional) Sprite ID if using spritesheet",
				"Time (frames)", "Position X", "Position Y"],
		})
	
	RegisterFunction("VFXTime", [1])
	RegisterFunction("VFXPosition", [1, 2])
	RegisterFunction("VFXRotation", [1])
	RegisterFunction("VFXScale", [1])
	
	RegisterFunction("VFXAnimation", [0,1,2])
	
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
	
	RegisterConfig("UIRootScene", "res://castagne/modules/graphics/ui/UISceneRoot.tscn")
	RegisterConfig("UIPlayerRootScene", "res://castagne/modules/graphics/ui/UIPlayerRoot.tscn")
	RegisterConfig("UIFlipSecondPlayerUI", true)
	
	# -[CTG_INTERNALS]------------------------------------------------------------------------------

func BattleInit(stateHandle, battleInitData):
	graphicsRoot = _CreateGraphicsRootNode(engine)
	var config = stateHandle.ConfigData()
	
	var camera = _InitCamera(stateHandle, battleInitData)
	graphicsRoot.add_child(camera)
	#engine.graphicsModule = self
	
	POSITION_SCALE = config.Get("PositionScale")
	
	stateHandle.IDGlobalSet("GraphicsRoot", graphicsRoot)
	stateHandle.IDGlobalSet("Camera", camera)
	lastRegisteredCamera = camera
	
	cameraOffset = Vector3(config.Get("CameraOffsetX"), config.Get("CameraOffsetY"), config.Get("CameraOffsetZ"))
	
	var prefabMap = Castagne.Loader.Load(Castagne.SplitStringToArray(config.Get("StagePaths"))[battleInitData["map"]])
	var map = prefabMap.instance()
	graphicsRoot.add_child(map)
	stateHandle.IDGlobalSet("map", map)
	
	stateHandle.IDGlobalSet("VFXState", [])
	
	return # TODOUI
	var uiRoot = null
	var uiRootScenePath = config.Get("UIRootScene")
	if(uiRootScenePath != null):
		var uiRootScenePacked = Castagne.Loader.Load(uiRootScenePath)
		if(uiRootScenePacked != null):
			uiRoot = uiRootScenePacked.instance()
		else:
			ModuleError("Graphics: Can't instance UI Root at path "+str(uiRootScenePath))
		stateHandle.Engine().add_child(uiRoot)
		uiRoot.UIInitialize(stateHandle, battleInitData)
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
var cameraOffset = Vector3()
func UpdateGraphics(stateHandle):
	var camera = stateHandle.IDGlobalGet("Camera")
	
	var playerPosCenter = Vector3(stateHandle.GlobalGet("_CameraX"), stateHandle.GlobalGet("_CameraY") - stateHandle.ConfigData().Get("CameraYBuffer"), 0)
	if(playerPosCenter.y < 0):
		playerPosCenter.y = 0.0
	var cameraPos = playerPosCenter + cameraOffset
	cameraPos.x = clamp(cameraPos.x, stateHandle.ConfigData().Get("CameraPosMinX"), stateHandle.ConfigData().Get("CameraPosMaxX"))
	cameraPos.y = clamp(cameraPos.y, stateHandle.ConfigData().Get("CameraPosMinY"), stateHandle.ConfigData().Get("CameraPosMaxY"))
	cameraPos = IngameToGodotPos(cameraPos)
	_UpdateCamera(stateHandle, camera, cameraPos)
	stateHandle.GlobalSet("_GraphicsCamPos", cameraPos)
	
	for eid in stateHandle.GlobalGet("_ActiveEntities"):
		stateHandle.PointToEntity(eid)
		
		var sprite = stateHandle.IDEntityGet("Sprite")
		if(sprite != null):
			_UpdateSprite(sprite, stateHandle)
		
		var anim = stateHandle.EntityGet("_Anim")
		var animPlayer = stateHandle.IDEntityGet("AnimPlayer")
		if(anim != null and animPlayer != null):
			var animFrameID = stateHandle.EntityGet("_AnimFrame")
			if(animPlayer.has_animation(anim)):
				animPlayer.play(anim, 0.0, 0.0)
				animPlayer.seek(float(animFrameID-1)/60.0, true)
			else:
				ModuleError("Animation " + anim + " doesn't exist.", stateHandle)
		
		var modelPosition = [stateHandle.EntityGet("_ModelPositionX"), stateHandle.EntityGet("_ModelPositionY"), 0]
		var modelRotation = stateHandle.EntityGet("_ModelRotation")
		var modelScale = stateHandle.EntityGet("_ModelScale")
		
		var modelRoot = stateHandle.IDEntityGet("Root")
		if(modelRoot != null):
			_ModelApplyTransform(stateHandle, modelRoot, modelPosition, modelRotation, modelScale)
	
	
	for vfx in stateHandle.GlobalGet("_VFXList"):
		_VFXUpdate_UpdateGraphics(stateHandle, vfx)
	
	
	return # TODOUI
	var uiRoot = stateHandle.IDGlobalGet("UIRoot")
	if(uiRoot != null):
		uiRoot.UIUpdate(stateHandle)











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
func ModelSwitchFacing(_args, stateHandle):
	return





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
	var sprite = _CreateSprite_Instance()
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
		"PixelSize":100, "PaletteMode": 0,
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

func SpriteOrder(args, stateHandle):
	_SpriteOrderSet(stateHandle, ArgInt(args, stateHandle, 0), ArgInt(args, stateHandle, 1, stateHandle.EntityGet("_SpriteOrderOffset")))
func SpriteOrderOffset(args, stateHandle):
	_SpriteOrderSet(stateHandle, stateHandle.EntityGet("_SpriteOrder"), ArgInt(args, stateHandle, 0))
func _SpriteOrderSet(stateHandle, order, orderOffset):
	stateHandle.EntitySet("_SpriteOrder", order)
	stateHandle.EntitySet("_SpriteOrderOffset", orderOffset)
	var finalOrder = order + orderOffset
	if(finalOrder < VisualServer.CANVAS_ITEM_Z_MIN or finalOrder > VisualServer.CANVAS_ITEM_Z_MAX):
		ModuleError("Sprite order out of bounds: " + str(finalOrder) + " ("+str(order)+"+"+str(orderOffset)+") is outside of ["+str(VisualServer.CANVAS_ITEM_Z_MIN)+", "+str(VisualServer.CANVAS_ITEM_Z_MAX)+"]!", stateHandle)







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
	var loopPointStart = ArgInt(args, stateHandle, 1, 0)
	var loopSpan = max(loopPointEnd - loopPointStart, 1)
	
	var frame = stateHandle.EntityGet("_AnimFrame")
	if(frame >= loopPointEnd):
		frame = ((frame - loopPointStart) % loopSpan) + loopPointStart
		stateHandle.EntitySet("_AnimFrame", frame)











# -[CTG_VFX]----------------------------------------------------------------------------------------
func VFXPrepare(args, stateHandle):
	#var vfxName = ArgStr(args, stateHandle, 0)
	var time = ArgInt(args, stateHandle, 0)
	var posX = ArgInt(args, stateHandle, 1)
	var posY = ArgInt(args, stateHandle, 2)
	
	var pos = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityToWorld([posX, posY], stateHandle)
	var facing = stateHandle.EntityGet("_FacingHPhysics")

func VFXReset(_args, stateHandle):
	_ResetVFXData(stateHandle)

func VFXModel(args, stateHandle):
	var vfxName = ArgStr(args, stateHandle, 0)
	_VFXSet(stateHandle, "ScenePath", vfxName)
	
func VFXSprite(args, stateHandle):
	_VFXSet(stateHandle, "ScenePath", null)
	var spriteFrame = 0
	var spriteSheet = null
	var spriteAnim = null
	if(args.size() == 1):
		spriteAnim = ArgStr(args, stateHandle, 0)
	else:
		spriteSheet = ArgStr(args, stateHandle, 0)
		spriteFrame = ArgInt(args, stateHandle, 1)
	_VFXSet(stateHandle, "SpriteFrame", spriteFrame)
	_VFXSet(stateHandle, "Spritesheet", spriteSheet)
	_VFXSet(stateHandle, "Animation", spriteAnim)

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


func VFXTime(args, stateHandle):
	var time = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_PreparingVFX")["TimeRemaining"] = time
func VFXPosition(args, stateHandle):
	var posX = ArgInt(args, stateHandle, 0)
	var posY = ArgInt(args, stateHandle, 1)
	var pos = stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS).TransformPosEntityToWorld([posX, posY], stateHandle)
	stateHandle.EntityGet("_PreparingVFX")["PosX"] = pos[0]
	stateHandle.EntityGet("_PreparingVFX")["PosY"] = pos[1]
func VFXPositionWorld(args, stateHandle):
	stateHandle.EntityGet("_PreparingVFX")["PosX"] = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_PreparingVFX")["PosY"] = ArgInt(args, stateHandle, 1)
func VFXRotation(args, stateHandle):
	var rotation = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_PreparingVFX")["Rotation"] = rotation
func VFXScale(args, stateHandle):
	var scale = ArgInt(args, stateHandle, 0)
	stateHandle.EntityGet("_PreparingVFX")["Scale"] = scale
func VFXAnimation(args, stateHandle):
	var animName = ArgStr(args, stateHandle, 0, "default")
	var animPlayer = ArgStr(args, stateHandle, 1, "AnimationPlayer")
	stateHandle.EntityGet("_PreparingVFX")["Animation"] = animName
	stateHandle.EntityGet("_PreparingVFX")["AnimationPlayer"] = animPlayer
	
func VFXCreate(args, stateHandle):
	var data = stateHandle.EntityGet("_PreparingVFX").duplicate(true)
	
	var isSprite = (data["ScenePath"] == null)
	var vfxNode = null
	
	if(isSprite):
		vfxNode = _CreateSprite_Instance()
		vfxNode.Initialize(stateHandle, vfxNode)
		data["SpritesheetDataHolder"] = stateHandle.IDEntityGet("SpriteData")
	else:
		var modelPS = Castagne.Loader.Load(data["ScenePath"])
		vfxNode = modelPS.instance()
	
	
	_ModelApplyTransformDirect(vfxNode, [data["PosX"], data["PosY"], data["PosZ"]], data["Rotation"], data["Scale"], data["Facing"])
	
	graphicsRoot.add_child(vfxNode)
	if(data["AnimationPlayer"] != null):
		var animPlayer = vfxNode.get_node(data["AnimationPlayer"])
		animPlayer.play(data["Animation"])
	
	data["ID"] = stateHandle.IDGlobalGet("VFXState").size()
	var idData = {"VFXNode": vfxNode, "IsSprite": isSprite}
	
	stateHandle.IDGlobalAdd("VFXState", [idData])
	stateHandle.GlobalAdd("_VFXList", [data])
	

# Internal helper to set VFX values in VFX functions
func _VFXSet(stateHandle, field, value):
	stateHandle.EntityGet("_PreparingVFX")[field] = value
	
func _ResetVFXData(stateHandle):
	var defaultVFXData = {
		"ScenePath":null, # Path to scene, if null use sprites
		"TimeRemaining":60, "TimeAlive": 0,
		"PosX": 0, "PosY": 0, "PosZ": 0,
		"Facing": stateHandle.EntityGet("_FacingHPhysics"),
		"Scale": 1000, "Rotation": 0,
		"AnimationPlayer": null, "Animation":null,
		"SpriteFrame": 0, "Spritesheet": null,
		"SpritesheetDataHolder": null,
		"SpriteOrder":stateHandle.EntityGet("_SpriteOrder") + stateHandle.EntityGet("_SpriteOrderOffset"),
	}
	stateHandle.EntitySet("_PreparingVFX", defaultVFXData)

func _VFXUpdate_FrameStart(stateHandle, vfxData):
	var idData = stateHandle.IDGlobalGet("VFXState")[vfxData["ID"]]
	vfxData["TimeRemaining"] -= 1
	vfxData["TimeAlive"] += 1
	if(vfxData["TimeRemaining"] <= 0):
		idData["VFXNode"].queue_free()
		return null
	
	return vfxData
	
func _VFXUpdate_UpdateGraphics(stateHandle, vfxData):
	var idData = stateHandle.IDGlobalGet("VFXState")[vfxData["ID"]]
	var isSprite = (vfxData["ScenePath"] == null)
	var vfxNode = idData["VFXNode"]
	
	if(isSprite):
		vfxNode.UpdateSpriteVFX(vfxData)
	## TODO : Actual animation support
	
	_ModelApplyTransformDirect(vfxNode, [vfxData["PosX"], vfxData["PosY"], vfxData["PosZ"]], vfxData["Rotation"], vfxData["Scale"], vfxData["Facing"])





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













# -[CTG_INTERNALS]----------------------------------------------------------------------------------
func _EnsureRootIsSet(stateHandle):
	if(stateHandle.IDEntityGet("Root") == null):
		var root = _CreateRootNode()
		stateHandle.IDEntitySet("Root", root)
		graphicsRoot.add_child(root)

func _InitCamera(_stateHandle, _battleInitData):
	var cam = Camera.new()
	return cam

func _CreateSprite_Instance():
	var s3D = Sprite3D.new()
	s3D.set_script(Castagne.Loader.Load("res://castagne/modules/graphics/CMGraphics_Sprite.gd"))
	s3D.is2D = false
	s3D.graphicsModule = self
	return s3D


func _UpdateSprite(sprite, stateHandle):
	sprite.UpdateSprite(stateHandle)

func _UpdateCamera(_stateHandle, camera, cameraPos):
	camera.set_translation(cameraPos)

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

func TranslateIngamePosToScreen(ingamePosition):
	if(lastRegisteredCamera != null):
		return lastRegisteredCamera.unproject_position(IngameToGodotPos(ingamePosition))
	return Vector2(0,0)
