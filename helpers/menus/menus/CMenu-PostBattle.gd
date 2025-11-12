# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneMenuCore.gd"

var _players = []
var _battleInitData


func Setup(_menuData, menuParams):
	var stateHandle = menuParams["StateHandle"]
	var engine = stateHandle.Engine()
	
	var nbPlayers = stateHandle.GlobalGet("_NbPlayers")
	_battleInitData = stateHandle.IDGlobalGet("BattleInitData")
	_configData = stateHandle.ConfigData()
	
	for pid in range(nbPlayers):
		var pdevice = engine.GetInputDevice(pid)
		CreatePlayer(pid, pdevice, IsWinner(menuParams, pid), menuParams)

func IsWinner(menuParams, pid):
	var winner = menuParams["Caller"]
	return pid == winner

func CreatePlayer(pid, device, winner, menuParams):
	var player = Castagne.Loader.Load("res://castagne/helpers/menus/helpers/postbattle/default/CMenu-PostBattle-Player.tscn").instance()
	player.InitPlayer(self, pid, device, winner, menuParams)
	_players.push_back(player)
	$Players.add_child(player)

func TryRematch():
	for p in _players:
		if(!p.wantsRematch):
			return false
	Rematch()

func Rematch():
	queue_free()
	
	# Hacky but whatever for the current system
	var e = Castagne.InstanceCastagneEngine(_battleInitData, _configData)
	get_tree().get_root().add_child(e)

func GoToMainMenu():
	queue_free()
	Castagne.Menus.FindMenuCallback("BackToMainMenu").call_func(null)
