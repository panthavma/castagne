# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "CMGraphics3D.gd"

func ModuleSetup():
	RegisterModule("Graphics 2.5D", Castagne.MODULE_SLOTS_BASE.GRAPHICS)
	.ModuleSetup()
