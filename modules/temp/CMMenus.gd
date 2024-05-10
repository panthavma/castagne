# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"

func ModuleSetup():
	RegisterModule("Menus", null)
	#RegisterBaseCaspFile("res://castagne/modules/coreset/Base-Core.casp", -9000)
	
	RegisterCategory("Main Menu")
	RegisterConfig("MenuPath-Main", "", {"Flags":["Advanced"]})
	
	RegisterCategory("Character Select Screen")
	RegisterConfig("MenuPath-CSS", "", {"Flags":["Advanced"]})
