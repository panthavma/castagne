extends Control

var nullTemplate = ["## Entity Init", "## Entity Behavior", "## Entity Variables"]

var templates
func InitPopup():
	templates = {
		"Empty":[null, null, null]
	}
	
	var editor = $"../../.."
	var character = editor.character
	
	for i in range(character["NbFiles"]):
		for s in character[i]["States"]:
			if(s.begins_with("EntityTemplate-")):
				var tname = s.right(15)
				var sep = -1
				var id = -1
				
				if(tname.ends_with("-Init")):
					sep = tname.length() - 5
					id = 0
				if(tname.ends_with("-Action")):
					sep = tname.length() - 7
					id = 1
				if(tname.ends_with("-Variables")):
					sep = tname.length() - 10
					id = 2
				
				if(id < 0 or sep < 1):
					continue
				
				tname = tname.left(sep)
				
				if(!templates.has(tname)):
					templates[tname] = [null, null, null]
				
				var tcode = character[i]["States"][s]["Text"]
				templates[tname][id] = tcode
	
	var templateList = $Central/TemplateList
	templateList.clear()
	for tname in templates:
		templateList.add_item(tname)
	
	$Central/TemplateList.select(0)
	
	$StateName.set_text("")
	_on_StateName_text_changed("")
	SelectTemplate()
	
	$StateName.grab_focus()

func SelectTemplate(selectedID = 0):
	var stemplate = templates[templates.keys()[selectedID]]
	$Central/CodePreviewInit.set_text((stemplate[0] if stemplate[0] != null else nullTemplate[0]))
	$Central/CodePreviewCode.set_text((stemplate[1] if stemplate[1] != null else nullTemplate[1]))
	$CreateVariables.set_text("Create Variables Block" + (" (Empty)" if stemplate[2] == null else ""))

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
	
	var stemplate = templates[templates.keys()[$Central/TemplateList.get_selected_items()[0]]]
	
	var initStateName = "Init--"+ename
	var actionStateName = ename+"--Action"
	var variablesStateName = "Variables--"+ename
	
	var editor = $"../../.."
	var character = editor.character
	
	if(character[editor.curFile]["States"].has(initStateName) or character[editor.curFile]["States"].has(actionStateName)):
		print("CECPopupNewState: Name collision") # never reached i think
		return
	else:
		character[editor.curFile]["Modified"] = true
		character[editor.curFile]["States"][initStateName] = {"Text":stemplate[0]+"\nTransition("+actionStateName+")"}
		character[editor.curFile]["States"][actionStateName] = {"Text":stemplate[1]}
		if($CreateVariables.is_pressed()):
			character[editor.curFile]["States"][variablesStateName] = {"Text":stemplate[2]}
	
	var curFile = editor.curFile
	editor.SaveFile()
	editor.ReloadCodePanel()
	editor.ReloadEngine()
	editor.ChangeCodePanelState(initStateName, curFile)

func _on_StateName_text_changed(new_text):
	var t = $StateName.get_text().strip_edges()
	$Buttons/Create.set_disabled(!IsTextValid())
	
func IsTextValid():
	var ename = $StateName.get_text().strip_edges()
	if(ename.empty() or ename == "Main"):
		return false
	
	var editor = $"../../.."
	var character = editor.character
	
	var initStateName = "Init--"+ename
	var actionStateName = ename+"--Action"
	var variablesStateName = "Variables--"+ename
	
	var statesToCheck = [initStateName, actionStateName, variablesStateName]
	
	for i in range(editor.curFile, -1, -1):
		for s in statesToCheck:
			if(character[i]["States"].has(s)):
				return false
	
	return true



