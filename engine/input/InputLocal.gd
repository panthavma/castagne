extends "InputBase.gd"

var prefix

const INPUT_ANALOG_STICK_THRESHOLD = 0.4

func Init(param):
	prefix = param


func PollRaw():
	var id = GetEmptyRawInputData()
	
	var dpad = Vector2(
		Input.get_action_strength(prefix+"_right") - Input.get_action_strength(prefix+"_left"),
		Input.get_action_strength(prefix+"_up") - Input.get_action_strength(prefix+"_down")
	)
	
	id["Right"] = (dpad.x >=  INPUT_ANALOG_STICK_THRESHOLD)
	id["Left"]  = (dpad.x <= -INPUT_ANALOG_STICK_THRESHOLD)
	id["Up"]    = (dpad.y >=  INPUT_ANALOG_STICK_THRESHOLD)
	id["Down"]  = (dpad.y <= -INPUT_ANALOG_STICK_THRESHOLD)
	
	id["A"] = Input.is_action_pressed(prefix+"_a")
	id["B"] = Input.is_action_pressed(prefix+"_b")
	id["C"] = Input.is_action_pressed(prefix+"_c")
	id["D"] = Input.is_action_pressed(prefix+"_d")
	id["L"] = Input.is_action_pressed(prefix+"_l")
	id["R"] = Input.is_action_pressed(prefix+"_r")
	id["Pause"] = Input.is_action_pressed(prefix+"_start")
	id["Reset"] = Input.is_action_pressed(prefix+"_select")
	id["M1"] = Input.is_action_pressed(prefix+"_m1")
	id["M2"] = Input.is_action_pressed(prefix+"_m2")
	id["M3"] = Input.is_action_pressed(prefix+"_m3")
	return id
