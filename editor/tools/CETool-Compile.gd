extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var smallErrorWindow
var errorData = []
func SetupTool():
	smallErrorWindow = $CompileSmall/Errors
	toolName = "Compiler Output"
	toolDescription = "Base tool that shows the results of compilation, especially errors."
	Castagne.connect("castagne_error", self, "OnError")
	Castagne.connect("castagne_log", self, "OnLog")

var acceptRuntimeErrors = false

func ResetErrorData():
	smallErrorWindow.clear()
	errorData = []

func OnEngineRestarting(engine, battleInitData):
	ResetErrorData()
	acceptRuntimeErrors = false

func OnEngineRestarted(engine):
	ResetErrorData()
	smallErrorWindow.add_item("No compilation errors!", null, false)
	acceptRuntimeErrors = true

func OnEngineInitError(engine):
	var onlyRuntimeErrors = true
	for ed in errorData:
		if(!ed["Runtime"]):
			onlyRuntimeErrors = false
			break
	if(onlyRuntimeErrors):
		ResetErrorData()
	
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
			"Runtime":false,
		}
		
		errorData += [ed]
		
		var t = "["+str(e["Type"])+"] " + filePath +" - "+state+" l." + str(stateLine) + ": " + e["Text"]
		smallErrorWindow.add_item(t)

func OnError(message):
	AddLogOrError("Error /!\\ " + message)
func OnLog(message):
	AddLogOrError(message)

func AddLogOrError(message):
	if(errorData.size() == 0):
		ResetErrorData()
	
	if(!acceptRuntimeErrors):
		return
	
	var ed = {
		"Runtime":true,
	}
	errorData += [ed]
	
	smallErrorWindow.add_item(message)
	smallErrorWindow.select(smallErrorWindow.get_item_count() - 1)
	smallErrorWindow.ensure_current_is_visible()


func _on_Errors_item_activated(index):
	if(errorData.size() <= index):
		return
	var ed = errorData[index]
	if(ed["Runtime"]):
		return
	editor.ChangeCodePanelState(ed["State"], ed["FileID"], ed["Line"])
