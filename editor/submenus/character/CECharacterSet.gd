# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"

# TODO: Error when 0 fighters are valid
# TODO: Add new char, go to real id = prob avec getselecteditems

var SORTING_OPTIONS = {
	"Editor Order": "EditorOrder",
	"Real ID": "ID",
	"Name": "Name",
	"Path": "Path"
}
var MOVABLE_KEYS = ["EditorOrder", "ID"]

onready var skelListRoot = $LeftPanel/SkeletonList
onready var charListRoot = $LeftPanel/CharacterList
onready var sortOrderButton = $LeftPanel/CharacterShow/SortOrder
onready var sortOrderReversedButton = $LeftPanel/CharacterShow/SortReversed
onready var charInfoRoot = $CharacterInfo
onready var charDataRoot = $CharacterInfo/Data/VBox

onready var buttonCharUp = $LeftPanel/CharacterControls/CharUp
onready var buttonCharDown = $LeftPanel/CharacterControls/CharDown

var sortKey
var sortReversed
var skeletons = []
var characters = []
var cidToPosInArray = []

func Enter():
	InitializeFromConfigData()
	SortCharacters("EditorOrder")
	CreateWindow()
	SelectCharacter(0)
	skelListRoot.select(0)
	_on_SkeletonList_item_selected(0)
	if(dataPassthrough == "CharAdd"):
		_on_CharAdd_pressed()

func InitializeFromConfigData():
	skeletons = Castagne.SplitStringToArray(editor.configData.Get("Skeletons"))
	characters = editor.configData.GetEditorCharacterList()
	SortCharacters()

func AddCharacterFromPath(path):
	var c = editor.configData.GetEditorCharacterData(path)
	c["ID"] = characters.size()
	characters.push_back(c)

func CreateWindow():
	sortOrderButton.clear()
	
	for so in SORTING_OPTIONS:
		sortOrderButton.add_item(so)
	
	UpdateCharacterList()
	UpdateSkeletonList()

func UpdateCharacterList():
	charListRoot.clear()
	for c in characters:
		charListRoot.add_item("["+str(c["ID"])+"] "+c["Name"])

func UpdateSkeletonList():
	skelListRoot.clear()
	for i in range(skeletons.size()):
		skelListRoot.add_item("["+str(i)+"] " + skeletons[i])

func SortCharacters(key = "ID", reversed = false):
	# Editor Order Management (if not set)
	var maxEditorOrder = 0
	for c in characters:
		if(c["EditorOrder"] != null):
			maxEditorOrder = max(c["EditorOrder"], maxEditorOrder)
	for c in characters:
		if(c["EditorOrder"] == null):
			maxEditorOrder += 100
			c["EditorOrder"] = maxEditorOrder
	
	# Sort
	sortKey = key
	sortReversed = reversed
	characters.sort_custom(self, "_SortCharacters_Sorter")
	
	# Update indexes
	cidToPosInArray = []
	for i in range(characters.size()):
		cidToPosInArray.push_back(-1)
	for i in range(characters.size()):
		var c = characters[i]
		cidToPosInArray[c["ID"]] = i
	
	UpdateCharacterList()

func _SortCharacters_Sorter(a, b):
	var aVal = a[sortKey]
	var bVal = b[sortKey]
	if(aVal == bVal):
		aVal = a["ID"]
		bVal = b["ID"]
	
	if(sortReversed):
		return bVal < aVal
	else:
		return aVal < bVal

func SelectCharacter(cid):
	var pos = cidToPosInArray[cid]
	_SelectCharacterByPos(pos)

func _SelectCharacterByPos(pos):
	charListRoot.select(pos)
	_CharacterFocused(pos)
	var c = characters[pos]
	
	charInfoRoot.get_node("Title").set_text(c["Name"])
	charInfoRoot.get_node("IDs/RealID").set_value(c["ID"])
	charInfoRoot.get_node("IDs/EditorOrder").set_value(c["EditorOrder"])
	charInfoRoot.get_node("Filepath/LineEdit").set_text(c["Path"])
	
	for child in charDataRoot.get_children():
		child.queue_free()
	for k in c["Data"]:
		var v = c["Data"][k]
		var l = Label.new()
		l.set_text(str(k)+": "+str(v))
		charDataRoot.add_child(l)

func _CharacterFocused(pos):
	if(sortKey in MOVABLE_KEYS):
		buttonCharUp.set_disabled(pos == 0)
		buttonCharDown.set_disabled(pos == characters.size()-1)
	else:
		buttonCharUp.set_disabled(true)
		buttonCharDown.set_disabled(true)
	$LeftPanel/CharacterControls/CharRemove.set_disabled(characters.size() <= 1)


func _on_CharacterList_item_activated(index):
	_SelectCharacterByPos(index)
func _on_CharacterList_item_selected(index):
	_CharacterFocused(index)

func _on_SkelAdd_pressed():
	$NewSkelDialog.popup_centered()
