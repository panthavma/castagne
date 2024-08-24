# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Extension of the bar widget to be more usable for prototypes and simple projects through basic assets

extends "../CUIWidget_Bar.gd"


func WidgetInitialize(stateHandle, battleInitData = null, caspData = null):
	.WidgetInitialize(stateHandle, battleInitData, caspData)
	
	var c = _DefaultWidget_GetColor(caspData)
	rootMain.set_progress_texture(_DefaultWidget_LoadPath("widgetbar-progress-"+str(c)+".png"))
	if(rootSub != null):
		rootSub.set_progress_texture(_DefaultWidget_LoadPath("widgetbar-progress-"+str(c)+"-second.png"))
