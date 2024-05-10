extends Node

const DEFAULT_SOUND_BUS_SETTING := 'network/rollback/sound_manager/default_sound_bus'

var default_bus := "Master"
var ticks := {}

var SyncManager

func _ready() -> void:
	if ProjectSettings.has_setting(DEFAULT_SOUND_BUS_SETTING):
		default_bus = ProjectSettings.get_setting(DEFAULT_SOUND_BUS_SETTING)

func setup_sound_manager(_sync_manager) -> void:
	SyncManager = _sync_manager
	SyncManager.connect("tick_retired", self, "_on_SyncManager_tick_retired")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")

func play_sound(identifier: String, sound: AudioStream, info: Dictionary = {}) -> void:
	if SyncManager.is_respawning():
		return
	
	if ticks.has(SyncManager.current_tick):
		if ticks[SyncManager.current_tick].has(identifier):
			return
	else:
		ticks[SyncManager.current_tick] = {}
	ticks[SyncManager.current_tick][identifier] = true
	
	var node
	if info.has('position'):
		node = AudioStreamPlayer2D.new()
	else:
		node = AudioStreamPlayer.new()
	
	node.stream = sound
	node.volume_db = info.get('volume_db', 0.0)
	node.pitch_scale = info.get('pitch_scale', 1.0)
	node.bus = info.get('bus', default_bus)
	
	add_child(node)
	if info.has('position'):
		node.global_position = info['position']
	
	node.play()
	
	node.connect("finished", self, "_on_audio_finished", [node])

func _on_audio_finished(node: Node) -> void:
	remove_child(node)
	node.queue_free()

func _on_SyncManager_tick_retired(tick) -> void:
	ticks.erase(tick)

func _on_SyncManager_sync_stopped() -> void:
	ticks.clear()
