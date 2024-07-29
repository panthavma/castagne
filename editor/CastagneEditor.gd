# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

var documentation
var configData = null
var tutorialPath = null
var skipFirstTimeFlow = false

func _ready():
	if(configData == null):
		configData = Castagne.baseConfigData
	
	$Config.editor = self
	$CharacterEdit.editor = self
	$Documentation.editor = self
	
	$Documentation.SetupDocumentation()
	
	EnterMenu()
	
	if(tutorialPath != null):
		$TutorialSystem.StartTutorial(tutorialPath)

func EnterMenu():
	for c in get_children():
		c.hide()
	$Background.show()
	$MainMenu.show()
	
	# Header
	var gameTitle = configData.Get("GameTitle")+"\n"+configData.Get("GameVersion")
	var castagneTitle = configData.Get("CastagneVersion")
	$MainMenu/Header/GameTitle.set_text(gameTitle)
	$MainMenu/Header/CastagneTitle.set_text(castagneTitle)
	
	var flowModule = configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.FLOW)
	var flowRoot = $MainMenu/FlowPanel
	if(flowModule != null):
		for c in flowRoot.get_children():
			c.show()
		flowRoot.get_node("Error").hide()
		flowRoot.get_node("Generic").hide()
		
		var customRoot = flowRoot.get_node("Custom/VBox")
		for c in customRoot.get_children():
			c.queue_free()
		
		FlowCreateAdvancedWindow(flowRoot.get_node("Generic"))
		
		flowModule.EditorCreateFlowWindow(self, customRoot)
		_on_FlowAdvanced_toggled(flowRoot.get_node("FlowAdvanced").is_pressed())
	else:
		for c in flowRoot.get_children():
			c.hide()
		flowRoot.get_node("Error").show()
	
	
	# First time flow
	if(!skipFirstTimeFlow):
		if(!configData.Get("LocalConfig-Editor-FirstTimeLaunchDone")):
			EnterSubmenu("FirstTimeLaunch")
		elif(!configData.Get("Editor-FirstTimeFlowDone")):
			EnterSubmenu("FirstTimeFlow")
	
	if(tutorialPath != null):
		$TutorialSystem.show()


func EnterSubmenu(submenuName, callback = null, dataPassthrough = null):
	for c in get_children():
		c.hide()
	$Background.show()
	var submenu = get_node(submenuName)
	if(callback == null):
		callback = funcref(self, "SubmenuStandardCallback")
	submenu.callbackFunction = callback
	submenu.dataPassthrough = dataPassthrough
	submenu.show()
	submenu.Enter()
	if(tutorialPath != null):
		$TutorialSystem.show()

func SubmenuStandardCallback(_idx):
	EnterMenu()

func OpenDocumentation(page = null):
	$Documentation.show()
	$Documentation.OpenDocumentation(page)















func _tools_ready():
	$TextEdit.set_text(PrintDocumentation())

func PrintStateActions(actions, indentLevel = 1):
	for action in actions:
		var indent = ""
		for i in range(indentLevel):
			indent += "    "
		var t = indent + action["FuncName"]
		print(t)
		if(action["FuncName"].begins_with("Instruction ")):
			PrintStateActions(action["True"], indentLevel+1)
			print(indent+"else")
			PrintStateActions(action["False"], indentLevel+1)

func PrintCharacterOverview(cdata):
	var t = "--- [Character Overview] "+cdata["Character"]["Name"]+" ---"
	
	t += "\n>>> [METADATA] : "+str(cdata["Character"].size())
	#t += "\n"+str(cdata["Character"].keys())
	t += "\n>>> [CONSTANTS] : "+str(cdata["Constants"].size())
	#t += "\n"+str(cdata["Constants"].keys())
	t += "\n>>> [VARIABLES] : "+str(cdata["Variables"].size())
	#t += "\n"+str(cdata["Variables"].keys())
	t += "\n>>> [STATES] : "+str(cdata["States"].size())
	t += "\n"+str(cdata["States"].keys())
	
	print(t)

