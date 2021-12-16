extends Node

var castagne

func Setup():
	pass
func InitTool(_engine, _battleInitData):
	pass
func StateSetup(_pid, _state, _engine):
	pass
func FrameStart(_previousState, _state, _engine):
	pass
func PreFrame(_pid, _playerState, _inputs, _previousState, _state):
	pass
func PostFrame(_pid, _playerState, _inputs, _previousState, _state):
	pass
func PrePhysics(_pid, _playerState, _inputs, _previousState, _state):
	pass
func PostPhysics(_pid, _playerState, _inputs, _previousState, _state):
	pass
func PostTransition(_pid, _playerState, _inputs, _previousState, _state):
	pass

func UpdateGraphics(_state, _engine):
	pass
func UpdatePlayerGraphics(_pid, _globalState, _engine):
	pass

func IsHitConfirmed(isCurrentlyHit, _attackData, _defenderPID, _attackerPID, _state):
	return isCurrentlyHit
func OnHit(_attackData, _defenderPID, _attackerPID, _state, _defenderEvents):
	pass
func OnBlock(_attackData, _defenderPID, _attackerPID, _state, _defenderEvents):
	pass

func RegisterFunction(functionName, nbArguments, flags = null):
	var parseFunc = null
	var actionFunc = null
	
	if(flags == null):
		flags = ["FrameFunc"]
	
	if(!flags.has("TransitionFunc") and !flags.has("FrameFunc") and !flags.has("NoFunc")):
		flags += ["FrameFunc"]
	
	if(has_method("Parse"+functionName)):
		parseFunc = funcref(self, "Parse"+functionName)
	
	if(has_method(functionName)):
		actionFunc = funcref(self, functionName)
	
	if(parseFunc == null and actionFunc == null):
		castagne.Error(functionName+" : Parse function or Action func couldn't be found.")
		return
	
	castagne.functions[functionName] = {
		"Name": functionName,
		"NbArgs": nbArguments,
		"ParseFunc": parseFunc,
		"ActionFunc": actionFunc,
		"Flags": flags,
	}


func CallOtherFunction(functionName, args, pid, state, engine=null, neededFlag=null):
	if(neededFlag != null):
		castagne.functions[functionName]["ActionFunc"].call_func(args, pid, state, engine, neededFlag)
	else:
		castagne.functions[functionName]["ActionFunc"].call_func(args, pid, state)

func GetInt(value, pid, state):
	return Castagne.GetInt(value, pid, state)

func GetStr(value, pid, state):
	return Castagne.GetStr(value, pid, state)

func GetBool(value, pid, state):
	return Castagne.GetBool(value, pid, state)

func GetIntArg(id, default, args, pid, state):
	return (GetInt(args[id], pid, state) if args.size() > id else default)
func GetStrArg(id, default, args, pid, state):
	return (GetStr(args[id], pid, state) if args.size() > id else default)
func GetBoolArg(id, default, args, pid, state):
	return (GetBool(args[id], pid, state) if args.size() > id else default)

