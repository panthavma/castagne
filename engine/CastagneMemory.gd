# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Holds a stack

extends Node

var _memoryGlobal = {}
var _memoryPlayers = []
var _memoryEntities = []

func InitMemory():
	pass

func CopyFrom(other):
	_memoryGlobal = other._memoryGlobal.duplicate(true)
	_memoryPlayers = other._memoryPlayers.duplicate(true)
	_memoryEntities = other._memoryEntities.duplicate(true)

func GlobalGet(keyName):
	if(_memoryGlobal.has(keyName)):
		return _memoryGlobal[keyName]
	Castagne.Error("Memory Global Get: Key is undefined: " + str(keyName))
	return null

func GlobalSet(keyName, value, newValue = false):
	if(newValue or _memoryGlobal.has(keyName)):
		_memoryGlobal[keyName] = value
	else:
		Castagne.Error("Memory Global Set: Key doesn't already exist: " + str(keyName))

func GlobalHas(keyName):
	return _memoryGlobal.has(keyName)



func AddPlayer():
	_memoryPlayers += [{}]

func PlayerGet(pid, keyName):
	if(_memoryPlayers[pid].has(keyName)):
		return _memoryPlayers[pid][keyName]
	Castagne.Error("Memory Player Get ("+str(pid)+"): Key is undefined: " + str(keyName))
	return null

func PlayerSet(pid, keyName, value, newValue = false):
	if(newValue or _memoryPlayers[pid].has(keyName)):
		_memoryPlayers[pid][keyName] = value
	else:
		Castagne.Error("Memory Player Set ("+str(pid)+"): Key doesn't already exist: " + str(keyName))

func PlayerHas(pid, keyName):
	return _memoryPlayers[pid].has(keyName)


func AddEntity():
	_memoryEntities += [{}]
	return _memoryEntities.size()-1

func RemoveEntity(eid):
	_memoryEntities[eid] = null

func EntityGet(eid, keyName):
	if(_memoryEntities[eid].has(keyName)):
		return _memoryEntities[eid][keyName]
	Castagne.Error("Memory Entity Get ("+str(eid)+"): Key is undefined: " + str(keyName))
	return null

func EntitySet(eid, keyName, value, newValue = false):
	if(newValue or _memoryEntities[eid].has(keyName)):
		_memoryEntities[eid][keyName] = value
	else:
		Castagne.Error("Memory Entity Set ("+str(eid)+"): Key doesn't already exist: " + str(keyName))

func EntityHas(eid, keyName):
	return _memoryEntities[eid].has(keyName)
