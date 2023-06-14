extends "CastagneEditorSubmenu.gd"

var flowData = {}

func Enter():
	flowData = {
		"Name": "NO NAME",
		"Pinned": false,
		"BID":{},
	}
	
	if(dataPassthrough == null):
		var dt = OS.get_datetime()
		flowData["Name"] = str(dt["year"])+"-"+str(dt["month"])+"-"+str(dt["day"])+" "+str(dt["hour"])+":"+str(dt["minute"])+":"+str(dt["second"])
	
	var bid = editor.configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.FLOW).GetBaseBattleInitData(editor.configData)
	Castagne.FuseDataOverwrite(bid, flowData["BID"])
	flowData["BID"] = bid
	
	UpdateUIParameters()
	UpdateBID()


func UpdateUIParameters():
	$Parameters/FlowName/LineEdit.set_text(flowData["Name"])

func UpdateBID():
	var bid = flowData["BID"]
	var root = $BID/VBox
	for c in root.get_children():
		c.queue_free()
	
	UpdateBIDDictionary(root, bid)

func UpdateBIDDictionary(root, d):
	for key in d:
		var data = d[key]
		var t = typeof(data)
		
		var l = Label.new()
		l.set_text(key + " / " + str(typeof(data)))
		root.add_child(l)

func _on_Save_pressed():
	#editor.configData.Set("InputLayout", layout)
	Exit(1)


func _on_Cancel_pressed():
	Exit()
