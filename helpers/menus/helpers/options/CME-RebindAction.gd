# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.


extends "../../elements/CME-Action.gd"



func Setup():
	.Setup()
	$Name.set_text(optionData["GameInput"])
	RefreshBind()

func OnSelect():
	$Name.set_text(">> "+optionData["GameInput"]+" <<")

func OnUnselect():
	$Name.set_text(optionData["GameInput"])


func RefreshBind():
	var action = optionData["GodotAction"]
	
	var events = InputMap.get_action_list(action)
	var text = ""
	for e in events:
		text += " | "+str(e.as_text())
	text += " | "
	$Bind.set_text(text)

func _on_MouseRebind_pressed():
	StartRebind()


func StartRebind(_args = null):
	if $"../.."._tmpInputCooldown > 0:
		return
	$Bind.set_text("Press a key to bind...")
	$"../.."._active = false
	rebinding = true
	# InputMap.action_erase_events

var rebinding = false
func _input(event):
	if not rebinding:
		return
	if event is InputEventKey and event.is_pressed():
		InputMap.action_erase_events(optionData["GodotAction"])
		InputMap.action_add_event(optionData["GodotAction"], event)
		Castagne.PlayerConfig_Set("bindings-"+optionData["GodotAction"], event.get_scancode())
		Castagne.PlayerConfig_Save()
		EndRebind()

func EndRebind():
	RefreshBind()
	$"../.."._active = true
	$"../.."._tmpInputCooldown = 0.4
	rebinding = false
