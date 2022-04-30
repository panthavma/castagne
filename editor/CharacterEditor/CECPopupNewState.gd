extends WindowDialog


func Show():
	$"..".show()
	popup_centered()
	get_close_button().hide()


func Cancel():
	pass

func Create():
	pass
