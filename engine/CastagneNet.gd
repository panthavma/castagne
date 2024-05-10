# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node

# Manages online / network for castagne.
# Serves as an interface between CastagneEngine, the rollback, and the server
# Also not maintained until v0.8 cycle

var SERVER_IP = "127.0.0.1"
var SERVER_PORT = 6442
var netLog = ""
var nbPeers = 0

var SyncManager = 0 # temp

enum NetworkSyncStatus {
	Off, Starting, Ready, Stopping
}

var networkSyncStatus = NetworkSyncStatus.Off

# ------------------------------------------------------------------------------
# Network set/stop


func Host():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, 2)
	get_tree().network_peer = peer
	nbPeers += 1
	Log("Hosting Server : " + str(peer))
func Join():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	Log("Joining Server : " + str(peer))

func Disconnect():
	SyncManager.stop()
	var peer = get_tree().network_peer
	if(peer):
		peer.close_connection()

func StartSync():
	if(get_tree().is_network_server()):
		Log("Starting Sync")
		SyncManager.start()

func StopSync():
	if(get_tree().is_network_server()):
		Log("Stopping Sync")
		SyncManager.stop()
		SyncManager.stop_logging()
		


const engineScript = preload("res://castagne/engine/CastagneEngine.gd")
func StartNetworkMatch():
	Old1_StartNetworkMatch()

func Old2_StartNetworkMatch():
	Log("Starting Network Match...")
	Castagne.battleInitData["online"] = true
	StartSync()
	while !SyncManager.started:
		yield(get_tree(),"idle_frame")
	
	yield(get_tree().create_timer(2.0), "timeout")
	Log("Sync started, spawning engine")
	var data = {}
	#SyncManager.spawn("CastagneEngine", get_tree().get_root(), engineprefab, data)

func Old1_StartNetworkMatch():
	Log("Starting Network Match...")
	Castagne.battleInitData["online"] = true
	rpc("Old1_StartNetworkMatch_RPC", Castagne.battleInitData)
remotesync func Old1_StartNetworkMatch_RPC(battleInitData):
	Log("Recieved Network Match order : Starting Network Match...")
	Castagne.battleInitData = battleInitData
	#var s = engineprefab.instance()
	#get_tree().get_root().add_child(s)


func StartLogging():
	SyncManager.start_logging("user://network_logs/"+str(OS.get_unix_time())+"-"+str(get_tree().network_peer.get_unique_id())+".log")


# --------------------------------------

func _ready():
	var _r = get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	_r = get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	_r = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	return
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")

func _on_network_peer_connected(peer_id: int):
	# Use .set_network_master(peer_id) on the input provider i think
	# Don't forget SyncManager.start() once everything good
	Log("Network Peer Connected : " + str(peer_id))
	SyncManager.add_peer(peer_id)
	nbPeers += 1
	#if get_tree().is_network_server():

func _on_network_peer_disconnected(peer_id: int):
	Log("Network Peer Disconnected : " + str(peer_id))
	SyncManager.remove_peer(peer_id)
	SyncManager.stop_logging()

func _on_server_disconnected() -> void:
	Log("Server Disconnected.")
	_on_network_peer_disconnected(1)
	SyncManager.stop_logging()

func _on_SyncManager_sync_started() -> void:
	Log("SyncManager Sync Started")
	#StartLogging()
func _on_SyncManager_sync_stopped() -> void:
	Log("SyncManager Sync Stopped")

func _on_SyncManager_sync_lost() -> void:
	Log("SyncManager Sync Lost")

func _on_SyncManager_sync_regained() -> void:
	Log("SyncManager Sync Regained")

func _on_SyncManager_sync_error(msg: String) -> void:
	Error("SyncManager Fatal Sync Error ! " + msg)
	SyncManager.stop_logging()
	var peer = get_tree().network_peer
	if peer:
		peer.close_connection()
	SyncManager.clear_peers()


# ------------------------------------------------------------------------------
# Misc

func _GetLogPrefix():
	return "[Net] "

func Log(message):
	Castagne.Log(_GetLogPrefix()+str(message))
	netLog += _GetLogPrefix()+str(message)+"\n"

func Error(message):
	Castagne.Error(_GetLogPrefix()+str(message))
	netLog += _GetLogPrefix()+str(message)+"\n"
