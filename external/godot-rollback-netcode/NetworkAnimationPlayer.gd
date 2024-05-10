extends AnimationPlayer
class_name NetworkAnimationPlayer

export (bool) var auto_reset := true

func _ready() -> void:
	method_call_mode = AnimationPlayer.ANIMATION_METHOD_CALL_IMMEDIATE
	playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_MANUAL
	add_to_group('network_sync')

func _network_process(input: Dictionary) -> void:
	if is_playing():
		advance(SyncManager.tick_time)

func _save_state() -> Dictionary:
	if is_playing() and (not auto_reset or current_animation != 'RESET'):
		return {
			is_playing = true,
			current_animation = current_animation,
			current_position = current_animation_position,
		}
	else:
		return {
			is_playing = false,
			current_animation = '',
			current_position = 0.0,
		}

func _load_state(state: Dictionary) -> void:
	if state['is_playing']:
		if not is_playing() or current_animation != state['current_animation']:
			play(state['current_animation'])
		seek(state['current_position'], true)
	elif is_playing():
		if auto_reset and has_animation("RESET"):
			play("RESET")
		else:
			stop()
