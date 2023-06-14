# Holds a stack

extends Node

var _memoryGlobal = {}
var _memoryPlayers = []
var _memoryEntities = []

func InitMemory():
	pass

func CopyFrom(other):
	#var start = OS.get_ticks_usec()
	_memoryGlobal = other._memoryGlobal.duplicate(true)
	_memoryPlayers = other._memoryPlayers.duplicate(true)
	_memoryEntities = other._memoryEntities.duplicate(true)
	#print("Copy mem percent budget: " + str(((OS.get_ticks_usec() - start)/1000000.0)/(100.0/60.0)))
	#for op in other._memoryPlayers:
	#	if(op != null):
	#		op = op.duplicate(true)
	#	_memoryPlayers += [op]
	#for oe in other._memoryEntities:
	#	if(oe != null):
	#		oe = oe.duplicate(true)
	#	_memoryEntities += [oe]

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
