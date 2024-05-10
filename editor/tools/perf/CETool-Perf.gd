extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var perfLabel
var perfLabel2
var perfBar
var perfGFXLabel
var perfPhases
var perfPhysics

var frameTimerStart = -1
var frameTimerTotal = -1
var phaseTimers = {}

func SetupTool():
	toolName = "Performance"
	toolDescription = "In progress."
	perfLabel = $PerfSmall/FrameTime/FrameTime
	perfLabel2 = $PerfSmall/FrameTime/FrameTime2
	perfBar = $PerfSmall/FrameTime/BudgetBar
	perfGFXLabel = $PerfSmall/FrameTime/GraphicsTime
	perfPhases = $PerfSmall/Phases
	perfPhysics = $PerfSmall/Physics
	ResetTimer()

func OnEngineRestarting(engine, _battleInitData):
	ResetTimer()

func OnEngineRestarted(engine):
	var editorModule = engine.configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.EDITOR)
	editorModule.connect("EngineTick_FramePreStart", self, "EngineTick_FramePreStart")
	editorModule.connect("EngineTick_FrameEnd", self, "EngineTick_FrameEnd")
	
	for p in ["Init", "Input", "Action", "Physics", "Reaction"]:
		editorModule.connect("EngineTick_"+p+"Start", self, "PhaseTimerStart", [p])
		editorModule.connect("EngineTick_"+p+"StartEntity", self, "PhaseTimerStartEntity", [p])
		editorModule.connect("EngineTick_"+p+"EndEntity", self, "PhaseTimerEndEntity", [p])
		editorModule.connect("EngineTick_"+p+"End", self, "PhaseTimerEnd", [p])
	
	ResetTimer()

func OnEngineInitError(_engine):
	ResetTimer()

func ResetTimer():
	frameTimerStart=-1
	frameTimerTotal=-1
	phaseTimers = {}
	perfLabel.set_text("Time unavailable")
	perfGFXLabel.set_text("Update Graphics: Time unavailable")
	perfBar.set_value(0)
	for r in perfPhases.get_children():
		UpdatePhaseTimer(r)
	UpdatePhysicsTimer()

func PhaseTimerStart(_stateHandle, phase):
	phaseTimers[phase] = {
		"Start":OS.get_ticks_usec(),
		"CodeStart":-1, "CodeEnd":-1, "End":-1
	}
func PhaseTimerStartEntity(_stateHandle, phase):
	phaseTimers[phase]["CodeStart"] = OS.get_ticks_usec()
func PhaseTimerEndEntity(_stateHandle, phase):
	if(phaseTimers[phase]["CodeEnd"] == -1):
		phaseTimers[phase]["CodeEnd"] = OS.get_ticks_usec()
func PhaseTimerEnd(_stateHandle, phase):
	phaseTimers[phase]["End"] = OS.get_ticks_usec()

func UpdatePhaseTimer(phaseRoot):
	var phaseName = phaseRoot.get_name()
	if(!phaseTimers.has(phaseName)):
		phaseRoot.get_node("TotalTime").set_text("/")
		phaseRoot.get_node("StartTime").set_text("/")
		phaseRoot.get_node("CodeTime").set_text("/")
		phaseRoot.get_node("EndTime").set_text("/")
		return
	var phaseData = phaseTimers[phaseName]
	
	phaseRoot.get_node("TotalTime").set_text(str((phaseData["End"] - phaseData["Start"])/1000.0) + "ms")
	phaseRoot.get_node("StartTime").set_text(str((phaseData["CodeStart"] - phaseData["Start"])/1000.0) + "ms")
	phaseRoot.get_node("CodeTime").set_text(str((phaseData["CodeEnd"] - phaseData["CodeStart"])/1000.0) + "ms")
	phaseRoot.get_node("EndTime").set_text(str((phaseData["End"] - phaseData["CodeEnd"])/1000.0) + "ms")

func UpdatePhysicsTimer(pm = null):
	if(pm == null):
		for n in ["Total", "Setup", "EnvTotal", "EnvSetup", "EnvMain", "AtkTotal", "AtkSetup", "AtkMain"]:
			perfPhysics.get_node(n).set_text("/")
		return
	
	perfPhysics.get_node("Total").set_text("Total: "+str((pm._castProfiling_PhysicsEnd - pm._castProfiling_PhysicsStart)/1000.0) + "ms")
	perfPhysics.get_node("Setup").set_text("Physics Setup: "+str((pm._castProfiling_PhysicsSetupDone - pm._castProfiling_PhysicsStart)/1000.0) + "ms")
	perfPhysics.get_node("EnvTotal").set_text("Env Total: "+str((pm._castProfiling_EnvColEnd - pm._castProfiling_PhysicsSetupDone)/1000.0) + "ms")
	perfPhysics.get_node("EnvSetup").set_text("Env Setup: "+str((pm._castProfiling_Env_SetupDone - pm._castProfiling_PhysicsStart)/1000.0) + "ms")
	perfPhysics.get_node("EnvMain").set_text("Env Resolve: "+str((pm._castProfiling_EnvColEnd - pm._castProfiling_Env_SetupDone)/1000.0) + "ms")
	perfPhysics.get_node("AtkTotal").set_text("Attack Total: "+str((pm._castProfiling_PhysicsEnd - pm._castProfiling_EnvColEnd)/1000.0) + "ms")
	perfPhysics.get_node("AtkSetup").set_text("Attack Setup: "+str((pm._castProfiling_Atk_SetupDone - pm._castProfiling_EnvColEnd)/1000.0) + "ms")
	perfPhysics.get_node("AtkMain").set_text("Attack Resolve: "+str((pm._castProfiling_PhysicsEnd - pm._castProfiling_Atk_SetupDone)/1000.0) + "ms")

func EngineTick_FramePreStart(_stateHandle):
	frameTimerStart = OS.get_ticks_usec()

var trailingMeanValues = []
var TRAILING_MEAN_FRAMES = 120
func EngineTick_FrameEnd(stateHandle):
	var engine = stateHandle.Engine()
	#frameTimerTotal = OS.get_ticks_usec() - frameTimerStart
	frameTimerTotal = OS.get_ticks_usec() - engine._castProfilingTickStart
	var gfxTime = engine._castProfilingGraphicsEnd - engine._castProfilingGraphicsStart
	
	trailingMeanValues.push_back(frameTimerTotal)
	if(trailingMeanValues.size() > TRAILING_MEAN_FRAMES):
		trailingMeanValues.pop_front()
	
	var trailingMean = 0
	var trailingMin = frameTimerTotal
	var trailingMax = frameTimerTotal
	for ftt in trailingMeanValues:
		trailingMean += ftt
		if(ftt < trailingMin):
			trailingMin = ftt
		if(ftt > trailingMax):
			trailingMax = ftt
	trailingMean /= trailingMeanValues.size()
	
	perfLabel.set_text(str(frameTimerTotal/1000.0)+"ms\nMean: "+str(trailingMean/1000.0)+"ms")
	perfLabel2.set_text("Min: "+str(trailingMin/1000.0)+"ms\nMax: "+str(trailingMax/1000.0)+"ms")
	perfGFXLabel.set_text("Update Graphics: " + str(gfxTime / 1000.0) +"ms")
	perfBar.set_value(frameTimerTotal)
	
	UpdatePhysicsTimer(stateHandle.ConfigData().GetModuleSlot(Castagne.MODULE_SLOTS_BASE.PHYSICS))
	for r in perfPhases.get_children():
		UpdatePhaseTimer(r)
