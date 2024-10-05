# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var prefabInputButton = preload("res://castagne/editor/tools/inputs/CETool-Inputs-Button.tscn")
var inputPlayerData = []
var _inputGridRoot
var _inputGrids = []
var _inputOverrideButton
var _inputControl
var _nbPlayers
var inputPID
func SetupTool():
	_inputGridRoot = $InputVisu/Players
	inputPID = $InputVisu/Controls/PID
	_inputOverrideButton = $InputVisu/Controls/OverrideInputs
	_inputControl = $InputVisu/Controls
	toolName = "Input Viewer"
	toolDescription = "Basic tool to check what inputs are pressed or not."

func ClearInputPanel():
	for c in _inputGridRoot.get_children():
		c.queue_free()
	_inputGrids = []

func CreatePanelForPlayer(engine):
	ClearInputPanel()
	
	var castagneInput = engine.configData.Input()
	var physInputs = castagneInput.GetPhysicalInputs()
	
	var pidToShow = inputPID.get_value() - 1
	var inputGridToShow = null
	
	for pid in range(_nbPlayers):
		var inputGridScroll = ScrollContainer.new()
		var inputGrid = GridContainer.new()
		inputGrid.set_h_size_flags(SIZE_EXPAND_FILL)
		inputGrid.set_v_size_flags(SIZE_EXPAND_FILL)
		inputGridScroll.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		inputGrid.set_columns(4)
		inputGridScroll.hide()
		if(pid == pidToShow):
			inputGridToShow = inputGridScroll
		inputGridScroll.add_child(inputGrid)
		_inputGridRoot.add_child(inputGridScroll)
		_inputGrids.push_back(inputGrid)
		for physicalInput in physInputs:
			var gameInputNames = castagneInput.PhysicalInputGetGameInputNames(physicalInput)
			for giName in gameInputNames:
				AddButtonInput(inputGrid, giName)
	
	ShowPID(pidToShow)
	inputGridToShow.show()

func AddButtonInput(inputGrid, gameInputName):
	var button = prefabInputButton.instance()
	button.Setup(gameInputName)
	inputGrid.add_child(button)

func OnEngineRestarting(engine, battleInitData):
	ClearInputPanel()
	
	var editorModule = engine.configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.EDITOR)
	editorModule.connect("EngineTick_AIStartEntity", self, "EngineTick_AIStartEntity")
	editorModule.connect("EngineTick_InputEnd", self, "EngineTick_InputEnd")
	
	var nbPlayers = battleInitData["players"].size() - 1
	inputPID.set_max(nbPlayers)
	_nbPlayers = nbPlayers
	while(inputPlayerData.size() < _nbPlayers):
		inputPlayerData.push_back({"Override":false, "Device":null})
	
	var castagneInput = engine.configData.Input()
	
	for pid in range(nbPlayers):
		var p = Castagne.BattleInitData_GetPlayer(battleInitData, pid)
		inputPlayerData[pid]["Device"] = castagneInput.GetDevice(p["inputdevice"])["DisplayName"]

func OnEngineRestarted(engine):
	CreatePanelForPlayer(engine)

func OnEngineInitError(_engine):
	ClearInputPanel()

func ShowPID(pidToShow):
	for pid in range(_nbPlayers):
		var g = _inputGridRoot.get_child(pid)
		if(pid == pidToShow):
			g.show()
			var ipd = inputPlayerData[pid]
			_inputOverrideButton.set_pressed_no_signal(ipd["Override"])
			_inputControl.get_node("Device").set_text("Device: "+str(ipd["Device"]))
		else:
			g.hide()


func EngineTick_AIStartEntity(stateHandle):
	var pid = stateHandle.EntityGet("_Player")
	
	# If not in input override mode, don't do anything
	if(!inputPlayerData[pid]["Override"]):
		return
	
	var inputs = stateHandle.EntityGet("_Inputs")
	if(inputs == null):
		return
	
	if(_inputGrids.size() <= pid):
		return
	var inputGrid = _inputGrids[pid]
	if(inputGrid == null):
		return
	
	for c in inputGrid.get_children():
		c.OverrideInputs(inputs)
	stateHandle.EntitySet("_Inputs", inputs)

func EngineTick_InputEnd(stateHandle):
	for pid in range(_nbPlayers):
		stateHandle.PointToPlayer(pid)
		var mainEID = stateHandle.PlayerGet("MainEntity")
		if(mainEID == -1):
			continue
		
		stateHandle.PointToEntity(mainEID)
		var inputs = stateHandle.EntityGet("_Inputs")
		if(inputs.empty()):
			continue
		
		# If in input override mode, don't update
		if(inputPlayerData[pid]["Override"]):
			continue
		
		if(_inputGrids.size() <= pid):
			return
		var inputGrid = _inputGrids[pid]
		if(inputGrid == null):
			return
		
		for c in inputGrid.get_children():
			c.Update(inputs)


func _on_OverrideInputs_toggled(button_pressed):
	inputPlayerData[inputPID.get_value() - 1]["Override"] = button_pressed


func _on_PID_value_changed(value):
	ShowPID(value - 1)
