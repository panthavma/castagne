extends HBoxContainer

const PeerStatus = preload("res://addons/godot-rollback-netcode/debugger/PeerStatus.tscn")

func _ready() -> void:
	SyncManager.connect("peer_removed", self, "_on_SyncManager_peer_removed")

func _on_SyncManager_peer_removed(peer_id) -> void:
	var peer_id_str = str(peer_id)
	var peer_status = get_node_or_null(peer_id_str)
	if peer_status:
		peer_status.queue_free()
		remove_child(peer_status)

func _create_or_get_peer_status(peer_id: int):
	var peer_id_str = str(peer_id)
	var peer_status = get_node_or_null(peer_id_str)
	if peer_status:
		return get_node(peer_id_str)
	
	peer_status = PeerStatus.instance()
	peer_status.name = peer_id_str
	add_child(peer_status)
	
	return peer_status

func update_peer(peer: SyncManager.Peer) -> void:
	var peer_status = _create_or_get_peer_status(peer.peer_id)
	peer_status.update_peer(peer)

func add_message(peer_id: int, msg: String) -> void:
	var peer_status = _create_or_get_peer_status(peer_id)
	peer_status.add_message(msg)
