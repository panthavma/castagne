tool
extends HBoxContainer

onready var peer_label = $PeerLabel
onready var offset_value_field = $OffsetValue

signal time_offset_changed (value)

func setup_time_offset_setting(_label: String, _value: int) -> void:
	peer_label.text = _label
	offset_value_field.value = _value

func get_time_offset() -> int:
	return offset_value_field.value

func _on_OffsetValue_value_changed(value: float) -> void:
	emit_signal("time_offset_changed", int(offset_value_field.value))
