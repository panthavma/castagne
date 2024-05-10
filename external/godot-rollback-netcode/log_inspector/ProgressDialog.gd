tool
extends PopupDialog

onready var label = $MarginContainer/VBoxContainer/Label
onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar

func set_label(text: String) -> void:
	label.text = text

func update_progress(value, max_value) -> void:
	progress_bar.max_value = max_value
	progress_bar.value = value
