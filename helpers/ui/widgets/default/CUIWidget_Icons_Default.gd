# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Extension of the icons widget to be more usable for prototypes and simple projects through basic assets

extends "../CUIWidget_Icons.gd"

func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	var c = _DefaultWidget_GetColor(caspData)
	iconTexture = _DefaultWidget_LoadPath("widgetpoints-main-"+str(c)+".png")
	
	.WidgetInitialize(stateHandle, battleInitData, caspData)
