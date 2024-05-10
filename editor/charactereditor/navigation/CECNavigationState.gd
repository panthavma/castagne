# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends PanelContainer

# color out 018200
# color sel 826800

var _state
var _fileID
var _forceColorNonState = false

var charEditor = null

var padState = 0

func InitFromState(stateData):
	var baseData = {
		"Name":"No Name",
		"StateDoc":"SHORT DOC",
		"StateFullDoc":"FULL DOC",
		"StateFlags":[],
		"Overridable":null,
		"StateType":Castagne.STATE_TYPE.Normal,
		"FileID": -1,
	}
	
	_state = stateData.duplicate(true)
	Castagne.FuseDataNoOverwrite(_state, baseData)
	
	var fileID = _state["FileID"]
	if(fileID == -1):
		fileID = charEditor.curFile
	_fileID = fileID
	
	SetButtonText(_state["Name"])
	var filePath = charEditor.character[fileID]["Path"]
	$Padder/Contents/MainLine/Filepath.set_text(" - " + filePath.right(filePath.find_last("/")+1))
	$Padder/Contents/MainLine/Filepath.set_visible(fileID != charEditor.curFile)
	$Padder/Contents/Selected/Shortdoc.set_text(_state["StateDoc"])
	$Padder/Contents/MainLine/Shortdoc.set_text(_state["StateDoc"])
	
	var stateType = _state["StateType"]
	for st in $Padder/Contents/MainLine/StateType.get_children():
		st.hide()
	$Padder/Contents/MainLine/StateType.get_child(stateType).show()
	
	$Padder/Helper.set_visible(padState > 0)
	
	
	var flagsRoot = $Padder/Contents/MainLine/Flags
	var flags = _state["StateFlags"].duplicate()
	flags.sort()
	for f in flags:
		var t
		var icon = Castagne.Loader.LoadCastagneAsset("editor/stateflags/EF"+f+".png")
		if(icon != null):
			t = TextureRect.new()
			t.set_texture(icon)
			t.set_expand(true)
			t.set_stretch_mode(TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
			t.set_custom_minimum_size(Vector2(32,32))
		else:
			t = Label.new()
			t.set_text("["+f+"]")
		t.set_tooltip(f)
		flagsRoot.add_child(t)
	
	if(_state["Overridable"] != null):
		$Padder/Contents/Selected/Over.show()
		$Padder/Contents/Selected/Over/OverText.set_text(_state["Overridable"])
	else:
		$Padder/Contents/Selected/Over.hide()
	
	Deselect()

func Deselect():
	$Padder/Contents/Selected.hide()
	if(_fileID == charEditor.curFile and !_forceColorNonState):
		set_self_modulate("018200")
	else:
		set_self_modulate("820100")
	$Action.set_tooltip(_state["StateDoc"])
	#$Contents/MainLine/Shortdoc.show()

func Select():
	$Padder/Contents/Selected.show()
	set_self_modulate("826800")
	$Padder/Contents/MainLine/Shortdoc.hide()
	$Action.set_tooltip(_state["StateFullDoc"])
	charEditor._navigationSelected = self
	

func GetStateData():
	return _state

func GetFileID():
	return _fileID

func SetButtonText(text):
	$Padder/Contents/MainLine/Name.set_text(text)

var _lastClickTime = null
func _on_Action_pressed():
	charEditor.Navigation_SelectState(self)
	
	var clickTime = OS.get_ticks_msec()
	if(_lastClickTime != null and clickTime < _lastClickTime + 500):
		charEditor.Navigation_OpenState()
	else:
		_lastClickTime = clickTime
