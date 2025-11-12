# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModuleSpecblock.gd"

func SetupSpecblock(_argument):
	SetDisplayName("Battle Flow")
	SetForMainEntitySubEntity(true, false)
	
	
	AddCategory("Battle Flow")
	AddDefine("FLOW_IntroState", "Intro", "Intro State")
	AddDefine("FLOW_IntroTime", 60, "Intro Time")
	AddDefine("FLOW_NbRoundsToWin", 2, "Rounds to Win")
	AddDefine("FLOW_TimerUnits", 99, "Timer Units")
	AddDefine("FLOW_TimerFramesPerUnit", 60, "Frames per Timer Unit")
	AddDefine("FLOW_WinDelay", 90, "Win Delay")
	#AddDefine("FLOW_CanControlAfterWin", false, "Can control after win")
