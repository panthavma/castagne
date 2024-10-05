# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Handles player

extends Node

var character
var css
var stack

var neighboors = {
	"Left": null,
	"Right": null,
	"Up": null,
	"Down": null,
}


# Callback to override
func Setup():
	pass

func SetSelect(pid, isSelected):
	pass


func InitIcon(_character, _css, _stack):
	character = _character
	css = _css
	stack = _stack
	Setup()

func GetCharacter():
	return character

func GetNeighboor(direction):
	return neighboors[direction]
func SetNeighboor(direction, neighboor):
	neighboors[direction] = neighboor

