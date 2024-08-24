# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Extension of the icon switch widget to be more usable for prototypes and simple projects through basic assets

extends "../CUIWidget_IconSwitch.gd"

func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	.WidgetInitialize(stateHandle, battleInitData, caspData)
	
	if(get_child_count() == 0):
		var c = _DefaultWidget_GetColor(caspData)
		AddIcon(_DefaultWidget_LoadPath("widgetpoints-back-gray.png"))
		AddIcon(_DefaultWidget_LoadPath("widgetpoints-main-"+str(c)+".png"))
		AddIcon(_DefaultWidget_LoadPath("widgetpoints-second-"+str(c)+".png"))
