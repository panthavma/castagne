# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control


var entity
var originalName
func InitPopup():
	var editor = $"../../.."
	var character = editor.character
	
	originalName = editor._navigationSelected.GetStateData()["Name"]
	
	entity = Castagne.Parser._GetEntityNameFromStateName(originalName)
	originalName = Castagne.Parser._GetPureStateNameFromStateName(originalName)
	
	if(entity == null):
		$VBox/Label.set_text("Rename State - "+originalName)
	else:
		$VBox/Label.set_text("Rename State - "+originalName+" ("+entity+")")
	
	$VBox/StateName.set_text(originalName)
	$VBox/StateName.set_placeholder(originalName)
	_on_StateName_text_changed("")
	
	$VBox/StateName.grab_focus()

func _on_Create_pressed():
	CreateState()
func CreateState():
	var sname = $VBox/StateName.get_text().strip_edges()
	if(!IsTextValid()):
		return
	sname = _GetFinalStateName(sname)
	
	var editor = $"../../.."
	var character = editor.character
	
	if(character[editor.curFile]["States"].has(sname)):
		print("CECPopupRenameState: Name collision") # never reached i think
		return
		
	character[editor.curFile]["Modified"] = true
	character[editor.curFile]["States"][sname] = character[editor.curFile]["States"][_GetFinalStateName(originalName)]
	character[editor.curFile]["States"].erase(_GetFinalStateName(originalName))
	
	var curFile = editor.curFile
	editor.SaveFile()
	editor.ReloadCodePanel()
	editor.ReloadEngine()
	editor.ChangeCodePanelState(sname, curFile)

func _on_StateName_text_changed(new_text):
	var t = $VBox/StateName.get_text().strip_edges()
	$VBox/Buttons/Create.set_disabled(!IsTextValid())
	
func IsTextValid():
	var sname = $VBox/StateName.get_text().strip_edges()
	if(sname.empty()):
		return false
	sname = _GetFinalStateName(sname)
	
	var editor = $"../../.."
	var character = editor.character
	
	return !(character[editor.curFile]["States"].has(sname))



func _GetFinalStateName(stateName):
	if(entity == null):
		return stateName
	return entity+"---"+stateName
