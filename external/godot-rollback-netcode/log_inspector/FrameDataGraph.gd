tool
extends VBoxContainer

const LogData = preload("res://addons/godot-rollback-netcode/log_inspector/LogData.gd")

onready var canvas = $Canvas
onready var scroll_bar = $ScrollBar

var cursor_time: int = -1 setget set_cursor_time

var log_data: LogData

signal cursor_time_changed (cursor_time)

func set_log_data(_log_data: LogData) -> void:
	log_data = _log_data
	canvas.set_log_data(log_data)

func refresh_from_log_data() -> void:
	scroll_bar.max_value = log_data.end_time - log_data.start_time
	canvas.refresh_from_log_data()

func set_cursor_time(_cursor_time: int) -> void:
	if cursor_time != _cursor_time:
		cursor_time = _cursor_time
		canvas.cursor_time = cursor_time
		emit_signal("cursor_time_changed", cursor_time)

func _on_ScrollBar_value_changed(value: float) -> void:
	canvas.start_time = int(value)

func _on_Canvas_cursor_time_changed(_cursor_time) -> void:
	set_cursor_time(_cursor_time)

func _on_Canvas_start_time_changed(start_time) -> void:
	scroll_bar.value = start_time
