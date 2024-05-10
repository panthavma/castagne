# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"

var genres = []

const STATUSLEVEL_OK = 0
const STATUSLEVEL_WARNING = 1
const STATUSLEVEL_UNSUPPORTED = 2
const STATUSLEVEL_FULLSUPPORT = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	var fighter2DCommon = """Games where two characters fight each other from a sideways view.
These tend to be focused a lot on space control on ground and air. Two main types exist:
	- Traditional: More focused on the ground game, with limited options and blocking in the air.
	- Airdasher: Focused on fast movement, often paired with strong unique tools.

"""
	
	
	AddGenre("2D Fighter", "res://castagne/helpers/genreskeletons/CC2DFighter.json",
		"res://castagne/assets/editor/genres/2DFighter-icon.png", "res://castagne/assets/editor/genres/2DFighter-image.png",
		STATUSLEVEL_WARNING, "Genre support still in early stages!",
		fighter2DCommon+"""This setting is for games that use 2D backgrounds and sprites, an older, often simpler look.

Castagne Examples: Molten Winds (Panthavma)
Game Examples: Street Fighter II (Capcom), King of Fighters XIII (SNK)""")

	AddGenre("2.5D Fighter", "res://castagne/helpers/genreskeletons/CC25DFighter.json",
		"res://castagne/assets/editor/genres/25DFighter-icon.png", "res://castagne/assets/editor/genres/25DFighter-image.png",
		STATUSLEVEL_WARNING, "Genre support still in early stages!",
		fighter2DCommon+"""This setting is for games that use 3D background with 2D or 3D characters, usually a more modern look.

Castagne Examples: Kronian Titans (Panthavma)
Game Examples: BlazBlue (Arc System Works), Street Fighter V (Capcom), Mortal Combat 11 (NetherRealm), Under-Night In-Birth (French Bread)""")


	
	AddGenre("Custom", "",
		"res://castagne/assets/editor/genres/Custom-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Advanced users only!",
		"""No preset, using Castagne as a blank slate.

This setting is meant for advanced users, for when you need some really specific gameplay. You will need to specify modules manually.

Castagne Examples: None yet
Game Examples: By definition, this is too wide to list.""")
	
	
	var genreList = $GenreList
	genreList.clear()
	for g in genres:
		genreList.add_item(g["Name"], g["ListIcon"])
	genreList.select(1)
	OnSelect(1)

func AddGenre(name, skeletonPath, listIcon, exampleImage, statusLevel, status, description):
	var g = {
		"Name":name,
		"SkeletonPath":skeletonPath,
		"StatusLevel":statusLevel,
		"Status":status,
		"Description":description,
		"ListIcon":null,
	}
	
	if(exampleImage == null):
		g["Image"] = Castagne.Loader.Load("res://castagne/assets/icons/CastagneLogo.png")
	else:
		g["Image"] = Castagne.Loader.Load(exampleImage)
	
	if(listIcon != null):
		g["ListIcon"] = Castagne.Loader.Load(listIcon)
	
	genres += [g]

func OnSelect(idx):
	var g = genres[idx]
	
	var statusLevelRoot = $DescPanel/Status
	for i in range(statusLevelRoot.get_child_count() - 1):
		statusLevelRoot.get_child(i).set_visible(i == g["StatusLevel"])
	
	$DescPanel/Description.set_text(g["Description"])
	$DescPanel/Status/Label.set_text(g["Status"])
	$DescPanel/Picture.set_texture(g["Image"])


func _on_OK_pressed():
	var index = $GenreList.get_selected_items()[0]
	var g = genres[index]
	editor.configData.Set("ConfigSkeleton", g["SkeletonPath"])
	
	Exit(index)


func _on_Cancel_pressed():
	Exit(null)


func _on_GenreList_item_selected(index):
	OnSelect(index)
