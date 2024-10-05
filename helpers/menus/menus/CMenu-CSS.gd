# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneMenuCore.gd"

var characterList
var playerSlots
var devices
export var MenuCSSGridPath = "Characters/Rows"
export var MenuPlayerSlotsPath = "Players/PlayersRoot"

func Setup(menuData, menuParams):
	devices = menuParams["Devices"]
	GatherCharacterList()
	CreateCharacterGrid()
	CreatePlayerSlots()


func GatherCharacterList():
	characterList = _configData.GetGameCharacterList()

func CreateCharacterGrid():
	if(characterList.empty()):
		return
	
	# Get initial grid size
	var posCharacter0 = GetCharacterGridPosition(characterList[0])
	var gridXMin = posCharacter0[0]
	var gridXMax = posCharacter0[0]
	var gridYMin = posCharacter0[1]
	var gridYMax = posCharacter0[1]
	
	for c in characterList:
		var pos = GetCharacterGridPosition(c)
		gridXMin = (gridXMin if gridXMin <= pos[0] else pos[0])
		gridXMax = (gridXMax if gridXMax >= pos[0] else pos[0])
		gridYMin = (gridYMin if gridYMin <= pos[1] else pos[1])
		gridYMax = (gridYMax if gridYMax >= pos[1] else pos[1])
	
	var gridXSize = gridXMax - gridXMin + 1
	var gridYSize = gridYMax - gridYMin + 1
	var gridXOffset = -gridXMin
	var gridYOffset = -gridYMin
	
	# Get grid positions and conflicts
	var gridData = []
	var gridDataLine = []
	for i in gridXSize:
		gridDataLine.push_back([null, []])
	for i in gridYSize:
		gridData.push_back(gridDataLine.duplicate(true))
	
	var gridConflicts = []
	var gridBaseChars = 0
	for c in characterList:
		var pos = GetCharacterGridPosition(c)
		pos[0] += gridXOffset
		pos[1] += gridYOffset
		
		c["CSS"] = {
			"GridPos": pos,
			"Data": c["TransformedData"]["MenuData"]["Defines"],
			"Node": null,
		}
		
		var g = gridData[pos[1]][pos[0]]
		if(pos[2] == 0): # Base character
			if(g[0] == null):
				g[0] = c
				gridBaseChars += 1
			else:
				gridConflicts.push_back(c)
		else: # Stacked characters
			g[1].push_back(c)
	
	# Slide Z stacks if needed and manage conflicts
	for y in gridYSize:
		for x in gridXSize:
			var g = gridData[y][x]
			g[1].sort_custom(self, "_CreateCharacterGrid_ZStack")
			if(g[0] == null and !g[1].empty()):
				g[0] = g[1].pop_front()
				gridBaseChars += 1
	
	if(!gridConflicts.empty()):
		while(gridXSize*gridYSize < gridBaseChars + gridConflicts.size()):
			gridYSize += 1
			gridData.push_back(gridDataLine.duplicate(true))
		
		for c in gridConflicts:
			Castagne.Error("CSS Conflict: "+c["Character"]["Filepath"])
			var emptyG = null
			for y in gridYSize:
				for x in gridXSize:
					if(emptyG != null):
						continue
					var g = gridData[y][x]
					if(g[0] == null):
						emptyG = g
			emptyG[0] = c
	
	# Create icons and grid nodes
	var nodes = []
	var nodesRoot = get_node(MenuCSSGridPath)
	for y in gridYSize:
		var nodesRow = []
		var nRow = CreateCSSGridRow()
		for x in gridXSize:
			var g = gridData[y][x]
			var n = CreateCharacterIcon(g)
			if(g[0] != null):
				g[0]["CSS"]["Node"] = n
			nodesRow.push_back(n)
			nRow.add_child(n)
		nodes.push_back(nodesRow)
		nodesRoot.add_child(nRow)
	
	# Create links
	for y in gridYSize:
		for x in gridXSize:
			var g = gridData[y][x]
			if(g[0] == null):
				continue
			var n = g[0]["CSS"]["Node"]
			n.SetNeighboor("Left", _CreateCharacterGrid_GetNeighboorBase(gridData, x, y, gridXSize, gridYSize, -1, true))
			n.SetNeighboor("Right", _CreateCharacterGrid_GetNeighboorBase(gridData, x, y, gridXSize, gridYSize, 1, true))
			n.SetNeighboor("Up", _CreateCharacterGrid_GetNeighboorBase(gridData, x, y, gridXSize, gridYSize, -1, false))
			n.SetNeighboor("Down", _CreateCharacterGrid_GetNeighboorBase(gridData, x, y, gridXSize, gridYSize, 1, false))

func _CreateCharacterGrid_ZStack(a, b):
	return a["CSS"]["GridPos"][2] < b["CSS"]["GridPos"][2]

func _CreateCharacterGrid_GetNeighboorBase(gridData, x, y, gridXSize, gridYSize, direction, horizontal, cycle = true):
	if(horizontal):
		var directNeighboor = _CreateCharacterGrid_GetHorizontalNeighboor(gridData, x, y, gridXSize, gridYSize, direction, false, true)
		if(directNeighboor[0] == null):
			return _CreateCharacterGrid_GetHorizontalNeighboor(gridData, x, y, gridXSize, gridYSize, direction, cycle, false)[0]
		return directNeighboor[0]
	else:
		return _CreateCharacterGrid_GetVerticalNeighboor(gridData, x, y, gridXSize, gridYSize, direction, cycle)[0]