func _on_SkelRemove_pressed():
	var index = skelListRoot.get_selected_items()[0]
	skeletons.remove(index)
	UpdateSkeletonList()
	skelListRoot.select(0)
	_on_SkeletonList_item_selected(0)
func _on_SkelUp_pressed():
	var index = skelListRoot.get_selected_items()[0]
	SkelSwap(index-1)
	UpdateSkeletonList()
func _on_SkelDown_pressed():
	var index = skelListRoot.get_selected_items()[0]
	SkelSwap(index)
	UpdateSkeletonList()
func SkelSwap(posLow):
	var posHigh = posLow + 1
	var h = skeletons.pop_at(posHigh)
	skeletons.insert(posLow, h)

func _on_CharAdd_pressed():
	$NewCharDialog.popup_centered()
func _on_CharRemove_pressed():
	var pos = charListRoot.get_selected_items()[0]
	var removedCID = characters[pos]["ID"]
	characters.remove(pos)
	
	for c in characters:
		if(c["ID"] >= removedCID):
			c["ID"] -= 1
	
	SortCharacters(sortKey, sortReversed)
	UpdateCharacterList()
	if(pos == characters.size()):
		pos -= 1
	_SelectCharacterByPos(pos)
func _on_CharUp_pressed():
	_CharUpDown(-1)
func _on_CharDown_pressed():
	_CharUpDown(1)
func _CharUpDown(posDiff):
	if(sortKey in MOVABLE_KEYS):
		var pos = charListRoot.get_selected_items()[0]
		CharSwapKey(pos, pos+posDiff, sortKey)
		SortCharacters(sortKey, sortReversed)
		_SelectCharacterByPos(pos+posDiff)
func CharSwapKey(posA, posB, keyToSwap):
	var s = characters[posA][keyToSwap]
	characters[posA][keyToSwap] = characters[posB][keyToSwap]
	characters[posB][keyToSwap] = s

func _on_SortOrder_item_selected(index):
	var newKey = SORTING_OPTIONS[SORTING_OPTIONS.keys()[index]]
	_ChangeSorting(newKey, sortReversed)
func _on_SortReversed_toggled(button_pressed):
	_ChangeSorting(sortKey, button_pressed)
func _ChangeSorting(newKey, reversed):
	var prevPos = charListRoot.get_selected_items()[0]
	var cid = characters[prevPos]["ID"]
	SortCharacters(newKey, reversed)
	SelectCharacter(cid)

func _on_Confirm_pressed():
	# TODO save
	SortCharacters()
	var characterList = null
	var editorOrders = []
	for c in characters:
		var path = c["Path"]
		if(characterList == null):
			characterList = ""
		else:
			characterList += ", "
		characterList += path
		editorOrders += [c["EditorOrder"]]
	editor.configData.Set("CharacterPaths", characterList)
	editor.configData.Set("EditorCharacterOrder", editorOrders)
	
	var skeletonsList = null
	for path in skeletons:
		if(skeletonsList == null):
			skeletonsList = ""
		else:
			skeletonsList += ", "
		skeletonsList += path
	editor.configData.Set("Skeletons", skeletonsList)
	
	
	Exit(OK)



func _on_NewCharDialog_file_selected(path):
	if(!CheckIfCaspFileIsValidOrCreateIt(path)):
		return
	CharacterIsAdded(path)



func CharacterIsAdded(path):
	AddCharacterFromPath(path)
	SortCharacters(sortKey, sortReversed)
	UpdateCharacterList()

func CheckIfCaspFileIsValidOrCreateIt(path):
	if(!path.ends_with(".casp")):
		path += ".casp"
	
	var f = File.new()
	var fileExists = f.file_exists(path)
	
	if(path.begins_with("res://castagne/") and !fileExists):
		Castagne.Error("Can't create a character inside of the Castagne folders!")
		$ErrorDialog.popup_centered()
		return false
	
	if(!fileExists):
		editor.EnterSubmenu("CharacterAddNew", funcref(self, "OnReturnFromCharacterNewMenu"), path)
		return false
	
	return true

func OnReturnFromCharacterNewMenu(path):
	get_node("../CharacterAddNew").hide()
	show()
	
	if(path == null):
		return
	
	CharacterIsAdded(path)


func _on_SkeletonList_item_selected(index):
	$LeftPanel/SkeletonControls/SkelUp.set_disabled(index == 0)
	$LeftPanel/SkeletonControls/SkelDown.set_disabled(index >= skeletons.size()-1)
	$LeftPanel/SkeletonControls/SkelRemove.set_disabled(skeletons.size() == 0)


func _on_NewSkelDialog_file_selected(path):
	if(!CheckIfCaspFileIsValidOrCreateIt(path)):
		return
	
	skeletons += [path]
	UpdateSkeletonList()


func _on_SkeletonList_nothing_selected():
	$LeftPanel/SkeletonControls/SkelUp.set_disabled(true)
	$LeftPanel/SkeletonControls/SkelDown.set_disabled(true)
	$LeftPanel/SkeletonControls/SkelRemove.set_disabled(true)
