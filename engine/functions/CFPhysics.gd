extends "CastagneFunctions.gd"

func Setup():
	RegisterFunction("Move", [2])
	RegisterFunction("MoveAbsolute", [2])
	RegisterFunction("AddMomentum", [2])
	RegisterFunction("AddMomentumAbsolute", [2])
	RegisterFunction("SetMomentum", [2])
	RegisterFunction("SetMomentumAbsolute", [2])
	RegisterFunction("BreakMomentum", [2])
	RegisterFunction("CapMomentum", [2])
	RegisterFunction("AddMomentumTurn", [2])
	RegisterFunction("AddMomentumTurnAbsolute", [2])
	
	RegisterFunction("SetOpponentPosition", [2])
	RegisterFunction("SetOpponentPositionAbsolute", [2])
	RegisterFunction("MoveOpponent", [2])
	RegisterFunction("MoveOpponentAbsolute", [2])
	
	RegisterFunction("Hurtbox", [4])
	RegisterFunction("Hitbox", [4])
	RegisterFunction("Colbox", [4])
	RegisterFunction("ResetHurtboxes", [0])
	RegisterFunction("ResetHitboxes", [0])

func StateSetup(pid, state, _engine):
	state[pid]["MomentumHor"] = 0
	state[pid]["MomentumVer"] = 0
	state[pid]["MovementHor"] = 0
	state[pid]["MovementVer"] = 0
	state[pid]["NbHurtboxes"] = 0
	state[pid]["NbHitboxes"] = 0
	state[pid]["Colbox"] = {"Left":-1, "Right":1, "Down":0, "Up":1}
	state[pid]["AttackHasHit"] = false
	state[pid]["Proration"] = 1.0

func PreFrame(pid, _playerState, _inputs, _previousState, state):
	state[pid]["MovementHor"] = 0
	state[pid]["MovementVer"] = 0
	
	state[pid]["NbHurtboxes"] = 0
	state[pid]["NbHitboxes"] = 0

func PostFrame(pid, _playerState, _inputs, _previousState, state):
	state[pid]["MovementHor"] += state[pid]["MomentumHor"]
	state[pid]["MovementVer"] += state[pid]["MomentumVer"]
	

func PrePhysics(pid, _playerState, _inputs, _previousState, state):
	state[pid]["PositionHor"] += state[pid]["MovementHor"]
	state[pid]["PositionVer"] += state[pid]["MovementVer"]

func PostPhysics(pid, _playerState, _inputs, _previousState, state):
	if(state[pid]["Events"].has("Grounded")):
		state[pid]["MomentumVer"] = max(state[pid]["MomentumVer"], 0)



func Move(args, pid, state):
	var newArgs = [GetInt(args[0], pid, state)*state[pid]["Facing"], GetInt(args[1], pid, state)]
	MoveAbsolute(newArgs, pid, state)
func MoveAbsolute(args, pid, state):
	state[pid]["MovementHor"] += GetInt(args[0], pid, state)
	state[pid]["MovementVer"] += GetInt(args[1], pid, state)

func AddMomentum(args, pid, state):
	var newArgs = [GetInt(args[0], pid, state)*state[pid]["Facing"], GetInt(args[1], pid, state)]
	AddMomentumAbsolute(newArgs, pid, state)
func AddMomentumAbsolute(args, pid, state):
	state[pid]["MomentumHor"] += GetInt(args[0], pid, state)
	state[pid]["MomentumVer"] += GetInt(args[1], pid, state)

func SetMomentum(args, pid, state):
	var newArgs = [GetInt(args[0], pid, state)*state[pid]["Facing"], GetInt(args[1], pid, state)]
	SetMomentumAbsolute(newArgs, pid, state)
func SetMomentumAbsolute(args, pid, state):
	state[pid]["MomentumHor"] = GetInt(args[0], pid, state)
	state[pid]["MomentumVer"] = GetInt(args[1], pid, state)

func BreakMomentum(args, pid, state):
	var h = min(GetInt(args[0], pid, state), abs(state[pid]["MomentumHor"]))
	var v = min(GetInt(args[1], pid, state), abs(state[pid]["MomentumVer"]))
	state[pid]["MomentumHor"] -= sign(state[pid]["MomentumHor"]) * h
	state[pid]["MomentumVer"] -= sign(state[pid]["MomentumVer"]) * v