func PrintDocumentation():
	var t = "----\n"
	
	for m in Castagne.modules:
		t += "# " + m.moduleName + "\n"
		t += m.moduleDocumentation["Description"] + "\n\n"
		for categoryName in m.moduleDocumentationCategories:
			var c = m.moduleDocumentationCategories[categoryName]
			var vars = c["Variables"]
			var funcs = c["Functions"]
			var flags = c["Flags"]
			if(vars.empty() and funcs.empty() and flags.empty()):
				continue
			t += "## " + categoryName + "\n"
			t += c["Description"] + "\n"
			
			
			if(!funcs.empty()):
				t += "\n### Functions\n"
				for f in funcs:
					t += "--- " + f["Name"] + ":  ("+str(f["Documentation"]["Arguments"])+")\n"
					t += f["Documentation"]["Description"] + "\n\n"
			
			if(!vars.empty()):
				t += "\n### Variables\n"
				for v in vars:
					t += v["Name"] + ": " + v["Description"] + "\n"
			if(!flags.empty()):
				t += "\n### Flags\n"
				for f in flags:
					t += f["Name"] + ": " + f["Description"] + "\n"
			
			t += "\n"
		t += "----\n"
	
	return t


func _on_Config_pressed(advanced=false):
	EnterConfig(advanced)

func EnterConfig(advanced=false):
	$MainMenu.hide()
	$Config.EnterMenu(advanced)

func _on_CharacterEdit_pressed():
	StartCharacterEditor()
func _on_CharacterEditSafe_pressed():
	StartCharacterEditor(true)

func StartCharacterEditor(safeMode = false, battleInitData = null):
	$MainMenu.hide()
	$CharacterEdit.safeMode = safeMode
	if(battleInitData == null):
		battleInitData = GetCurrentlySelectedBattleInitData()
	
	$CharacterEdit.EnterMenu(battleInitData)

func GetCurrentlySelectedBattleInitData():
	if($MainMenu/FlowPanel/FlowAdvanced.is_pressed()):
		Castagne.Error("TODO: Use the correct BID from the flow panel")
		return configData.GetBaseBattleInitData()
	else:
		return configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.FLOW).EditorGetCurrentBattleInitData(self, $MainMenu/FlowPanel/Custom/VBox)

func StartBattle(battleInitData = null):
	if(battleInitData == null):
		battleInitData = GetCurrentlySelectedBattleInitData()
	queue_free()
	var ce = Castagne.InstanceCastagneEngine(battleInitData, configData)
	get_tree().get_root().add_child(ce)


func _on_CharacterEditNew_pressed():
	EnterSubmenu("CharacterSet", null, "CharAdd")




func _on_MainMenuDocumentation_pressed():
	OpenDocumentation($Documentation.defaultPage)

func _on_Updater_pressed():
	$MainMenu/UpdaterPanel.Open()


func _on_Characters_item_activated(_index):
	_on_CharacterEdit_pressed()




# Just copied from the started, a bit of a code smell lol
func _on_StartGame_pressed():
	var menu = Castagne.Menus.InstanceMenu("MainMenu")
	get_tree().get_root().add_child(menu)
	queue_free()
	#call_deferred("LoadLevel", configData.Get("PathMainMenu"))
func _on_StartGameMatch_pressed():
	pass # Replace with function body.
func _on_StartGameTraining_pressed():
	StartBattle()
func LoadLevel(path):
	var ps = load(path)
	var s = ps.instance()
	get_tree().get_root().add_child(s)
	queue_free()


func _on_Tutorials_pressed():
	EnterSubmenu("TutorialSelect")


func _on_FlowAdvanced_toggled(button_pressed):
	$MainMenu/FlowPanel/Custom.set_visible(!button_pressed)
	$MainMenu/FlowPanel/TmpOut.set_visible(button_pressed)
	$MainMenu/FlowPanel/Generic.set_visible(false)

func FlowCreateAdvancedWindow(flowRoot):
	var flowsRecent = flowRoot.get_node("VBox/Flows/Recent")
	var flowsPinned = flowRoot.get_node("VBox/Flows/Pinned")
	
	for c in flowsRecent.get_children():
		c.queue_free()
	for c in flowsPinned.get_children():
		c.queue_free()


func _on_FlowNewBID_pressed():
	EnterSubmenu("FlowSetup")




