extends Control


var callbackFunction
var dataPassthrough
onready var editor = $".."

func Enter():
	show()

func Exit(param = null):
	callbackFunction.call_func(param)


func _on_Cancel_pressed():
	Exit()

func _on_Confirm_pressed():
	Exit(OK)