#func BreakSecondaryMomentum(args, pid, state):
#	var h = min(GetInt(args[0], pid, state), abs(state[pid]["SecondaryMomentumHor"]))
#	var v = min(GetInt(args[1], pid, state), abs(state[pid]["SecondaryMomentumVer"]))
#	state[pid]["SecondaryMomentumHor"] -= sign(state[pid]["SecondaryMomentumHor"]) * h
#	state[pid]["SecondaryMomentumVer"] -= sign(state[pid]["SecondaryMomentumVer"]) * v

func CapMomentum(args, pid, state):
	var h = GetInt(args[0], pid, state)
	var v = GetInt(args[1], pid, state)
	
	if(h >= 0):
		state[pid]["MomentumHor"] = sign(state[pid]["MomentumHor"]) * min(abs(state[pid]["MomentumHor"]), h)
	if(v >= 0):
		state[pid]["MomentumVer"] = sign(state[pid]["MomentumVer"]) * min(abs(state[pid]["MomentumVer"]), v)

func AddMomentumTurn(args, pid, state):
	var newArgs = [GetInt(args[0], pid, state)*state[pid]["Facing"], GetInt(args[1], pid, state)]
	AddMomentumTurnAbsolute(newArgs, pid, state)
func AddMomentumTurnAbsolute(args, pid, state):
	var h = GetInt(args[0], pid, state)
	var v = GetInt(args[1], pid, state)
	
	if(h != 0 and sign(h) != sign(state[pid]["MomentumHor"])):
		state[pid]["MomentumHor"] = 0
	if(v != 0 and sign(v) != sign(state[pid]["MomentumVer"])):
		state[pid]["MomentumVer"] = 0
	
	AddMomentumAbsolute(args, pid, state)



func SetOpponentPosition(args, pid, state):
	var newArgs = [GetInt(args[0], pid, state)*state[pid]["Facing"], GetInt(args[1], pid, state)]
	SetOpponentPositionAbsolute(newArgs, pid, state)
func SetOpponentPositionAbsolute(args, pid, state):
	var opponentPID = ("p1" if pid=="p2" else "p2")
	state[opponentPID]["MovementHor"] += (state[pid]["PositionHor"] + GetInt(args[0], pid, state)) - state[opponentPID]["PositionHor"]
	state[opponentPID]["MovementVer"] += (state[pid]["PositionVer"] + GetInt(args[1], pid, state)) - state[opponentPID]["PositionVer"]
func MoveOpponent(args, pid, state):
	var newArgs = [GetInt(args[0], pid, state)*state[pid]["Facing"], GetInt(args[1], pid, state)]
	MoveOpponentAbsolute(newArgs, pid, state)
func MoveOpponentAbsolute(args, pid, state):
	var opponentPID = ("p1" if pid=="p2" else "p2")
	state[opponentPID]["MovementHor"] += GetInt(args[0], pid, state)
	state[opponentPID]["MovementVer"] += GetInt(args[1], pid, state)











func Colbox(args, pid, state):
	state[pid]["Colbox"] = {
		"Left":GetInt(args[0], pid, state),
		"Right":GetInt(args[1], pid, state),
		"Down":GetInt(args[2], pid, state),
		"Up":GetInt(args[3], pid, state),
	}

func Hurtbox(args, pid, state):
	var hurtboxID = state[pid]["NbHurtboxes"]
	
	state[pid]["Hurtbox"+str(hurtboxID)] = {
		"Left":GetInt(args[0], pid, state),
		"Right":GetInt(args[1], pid, state),
		"Down":GetInt(args[2], pid, state),
		"Up":GetInt(args[3], pid, state),
	}
	
	state[pid]["NbHurtboxes"] += 1

func Hitbox(args, pid, state):
	var hurtboxID = state[pid]["NbHitboxes"]
	
	state[pid]["Hitbox"+str(hurtboxID)] = {
		"Left":GetInt(args[0], pid, state),
		"Right":GetInt(args[1], pid, state),
		"Down":GetInt(args[2], pid, state),
		"Up":GetInt(args[3], pid, state),
		"AttackData":state[pid]["AttackData"]
	}
	
	state[pid]["NbHitboxes"] += 1

func ResetHurtboxes(_args, pid, state):
	state[pid]["NbHurtboxes"] = 0
func ResetHitboxes(_args, pid, state):
	state[pid]["HitboxNb"] = 0
