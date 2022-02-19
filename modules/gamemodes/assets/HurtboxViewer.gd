extends Spatial

var engine
onready var modelHurtboxes1 = $Hurtboxes1
onready var modelHurtboxes2 = $Hurtboxes2
onready var modelHitboxes1 = $Hitboxes1
onready var modelHitboxes2 = $Hitboxes2
onready var modelColbox1 = $Colbox1
onready var modelColbox2 = $Colbox2

func _ready():
	set_translation(Vector3(0.0,0.0,-0.15))
	
	modelHurtboxes1.set_scale(Vector3(1.0,1.0,0.05))
	modelHitboxes1.set_scale(Vector3(1.0,1.0,0.05))
	modelColbox1.set_scale(Vector3(1.0,1.0,0.05))
	modelHitboxes1.set_translation(Vector3(0,0,0.05))
	modelColbox1.set_translation(Vector3(0,0,0.02))
	
	modelHurtboxes2.set_scale(Vector3(1.0,1.0,0.05))
	modelHitboxes2.set_scale(Vector3(1.0,1.0,0.05))
	modelColbox2.set_scale(Vector3(1.0,1.0,0.05))
	modelHitboxes2.set_translation(Vector3(0,0,0.05))
	modelColbox2.set_translation(Vector3(0,0,0.02))

func UpdateGraphics(state, data):
	engine = data["Engine"]
	var fighterState1 = state[state["Players"][0]["MainEntity"]]
	var fighterState2 = state[state["Players"][1]["MainEntity"]]
	
	SetAllBoxes(modelHurtboxes1, fighterState1["Hurtboxes"], fighterState1)
	SetAllBoxes(modelHitboxes1, fighterState1["Hitboxes"], fighterState1)
	SetAllBoxes(modelHurtboxes2, fighterState2["Hurtboxes"], fighterState2)
	SetAllBoxes(modelHitboxes2, fighterState2["Hitboxes"], fighterState2)
	SetAllBoxes(modelColbox1, [fighterState1["Colbox"]], fighterState1)
	SetAllBoxes(modelColbox2, [fighterState2["Colbox"]], fighterState2)

func SetAllBoxes(nodeRoot, boxes, fighterState):
	var boxID = 0
	var nbModels = nodeRoot.get_child_count()
	
	for node in nodeRoot.get_children():
		node.hide()
	
	for box in boxes:
		if(boxID >= nbModels):
			Castagne.Error("Hurtbox Viewer : Not enough boxes model ("+str(boxID+1)+") in " + nodeRoot.get_name())
			continue
		
		var node = nodeRoot.get_child(boxID)
		SetBox(node, box, fighterState)
		node.show()
		
		boxID += 1

func SetBox(node, box, fighterState):
	var boxPos = GetBoxPosition(fighterState, box)
	
	var boxCenterHor = (boxPos["Left"]+boxPos["Right"])/2.0
	var boxCenterVer = (boxPos["Down"]+boxPos["Up"])/2.0
	
	var boxSizeHor = boxPos["Right"] - boxPos["Left"]
	var boxSizeVer = boxPos["Up"] - boxPos["Down"]
	
	node.set_translation(Vector3(boxCenterHor, boxCenterVer, 0) * engine.POSITION_SCALE)
	node.set_scale(Vector3(boxSizeHor, boxSizeVer, 1) * engine.POSITION_SCALE * 0.5)
	
func GetBoxPosition(fighterState, box):
	var boxLeft = fighterState["PositionHor"]
	var boxRight = fighterState["PositionHor"]
	
	if(fighterState["Facing"] > 0):
		boxLeft += box["Left"]
		boxRight += box["Right"]
	else:
		boxLeft -= box["Right"]
		boxRight -= box["Left"]
	
	var boxDown = fighterState["PositionVer"] + box["Down"]
	var boxUp = fighterState["PositionVer"] + box["Up"]
	
	return {"Left":boxLeft, "Right":boxRight,"Down":boxDown,"Up":boxUp}
