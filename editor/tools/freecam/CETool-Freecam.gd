extends "res://castagne/editor/tools/CastagneEditorTool.gd"

var overrideButton
var orbitButton
var speedSlider

var camRef
var camGT

var savedGT = null

func SetupTool():
	toolName = "Freecam"
	toolDescription = "Move the camera around the scene freely."
	
	overrideButton = $FreecamSmall/Override
	speedSlider = $FreecamSmall/Speed
	orbitButton = $FreecamSmall/Params/Orbit
	orbitButton.hide() # outta sight outta mind, fix it later
	
	$FreecamSmall/Params/Load.connect("pressed", self, "LoadGT")
	$FreecamSmall/Params/Save.connect("pressed", self, "SaveGT")
	
	for b in $FreecamSmall/Controls.get_children():
		var bn = b.get_name()
		var isRota = false
		if(bn.begins_with("Move")):
			isRota = false
		elif(bn.begins_with("Rota")):
			isRota = true
		else:
			continue
		
		var axis = {
			"X+":Vector3.RIGHT,
			"Y+":Vector3.UP,
			"Z+":Vector3.BACK,
			"X-":Vector3.LEFT,
			"Y-":Vector3.DOWN,
			"Z-":Vector3.FORWARD
			}
		
		for d in axis:
			if(bn.ends_with(d)):
				b.connect("pressed", self, "CamButtonPressed", [isRota, axis[d]])
				break

func OnEngineRestarted(engine):
	var editorModule = engine.configData.GetModuleSlot(Castagne.MODULE_SLOTS_BASE.EDITOR)
	editorModule.connect("EngineTick_UpdateGraphics", self, "EngineTick_UpdateGraphics")
	camRef = null
	#camGT = null

func EngineTick_UpdateGraphics(stateHandle):
	if(overrideButton.is_pressed()):
		if(camRef == null):
			camRef = stateHandle.IDGlobalGet("Camera")
		if(camRef == null):
			return
		
		if(camGT == null):
			camGT = camRef.get_global_transform()
		
		camRef.call_deferred("set_global_transform",camGT)
	else:
		camGT = null

func _process(delta):
	if(overrideButton.is_pressed() and camRef != null and camGT != null):
		camRef.call_deferred("set_global_transform",camGT)

func GetSpeed(isRotation):
	var speedVal = float(speedSlider.get_value())
	var baseMove = 0.1
	var baseRotation = deg2rad(5.0)
	var speedMult = speedVal / 100.0
	if(isRotation):
		return speedMult * baseRotation
	else:
		return speedMult * baseMove

func CamButtonPressed(isRotation, axis):
	if(!overrideButton.is_pressed() or camGT == null):
		return
	if(isRotation):
		var origin = camGT.origin
		#var axisInLocal = camGT.translated(-origin).xform_inv(axis).normalized()
		# Am I stupid
		var tGT = camGT
		var axisInLocal = axis.x * tGT.basis.x + axis.y * tGT.basis.y + axis.z * tGT.basis.z
		if(orbitButton.is_pressed()):
			camGT = camGT.rotated(axisInLocal, GetSpeed(true))
		else:
			camGT = camGT.translated(-origin).rotated(axisInLocal, GetSpeed(true)).translated(origin)
	else:
		camGT = camGT.translated(axis * GetSpeed(false))

func LoadGT():
	if(savedGT != null):
		camGT = savedGT
		overrideButton.set_pressed_no_signal(true)

func SaveGT():
	if(camGT != null):
		savedGT = camGT
