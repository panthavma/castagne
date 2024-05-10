# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"
# Based on the genre selector, used in conjuction with the CharacterSet menu

var presets = []

func _ready():
	AddPreset("Empty", null, "res://castagne/assets/icons/editor/genres/Custom-icon.png", null,
	"""Basic empty file, for when you already have your model and animations and want to set them right away.
If you are trying the engine for the first time, it will be probably more fun for you to use another preset to get your bearings.""")
	AddPreset("Baston Labatte", "res://castagne/examples/fighters/baston/Baston-Model.casp",
	"res://castagne/assets/fighters/baston/BastonIcon.png", "res://castagne/assets/fighters/baston/BastonTemplateScreen.png",
	"""Simple human character with a bat. Has attack animations that use the bat, and others that don't.
If you are trying the engine for the first time, this is probably the simplest option at first!""")
	
	var genreList = $GenreList
	genreList.clear()
	for g in presets:
		genreList.add_item(g["Name"], g["ListIcon"])
	genreList.select(1)
	OnSelect(1)


func AddPreset(name, skeletonPath, listIcon, exampleImage, description):
	var g = {
		"Name":name,
		"SkeletonPath":skeletonPath,
		"Description":description,
		"ListIcon":null,
	}
	
	if(exampleImage == null):
		g["Image"] = Castagne.Loader.Load("res://castagne/assets/icons/CastagneLogo.png")
	else:
		g["Image"] = Castagne.Loader.Load(exampleImage)
	
	if(listIcon != null):
		g["ListIcon"] = Castagne.Loader.Load(listIcon)
	
	presets += [g]


func OnSelect(idx):
	var g = presets[idx]
	
	$DescPanel/Description.set_text(g["Description"])
	$DescPanel/Picture.set_texture(g["Image"])


func _on_OK_pressed():
	var index = $GenreList.get_selected_items()[0]
	var g = presets[index]
	
	CreateFile(dataPassthrough, g)
	
	Exit(dataPassthrough)


func _on_Cancel_pressed():
	Exit(null)


func _on_GenreList_item_selected(index):
	OnSelect(index)

func CreateFile(path, preset):
	var f = File.new()
	f.open(path, File.WRITE)
	var t = ":Character:\n"
	t += "## This is the Character block, where you add some basic information about your character that can be accessed from outside, like their name or place on the select screen."
	t += "\n## You can also add another file to this with the Skeleton: property."
	if(preset["SkeletonPath"] != null):
		t +="\nSkeleton: " + preset["SkeletonPath"]
	t += "\n:Variables:\n"
	t += "## This is the Variables block, where you can store custom variables or overwrite defined ones."
	t += "You can see all available default variables by activating 'Show All Variables' in the navigation panel.\n"
	f.store_string(t)
	f.close()
