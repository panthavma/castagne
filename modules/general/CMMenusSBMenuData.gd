# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Menu")
	SetForMainEntitySubEntity(true, false)
	
	AddDefine("MENU_Name", "Missing Name", "Name")
	AddDefine("MENU_Hidden", false, "Hide")
	
	AddCategory("Character Select Screen")
	AddDefine("MENU_CSSIconPath", "res://castagne/assets/icons/DefaultIcon.png", "Icon Path")
	AddDefine("MENU_CSSGridX", 0, "Grid X")
	AddDefine("MENU_CSSGridY", 0, "Grid Y")
	AddDefine("MENU_CSSGridZ", 0, "Grid Z") # Z is more freeform, 0 is only special value
