# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

var existingEntities
var entitiesKeys
func InitPopup():
	var editor = $"../../.."
	var character = editor.character
	
	existingEntities = {
		"None":"Choose this when you want to make an entity from scratch, including system stuff. This is for experts only."
	}
	
	for i in range(character["NbFiles"]):
		for s in character[i]["States"]:
			var e = Castagne.Parser._GetEntityNameFromStateName(s)
			
			if(e == null):
				continue
			if(e in existingEntities):
				continue
			
			existingEntities[e] = character[i]["States"][s]["StateFullDoc"]
	
	entitiesKeys = existingEntities.keys()
	entitiesKeys.erase("Base")
	entitiesKeys.erase("None")
	entitiesKeys.sort()
	entitiesKeys.push_front("None")
	entitiesKeys.push_front("Base")
	
	var entityList = $Central/EntityList
	entityList.clear()
	for e in entitiesKeys:
		entityList.add_item(e)
	
	entityList.select(0)
	
	$StateName.set_text("")
	_on_StateName_text_changed("")
	SelectTemplate()
	
	$StateName.grab_focus()

func SelectTemplate(selectedID = 0):
	var ename = entitiesKeys[selectedID]
	$Central/Description.set_text(existingEntities[ename])
	$CreateVariables.set_text("Create Variables Block")

func _on_Create_pressed():
	CreateState()
func _on_TemplateList_item_selected(index):
	SelectTemplate(index)
func _on_TemplateList_item_activated(index):
	SelectTemplate(index)
	CreateState()
func CreateState():
	var ename = $StateName.get_text().strip_edges()
	if(!IsTextValid()):
		return
	
	var eparentname = entitiesKeys[$Central/EntityList.get_selected_items()[0]]
	
	var subentityStateName = ename + "---Subentity"
	var variablesStateName = ename + "---Variables"
	var actionStateName = ename + "---Action"
	
	var editor = $"../../.."
	var character = editor.character
	
	if(character[editor.curFile]["States"].has(subentityStateName) or character[editor.curFile]["States"].has(actionStateName)):
		print("CECPopupNewState: Name collision") # never reached i think
		return
	else:
		character[editor.curFile]["Modified"] = true
		character[editor.curFile]["States"][subentityStateName] = {"Text":"## Describe entity here\nSkeleton: "+str(eparentname)}
		character[editor.curFile]["States"][actionStateName] = {"Text":"## Write your behavior here\nCallParent()"}
		if($CreateVariables.is_pressed()):
			character[editor.curFile]["States"][variablesStateName] = {"Text":"## Put variables here"}
	
	var curFile = editor.curFile
	editor.SaveFile()
	editor.ReloadCodePanel()
	editor.ReloadEngine()
	editor.ChangeCodePanelState(actionStateName, curFile)

func _on_StateName_text_changed(new_text):
	var t = $StateName.get_text().strip_edges()
	$Buttons/Create.set_disabled(!IsTextValid())
	
func IsTextValid():
	var ename = $StateName.get_text().strip_edges()
	if(ename.empty() or ename == "Main"):
		return false
	
	var editor = $"../../.."
	var character = editor.character
	
	var subentityStateName = ename + "---Subentity"
	var variablesStateName = ename + "---Variables"
	var actionStateName = ename + "---Action"
	
	var statesToCheck = [subentityStateName, actionStateName, variablesStateName]
	
	for i in range(editor.curFile, -1, -1):
		for s in statesToCheck:
			if(character[i]["States"].has(s)):
				return false
	
	return true



