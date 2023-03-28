extends "CastagneEditorSubmenu.gd"

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
		"res://castagne/assets/icons/editor/genres/2DFighter-icon.png", "res://castagne/assets/icons/editor/genres/2DFighter-image.png",
		STATUSLEVEL_WARNING, "Genre support still in early stages!",
		fighter2DCommon+"""This setting is for games that use 2D backgrounds and sprites, an older, often simpler look.

Castagne Examples: Molten Winds (Panthavma)
Game Examples: Street Fighter II (Capcom), King of Fighters XIII (SNK)""")

	AddGenre("2.5D Fighter", "res://castagne/helpers/genreskeletons/CC25DFighter.json",
		"res://castagne/assets/icons/editor/genres/25DFighter-icon.png", "res://castagne/assets/icons/editor/genres/25DFighter-image.png",
		STATUSLEVEL_WARNING, "Genre support still in early stages!",
		fighter2DCommon+"""This setting is for games that use 3D background with 2D or 3D characters, usually a more modern look.

Castagne Examples: Kronian Titans (Panthavma)
Game Examples: BlazBlue (Arc System Works), Street Fighter V (Capcom), Mortal Combat 11 (NetherRealm), Under-Night In-Birth (French Bread)""")

	AddGenreTemp("3D Fighter", "",
		"res://castagne/assets/icons/editor/genres/3DFighter-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Very basic support, no special tools.",
		"""Games where two characters fight in a 3D space, being able to move sideways too.
These games tend to be focused a lot on close range grounded move interactions.

Castagne Examples: None yet
Game Examples: Tekken 7 (Bandai Namco), Soul Calibur 6 (Bandai Namco)""")
	
	AddGenreTemp("Platform Fighter", "",
		"res://castagne/assets/icons/editor/genres/PlatFighter-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Not implemented",
		"""Games where characters fight on a 2D plane, and win by knocking an opponent out of the arena.
These tend to have rich movement, and dynamic combos and phases.

Castagne Examples: None yet
Game Examples: Super Smash Brothers (Nintendo), Rivals of Aether (Dan Fornace), Slap City (Ludosity)""")

	AddGenreTemp("Arena Fighter", "",
		"res://castagne/assets/icons/editor/genres/ArenaFighter-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Not implemented",
		"""Games where characters fight in a 3D arena, from a behind the shoulder perspective.
These tend to have a lot of characters and a more casual focus.

Castagne Examples: None yet
Game Examples: Gundam Extreme VS (Bandai Namco), KILL la KILL - IF (A+ Games)""")

	AddGenreTemp("Beat them All", "",
		"res://castagne/assets/icons/editor/genres/BeatThemAll-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Not implemented",
		"""Games where players fight a lot of computer controlled opponents in a 2D top-down view.
These tend to be cooperative and simple fun.

Castagne Examples: None yet
Game Examples: River City Girls (WayForward), Streets of Rage (SEGA), Castle Crashers (The Behemoth)""")

	AddGenreTemp("Character Action", "",
		"res://castagne/assets/icons/editor/genres/CharacterAction-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Not implemented",
		"""Games where players fight a lot of computer controlled opponents in a 3D arena.
These tend to be focused on complex movesets and spectacle.

Castagne Examples: None yet
Game Examples: Metal Gear Rising Revengeance (PlatinumGames), God Hand (Clover Studios), Devil May Cry (Capcom)""")

	AddGenreTemp("2D Platformer", "",
		"res://castagne/assets/icons/editor/genres/2DPlatformer-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Not implemented",
		"""Games with a focus on moving through an area in a 2D sideview.
These tend to have a focus on precise movement and fast gameplay.

Castagne Examples: None yet
Game Examples: Hollow Knight (Team Cherry), Celeste (Maddy Makes Games)""")

	AddGenreTemp("3D Platformer", "",
		"res://castagne/assets/icons/editor/genres/3DPlatformer-icon.png", null,
		STATUSLEVEL_UNSUPPORTED, "Not implemented",
		"""Games with a focus on moving through a 3D area.
These tend to have a focus on exploration.

Castagne Examples: None yet
Game Examples: Super Mario Sunshine (Nintendo), A Hat in Time (Gears for Breakfast)""")
	
	AddGenre("Custom", "",
		"res://castagne/assets/icons/editor/genres/Custom-icon.png", null,
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

func AddGenreTemp(_name, _skeletonPath, _listIcon, _exampleImage, _statusLevel, _status, _description):
	pass
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
