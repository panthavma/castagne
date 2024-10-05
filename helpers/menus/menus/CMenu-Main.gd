# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneMenuCore.gd"

onready var _deviceSelect = $DeviceSelect

func MCB_MMTraining(_args):
	StartDeviceSelect(funcref(self, "TrainingStart"))
func MCB_MMLocalBattle(_args):
	StartDeviceSelect(funcref(self, "LocalBattleStart"))


func _MatchCSSParamsCommon(devices, mode):
	return {
		"Devices": devices,
		"CallbackBack": FindMenuCallback("BackToMainMenu"),
		"CallbackBackParams": [null, _configData],
		"CallbackAdvance": FindMenuCallback("StartMatchFromCSS"),
		"CallbackAdvanceParams": {
			"Mode": mode,
		}
	}

func TrainingStart(devices):
	queue_free()
	var menuParams = _MatchCSSParamsCommon(devices, Castagne.GAMEMODES.MODE_TRAINING)
	get_tree().get_root().add_child(Castagne.Menus.InstanceMenu("CSS", menuParams, _configData))

func LocalBattleStart(devices):
	queue_free()
	var menuParams = _MatchCSSParamsCommon(devices, Castagne.GAMEMODES.MODE_BATTLE)
	get_tree().get_root().add_child(Castagne.Menus.InstanceMenu("CSS", menuParams, _configData))





func StartDeviceSelect(advanceCallback):
	_active = false
	_deviceSelect.Start(self, advanceCallback, funcref(self, "StopDeviceSelect"))

func StopDeviceSelect():
	_active = true
