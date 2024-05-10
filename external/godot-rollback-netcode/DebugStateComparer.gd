extends Reference

const JSON_INDENT = "    "

enum MismatchType {
	MISSING,
	EXTRA,
	REORDER,
	DIFFERENCE,
}

class Mismatch:
	var type: int
	var path: String
	var local_state
	var remote_state
	
	func _init(_type: int, _path: String, _local_state, _remote_state) -> void:
		type = _type
		path = _path
		local_state = _local_state
		remote_state = _remote_state

var mismatches := []

func find_mismatches(local_state: Dictionary, remote_state: Dictionary) -> void:
	_find_mismatches_recursive(
		_clean_up_state(local_state),
		_clean_up_state(remote_state))

static func _clean_up_state(state: Dictionary) -> Dictionary:
	state = state.duplicate(true)
	
	# Remove hash.
	state.erase('$')
	
	# Remove any keys that are ignored in the hash.
	for node_path in state:
		for key in state[node_path].keys():
			var value = state[node_path]
			if key is String:
				if key.begins_with('_'):
					value.erase(key)
			elif key is int:
				if key < 0:
					value.erase(key)
	
	return state

func _find_mismatches_recursive(local_state: Dictionary, remote_state: Dictionary, path: Array = []) -> void:
	var missing_or_extra := false
	
	for key in local_state:
		if not remote_state.has(key):
			missing_or_extra = true
			mismatches.append(Mismatch.new(
				MismatchType.MISSING,
				_get_diff_path_string(path, key),
				local_state[key],
				null
			))
	
	for key in remote_state:
		if not local_state.has(key):
			missing_or_extra = true
			mismatches.append(Mismatch.new(
				MismatchType.EXTRA,
				_get_diff_path_string(path, key),
				null,
				remote_state[key]
			))
	
	if not missing_or_extra:
		if local_state.keys() != remote_state.keys():
			mismatches.append(Mismatch.new(
				MismatchType.REORDER,
				_get_diff_path_string(path, 'KEYS'),
				local_state.keys(),
				remote_state.keys()
			))
	
	for key in local_state:
		var local_value = local_state[key]
		
		if not remote_state.has(key):
			continue
		var remote_value = remote_state[key]
		
		if local_value is Dictionary:
			if remote_value is Dictionary:
				if local_value.hash() != remote_value.hash():
					_find_mismatches_recursive(local_value, remote_value, _extend_diff_path(path, key))
			else:
				_add_diff_mismatch(local_value, remote_value, path, key)
		elif local_value is Array:
			if remote_value is Array:
				if local_value != remote_value:
					_find_mismatches_recursive(_convert_array_to_dictionary(local_value), _convert_array_to_dictionary(remote_value), _extend_diff_path(path, key))
			else:
				_add_diff_mismatch(local_value, remote_value, path, key)
		elif local_value != remote_value:
			_add_diff_mismatch(local_value, remote_value, path, key)

static func _get_diff_path_string(path: Array, key) -> String:
	if path.size() > 0:
		return PoolStringArray(path).join(" -> ") + " -> " + str(key)
	return str(key)

static func _extend_diff_path(path: Array, key) -> Array:
	var new_path = path.duplicate()
	new_path.append(str(key))
	return new_path

func _add_diff_mismatch(local_value, remote_value, path: Array, key) -> void:
	mismatches.append(Mismatch.new(
		MismatchType.DIFFERENCE,
		_get_diff_path_string(path, key),
		local_value,
		remote_value
	))

static func _convert_array_to_dictionary(a: Array) -> Dictionary:
	var d := {}
	for i in range(a.size()):
		d[i] = a[i]
	return d

func print_mismatches() -> String:
	var data := PoolStringArray()
	
	for mismatch in mismatches:
		match mismatch.type:
			MismatchType.MISSING:
				data.append(" => [MISSING] %s" % mismatch.path)
				data.append(JSON.print(mismatch.local_state, JSON_INDENT))
				data.append('')
			
			MismatchType.EXTRA:
				data.append(" => [EXTRA] %s" % mismatch.path)
				data.append(JSON.print(mismatch.remote_state, JSON_INDENT))
				data.append('')
			
			MismatchType.REORDER:
				data.append(" => [REORDER] %s" % mismatch.path)
				data.append("LOCAL:  %s" % JSON.print(mismatch.local_state, JSON_INDENT))
				data.append("REMOTE: %s" % JSON.print(mismatch.remote_state, JSON_INDENT))
				data.append('')
			
			MismatchType.DIFFERENCE:
				data.append(" => [DIFF] %s" % mismatch.path)
				data.append("LOCAL:  %s" % JSON.print(mismatch.local_state, JSON_INDENT))
				data.append("REMOTE: %s" % JSON.print(mismatch.remote_state, JSON_INDENT))
				data.append('')
	
	return data.join("\n")
