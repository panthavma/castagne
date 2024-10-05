# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "CMenu-Pause.gd"

func SyncWithEngine(stateHandle, cmMenus):
	.SyncWithEngine(stateHandle, cmMenus)
	
	var cbData = {
		"StateHandle": stateHandle,
		"CMMenus": cmMenus,
	}
	
	for eid in stateHandle.GlobalGet("_ActiveEntities"):
		stateHandle.PointToEntity(eid)
		cmMenus.CallFunction("FlagNext", ["TF_Training"], stateHandle)
	
	for option in _menuOptions:
		option.UseMenuAction("Training", cbData)

