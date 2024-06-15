# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"

var listLength = 1
onready var listCont = $Data/VBoxContainer

func Enter():
	var aliases = editor.configData.Get("MotionAliases").duplicate(true)
	var delete = listCont.get_node("0/Delete")
	delete.connect("pressed", self, "_on_Delete_pressed", [delete])
	if listLength < len(aliases):
		AddField(len(aliases) - listLength)
	for i in range(len(aliases)):
		listCont.get_node(str(i)).get_node("Name").set_text(aliases[i]["Name"])
		listCont.get_node(str(i)).get_node("Alias").set_text(aliases[i]["Aliases"])

func _on_Confirm_pressed():
	var aliases = []
	aliases.resize(listLength)
	for i in range(listLength):
		aliases[i] = {
			"Name":listCont.get_node(str(i)).get_node("Name").get_text(),
			"Aliases":listCont.get_node(str(i)).get_node("Alias").get_text()
		}
	editor.configData.Set("MotionAliases", aliases)
	Exit(OK)

func _on_Cancel_pressed():
	Exit()


func _on_AddField_pressed():
	AddField()

func AddField(num = 1):
	var addButton = listCont.get_node("AddField")
	if num < 1:
		return
	for i in range(listLength, listLength + num):
		var newField = listCont.get_node("0").duplicate()
		newField.set_name(str(i))
		newField.get_node("Name").set_text("")
		newField.get_node("Alias").set_text("")
		
		var newDelete = newField.get_node("Delete")
		newDelete.connect("pressed", self, "_on_Delete_pressed", [newDelete])
		
		listCont.add_child(newField)
		listCont.move_child(addButton, addButton.get_index() + 1)
	listLength += num

func DeleteField(index):
	if index < 0 || index >= listLength:
		return
	if listLength <= 1:
		listCont.get_node("0/Name").set_text("")
		listCont.get_node("0/Alias").set_text("")
		return
	
	#have to rename here so the queue'd node isn't preventing other nodes from being renamed
	listCont.get_node(str(index)).set_name("x")
	listCont.get_node("x").queue_free()
	
	for i in range(index + 1, listLength):
		listCont.get_node(str(i)).set_name(str(i-1))
	
	listLength -= 1

func _on_Delete_pressed(button):
	#I think its simplest to use the name of the container as the index
	var index = int(button.get_parent().get_name())
	DeleteField(index)
