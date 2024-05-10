extends Node

signal received_ping (peer_id, msg)
signal received_ping_back (peer_id, msg)
signal received_remote_start ()
signal received_remote_stop ()
signal received_input_tick (peer_id, msg)

func attach_network_adaptor(sync_manager) -> void:
	pass

func detach_network_adaptor(sync_manager) -> void:
	pass

func start_network_adaptor(sync_manager) -> void:
	pass

func stop_network_adaptor(sync_manager) -> void:
	pass

func send_ping(peer_id: int, msg: Dictionary) -> void:
	push_error("UNIMPLEMENTED ERROR: NetworkAdaptor.send_ping()")

func send_ping_back(peer_id: int, msg: Dictionary) -> void:
	push_error("UNIMPLEMENTED ERROR: NetworkAdaptor.send_ping_back()")

func send_remote_start(peer_id: int) -> void:
	push_error("UNIMPLEMENTED ERROR: NetworkAdaptor.send_remote_start()")

func send_remote_stop(peer_id: int) -> void:
	push_error("UNIMPLEMENTED ERROR: NetworkAdaptor.send_remote_stop()")

func send_input_tick(peer_id: int, msg: PoolByteArray) -> void:
	push_error("UNIMPLEMENTED ERROR: NetworkAdaptor.send_input_tick()")

func poll() -> void:
	pass

