extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var topRow
var botRow

func SetupTool():
	topRow = $Table/TopRow
	botRow = $Table/BotRow
	toolName = "Frame Data Display"
	toolDescription = "Made by crosseyed. Tool that displays the frame data of the most recently performed attack.\n To display Startup, Active, and Recovery frames, use AttackParam(Startup, X), AttackParam(ACtive, X), and AttackParam(Recovery, X).\n To include knockdown time into hit advantage use AttackParam(KDTime, X).\n Currently does not support multihits."

func OnEngineRestarted(engine):
	var editorModule = engine.configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.EDITOR)
	editorModule.connect("EngineTick_PhysicsStartEntity", self, "EngineTick_PhysicsStartEntity")
	
func EngineTick_PhysicsStartEntity(stateHandle):
	if stateHandle.GetPlayer() == 0:
		CollectFrameData(stateHandle)

func CollectFrameData(stateHandle):
	var attackData = stateHandle.EntityGet("_AttackData")
	var attackName = stateHandle.EntityGet("_State")
	var damage = attackData["Damage"]
	var hitstun = attackData["Hitstun"]
	var blockstun = attackData["Blockstun"]
	var flags = attackData["Flags"].duplicate()
	var initialProration = attackData["StarterProrationDamage"]
	var proration = attackData["ProrationDamage"]
	
	var startup = 0
	if attackData.has("Startup"):
		startup = attackData["Startup"]
	var active = 0
	if attackData.has("Active"):
		active = attackData["Active"]
	var recovery = 0
	if attackData.has("Recovery"):
		recovery = attackData["Recovery"]
	
	var noteKD = ""
	var knockdownTime = 0
	if attackData.has("KDTime"):
		knockdownTime = attackData["KDTime"]
		noteKD = " (KD)"
	
	var duration = startup + active + recovery - 1
	var hitAdv = hitstun - (active + recovery) + knockdownTime
	var blockAdv = blockstun - (active + recovery)
	
	var guard = "Mid"
	if flags.has("Mid"):
		flags.erase("Mid")
	if flags.has("Overhead"):
		guard = "High"
		flags.erase("Overhead")
	if flags.has("Low"):
		guard = "Low"
		flags.erase("Low")
	if flags.has("Throw"):
		guard = "Throw"
		flags.erase("Throw")
	
	var propertiesList = []
	for f in flags:
		propertiesList += [f]
	if propertiesList.empty():
		propertiesList += ["N/A"]
	var properties = PoolStringArray(propertiesList).join(", ")
	
	if stateHandle.EntityHasFlag("Attacking"):
		topRow.get_node("Name/Value").set_text(attackName)
		topRow.get_node("Damage/Value").set_text(str(damage))
		topRow.get_node("Startup/Value").set_text(str(startup))
		topRow.get_node("Active/Value").set_text(str(active))
		topRow.get_node("Recovery/Value").set_text(str(recovery))
		
		botRow.get_node("Proration/Value").set_text(str(initialProration)+", "+str(proration))
		botRow.get_node("Guard/Value").set_text(guard)
		botRow.get_node("Properties/Value").set_text(str(properties))
		botRow.get_node("Advantage/Value").set_text(("+" if sign(hitAdv)==1 else "")+str(hitAdv)+noteKD+" / "+("+" if sign(blockAdv)==1 else "")+str(blockAdv))
	
