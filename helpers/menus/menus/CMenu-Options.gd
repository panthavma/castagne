# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneMenuCore.gd"


var deviceList = null

func MCB_OMFullScreen(_args):
	OS.set_window_fullscreen(!OS.is_window_fullscreen())
	Castagne.PlayerConfig_Set("fullscreen", OS.is_window_fullscreen())
	Castagne.PlayerConfig_Save()

func MCB_OMRebind(_args, deviceID):
	var device = deviceList[deviceID]
	$Menu.hide()
	$Rebind.InitMenu(null, device)
	$Rebind.show()
	_active = false
	$Rebind._active = true

func MCB_OMReturn(_args):
	queue_free()
	Castagne.Menus.MCB_BackToMainMenu(null)

func InitMenu(menuData, menuParams):
	.InitMenu(menuData, menuParams)
	$Rebind._configData = _configData
	$Rebind.InitMenu(menuData, "k1")
	$Rebind._active = false
	$Rebind.hide()

func Setup(menuData, menuParams):
	deviceList = _configData.Input().GetConnectedDevices()
	
	for o in menuData["Options"]:
		if(o["Action"] == "OMRebind"):
			o["List"] = deviceList.duplicate()
	
	.Setup(menuData, menuParams)
	
	get_node(MenuRootPath).add_child(SetupMouseRebindSelect())

func SetupMouseRebindSelect():
	var sceneRoot = VBoxContainer.new()
	var label = Label.new()
	label.set_text("Rebind Controls of Device:")
	label.set_align(Label.ALIGN_CENTER)
	sceneRoot.add_child(label)
	var root = HFlowContainer.new()
	root.set_alignment(FlowContainer.ALIGN_CENTER)
	sceneRoot.add_child(root)
	
	for dID in range(deviceList.size()):
		var b = Button.new()
		b.set_text(deviceList[dID])
		b.connect("pressed", self, "MCB_OMRebind", [null, dID])
		root.add_child(b)
	
	return sceneRoot
