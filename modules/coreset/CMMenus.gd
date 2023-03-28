
extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Menus", null)
	#RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Core.casp", -9000)
	
	RegisterCategory("Main Menu")
	RegisterConfig("MenuPath-Main", "", {"Flags":["Advanced"]})
	
	RegisterCategory("Character Select Screen")
	RegisterConfig("MenuPath-CSS", "", {"Flags":["Advanced"]})
