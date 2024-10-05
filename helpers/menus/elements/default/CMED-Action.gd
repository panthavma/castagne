# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CME-Action.gd"


func Setup():
	.Setup()
	get_node(".").set_text(optionData["DisplayName"])

func OnSelect():
	get_node(".").set_text(">> "+optionData["DisplayName"]+" <<")

func OnUnselect():
	get_node(".").set_text(optionData["DisplayName"])
