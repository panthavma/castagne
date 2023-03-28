extends Node

var _loaded = {}


func Load(path):
	if(_loaded.has(path)):
		return _loaded[path]
	return Preload(path)

func Preload(path):
	if(!File.new().file_exists(path)):
		return null
	var i = load(path)
	_loaded[path] = i
	return i

func LoadCastagneAsset(path):
	var fullPath = "res://castagne/assets/"+path
	return Load(fullPath)
