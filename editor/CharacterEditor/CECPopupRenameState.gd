extends Control


var originalName
func InitPopup():
	var editor = $"../../.."
	var character = editor.character
	
	originalName = editor._navigationSelected.GetStateData()["Name"]
	
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
	
	var editor = $"../../.."
	var character = editor.character
	
	if(character[editor.curFile]["States"].has(sname)):
		print("CECPopupRenameState: Name collision") # never reached i think
		return
		
	character[editor.curFile]["Modified"] = true
	character[editor.curFile]["States"][sname] = character[editor.curFile]["States"][originalName]
	character[editor.curFile]["States"].erase(originalName)
	
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
	
	var editor = $"../../.."
	var character = editor.character
	
	return !(character[editor.curFile]["States"].has(sname))



