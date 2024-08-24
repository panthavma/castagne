# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var smallErrorWindow
var errorData = []
var analyzer
var phaseButtonsRoot
var currentPhase = "Action"
var compilStatusButton
func SetupTool():
	smallErrorWindow = $CompileSmall/Errors
	toolName = "Compiler Output"
	toolDescription = "Base tool that shows the results of compilation, especially errors."
	Castagne.connect("castagne_error", self, "OnError")
	Castagne.connect("castagne_log", self, "OnLog")
	compilStatusButton = editor.get_node("BottomPanel/BMiniPanel/HBox/Middle/TopBar/Other/CompilStatus")
	UpdateCompilStatusButton()
	
	analyzer = $Analyzer
	phaseButtonsRoot = $Analyzer/Sidebar/Phases
	for b in phaseButtonsRoot.get_children():
		b.connect("pressed", self, "ChangePhase", [b.get_name()])
		b.set_toggle_mode(true)
	ChangePhase("Action")

var acceptRuntimeErrors = false

func ResetErrorData():
	smallErrorWindow.clear()
	errorData = []
	UpdateCompilStatusButton()

func OnEngineRestarting(_engine, _battleInitData):
	ResetErrorData()
	acceptRuntimeErrors = false
	RefreshState()
	UpdateCompilStatusButton()

func OnEngineRestarted(engine):
	ResetErrorData()
	smallErrorWindow.add_item("No compilation errors!", null, false)
	acceptRuntimeErrors = true
	RefreshState()
	
	RefreshVariablesStats(engine._memory)
	UpdateCompilStatusButton()

func OnEngineInitError(_engine):
	RefreshState()
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
		var stateLine = -1
		
		var states = editor.character[fileID]["States"]
		for sName in states:
			var s = states[sName]
			var sLineStart = s["LineStart"]
			var sLineEnd = s["LineEnd"]
			if(sLineStart <= line and line < sLineEnd):
				state = sName
				stateLine = line - sLineStart
				if(!s["StateFlags"].has("Error")):
					s["StateFlags"] += ["Error"]
		
		var ed = {
			"FileID":fileID,
			"State":state,
			"Line":stateLine,
			"Runtime":false,
			"Error":true,
		}
		
		errorData += [ed]
		
		var t = "["+str(e["Type"])+"] " + filePath +" - "+state+" l." + str(stateLine) + ": " + e["Text"]
		smallErrorWindow.add_item(t)
	UpdateCompilStatusButton()

func OnError(message):
	AddLogOrError("Error /!\\ " + message, true)
func OnLog(message):
	AddLogOrError(message)

func AddLogOrError(message, error = false):
	if(errorData.size() == 0):
		ResetErrorData()
	
	if(!acceptRuntimeErrors):
		return
	
	var ed = {
		"Runtime":true,
		"Error":error,
	}
	errorData += [ed]
	
	smallErrorWindow.add_item(message)
	smallErrorWindow.select(smallErrorWindow.get_item_count() - 1)
	smallErrorWindow.ensure_current_is_visible()
	UpdateCompilStatusButton()


func UpdateCompilStatusButton():
	var nbErrors = 0
	for ed in errorData:
		if(ed["Error"]):
			nbErrors += 1
	if(nbErrors == 0):
		compilStatusButton.set_text("No errors")
	else:
		compilStatusButton.set_text(str(nbErrors)+" errors!")


func _on_Errors_item_activated(index):
	if(errorData.size() <= index):
		return
	var ed = errorData[index]
	if(ed["Runtime"]):
		return
	editor.ChangeCodePanelState(ed["State"], ed["FileID"], ed["Line"])








func RefreshState():
	var stateName = analyzer.get_node("Sidebar/StateName").get_text()
	var stateNameTitle = analyzer.get_node("Main/State")
	stateNameTitle.set_text("State: " + str(stateName) + " ("+str(currentPhase)+")")
	var bytecodeDisplay = analyzer.get_node("Main/Display")
	
	var bytecodeText = "Engine not started!"
	var engine = editor.engine
	if(engine != null):
		bytecodeText = "Fighter scripts not found!"
		var fighterScripts = engine.GetFighterAllScripts(0)
		if(fighterScripts != null):
			bytecodeText = "State not found!"
			if(fighterScripts.has(stateName)):
				bytecodeText = "Phase not found!"
				if(fighterScripts[stateName].has(currentPhase)):
					bytecodeText = ParseFighterScript(fighterScripts[stateName][currentPhase])
	
	bytecodeDisplay.set_text(bytecodeText)

func ParseFighterScript(script, linePrefix = ""):
	var configData = editor.editor.configData
	var moduleFunctions = configData.GetModuleFunctions()
	var funcrefReverseLookup = {}
	
	for fName in moduleFunctions:
		var fref = moduleFunctions[fName]["ActionFunc"]
		funcrefReverseLookup[fref] = fName
	
	var branchFunctions = Castagne.Parser._branchFunctions
	var branchFunctionsFuncrefsNames = []
	for fName in branchFunctions:
		var fref = branchFunctions[fName]
		#funcrefReverseLookup[fref] = fName
		branchFunctionsFuncrefsNames += [fref.get_function()]
	
	var t = ""
	for a in script:
		var fref = a[0]
		var fname = str(fref)
		if(funcrefReverseLookup.has(fref)):
			fname = str(funcrefReverseLookup[fref])
		
		if(fref.get_function() in branchFunctionsFuncrefsNames):
			fname = fref.get_function().right(11) # InstructionX
			t += linePrefix+fname + str(a[1][2]) + ":\n"
			t += ParseFighterScript(a[1][0], linePrefix + "    ")
			var elseT = ParseFighterScript(a[1][1], linePrefix + "    ")
			if(!(elseT.strip_edges().empty())):
				t += linePrefix+"else\n"
				t += elseT
			t += linePrefix+"endif\n"
		else:
			t += linePrefix + fname + "("
			var i = 0
			for b in a[1]:
				if(i > 0):
					t+= ", "
				t += str(b)
				i += 1
			t += ")\n"
	return t

func ChangePhase(newPhase):
	currentPhase = newPhase
	
	for b in phaseButtonsRoot.get_children():
		b.set_pressed_no_signal(b.get_name() == newPhase)
	
	RefreshState()



func _on_StateName_text_changed(_new_text):
	RefreshState()


func RefreshVariablesStats(memory):
	var nbVarsGlobal = memory._memoryGlobal.size()
	var nbVarsPlayers = 0
	var nbVarsEntities = 0
	for m in memory._memoryPlayers:
		if(m != null):
			nbVarsPlayers += m.size()
	for m in memory._memoryEntities:
		if(m != null):
			nbVarsEntities += m.size()
	
	analyzer.get_node("Sidebar/VariablesTotal").set_text("Global: "+str(nbVarsGlobal)+
		" / Players: "+str(nbVarsPlayers)+" / Entities: "+str(nbVarsEntities)+"\n"+
		"Total: "+str(nbVarsGlobal+nbVarsPlayers+nbVarsEntities))

