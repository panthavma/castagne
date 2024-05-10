tool
extends WindowDialog

const LogData = preload("res://addons/godot-rollback-netcode/log_inspector/LogData.gd")
const DataGraph = preload("res://addons/godot-rollback-netcode/log_inspector/FrameDataGraph.gd")
const TimeOffsetSetting = preload("res://addons/godot-rollback-netcode/log_inspector/FrameViewerTimeOffsetSetting.tscn")

onready var show_network_arrows_field := $MarginContainer/GridContainer/ShowNetworkArrows
onready var network_arrows_peer1_field := $MarginContainer/GridContainer/NetworkArrowsPeer1
onready var network_arrows_peer2_field := $MarginContainer/GridContainer/NetworkArrowsPeer2
onready var show_rollback_ticks_field = $MarginContainer/GridContainer/ShowRollbackTicks
onready var max_rollback_ticks_field = $MarginContainer/GridContainer/MaxRollbackTicks
onready var time_offset_container = $MarginContainer/GridContainer/TimeOffsetContainer

var log_data: LogData
var data_graph: DataGraph
var data_grid

func setup_settings_dialog(_log_data: LogData, _data_graph: DataGraph, _data_grid) -> void:
	log_data = _log_data
	data_graph = _data_graph
	data_grid = _data_grid
	refresh_from_log_data()

func refresh_from_log_data() -> void:
	_rebuild_peer_options(network_arrows_peer1_field)
	_rebuild_peer_options(network_arrows_peer2_field)
	_rebuild_peer_time_offset_fields()
	
	show_network_arrows_field.pressed = data_graph.canvas.show_network_arrows
	var network_arrow_peers = data_graph.canvas.network_arrow_peers.duplicate()
	network_arrow_peers.sort()
	if network_arrow_peers.size() > 0:
		network_arrows_peer1_field.select(network_arrows_peer1_field.get_item_index(network_arrow_peers[0]))
	if network_arrow_peers.size() > 1:
		network_arrows_peer2_field.select(network_arrows_peer2_field.get_item_index(network_arrow_peers[1]))
	
	show_rollback_ticks_field.pressed = data_graph.canvas.show_rollback_ticks
	max_rollback_ticks_field.text = str(data_graph.canvas.max_rollback_ticks)

func _rebuild_peer_options(option_button: OptionButton) -> void:
	var value = option_button.get_selected_id()
	option_button.clear()
	for peer_id in log_data.peer_ids:
		option_button.add_item("Peer %s" % peer_id, peer_id)
	if option_button.get_selected_id() != value:
		option_button.select(option_button.get_item_index(value))

func _rebuild_peer_time_offset_fields() -> void:
	# Remove all the old fields (disconnect signals).
	for child in time_offset_container.get_children():
		child.disconnect("time_offset_changed", self, "_on_peer_time_offset_changed")
		time_offset_container.remove_child(child)
		child.queue_free()
	
	# Re-create new fields and connect the signals.
	for peer_id in log_data.peer_ids:
		var child = TimeOffsetSetting.instance()
		child.name = str(peer_id)
		time_offset_container.add_child(child)
		child.setup_time_offset_setting("Peer %s" % peer_id, log_data.peer_time_offsets[peer_id])
		child.connect("time_offset_changed", self, "_on_peer_time_offset_changed", [peer_id])

func _on_peer_time_offset_changed(value, peer_id) -> void:
	log_data.set_peer_time_offset(peer_id, value)

func update_network_arrows() -> void:
	if show_network_arrows_field.pressed:
		if network_arrows_peer1_field.get_selected_id() != network_arrows_peer2_field.get_selected_id():
			data_graph.canvas.show_network_arrows = true
			data_graph.canvas.network_arrow_peers = [
				network_arrows_peer1_field.get_selected_id(),
				network_arrows_peer2_field.get_selected_id(),
			]
			data_graph.canvas.update()
	else:
		data_graph.canvas.show_network_arrows = false
		data_graph.canvas.update()

func _on_ShowNetworkArrows_toggled(button_pressed: bool) -> void:
	update_network_arrows()

func _on_NetworkArrowsPeer1_item_selected(index: int) -> void:
	update_network_arrows()

func _on_NetworkArrowsPeer2_item_selected(index: int) -> void:
	update_network_arrows()

func _on_ShowRollbackTicks_pressed() -> void:
	data_graph.canvas.show_rollback_ticks = show_rollback_ticks_field.pressed
	data_graph.canvas.update()

func _on_MaxRollbackTicks_text_changed(new_text: String) -> void:
	var value = max_rollback_ticks_field.text
	if value.is_valid_integer():
		var value_int = value.to_int()
		if value_int > 0:
			data_graph.canvas.max_rollback_ticks = value_int
			data_graph.canvas.update()
