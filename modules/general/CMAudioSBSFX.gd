# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Sound Effects")
	SetForMainEntitySubEntity(true, true)
	
	AddStructure("SFX", "AUDIO_SFX_", "Sound Effects")
	AddStructureDefine("Filepath", "res://")
	AddStructureDefine("Volume", 1000)
	
