# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
