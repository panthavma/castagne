extends Node

const REUSE_DESPAWNED_NODES_SETTING := 'network/rollback/spawn_manager/reuse_despawned_nodes'

var spawn_records := {}
var spawned_nodes := {}
var node_scenes := {}
var retired_nodes := {}
var counter := {}

var reuse_despawned_nodes := false

var is_respawning := false

signal scene_spawned (name, spawned_node, scene, data)

func _ready() -> void:
	if ProjectSettings.has_setting(REUSE_DESPAWNED_NODES_SETTING):
		reuse_despawned_nodes = ProjectSettings.get_setting(REUSE_DESPAWNED_NODES_SETTING)
	
	add_to_group('network_sync')

func setup_spawn_manager(SyncManager) -> void:
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")

func reset() -> void:
	spawn_records.clear()
	node_scenes.clear()
	counter.clear()
	
	for node in spawned_nodes.values():
		node.queue_free()
	spawned_nodes.clear()
	
	for nodes in retired_nodes.values():
		for node in nodes:
			node.queue_free()
	retired_nodes.clear()

func _on_SyncManager_sync_started() -> void:
	reset()

func _on_SyncManager_sync_stopped() -> void:
	reset()

func _rename_node(name: String) -> String:
	if not counter.has(name):
		counter[name] = 0
	counter[name] += 1
	return name + str(counter[name])

func _remove_colliding_node(name: String, parent: Node) -> void:
	var existing_node = parent.get_node_or_null(name)
	if existing_node:
		push_warning("Removing node %s which is in the way of new spawn" % existing_node)
		parent.remove_child(existing_node)
		existing_node.queue_free()

static func _node_name_sort_callback(a: Node, b: Node) -> bool:
	return a.name.casecmp_to(b.name) == -1

func _alphabetize_children(parent: Node) -> void:
	var children = parent.get_children()
	children.sort_custom(self, '_node_name_sort_callback')
	for index in range(children.size()):
		var child = children[index]
		parent.move_child(child, index)

func _instance_scene(resource_path: String) -> Node:
	if retired_nodes.has(resource_path):
		var nodes: Array = retired_nodes[resource_path]
		var node: Node
		
		while nodes.size() > 0:
			node = retired_nodes[resource_path].pop_front()
			if is_instance_valid(node) and not node.is_queued_for_deletion():
				break
			else:
				node = null
		
		if nodes.size() == 0:
			retired_nodes.erase(resource_path)
		
		if node:
			#print ("Reusing %s" % resource_path)
			return node
	
	#print ("Instancing new %s" % resource_path)
	var scene = load(resource_path)
	return scene.instance()

func spawn(name: String, parent: Node, scene: PackedScene, data: Dictionary, rename: bool = true, signal_name: String = '') -> Node:
	var spawned_node = _instance_scene(scene.resource_path)
	if signal_name == '':
		signal_name = name
	if rename:
		name = _rename_node(name)
	_remove_colliding_node(name, parent)
	spawned_node.name = name
	parent.add_child(spawned_node)
	_alphabetize_children(parent)
	
	if spawned_node.has_method('_network_spawn_preprocess'):
		data = spawned_node._network_spawn_preprocess(data)
	
	if spawned_node.has_method('_network_spawn'):
		spawned_node._network_spawn(data)
	
	var spawn_record := {
		name = spawned_node.name,
		parent = parent.get_path(),
		scene = scene.resource_path,
		data = data,
		signal_name = signal_name,
	}
	
	var node_path = str(spawned_node.get_path())
	spawn_records[node_path] = spawn_record
	spawned_nodes[node_path] = spawned_node
	node_scenes[node_path] = scene.resource_path
	
	#print ("[%s] spawned: %s" % [SyncManager.current_tick, spawned_node.name])
	
	emit_signal("scene_spawned", signal_name, spawned_node, scene, data)
	
	return spawned_node

func despawn(node: Node, node_path = null) -> void:
	if node_path == null:
		node_path = str(node.get_path())
	
	if node.has_method('_network_despawn'):
		node._network_despawn()
	if node.get_parent():
		node.get_parent().remove_child(node)
	
	if reuse_despawned_nodes and node_scenes.has(node_path) and is_instance_valid(node) and not node.is_queued_for_deletion():
		var scene_path = node_scenes[node_path]
		if not retired_nodes.has(scene_path):
			retired_nodes[scene_path] = []
		retired_nodes[scene_path].append(node)
	else:
		node.queue_free()
	
	spawn_records.erase(node_path)
	spawned_nodes.erase(node_path)
	node_scenes.erase(node_path)

func _save_state() -> Dictionary:
	for node_path in spawned_nodes.keys().duplicate():
		var node = spawned_nodes[node_path]
		if not is_instance_valid(node):
			spawned_nodes.erase(node_path)
			spawn_records.erase(node_path)
			node_scenes.erase(node_path)
			#print ("[SAVE %s] removing invalid: %s" % [SyncManager.current_tick, node_path])
		elif node.is_queued_for_deletion():
			if node.get_parent():
				node.get_parent().remove_child(node)
			spawned_nodes.erase(node_path)
			spawn_records.erase(node_path)
			node_scenes.erase(node_path)
			#print ("[SAVE %s] removing deleted: %s" % [SyncManager.current_tick, node_path])
	
	return {
		spawn_records = spawn_records.duplicate(),
		counter = counter.duplicate(),
	}

func _load_state(state: Dictionary) -> void:
	spawn_records = state['spawn_records'].duplicate()
	counter = state['counter'].duplicate()
	
	# Remove nodes that aren't in the state we are loading.
	for node_path in spawned_nodes.keys().duplicate():
		if not spawn_records.has(node_path):
			despawn(spawned_nodes[node_path], node_path)
			#print ("[LOAD %s] de-spawned: %s" % [SyncManager.current_tick, node_path])
	
	# Spawn nodes that don't already exist.
	for node_path in spawn_records.keys():
		if spawned_nodes.has(node_path):
			var old_node = spawned_nodes[node_path]
			if not is_instance_valid(old_node) or old_node.is_queued_for_deletion():
				spawned_nodes.erase(node_path)
				node_scenes.erase(node_path)
		
		is_respawning = true
		
		if not spawned_nodes.has(node_path):
			var spawn_record = spawn_records[node_path]
			var parent = get_tree().current_scene.get_node(spawn_record['parent'])
			assert(parent != null, "Can't re-spawn node when parent doesn't exist")
			var name = spawn_record['name']
			_remove_colliding_node(name, parent)
			var spawned_node = _instance_scene(spawn_record['scene'])
			spawned_node.name = name
			parent.add_child(spawned_node)
			_alphabetize_children(parent)
			
			if spawned_node.has_method('_network_spawn'):
				spawned_node._network_spawn(spawn_record['data'])
			
			spawned_nodes[node_path] = spawned_node
			node_scenes[node_path] = spawn_record['scene']
			
			# @todo Can we get rid of the load() and just use the path?
			emit_signal("scene_spawned", spawn_record['signal_name'], spawned_node, load(spawn_record['scene']), spawn_record['data'])
			#print ("[LOAD %s] re-spawned: %s" % [SyncManager.current_tick, node_path])
		
		is_respawning = false

