# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

export var PlayersPath = "Players"

var globalWidgets = []
var playerWidgets = []
var playerRoots = []

func UIInitialize(stateHandle, battleInitData):
	# 1. Find all global widgets
	globalWidgets = SearchForWidgets(self)
	for w in globalWidgets:
		w.WidgetInitialize(stateHandle, battleInitData)
	
	# 2. Spawn Player UI
	var nbPlayers = battleInitData["players"].size() - 1
	for pid in nbPlayers:
		var pBID = Castagne.BattleInitData_GetPlayer(battleInitData, pid)
		var widgets = []
		var playerUIRoot = null
		
		# What scene should we use?
		var playerUIScenePath = stateHandle.ConfigData().Get("UIPlayerRootScene")
		if(pBID.has("uiplayerroot-path") and pBID["uiplayerroot-path"] != null):
			playerUIScenePath = pBID["uiplayerroot-path"]
		
		# Should we actually spawn the player UI?
		if(pBID.has("uiplayerroot-use") and !pBID["uiplayerroot-use"]):
			playerUIScenePath = null
		
		# Spawn the UI
		if(playerUIScenePath != null and !playerUIScenePath.empty()):
			var playerUIScene = Castagne.Loader.Load(playerUIScenePath)
			if(playerUIScene == null):
				Castagne.Error("UIInitialize: UI Player Root not found: "+str(playerUIScenePath))
			else:
				playerUIRoot = playerUIScene.instance()
				_AddPlayerRoot(playerUIRoot, pid)
				var mirror = (pid == 1)
				playerUIRoot.UIInitialize(stateHandle, battleInitData, pid, mirror)
				widgets = SearchForWidgets(playerUIRoot)
				for w in widgets:
					w.isMirrored = mirror
					w.WidgetInitialize(stateHandle, battleInitData)
		playerWidgets.push_back(widgets)
		playerRoots.push_back(playerUIRoot)

func _AddPlayerRoot(node, pid):
	# :TODO: Custom player root placement
	var playersRoot = get_node(PlayersPath)
	playersRoot.add_child(node)

func AddPlayerWidget(pid, widget, hookPoint):
	if(pid < 0 or pid >= playerRoots.size()):
		Castagne.Error("Trying to add a widget to invalid player ID: "+str(pid))
		return false
	
	var pRoot = playerRoots[pid]
	if(pRoot == null):
		Castagne.Error("Trying to add a widget to an empty player root: "+str(pid))
		return false
	
	if(pRoot.AddWidget(widget, hookPoint)):
		playerWidgets[pid].push_back(widget)
		return true
	else:
		return false

func UIUpdate(stateHandle):
	for w in globalWidgets:
		w.WidgetUpdate(stateHandle)
	
	for pid in range(playerWidgets.size()):
		stateHandle.PointToPlayerMainEntity(pid)
		for w in playerWidgets[pid]:
			w.WidgetUpdate(stateHandle)


func SearchForWidgets(node):
	var w = []
	
	if(node.has_method("WidgetInitialize")):
		w.push_back(node)
	
	for c in node.get_children():
		w += SearchForWidgets(c)
	return w
