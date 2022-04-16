extends Control

# :TODO:Panthavma:20211230:Be able to parameter some autostart features
# :TODO:Panthavma:20211230:Start making an editor, Editor must include dev functions
# :TODO:Panthavma:20220317:Save the parameters to the settings
# :TODO:Panthavma:20220317:Use the parameters from the data


func MainMenu():
	call_deferred("LoadLevel", Castagne.configData["MainMenu"])

func LocalBattle():
	Castagne.battleInitData["mode"] = "Battle"
	call_deferred("LoadLevel", Castagne.configData["Engine"])

func Training():
	Castagne.battleInitData["mode"] = "Training"
	call_deferred("LoadLevel", Castagne.configData["Engine"])

func Editor():
	call_deferred("LoadLevel", Castagne.configData["Editor"])

func DevTools():
	print("no")

# --------------------------------------------------------------------------------------------------
# Internals

var timer = 2.0
var selectedItem = 0

func _ready():
	if OS.has_feature("standalone"):
		$Hide.show()
		MainMenu()
	else:
		$TitleLabel.set_text(Castagne.configData["GameTitle"]+" - "+Castagne.configData["GameVersion"]+"\n"+Castagne.configData["CastagneVersion"]+"\nPress any key to stop the timer")
		
		timer = float(Castagne.configData["Starter-Timer"])/1000.0
		
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
		selectedItem = Castagne.configData["Starter-Option"]
		if(selectedItem >= optionID):
			selectedItem = 0
		UpdateButtonText()
		
		# Init characters
		var listID = 0
		for list in $Characters.get_children():
			list.clear()
			for c in Castagne.configData["CharacterPaths"]:
				list.add_item(c)
			var charToSelect = Castagne.configData["Starter-P"+str(listID+1)]
			if(charToSelect >= Castagne.configData["CharacterPaths"].size()):
				charToSelect = 0
			list.select(charToSelect)
			listID += 1

func _process(delta):
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
		funcref(self, n).call_func()
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

func ApplyAndSaveSettings(optionID):
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "c1"
	
	Castagne.battleInitData["p1"] = $"Characters/0".get_selected_items()[0]
	Castagne.battleInitData["p2"] = $"Characters/1".get_selected_items()[0]
	Castagne.battleInitData["p1-palette"] = 0
	Castagne.battleInitData["p2-palette"] = (1 if Castagne.battleInitData["p1"] == Castagne.battleInitData["p2"] else 0)
	
	Castagne.configData["Starter-Option"] = optionID
	Castagne.configData["Starter-P1"] = Castagne.battleInitData["p1"]
	Castagne.configData["Starter-P2"] = Castagne.battleInitData["p2"]
	
	Castagne.SaveConfigFile()


func RollbackTest():
	Castagne.battleInitData["p1-control-type"] = "local"
	Castagne.battleInitData["p1-control-param"] = "k1"
	Castagne.battleInitData["p2-control-type"] = "local"
	Castagne.battleInitData["p2-control-param"] = "k1"
	call_deferred("LoadLevel", "res://dev/rollback-test/RollbackOnlineTest.tscn")
	#call_deferred("LoadLevel", "res://dev/rollback-demo/Main.tscn")

func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()
