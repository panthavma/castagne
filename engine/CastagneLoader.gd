extends Node

var _loaded = {}


func Load(path):
	if(_loaded.has(path)):
		return _loaded[path]
	return Preload(path)

func Preload(path):
	var i = load(path)
	_loaded[path] = i
	return i