func _CreateCharacterGrid_GetHorizontalNeighboor(gridData, x, y, gridXSize, gridYSize, direction, cycle = true, direct = false):
	if(direction == 0):
		Castagne.Error("_CreateCharacterGrid_GetHorizontalNeighboor: 0 direction")
		return [null, 0]
	var i = x + direction
	var distance = 0
	while(i != x and (cycle or (i >= 0 and i < gridXSize))):
		if(i < 0):
			i = gridXSize - 1
		if(i >= gridXSize):
			i = 0
		distance += 1
		var g = gridData[y][i]
		if(g[0] != null):
			return [g[0], distance]
		if(!direct):
			var u = _CreateCharacterGrid_GetVerticalNeighboor(gridData, i, y, gridXSize, gridYSize, -1, false, true)
			var d = _CreateCharacterGrid_GetVerticalNeighboor(gridData, i, y, gridXSize, gridYSize, 1, false, true)
			if(u[0] != null):
				if(d[0] != null):
					return ([u[0], u[1]+distance] if u[1] <= d[1] else [d[0], d[1]+distance])
				else:
					return [u[0], u[1]+distance]
			elif(d[0] != null):
				return [d[0], d[1]+distance]
		i += direction
	return [null, 0]
func _CreateCharacterGrid_GetVerticalNeighboor(gridData, x, y, gridXSize, gridYSize, direction, cycle = true, direct = false):
	if(direction == 0):
		Castagne.Error("_CreateCharacterGrid_GetVerticalNeighboor: 0 direction")
		return [null, 0]
	
	# TODO: Check direct above, then sides. prio smallest distance, then either left or right if equal
	var j = y + direction
	var distance = 0
	while(j != y and (cycle or (j >= 0 and j < gridYSize))):
		if(j < 0):
			j = gridYSize - 1
		if(j >= gridYSize):
			j = 0
		distance += 1
		var g = gridData[j][x]
		if(g[0] != null):
			return [g[0], distance]
		if(!direct):
			var l = _CreateCharacterGrid_GetHorizontalNeighboor(gridData, x, j, gridXSize, gridYSize, -1, false, true)
			var r = _CreateCharacterGrid_GetHorizontalNeighboor(gridData, x, j, gridXSize, gridYSize, 1, false, true)
			if(l[0] != null):
				if(r[0] != null):
					return ([l[0], l[1]+distance] if l[1] <= r[1] else [r[0], r[1]+distance])
				else:
					return [l[0], l[1]+distance]
			elif(r[0] != null):
				return [r[0], r[1]+distance]
		j += direction
	
	return [null, 0]

func GetCharacterGridPosition(characterData):
	var menuData = characterData["TransformedData"]["MenuData"]["Defines"]
	return [menuData["MENU_CSSGridX"], menuData["MENU_CSSGridY"], menuData["MENU_CSSGridZ"]]

func CreateCSSGridRow():
	var nRow = HBoxContainer.new()
	nRow.set_alignment(BoxContainer.ALIGN_CENTER)
	return nRow

func CreateCharacterIcon(gridSlot):
	var n = Castagne.Loader.Load("res://castagne/helpers/menus/helpers/css/default/CMenu-CSS-Icon.tscn").instance()
	n.InitIcon(gridSlot[0], self, gridSlot[1])
	return n


# Character (Name, Filepath), TransformedData (MenuData), CSS



func CreatePlayerSlots():
	var playerSlotsRoot = get_node(MenuPlayerSlotsPath)
	var defaultCharacter = characterList[0]
	playerSlots = []
	for pid in range(2):
		var n = Castagne.Loader.Load("res://castagne/helpers/menus/helpers/css/default/CMenu-CSS-Player.tscn").instance()
		n.InitPlayerSlot(self, devices[pid], pid, defaultCharacter)
		playerSlotsRoot.add_child(n)
		playerSlots.push_back(n)

func FindLendableDevicePlayerSlot():
	for ps in playerSlots:
		# Lending can be a chain, so it will go back up the chain if needed
		if(ps.device == null or !ps.IsReady() or ps.lendingDevice):
			continue
		var lendable = true
		
		if(lendable):
			return ps
	return null


func TryAdvance():
	for ps in playerSlots:
		if(!ps.IsReady()):
			return false
	Advance()
	return true

func Advance():
	if(_menuParams.has("CallbackAdvance")):
		var selectData = []
		for ps in playerSlots:
			selectData.push_back(ps.GetAdvanceData())
		
		var cbParams = (_menuParams["CallbackAdvanceParams"] if _menuParams.has("CallbackAdvanceParams") else null)
		
		_menuParams["CallbackAdvance"].call_func({
			"SelectData": selectData,
			"CallbackParams": cbParams,
			"Devices": devices,
			"CSSParams": _menuParams,
			"ConfigData": _configData,
		})
		queue_free()

func GoBack():
	if(_menuParams.has("CallbackBack")):
		var p = (_menuParams["CallbackBackParams"] if _menuParams.has("CallbackBackParams") else null)
		_menuParams["CallbackBack"].call_func(p)
		queue_free()
