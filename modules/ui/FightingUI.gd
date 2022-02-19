extends "../CastagneModule.gd"

# Temporary module until menus get refactored

var prefabUI = preload("res://castagne/menus/battleui/DefaultUI.tscn")
var ui
var isTrainingMode = false
func ModuleSetup():
	
	RegisterModule("Fighting UI (temporary module)")
	
func BattleInit(_state, _data, battleInitData):
	ui = prefabUI.instance()
	engine.add_child(ui)
	ui.InitTool(engine, battleInitData)

func UpdateGraphics(state, _data):
	ui.UpdateGraphics(state, engine)
