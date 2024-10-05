# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneMenuElement.gd"

var selectedListOption = 0
var listOptions

func Setup():
	if(!optionData.has("List")):
		Castagne.Error("CME_List: Invalid list")
		return
	
	if(optionData.has("Action") and optionData.has("ActionParams")):
		var a = FindMenuCallback(optionData["Action"])
		if(a != null):
			SetMenuAction("Confirm", a, optionData["ActionParams"])
	
	var defaultOption = 0
	if(optionData.has("ListDefaultOption")):
		defaultOption = optionData["ListDefaultOption"]
	listOptions = optionData["List"].duplicate(true)
	SelectOption(defaultOption)
	
	SetMenuAction("Right", funcref(self, "SelectNextOption"), null)
	SetMenuAction("Left", funcref(self, "SelectPreviousOption"), null)

func SelectOption(optionID):
	selectedListOption = optionID
	if(selectedListOption < 0):
		selectedListOption = 0
	if(selectedListOption >= listOptions.size()):
		selectedListOption = listOptions.size()-1
	UpdateOptionDisplay()

func SelectNextOption(_p):
	SelectOption(selectedListOption+1)
func SelectPreviousOption(_p):
	SelectOption(selectedListOption-1)

func UpdateOptionDisplay():
	pass


func MCB_TrainingFlagBroadcast(params, cbData):
	var stateHandle = cbData["StateHandle"]
	var cmMenus = cbData["CMMenus"]
	
	for eid in stateHandle.GlobalGet("_ActiveEntities"):
		stateHandle.PointToEntity(eid)
		var flags = null
		if(selectedListOption >= 0 and selectedListOption < params.size()):
			flags = params[selectedListOption]
		if(flags != null):
			for f in flags:
				cmMenus.CallFunction("FlagNext", [f], stateHandle)
