extends Spatial

var engine
onready var modelHurtboxes = $Hurtboxes
onready var modelHitboxes = $Hitboxes
onready var modelColboxes = $Colboxes
var nbUsedBoxes = []
var NB_BASE_HURTBOXES = 50
var NB_BASE_HITBOXES = 50
var NB_BASE_COLBOXES = 50
var POSITION_SCALE

func _ready():
	set_translation(Vector3(0.0,0.0,-0.15))
	
	var prefabHurtbox = load(Castagne.configData["HurtboxViewer-Hurtbox"])
	for i in range(NB_BASE_HURTBOXES):
		var hb = prefabHurtbox.instance()
		hb.hide()
		modelHurtboxes.add_child(hb)
	
	var prefabHitbox = load(Castagne.configData["HurtboxViewer-Hitbox"])
	for i in range(NB_BASE_HITBOXES):
		var hb = prefabHitbox.instance()
		hb.hide()
		modelHitboxes.add_child(hb)
	
	var prefabColbox = load(Castagne.configData["HurtboxViewer-Colbox"])
	for i in range(NB_BASE_COLBOXES):
		var hb = prefabColbox.instance()
		hb.hide()
		modelColboxes.add_child(hb)
	
	modelHurtboxes.set_scale(Vector3(1.0,1.0,0.05))
	modelHitboxes.set_scale(Vector3(1.0,1.0,0.05))
	modelColboxes.set_scale(Vector3(1.0,1.0,0.05))
	modelHitboxes.set_translation(Vector3(0,0,0.05))
	modelColboxes.set_translation(Vector3(0,0,0.02))

func UpdateGraphics(state, data):
	engine = data["Engine"]
	POSITION_SCALE = Castagne.configData["PositionScale"]
	
	for node in modelHurtboxes.get_children():
		node.hide()
	for node in modelHitboxes.get_children():
		node.hide()
	for node in modelColboxes.get_children():
		node.hide()
	
	var activeEIDs = state["ActiveEntities"]
	nbUsedBoxes = [0,0,0]
	
	for eid in activeEIDs:
		var eState = state[eid]
		SetAllBoxes(modelHurtboxes, eState["Hurtboxes"], eState, 0)
		SetAllBoxes(modelHitboxes, eState["Hitboxes"], eState, 1)
		SetAllBoxes(modelColboxes, [eState["Colbox"]], eState, 2)

func SetAllBoxes(nodeRoot, boxes, fighterState, boxType):
	var boxID = nbUsedBoxes[boxType]
	var nbModels = nodeRoot.get_child_count()
	
	for box in boxes:
		if(boxID >= nbModels):
			Castagne.Error("Hurtbox Viewer : Not enough boxes model ("+str(boxID+1)+") in " + nodeRoot.get_name())
			continue
		
		var node = nodeRoot.get_child(boxID)
		SetBox(node, box, fighterState)
		node.show()
		
		boxID += 1
	
	nbUsedBoxes[boxType] = boxID

func SetBox(node, box, fighterState):
	var boxPos = GetBoxPosition(fighterState, box)
	
	var boxCenterHor = (boxPos["Left"]+boxPos["Right"])/2.0
	var boxCenterVer = (boxPos["Down"]+boxPos["Up"])/2.0
	
	var boxSizeHor = boxPos["Right"] - boxPos["Left"]
	var boxSizeVer = boxPos["Up"] - boxPos["Down"]
	
	node.set_translation(Vector3(boxCenterHor, boxCenterVer, 0) * POSITION_SCALE)
	node.set_scale(Vector3(boxSizeHor, boxSizeVer, 1) * POSITION_SCALE * 0.5)
	
func GetBoxPosition(fighterState, box):
	var boxLeft = fighterState["PositionX"]
	var boxRight = fighterState["PositionX"]
	
	if(fighterState["Facing"] > 0):
		boxLeft += box["Left"]
		boxRight += box["Right"]
	else:
		boxLeft -= box["Right"]
		boxRight -= box["Left"]
	
	var boxDown = fighterState["PositionY"] + box["Down"]
	var boxUp = fighterState["PositionY"] + box["Up"]
	
	return {"Left":boxLeft, "Right":boxRight,"Down":boxDown,"Up":boxUp}
