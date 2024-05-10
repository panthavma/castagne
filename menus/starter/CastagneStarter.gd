# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

func MainMenu():
	call_deferred("LoadLevel", Castagne.baseConfigData.Get("PathMainMenu"))

func LocalBattle():
	Castagne.battleInitData["mode"] = "Battle"
	call_deferred("LoadLevel", Castagne.baseConfigData.Get("Engine"))

func Training():
	StartCastagneEngine(bid)

func Editor():
	StartCastagneEditor()

func DevTools():
	call_deferred("LoadLevel", "res://castagne/helpers/devtools/DevTools.tscn")

# --------------------------------------------------------------------------------------------------
# Internals

var timer = 2.0
var selectedItem = 0
var allowChoice = false


func _ready():
	if(Castagne.baseConfigData == null):
		$TitleLabel.set_text("Castagne Config had errors.")
		$Buttons.hide()
		$Characters.hide()
		return
	
	if(!allowChoice):
		if OS.has_feature("standalone"):
			$Hide.show()
			MainMenu()
		else:
			call_deferred("Editor")
		return
	
	$TitleLabel.set_text(Castagne.baseConfigData.Get("GameTitle")+" - "+Castagne.baseConfigData.Get("GameVersion")+"\n"+Castagne.baseConfigData.Get("CastagneVersion")+"\nPress any key to stop the timer")
	
	timer = float(Castagne.baseConfigData.Get("Starter-Timer"))/1000.0
	
	# Init Options
	var optionID = 0
	for button in $Buttons.get_children():
		var n = button.get_name()
		if(has_method(n)):
			var err = button.connect("pressed", self, "ButtonClick", [optionID])
			if err:
				Castagne.Error("[Starter]: " +str(n)+" button signal not connected!")
		else:
			Castagne.Error("[Starter]: " +str(n)+" button not associated to a function!")
		optionID += 1
	selectedItem = Castagne.baseConfigData.Get("Starter-Option")
	if(selectedItem >= optionID):
		selectedItem = 0
	UpdateButtonText()
	
	# Init characters
	var listID = 0
	for list in $Characters.get_children():
		list.clear()
		for c in Castagne.SplitStringToArray(Castagne.baseConfigData.Get("CharacterPaths")):
			list.add_item(c)
		var charToSelect = Castagne.baseConfigData.Get("Starter-P"+str(listID+1))
		if(charToSelect >= Castagne.SplitStringToArray(Castagne.baseConfigData.Get("CharacterPaths")).size()):
			charToSelect = 0
		list.select(charToSelect)
		listID += 1

func _process(delta):
	if(!allowChoice):
		return
	UpdateButtonText()
	
	if(timer >= 0):
		timer -= delta
		if(timer < 0):
			ActivateOption(selectedItem)

func _unhandled_input(event):
	if event is InputEventKey or event is InputEventJoypadButton:
		StopTimer()

func StopTimer():
	timer = -1

func ButtonClick(optionID):
	timer = 0
	selectedItem = optionID

func ActivateOption(optionID):
	var n = $Buttons.get_child(optionID).get_name()
	Castagne.Log("[Starter]: Activating option "+str(optionID)+": "+n)
	
	ApplyAndSaveSettings(optionID)
	
	if(has_method(n)):
		call_deferred(n)
	else:
		Castagne.Error("[Starter]: " +str(n)+" button not associated to a function!")

func UpdateButtonText():
	var i = 0
	for button in $Buttons.get_children():
		var n = button.get_name()
		
		if(i == selectedItem):
			if(timer > 0):
				var t = float(int(timer*100))/100.0
				n += " ("+str(t)+")"
			n = ">> "+n+" <<"
		i += 1
		
		button.set_text(n)

var bid = {}
func ApplyAndSaveSettings(optionID):
	bid = {}
	bid["online"] = false
	
	bid["p1-control-type"] = "local"
	bid["p1-control-param"] = "k1"
	bid["p2-control-type"] = "local"
	bid["p2-control-param"] = "c1"
	
	bid["map"] = 0
	
	bid["p1"] = $"Characters/0".get_selected_items()[0]
	bid["p2"] = $"Characters/1".get_selected_items()[0]
	bid["p1-palette"] = 0
	bid["p2-palette"] = (1 if bid["p1"] == bid["p2"] else 0)
	
	Castagne.baseConfigData.Set("Starter-Option", optionID)
	Castagne.baseConfigData.Get("Starter-P1", bid["p1"])
	Castagne.baseConfigData.Get("Starter-P2", bid["p2"])
	
	Castagne.baseConfigData.SaveConfigFile()


func RollbackTest():
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "k1"
	call_deferred("LoadLevel", "res://dev/rollback-test/RollbackOnlineTest.tscn")
	#call_deferred("LoadLevel", "res://dev/rollback-demo/Main.tscn")

func StartCastagneEngine(battleInitData = null, configData = null):
	var engine = Castagne.InstanceCastagneEngine(battleInitData, configData)
	get_tree().get_root().add_child(engine)
	queue_free()
	return engine

func StartCastagneEditor(configDataPath = null, addToTree = true):
	var configData = null
	if(configDataPath != null):
		configData = Castagne.LoadModulesAndConfig(configDataPath)
	var editor = Castagne.InstanceCastagneEditor(configData)
	if(addToTree):
		get_tree().get_root().add_child(editor)
	queue_free()
	return editor

func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()
