tool
extends Control

const Logger = preload("res://addons/godot-rollback-netcode/Logger.gd")
const LogData = preload("res://addons/godot-rollback-netcode/log_inspector/LogData.gd")

var start_time := 0 setget set_start_time
var cursor_time := -1 setget set_cursor_time

var show_network_arrows := true
var network_arrow_peers := []

var show_rollback_ticks := true
var max_rollback_ticks := 15

const FRAME_TYPE_COLOR = {
	Logger.FrameType.INTERFRAME: Color(0.7, 0.7, 0.7),
	Logger.FrameType.TICK: Color(0.0, 0.75, 0.0),
	Logger.FrameType.INTERPOLATION_FRAME: Color(0.0, 0.0, 0.5),
}

const ROLLBACK_LINE_COLOR := Color(1.0, 0.5, 0.0)

const NETWORK_ARROW_COLOR1 := Color(1.0, 0,5, 1.0)
const NETWORK_ARROW_COLOR2 := Color(0.0, 0.5, 1.0)
const NETWORK_ARROW_SIZE := 8

const EXTRA_WIDTH := 1000
const PEER_GAP := 10
const CURSOR_SCROLL_GAP := 100

var log_data: LogData
var _font: Font
var _font_big: Font

signal cursor_time_changed (cursor_time)
signal start_time_changed (start_time)

func set_log_data(_log_data: LogData) -> void:
	log_data = _log_data

func refresh_from_log_data() -> void:
	# Remove any invalid peers from network_arrow_peers
	for peer_id in network_arrow_peers:
		if not peer_id in log_data.peer_ids:
			network_arrow_peers.erase(peer_id)
	
	if show_network_arrows:
		# If we have at least two peers, set network_arrow_peers to first valid
		# options.
		if network_arrow_peers.size() < 2 and log_data.peer_ids.size() >= 2:
			network_arrow_peers = [log_data.peer_ids[0], log_data.peer_ids[1]]
	
	update()

func set_start_time(_start_time: int) -> void:
	if start_time != _start_time:
		start_time = _start_time
		update()
		emit_signal("start_time_changed", start_time)

func set_cursor_time(_cursor_time: int) -> void:
	if cursor_time != _cursor_time:
		cursor_time = _cursor_time
		update()
		emit_signal("cursor_time_changed", cursor_time)
		
		var relative_cursor_time = cursor_time - start_time
		if relative_cursor_time < 0:
			set_start_time(cursor_time - (rect_size.x - CURSOR_SCROLL_GAP))
		elif relative_cursor_time > rect_size.x:
			set_start_time(cursor_time - CURSOR_SCROLL_GAP)

func _ready() -> void:
	_font = DynamicFont.new()
	_font.font_data = load("res://addons/godot-rollback-netcode/log_inspector/monogram_extended.ttf")
	_font.size = 16
	
	_font_big = DynamicFont.new()
	_font_big.font_data = load("res://addons/godot-rollback-netcode/log_inspector/monogram_extended.ttf")
	_font_big.size = 32

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			set_cursor_time(int(start_time + event.position.x))

