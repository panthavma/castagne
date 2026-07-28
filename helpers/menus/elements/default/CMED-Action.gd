# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CME-Action.gd"


func Setup():
	.Setup()
	SetAllText(optionData["DisplayName"])

func OnSelect():
	SetAllText(">> "+optionData["DisplayName"]+" <<")

func OnUnselect():
	SetAllText(optionData["DisplayName"])


func SetAllText(t, n = null):
	if n == null:
		n = get_node(".")
	if n.has_method("set_text"):
		n.set_text(t)
	for c in n.get_children():
		SetAllText(t, c)
