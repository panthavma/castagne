extends PanelContainer


func InitFromCategory(categoryData):
	$Contents/Header/CategoryName.set_text(categoryData["Name"])
	Expand()

func AddItem(state):
	$Contents/States/StateList.add_child(state)


func _on_ButtonExpand_pressed():
	if($Contents/States.is_visible()):
		Reduce()
	else:
		Expand()


func Expand():
	$Contents/Header/ButtonExpand.set_text("-")
	$Contents/States.show()

func Reduce():
	$Contents/Header/ButtonExpand.set_text("+")
	$Contents/States.hide()
