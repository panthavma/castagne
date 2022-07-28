extends Control


var templates
func InitPopup():
	templates = {
		"Empty":""
	}
	
	var editor = $"../../.."
	var character = editor.character
	
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
func CreateState():
	var sname = $StateName.get_text().strip_edges()
	if(sname.empty()):
		return
	
	var stemplateCode = templates[templates.keys()[$TemplateList.get_selected_items()[0]]]
	
	var editor = $"../../.."
	var character = editor.character
	
	if(character[editor.curFile]["States"].has(sname)):
		print("CECPopupNewState: Name collision")
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
	var t = $StateName.get_text().strip_edges()
	$Buttons/Create.set_disabled(t.empty())
	




