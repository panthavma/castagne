extends PanelContainer

var editor
var _categoryData

func InitFromCategory(categoryData):
	$Contents/Header/CategoryName.set_text(categoryData["Name"])
	editor = categoryData["Editor"]
	_categoryData = categoryData
	if(categoryData["Open"]):
		Expand()
	else:
		Reduce()

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
	editor.categoriesStatus[_categoryData["FullName"]] = true

func Reduce():
	$Contents/Header/ButtonExpand.set_text("+")
	$Contents/States.hide()
	editor.categoriesStatus[_categoryData["FullName"]] = false
