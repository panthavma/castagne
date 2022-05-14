extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var smallErrorWindow
var errorData = []
func SetupTool():
	smallErrorWindow = $CompileSmall/Errors
	toolName = "Compiler Output"
	toolDescription = "Base tool that shows the results of compilation, especially errors."

func OnEngineRestarting(engine, battleInitData):
	smallErrorWindow.clear()
	errorData = []

func OnEngineRestarted(engine):
	smallErrorWindow.add_item("No compilation errors!", null, false)

func OnEngineInitError(engine):
	for e in Castagne.Parser._errors:
		var filePath = e["FilePath"]
		var line = e["LineID"]
		var fileID = 0
		for i in range(editor.character["NbFiles"]):
			if(editor.character[i]["Path"] == filePath):
				fileID = i
		
		filePath = filePath.right(filePath.find_last("/")+1)
		
		var state = ""
		var stateLine = 0
		
		var states = editor.character[fileID]["States"]
		for sName in states:
			var s = states[sName]
			var sLineStart = s["LineStart"]
			var sLineEnd = s["LineEnd"]
			if(sLineStart <= line and line < sLineEnd):
				state = sName
				stateLine = line - sLineStart
		
		var ed = {
			"FileID":fileID,
			"State":state,
			"Line":stateLine,
		}
		
		errorData += [ed]
		
		var t = "["+str(e["Type"])+"] " + filePath +" - "+state+" l." + str(stateLine) + ": " + e["Text"]
		smallErrorWindow.add_item(t)


func _on_Errors_item_activated(index):
	if(errorData.size() <= index):
		return
	var ed = errorData[index]
	editor.ChangeCodePanelState(ed["State"], ed["FileID"], ed["Line"])
