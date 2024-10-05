# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneMenuCore.gd"

# TODO: Single/list of device, disable other


var _shouldResume = false
var _battleInitData
var _engine
var _mode

func Setup(menuData, menuParams):
	.Setup(menuData, menuParams)
	_battleInitData = menuParams["BattleInitData"]
	_engine = menuParams["Engine"]
	_mode = _battleInitData["mode"]
	CloseMenu()

func OpenMenu(device):
	get_node(".").show()
	_active = true
	_shouldResume = false

func CloseMenu():
	get_node(".").hide()
	_active = false


func SyncWithEngine(stateHandle, cmMenus):
	if(_shouldResume):
		cmMenus.ClosePauseMenu(stateHandle)
		_shouldResume = false

func MCB_Resume(_params):
	_shouldResume = true

func MCB_ReturnToCSS(_params):
	if(_mode == Castagne.GAMEMODES.MODE_EDITOR):
		MCB_Resume(null)
		return
	
	_engine.queue_free()
	# TODO

func MCB_ReturnToMM(_params):
	if(_mode == Castagne.GAMEMODES.MODE_EDITOR):
		MCB_Resume(null)
		return
	
	_engine.queue_free()
	var menu = Castagne.Menus.InstanceMenu("MainMenu", null, _configData)
	get_tree().get_root().add_child(menu)
