tool
extends EditorPlugin

const LogInspector = preload("res://addons/godot-rollback-netcode/log_inspector/LogInspector.tscn")

var log_inspector
var _property_order: int = 1000

func _add_project_setting(name: String, type: int, default, hint = null, hint_string = null) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)
	
	ProjectSettings.set_initial_value(name, default)
	ProjectSettings.set_order(name, _property_order)
	
	_property_order += 1
	
	var info := {
		name = name,
		type = type,
	}
	if hint != null:
		info['hint'] = hint
	if hint_string != null:
		info['hint_string'] = hint_string
	
	ProjectSettings.add_property_info(info)

func _enter_tree() -> void:
	_add_project_setting('network/rollback/max_buffer_size', TYPE_INT, 20, PROPERTY_HINT_RANGE, "1, 60")
	_add_project_setting('network/rollback/ticks_to_calculate_advantage', TYPE_INT, 60, PROPERTY_HINT_RANGE, "1, 600")
	_add_project_setting('network/rollback/input_delay', TYPE_INT, 2, PROPERTY_HINT_RANGE, "0, 10")
	_add_project_setting('network/rollback/ping_frequency', TYPE_REAL, 1.0, PROPERTY_HINT_RANGE, "0.01, 5.0")
	_add_project_setting('network/rollback/interpolation', TYPE_BOOL, false)
	
	_add_project_setting('network/rollback/limits/max_input_frames_per_message', TYPE_INT, 5, PROPERTY_HINT_RANGE, "0, 60")
	_add_project_setting('network/rollback/limits/max_messages_at_once', TYPE_INT, 2, PROPERTY_HINT_RANGE, "0, 10")
	_add_project_setting('network/rollback/limits/max_ticks_to_regain_sync', TYPE_INT, 300, PROPERTY_HINT_RANGE, "0, 600")
	_add_project_setting('network/rollback/limits/min_lag_to_regain_sync', TYPE_INT, 5, PROPERTY_HINT_RANGE, "0, 60")
	_add_project_setting('network/rollback/limits/max_state_mismatch_count', TYPE_INT, 10, PROPERTY_HINT_RANGE, "0, 60")
	
	_add_project_setting('network/rollback/spawn_manager/reuse_despawned_nodes', TYPE_BOOL, false)
	_add_project_setting('network/rollback/sound_manager/default_sound_bus', TYPE_STRING, "Master")
	
	_add_project_setting('network/rollback/classes/network_adaptor', TYPE_STRING, "", PROPERTY_HINT_FILE, "*.gd")
	_add_project_setting('network/rollback/classes/message_serializer', TYPE_STRING, "", PROPERTY_HINT_FILE, "*.gd")
	_add_project_setting('network/rollback/classes/hash_serializer', TYPE_STRING, "", PROPERTY_HINT_FILE, "*.gd")
	
	_add_project_setting('network/rollback/debug/rollback_ticks', TYPE_INT, 0, PROPERTY_HINT_RANGE, "0, 60")
	_add_project_setting('network/rollback/debug/random_rollback_ticks', TYPE_INT, 0, PROPERTY_HINT_RANGE, "0, 60")
	_add_project_setting('network/rollback/debug/message_bytes', TYPE_INT, 0, PROPERTY_HINT_RANGE, "0, 2048")
	_add_project_setting('network/rollback/debug/skip_nth_message', TYPE_INT, 0, PROPERTY_HINT_RANGE, "0, 60")
	_add_project_setting('network/rollback/debug/physics_process_msecs', TYPE_REAL, 10.0, PROPERTY_HINT_RANGE, "0.0, 60.0")
	_add_project_setting('network/rollback/debug/process_msecs', TYPE_REAL, 10.0, PROPERTY_HINT_RANGE, "0.0, 60.0")
	
	add_autoload_singleton("SyncManager", "res://addons/godot-rollback-netcode/SyncManager.gd")
	
	add_custom_type("NetworkTimer", "Node", load("res://addons/godot-rollback-netcode/NetworkTimer.gd"), null)
	add_custom_type("NetworkAnimationPlayer", "AnimationPlayer", load("res://addons/godot-rollback-netcode/NetworkAnimationPlayer.gd"), null)
	add_custom_type("NetworkRandomNumberGenerator", "Node", load("res://addons/godot-rollback-netcode/NetworkRandomNumberGenerator.gd"), null)
	
	log_inspector = LogInspector.instance()
	get_editor_interface().get_base_control().add_child(log_inspector)
	add_tool_menu_item("Log inspector...", self, "open_log_inspector")
	
	if not ProjectSettings.has_setting("input/sync_debug"):
		var sync_debug = InputEventKey.new()
		sync_debug.scancode = KEY_F11
		
		ProjectSettings.set_setting("input/sync_debug", {
			deadzone = 0.5,
			events = [
				sync_debug,
			],
		})
		
		# Cause the ProjectSettingsEditor to reload the input map from the
		# ProjectSettings.
		get_tree().root.get_child(0).propagate_notification(EditorSettings.NOTIFICATION_EDITOR_SETTINGS_CHANGED)

func open_log_inspector(ud) -> void:
	log_inspector.popup_centered_ratio()

func _exit_tree() -> void:
	remove_custom_type("NetworkTimer")
	remove_custom_type("NetworkAnimationPlayer")
	remove_custom_type("NetworkRandomNumberGenerator")
	
	remove_tool_menu_item("Log inspector...")
	if log_inspector:
		log_inspector.free()
		log_inspector = null
