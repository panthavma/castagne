extends Node

export var PlayersPath = "Players"

var globalWidgets = []
var playerWidgets = []

func UIInitialize(stateHandle, battleInitData):
	_FindAllManualWidgets()
	
	#for w in globalWidgets:
	#	w["Node"].WidgetInitialize(stateHandle, battleInitData, w["CASPData"])
	
	#for pid in range(playerWidgets.size()):
	#	stateHandle.PointToPlayerMainEntity(pid)
	#	for w in playerWidgets[pid]:
	#		w["Node"].WidgetInitialize(stateHandle, battleInitData, w["CASPData"])
	
	for pid in range(playerWidgets.size()):
		for w in playerWidgets[pid]:
			w["Node"].isMirrored = (pid == 1)
			# Temp

func UIUpdate(stateHandle):
	for w in globalWidgets:
		w["Node"].WidgetUpdate(stateHandle)
	
	for pid in range(playerWidgets.size()):
		stateHandle.PointToPlayerMainEntity(pid)
		for w in playerWidgets[pid]:
			w["Node"].WidgetUpdate(stateHandle)


func _FindAllManualWidgets():
	_FindAllManualGlobalWidgets(self)
	
	# TODO: Auto creation
	var playersRoot = get_node(PlayersPath)
	for pid in range(playersRoot.get_child_count()):
		playerWidgets.push_back([])
		_FindAllManualPlayerWidgets(playersRoot.get_child(pid), pid)

func _FindAllManualGlobalWidgets(rootNode, rootPath = null):
	# Avoid the player widgets
	if(rootPath != null and rootPath.begins_with(PlayersPath)):
		return
	
	if(rootNode.has_method("WidgetInitialize")):
		globalWidgets.push_back(_CreateWidgetData(rootNode))
	
	if(rootPath == null):
		rootPath = ""
	else:
		rootPath += rootNode.get_name()+"/"
	for c in rootNode.get_children():
		_FindAllManualGlobalWidgets(c, rootPath)

func _FindAllManualPlayerWidgets(rootNode, pid):
	if(rootNode.has_method("WidgetInitialize")):
		playerWidgets[pid].push_back(_CreateWidgetData(rootNode))
	
	for c in rootNode.get_children():
		_FindAllManualPlayerWidgets(c, pid)

func _CreateWidgetData(widgetNode, caspData = null):
	return {
		"Node": widgetNode,
		"CASPData": caspData
	}
