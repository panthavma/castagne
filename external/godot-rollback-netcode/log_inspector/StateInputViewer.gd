tool
extends VBoxContainer

const LogData = preload("res://addons/godot-rollback-netcode/log_inspector/LogData.gd")
const DebugStateComparer = preload("res://addons/godot-rollback-netcode/DebugStateComparer.gd")

const JSON_INDENT = "    "

onready var tick_number_field = $HBoxContainer/TickNumber
onready var input_data_label = $GridContainer/InputPanel/InputDataLabel
onready var input_mismatches_data_label = $GridContainer/InputMismatchesPanel/InputMismatchesDataLabel
onready var state_data_label = $GridContainer/StatePanel/StateDataLabel
onready var state_mismatches_data_label = $GridContainer/StateMismatchesPanel/StateMismatchesDataLabel

var log_data: LogData

func set_log_data(_log_data: LogData) -> void:
	log_data = _log_data

func refresh_from_log_data() -> void:
	tick_number_field.max_value = log_data.max_tick
	_on_TickNumber_value_changed(tick_number_field.value)

func clear() -> void:
	tick_number_field.max_value = 0
	tick_number_field.value = 0
	input_data_label.text = ''
	input_mismatches_data_label.text = ''
	state_data_label.text = ''
	state_mismatches_data_label.text = ''

func _on_TickNumber_value_changed(value: float) -> void:
	var tick: int = int(value)
	
	var input_frame: LogData.InputData = log_data.input.get(tick, null)
	var state_frame: LogData.StateData = log_data.state.get(tick, null)
	
	if input_frame:
		input_data_label.text = JSON.print(input_frame.input, JSON_INDENT)
		
		if input_frame.mismatches.size() > 0:
			var mismatch_text := ''
			for peer_id in input_frame.mismatches:
				var peer_input = input_frame.mismatches[peer_id]
				mismatch_text += ("\n ==========  %s  ==========\n\n" % peer_id)
				
				var comparer = DebugStateComparer.new()
				comparer.find_mismatches(input_frame.input, peer_input)
				mismatch_text += comparer.print_mismatches()
			input_mismatches_data_label.text = mismatch_text
		else:
			input_mismatches_data_label.text = ''
	else:
		input_data_label.text = ''
		input_mismatches_data_label.text = ''
	
	if state_frame:
		state_data_label.text = JSON.print(state_frame.state, JSON_INDENT)
		
		if state_frame.mismatches.size() > 0:
			var mismatch_text := ''
			for peer_id in state_frame.mismatches:
				var peer_state = state_frame.mismatches[peer_id]
				mismatch_text += ("\n ==========  %s  ==========\n\n" % peer_id)
				
				var comparer = DebugStateComparer.new()
				comparer.find_mismatches(state_frame.state, peer_state)
				mismatch_text += comparer.print_mismatches()
			state_mismatches_data_label.text = mismatch_text
		else:
			state_mismatches_data_label.text = ''
	else:
		state_data_label.text = ''
		state_mismatches_data_label.text = ''

func _on_PreviousMismatchButton_pressed() -> void:
	var current_tick := int(tick_number_field.value)
	var previous_mismatch := -1
	for mismatch_tick in log_data.mismatches:
		if mismatch_tick < current_tick:
			previous_mismatch = mismatch_tick
		else:
			break
	if previous_mismatch != -1:
		tick_number_field.value = previous_mismatch

func _on_NextMismatchButton_pressed() -> void:
	var current_tick := int(tick_number_field.value)
	var next_mismatch := -1
	for mismatch_tick in log_data.mismatches:
		if mismatch_tick > current_tick:
			next_mismatch = mismatch_tick
			break
	if next_mismatch != -1:
		tick_number_field.value = next_mismatch

func _on_StartButton_pressed() -> void:
	tick_number_field.value = 0

func _on_EndButton_pressed() -> void:
	tick_number_field.value = tick_number_field.max_value
