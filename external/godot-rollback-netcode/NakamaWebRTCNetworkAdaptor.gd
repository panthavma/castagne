extends "res://addons/godot-rollback-netcode/RPCNetworkAdaptor.gd"

#onready var OnlineMatch = get_node('/root/OnlineMatch')

const DATA_CHANNEL_ID := 42

# If buffer exceeds this value, skip sending messages (except ping backs).
var max_buffered_amount := 0
# The max skipped input ticks in a row.
var max_skipped_input_in_a_row := 1
# The number of messages of history to check for duplicates.
var max_duplicate_history := 10
# The number of milliseconds to keep a message in the duplicate history.
var max_duplicate_msecs := 100
# The maximum packet lifetime for WebRTC to try to redeliver messages.
var max_packet_lifetime := 66

class MessageHash:
	var value: int
	var time: int
	
	func _init(_value: int, _time: int) -> void:
		value = _value
		time = _time

var _data_channels := {}
var _last_messages := {}

var _last_skipped_tick := 0
var _skipped_tick_count := 0

func attach_network_adaptor(sync_manager) -> void:
	if OnlineMatch:
		OnlineMatch.connect("webrtc_peer_added", self, '_on_OnlineMatch_webrtc_peer_added')
		OnlineMatch.connect("webrtc_peer_removed", self, '_on_OnlineMatch_webrtc_peer_removed')
		OnlineMatch.connect("disconnected", self, '_on_OnlineMatch_disconnected')
	else:
		push_error("Can't find OnlineMatch singleton that the NakamaWebRTCNetworkAdaptor depends on!")

func detach_network_adaptor(sync_manager) -> void:
	if OnlineMatch:
		OnlineMatch.disconnect("webrtc_peer_added", self, '_on_OnlineMatch_webrtc_peer_added')
		OnlineMatch.disconnect("webrtc_peer_removed", self, '_on_OnlineMatch_webrtc_peer_removed')
		OnlineMatch.disconnect("disconnected", self, '_on_OnlineMatch_disconnected')

func start_network_adaptor(sync_manager) -> void:
	_last_messages.clear()
	_last_skipped_tick = 0
	_skipped_tick_count = 0

func stop_network_adaptor(sync_manager) -> void:
	pass

func _on_OnlineMatch_webrtc_peer_added(webrtc_peer: WebRTCPeerConnection, player: OnlineMatch.Player) -> void:
	print ("Peer added -- trying to re-establish the data channel")
	
	var peer_id := player.peer_id
	
	if _data_channels.has(peer_id):
		_data_channels.erase(peer_id)
	
	var data_channel = webrtc_peer.create_data_channel('SyncManager', {
		negotiated = true,
		id = DATA_CHANNEL_ID,
		maxPacketLifeTime = max_packet_lifetime,
		ordered = false,
	})
	# data_channel can be null if the peer has disconnected
	if data_channel != null:
		data_channel.write_mode = WebRTCDataChannel.WRITE_MODE_BINARY
		_data_channels[peer_id] = data_channel
		
		if SyncManager._logger:
			SyncManager._logger.data['nakama_webrtc_data_channel_created_for_peer_%s' % peer_id] = true

func _on_OnlineMatch_webrtc_peer_removed(webrtc_peer: WebRTCPeerConnection, player: OnlineMatch.Player) -> void:
	var peer_id := player.peer_id
	if _data_channels.has(peer_id):
		# Can this cause problems with re-establishing the connection?
		#_data_channels[peer_id].close()
		_data_channels.erase(peer_id)

func _on_OnlineMatch_disconnected() -> void:
	_data_channels.clear()

func send_input_tick(peer_id: int, msg: PoolByteArray) -> void:
	if _data_channels.has(peer_id) and _data_channels[peer_id].get_ready_state() == WebRTCDataChannel.STATE_OPEN:
		var data_channel: WebRTCDataChannel = _data_channels[peer_id]
		
		# Skip sending if the data channel is over the max buffered amount.
		# Assuming the max_buffered_amount value is well tuned, this will kick
		# in when SCTP's flow control turns on, and we want to wait until it
		# turns back off before sending any more data.
		if max_buffered_amount > 0 and data_channel.get_buffered_amount() > max_buffered_amount:
			if _last_skipped_tick == SyncManager.current_tick:
				# We don't need to output the message multiple times per tick.
				return
			
			if _last_skipped_tick == SyncManager.current_tick - 1:
				_skipped_tick_count += 1
			else:
				_skipped_tick_count = 0
			
			if _skipped_tick_count < max_skipped_input_in_a_row:
				print ("[%s] Skipping send because buffer is too full (%s bytes)" % [SyncManager.current_tick, data_channel.get_buffered_amount()])
				if SyncManager._logger:
					SyncManager._logger.data['nakama_webrtc_send_skipped_to_peer_%s' % peer_id] = "Skipping send because buffer is too full (%s bytes)" % data_channel.get_buffered_amount()
				_last_skipped_tick = SyncManager.current_tick
				return
			else:
				_skipped_tick_count = 0
		
		if not _last_messages.has(peer_id):
			_last_messages[peer_id] = []
		var last_messages_for_peer = _last_messages[peer_id]
		
		# Clear out expired duplicate message records.
		var current_time = OS.get_ticks_msec()
		while last_messages_for_peer.size() > 0:
			if current_time - last_messages_for_peer[0].time >= max_duplicate_msecs:
				#print ("[%s] Retiring duplicate from duplicate message history" % [SyncManager.current_tick])
				last_messages_for_peer.pop_front()
			else:
				break
		
		# Avoid sending duplicate messages. We'll let WebRTC's reliability
		# layer deal with making sure the message arrives, otherwise we can run
		# afoul of SCTP's flow control algorithm.
		var msg_hash_value = hash(msg)
		for msg_hash in last_messages_for_peer:
			if msg_hash.value == msg_hash_value:
				print ("[%s] Skipping duplicate message" % [SyncManager.current_tick])
				if SyncManager._logger:
					SyncManager._logger.increment_value("nakama_webrtc_skipping_duplicate_messages_for_%s" % peer_id)
				return
		
		data_channel.put_packet(msg)
		
		# Add message hash to duplicate history and push out old messages.
		#last_messages_for_peer.append(MessageHash.new(msg_hash_value, current_time))
		_last_messages[peer_id].append(MessageHash.new(msg_hash_value, current_time))
		while last_messages_for_peer.size() > max_duplicate_history:
			last_messages_for_peer.pop_front()

func poll() -> void:
	for peer_id in _data_channels:
		var data_channel: WebRTCDataChannel = _data_channels[peer_id]
		var data_channel_state = data_channel.get_ready_state()
		if data_channel_state != WebRTCDataChannel.STATE_OPEN:
			# Attempt to reconnect the data channel, if necessary.
			if data_channel_state != WebRTCDataChannel.STATE_CONNECTING:
				var player = OnlineMatch.get_player_by_peer_id(peer_id)
				var webrtc_peer = OnlineMatch.get_webrtc_peer(player.session_id)
				_on_OnlineMatch_webrtc_peer_added(webrtc_peer, player)
			continue
		
		data_channel.poll()
		
		# Get all received messages.
		while data_channel.get_available_packet_count() > 0:
			var msg = data_channel.get_packet()
			emit_signal("received_input_tick", peer_id, msg)
