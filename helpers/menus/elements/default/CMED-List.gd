# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CME-List.gd"


func Setup():
	.Setup()
	get_node("Text/Name").set_text(optionData["DisplayName"])

func OnSelect():
	get_node("Text/Name").set_text(">> "+optionData["DisplayName"])

func OnUnselect():
	get_node("Text/Name").set_text(optionData["DisplayName"])

func UpdateOptionDisplay():
	get_node("Text/Option").set_text("< " + listOptions[selectedListOption] + " >")
