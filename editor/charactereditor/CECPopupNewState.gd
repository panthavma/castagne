# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control


var entity = null
var templates
func InitPopup():
	templates = {
		"Empty":""
	}
	
	var editor = $"../../.."
	var character = editor.character
	
	entity = Castagne.Parser._GetEntityNameFromStateName(editor.curState)
	
	if(entity == null):
		$Label.set_text("New State")
	else:
		$Label.set_text("New State ("+entity+")")
	
	for i in range(character["NbFiles"]):
		for s in character[i]["States"]:
			if(s.begins_with("StateTemplate-")):
				var tname = s.right(14)
				var tcode = character[i]["States"][s]["Text"]
				if(tcode.begins_with("TagLocal(")):
					var tcodeLineEnd = tcode.find("\n")
					if(tcodeLineEnd == -1):
						tcode = ""
					else:
						tcode = tcode.right(tcodeLineEnd+1)
				templates[tname] = tcode
	
	var templateList = $TemplateList
	templateList.clear()
	for tname in templates:
		templateList.add_item(tname)
	
	$TemplateList.select(0)
	
	$StateName.set_text("")
	_on_StateName_text_changed("")
	SelectTemplate()
	
	$StateName.grab_focus()

func SelectTemplate(selectedID = 0):
	$CodePreview.set_text(templates[templates.keys()[selectedID]])

func _on_Create_pressed():
	CreateState()
func _on_TemplateList_item_selected(index):
	SelectTemplate(index)
func _on_TemplateList_item_activated(index):
	SelectTemplate(index)
	CreateState()
func CreateState(override = false):
	var sname = $StateName.get_text().strip_edges()
	if(!IsTextValid(override)):
		return
	sname = _GetFinalStateName(sname)
	
	var stemplateCode = templates[templates.keys()[$TemplateList.get_selected_items()[0]]]
	
	if(override):
		stemplateCode = "# Override\nCallParent()\n"
	
	var editor = $"../../.."
	var character = editor.character
	
	if(character[editor.curFile]["States"].has(sname)):
		print("CECPopupNewState: Name collision") # never reached i think
	else:
		character[editor.curFile]["Modified"] = true
		character[editor.curFile]["States"][sname] = {}
		character[editor.curFile]["States"][sname]["Text"] = stemplateCode
	
	var curFile = editor.curFile
	editor.SaveFile()
	editor.ReloadCodePanel()
	editor.ReloadEngine()
	editor.ChangeCodePanelState(sname, curFile)

func _on_StateName_text_changed(new_text):
	$Buttons/Create.set_disabled(!IsTextValid())
	$Buttons/Override.set_disabled(!IsTextValid(true))
	
func IsTextValid(overrideOnly = false):
	var sname = $StateName.get_text().strip_edges()
	if(sname.empty()):
		return false
	sname = _GetFinalStateName(sname)
	
	var editor = $"../../.."
	var character = editor.character
	if(character[editor.curFile]["States"].has(sname)):
		return false
	
	for i in range(editor.curFile-1, -1, -1):
		if(character[i]["States"].has(sname)):
			return overrideOnly
	
	return !overrideOnly


func _GetFinalStateName(stateName):
	if(entity == null):
		return stateName
	return entity+"---"+stateName


func _on_Override_pressed():
	CreateState(true)
