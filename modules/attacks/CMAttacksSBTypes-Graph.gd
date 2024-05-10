# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

var types = ["Light", "Medium", "Heavy", "Special", "EX", "Super", "Throw"]
var sb # specblock

var nbHitsToShow = 20
onready var paramsRoot = $"../../../Params"

func _ready():
	for path in ["Starter", "NextHits"]:
		var option = paramsRoot.get_node(path)
		option.clear()
		for t in types:
			option.add_item(t)
		option.select(1)
		option.connect("item_focused", self, "Redraw")
		option.connect("item_selected", self, "Redraw")
	
	sb.connect("DefineValueChanged", self, "Redraw")
	
	paramsRoot.get_node("ShowDamage").connect("pressed", self, "Redraw")
	paramsRoot.get_node("ShowHitstun").connect("pressed", self, "Redraw")

func Redraw(_dn = null, _dv = null):
	update()

func _draw():
	var size = get_size()
	var drawArea = Rect2(size*0.05, size*0.9)
	DrawGrid(drawArea)
	
	var starterType = types[paramsRoot.get_node("Starter").get_selected_id()]
	var nextType = types[paramsRoot.get_node("NextHits").get_selected_id()]
	
	if(paramsRoot.get_node("ShowHitstun").is_pressed()):
		var starterProration = sb._specblockDefines["ATTACK_"+starterType+"_ProrationHitstunStarter"]["Value"]
		var nextHitProration = sb._specblockDefines["ATTACK_"+nextType+"_ProrationHitstun"]["Value"]
		DrawProration(drawArea, Color.aqua, starterProration, nextHitProration, Vector2(12, -6))
	if(paramsRoot.get_node("ShowDamage").is_pressed()):
		var starterProration = sb._specblockDefines["ATTACK_"+starterType+"_ProrationDamageStarter"]["Value"]
		var nextHitProration = sb._specblockDefines["ATTACK_"+nextType+"_ProrationDamage"]["Value"]
		DrawProration(drawArea, Color.crimson, starterProration, nextHitProration, Vector2(6, -12))

func DrawGrid(drawArea):
	draw_rect(drawArea, Color.silver, false, 2, true)
	var ySegmentation = 6
	for i in range(1, ySegmentation):
		var y = drawArea.position.y + drawArea.size.y * i/float(ySegmentation)
		var w = (2 if i == 3 else 1)
		
		draw_line(Vector2(drawArea.position.x, y), Vector2(drawArea.end.x, y), Color.silver, w, true)
		
	for i in range(1, nbHitsToShow-1):
		var x = drawArea.position.x + drawArea.size.x * i/float(nbHitsToShow-1)
		var w = (2 if i%5 == 0 else 1)
		draw_line(Vector2(x, drawArea.position.y), Vector2(x, drawArea.end.y), Color.silver, w, true)

func DrawProration(drawArea, color, starterProration, nextProration, markOffset = Vector2(16, -16)):
	#draw_line(drawArea.position, drawArea.end, color, 3, true)
	
	var prevP = 1.0
	var p = 1.0
	for i in range(nbHitsToShow-1):
		prevP = p
		p *= (starterProration if i == 0 else nextProration) / 1000.0
		
		var xPrev = drawArea.position.x + drawArea.size.x * i/float(nbHitsToShow-1)
		var xNext = drawArea.position.x + drawArea.size.x * (i+1)/float(nbHitsToShow-1)
		
		var yPrev = drawArea.position.y + drawArea.size.y * (1.0-prevP)
		var yNext = drawArea.position.y + drawArea.size.y * (1.0-p)
		
		var posPrev = Vector2(xPrev, yPrev)
		var posNext = Vector2(xNext, yNext)
		
		draw_line(posPrev, posNext, color, 2, true)
		
		draw_line(posPrev-markOffset, posPrev+markOffset, color, 3, true)
		
		if(i == nbHitsToShow-1):
			draw_line(posNext-markOffset, posNext+markOffset, color, 3, true)

