extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var checkAnimation = false
var isSprite = false
var spriteData = null
var animationData = {}

var _nAnimList
var _nAnimInfo
var _nCurAnimName
var _nCurAnimFrame
var _nCurStateName
var _nCurStateFrame

func SetupTool():
	toolName = "Animation Data"
	toolDescription = "Check animation length."
	#_viewport = $Small/SceneViewport
	#_controls = $Small/Main/Controls
	# UnloadScene()
	_nAnimList = $Small/Main/AnimList
	_nAnimInfo = $Small/Main/AnimInfo
	_nCurAnimName = $Small/Main/AnimCurName
	_nCurAnimFrame = $Small/Main/AnimCurFrame
	_nCurStateName = $Small/Main/StateCurName
	_nCurStateFrame = $Small/Main/StateCurFrame

func OnEngineRestarting(engine, battleInitData):
	_nAnimList.clear()
	_nAnimList.set_disabled(true)
	_nAnimInfo.set_text("Engine is not running.")
	checkAnimation = true

func OnEngineRestarted(engine):
	var editorModule = engine.configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.EDITOR)
	editorModule.connect("EngineTick_FrameEnd", self, "GetAnimationData")

func GetAnimationData(stateHandle):
	var canimName = "[None]"
	var canimFrame = 0
	var canimFrameMax = 0
	stateHandle.PointToEntity(0)
	if(stateHandle.EntityHas("_Anim")):
		canimName = stateHandle.EntityGet("_Anim")
		canimFrame = stateHandle.EntityGet("_AnimFrame")
	
	_nCurAnimName.set_text("Current Animation: "+str(canimName))
	if(canimName in animationData):
		canimFrameMax = animationData[canimName]["Length"]
		_nCurAnimFrame.set_text("Frame: "+str(canimFrame)+" / "+str(canimFrameMax))
	else:
		_nCurAnimFrame.set_text("Frame: "+str(canimFrame))
	
	_nCurStateName.set_text("Current State: "+str(stateHandle.EntityGet("_State")))
	_nCurStateFrame.set_text("Frame: "+str(stateHandle.EntityGet("_StateFrameID")))
	
	if(!checkAnimation):
		return
	checkAnimation = false
	
	
	
	
	if(!stateHandle.IDEntityHas("AnimPlayer")):
		_nAnimInfo.set_text("Can't access animation player.")
		return
	
	
	
	
	var animPlayer = stateHandle.IDEntityGet("AnimPlayer")
	animationData = {}
	if(animPlayer == null):
		_nAnimInfo.set_text("No animation player.")
		
		if(stateHandle.IDEntityHas("Sprite") and stateHandle.IDEntityGet("Sprite") != null):
			isSprite = true
			var sprite = stateHandle.IDEntityGet("Sprite")
			var spriteAnimations = sprite.animations
			for aName in spriteAnimations:
				var aData = spriteAnimations[aName]
				var length = 0
				for i in aData:
					length += i[0]
				animationData[aName] = {
					"Length": length
				}
		else:
			return
	else:
		isSprite = false
		spriteData = null
		var animList = animPlayer.get_animation_list()
		for aName in animList:
			var aData = animPlayer.get_animation(aName)
			var length = int(aData.get_length() * 60.0)
			animationData[aName] = {
				"Length": length
			}
	
	if(animationData.empty()):
		_nAnimInfo.set_text("No animations available.")
		return
	
	_nAnimList.set_disabled(false)
	for aName in animationData:
		_nAnimList.add_item(aName)
	
	_nAnimList.select(0)
	DisplayAnimationData(_nAnimList.get_item_text(0))
	

func DisplayAnimationData(animName):
	_nAnimInfo.set_text("Length: " + str(animationData[animName]["Length"]))


func _on_AnimList_item_selected(index):
	DisplayAnimationData(_nAnimList.get_item_text(index))
func _on_AnimList_item_focused(index):
	DisplayAnimationData(_nAnimList.get_item_text(index))