func _draw_peer(peer_id: int, peer_rect: Rect2, draw_data: Dictionary) -> void:
	var relative_start_time := start_time - EXTRA_WIDTH
	if relative_start_time < 0:
		relative_start_time = 0
	
	var absolute_start_time: int = log_data.start_time + relative_start_time
	var absolute_end_time: int = absolute_start_time + peer_rect.size.x + (EXTRA_WIDTH * 2)
	var frame: LogData.FrameData = log_data.get_frame_by_time(peer_id, absolute_start_time)
	if frame == null and log_data.get_frame_count(peer_id) > 0:
		frame = log_data.get_frame(peer_id, 0)
	if frame == null:
		return
	
	var tick_numbers_to_draw := []
	
	var capture_network_arrow_positions: bool = show_network_arrows and peer_id in network_arrow_peers
	var network_arrow_start_positions := {}
	var network_arrow_end_positions := {}
	
	var other_network_arrow_peer_id: int
	if capture_network_arrow_positions:
		for other_peer_id in network_arrow_peers:
			if other_peer_id != peer_id:
				other_network_arrow_peer_id = other_peer_id
				break
	var other_network_arrow_peer_key = "remote_ticks_received_from_%s" % other_network_arrow_peer_id
	
	# Adjust the peer rect for the extra width.
	var extended_peer_rect = peer_rect
	extended_peer_rect.position.x -= (EXTRA_WIDTH if start_time > EXTRA_WIDTH else start_time)
	extended_peer_rect.size.x += (EXTRA_WIDTH * 2)
	
	var last_rollback_point = null
	
	while frame.start_time <= absolute_end_time:
		var frame_rect = Rect2(
			Vector2(extended_peer_rect.position.x + frame.start_time - absolute_start_time, extended_peer_rect.position.y),
			Vector2(frame.end_time - frame.start_time, extended_peer_rect.size.y))
		if frame_rect.intersects(extended_peer_rect):
			frame_rect = frame_rect.clip(extended_peer_rect)
			if frame_rect.size.x == 0:
				frame_rect.size.x = 1
			
			var skipped: bool = frame.data.get('skipped', false)
			var fatal_error: bool = frame.data.get('fatal_error', false)
			var center_position: Vector2 = frame_rect.position + (frame_rect.size / 2.0)
			var frame_color: Color
			
			if fatal_error:
				frame_color = Color(1.0, 0.0, 0.0)
			elif skipped:
				frame_color = Color(1.0, 1.0, 0.0)
				if frame_rect.size.x <= 1.0:
					frame_rect.size.x = 3
					frame_rect.position.x -= 1.5
				
				if frame.data.has('skip_reason'):
					var tick_letter: String = ''
					match int(frame.data['skip_reason']):
						Logger.SkipReason.INPUT_BUFFER_UNDERRUN:
							tick_letter = 'B'
						Logger.SkipReason.WAITING_TO_REGAIN_SYNC:
							tick_letter = 'W'
						Logger.SkipReason.ADVANTAGE_ADJUSTMENT:
							tick_letter = 'A'
					if tick_letter != '':
						tick_numbers_to_draw.append([_font_big, center_position - Vector2(5, 0), tick_letter, Color('f04dff')])
			else:
				frame_color = FRAME_TYPE_COLOR[frame.type]
			
			draw_rect(frame_rect, frame_color)
			
			if frame.type == Logger.FrameType.TICK and frame.data.has('tick') and not skipped:
				var tick: int = frame.data['tick']
				tick_numbers_to_draw.append([_font, center_position - Vector2(3, 0), str(tick), Color(1.0, 1.0, 1.0)])
				if frame.data.has('input_tick') and capture_network_arrow_positions:
					var input_tick: int = frame.data['input_tick']
					network_arrow_start_positions[input_tick] = center_position
			
			if capture_network_arrow_positions and frame.data.has(other_network_arrow_peer_key):
				for tick in frame.data[other_network_arrow_peer_key]:
					network_arrow_end_positions[int(tick)] = center_position
			
			if show_rollback_ticks and frame.data.has('rollback_ticks'):
				var rollback_height = extended_peer_rect.size.y * (float(frame.data['rollback_ticks']) / float(max_rollback_ticks))
				if rollback_height > extended_peer_rect.size.y:
					rollback_height = extended_peer_rect.size.y
				var rollback_point = Vector2(center_position.x, frame_rect.position.y + frame_rect.size.y - rollback_height)
				if last_rollback_point != null:
					draw_line(last_rollback_point, rollback_point, ROLLBACK_LINE_COLOR, 2.0, true)
				last_rollback_point = rollback_point
				
		# Move on to the next frame.
		if frame.frame < log_data.get_frame_count(peer_id) - 1:
			frame = log_data.get_frame(peer_id, frame.frame + 1)
		else:
			break
	
	for tick_number_to_draw in tick_numbers_to_draw:
		draw_string(tick_number_to_draw[0], tick_number_to_draw[1], tick_number_to_draw[2], tick_number_to_draw[3])
	
	if capture_network_arrow_positions:
		if not draw_data.has("network_arrow_positions"):
			draw_data["network_arrow_positions"] = []
		draw_data["network_arrow_positions"].append([network_arrow_start_positions, network_arrow_end_positions])

func _draw_network_arrows(start_positions: Dictionary, end_positions: Dictionary, color: Color) -> void:
	for tick in start_positions:
		if not end_positions.has(tick):
			continue
		var start_position = start_positions[tick]
		var end_position = end_positions[tick]
		
		if start_position.y < end_position.y:
			start_position.y += 10
			end_position.y -= 15
		else:
			start_position.y -= 15
			end_position.y += 10
		
		draw_line(start_position, end_position, color, 2.0, true)
		
		# Draw the arrow head.
		var sqrt12 = sqrt(0.5)
		var vector: Vector2 = end_position - start_position
		var t := Transform2D(vector.angle(), end_position)
		var points := PoolVector2Array([
			t.xform(Vector2(0, 0)),
			t.xform(Vector2(-NETWORK_ARROW_SIZE, sqrt12 * NETWORK_ARROW_SIZE)),
			t.xform(Vector2(-NETWORK_ARROW_SIZE, sqrt12 * -NETWORK_ARROW_SIZE)),
		])
		var colors := PoolColorArray([
			color,
			color,
			color,
		])
		draw_primitive(points, colors, PoolVector2Array())

func _draw() -> void:
	if log_data == null:
		return
	var peer_count = log_data.peer_ids.size()
	if peer_count == 0:
		return
	
	var draw_data := {}
	var peer_rects := {}
	
	var peer_height: float = (rect_size.y - ((peer_count - 1) * PEER_GAP)) / peer_count
	var current_y := 0
	for peer_index in range(peer_count):
		var peer_id = log_data.peer_ids[peer_index]
		var peer_rect := Rect2(
			Vector2(0, current_y),
			Vector2(rect_size.x, peer_height))
		peer_rects[peer_id] = peer_rect
		_draw_peer(peer_id, peer_rect, draw_data)
		current_y += (peer_height + PEER_GAP)
	
	if show_network_arrows:
		var network_arrows_positions: Array = draw_data.get('network_arrow_positions', [])
		if network_arrows_positions.size() == 2:
			_draw_network_arrows(network_arrows_positions[0][0], network_arrows_positions[1][1], NETWORK_ARROW_COLOR1)
			_draw_network_arrows(network_arrows_positions[1][0], network_arrows_positions[0][1], NETWORK_ARROW_COLOR2)
	
	for peer_id in peer_rects:
		var peer_rect: Rect2 = peer_rects[peer_id]
		draw_string(_font, peer_rect.position + Vector2(0, PEER_GAP), "Peer %s" % peer_id, Color(1.0, 1.0, 1.0))
	
	if cursor_time >= start_time and cursor_time <= start_time + rect_size.x:
		draw_line(
			Vector2(cursor_time - start_time, 0),
			Vector2(cursor_time - start_time, rect_size.y),
			Color(1.0, 0.0, 0.0),
			3.0)
