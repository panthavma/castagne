# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneMenuElement.gd"


func Setup():
	if(!optionData.has("Action") or !optionData.has("ActionParams")):
		Castagne.Error("CME_Action: Invalid data and callback")
		return
	var a = FindMenuCallback(optionData["Action"])
	if(a != null):
		SetMenuAction("Confirm", a, optionData["ActionParams"])
