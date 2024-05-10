# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends HBoxContainer





func _on_Generic_pressed():
	call_deferred("GenericPerfTest")

func _on_Rollback_pressed():
	pass # Replace with function body.

func GenericPerfTest():
	Castagne.battleInitData["p1"] = "res://castagne/devtools/PerfTestFighter.casp"
	Castagne.battleInitData["p2"] = "res://castagne/devtools/PerfTestFighter.casp"
	Castagne.battleInitData["p1-palette"] = 0
	Castagne.battleInitData["p2-palette"] = 1
	var enginePrefab = Castagne.Loader.Load(Castagne.configData["Engine"])
	
	var testNames = ["PerfTestEmpty", "PerfTestCompute", "PerfTestCalls"]
	var initTimes = {}
	var computeTimes = {}
	for t in testNames:
		var msInitStart = OS.get_system_time_msecs()
		
		var engine = enginePrefab.instance()
		engine.renderGraphics = false
		add_child(engine)
		
		engine.LocalStepNoInput()
		engine.LocalStepNoInput()
		engine.LocalStepNoInput()
		
		var msInitStop = OS.get_system_time_msecs()
		
		engine._gameState[0]["State"] = t
		engine._gameState[1]["State"] = t
		
		
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		var msStart = OS.get_system_time_msecs()
		
		for i in range(1000):
			engine.LocalStepNoInput()
		
		var msStop = OS.get_system_time_msecs()
		
		engine.queue_free()
		initTimes[t] = msInitStop - msInitStart
		computeTimes[t] = msStop - msStart
		yield(get_tree(), "idle_frame")
	
	var text = ""
	for t in testNames:
		text += "/ " + t + ": "+str(computeTimes[t])+" (I:"+str(initTimes[t])+") /"
	$Result.set_text(text)
