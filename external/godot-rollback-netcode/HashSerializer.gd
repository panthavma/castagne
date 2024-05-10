extends Reference

func serialize(value):
	if value is Dictionary:
		return serialize_dictionary(value)
	elif value is Array:
		return serialize_array(value)
	elif value is Resource:
		return serialize_resource(value)
	elif value is Object:
		return serialize_object(value)
	return value

func serialize_dictionary(value: Dictionary) -> Dictionary:
	var serialized := {}
	for key in value:
		serialized[key] = serialize(value[key])
	return serialized

func serialize_array(value: Array):
	var serialized := []
	for item in value:
		serialized.append(serialize(item))
	return serialized

func serialize_resource(value: Resource):
	return value.resource_path

func serialize_object(value: Object):
	return value.to_string()
