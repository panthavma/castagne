extends Control

var _tutorialPath
var tutorialScript
onready var editor = $".."

var scriptState

func SetupTutorial(tutorialPath):
	tutorialScript = LoadTutorialScript(tutorialPath)
	var tutoEditor = tutorialScript.Setup()
	tutoEditor.tutorialPath = tutorialPath
	get_tree().get_root().add_child(tutoEditor)

func StartTutorial(tutorialPath):
	_tutorialPath = tutorialPath
	tutorialScript = LoadTutorialScript(tutorialPath)
	scriptState = tutorialScript.TutorialScript()

func LoadTutorialScript(tutorialPath):
	var node = Node.new()
	var scriptPrefab = load(tutorialPath)
	if(scriptPrefab == null):
		Castagne.Error("Can't find tutorial script to load: "+str(tutorialPath))
		return null
	node.set_script(scriptPrefab)
	node.system = self
	node.editor = editor
	add_child(node)
	return node

# SANDBOX

func TutorialSetupBasic(basicConfigFile, filesToCopy = []):
	filesToCopy += [basicConfigFile]
	var dir = Directory.new()
	
	var tutorialRoot = "user://tutorial/"
	if(!dir.dir_exists(tutorialRoot)):
		dir.make_dir_recursive(tutorialRoot)
	
	var configDstPath
	for srcPath in filesToCopy:
		var fileName = srcPath.right(srcPath.rfind("/")+1)
		var dstPath = tutorialRoot + fileName
		configDstPath = dstPath
		
		if(dir.copy(srcPath, dstPath) != OK):
			Castagne.Error("Tutorial setup failed to copy file, aborting")
			return null
	
	var tutoEditor = Castagne.InstanceCastagneEditor(Castagne.LoadModulesAndConfig(configDstPath))
	tutoEditor.skipFirstTimeFlow = true
	return tutoEditor

func ShowDialogue(text):
	$Dialog/Label.set_text(text)
	$DialogTop.hide()
	$Dialog.show()
	StencilNone()
func ShowTopDialogue(text):
	$DialogTop/Label.set_text(text)
	$DialogTop.show()
	$Dialog.hide()
	StencilNone()

func StencilRect(rect, canClick=false):
	var stencilRoot = $Stencil
	stencilRoot.get_node("W").set_margin(MARGIN_RIGHT, rect.position.x)
	stencilRoot.get_node("E").set_margin(MARGIN_LEFT, rect.end.x)
	stencilRoot.get_node("N").set_margin(MARGIN_LEFT, rect.position.x)
	stencilRoot.get_node("N").set_margin(MARGIN_RIGHT, rect.end.x)
	stencilRoot.get_node("N").set_margin(MARGIN_BOTTOM, rect.position.y)
	stencilRoot.get_node("S").set_margin(MARGIN_LEFT, rect.position.x)
	stencilRoot.get_node("S").set_margin(MARGIN_RIGHT, rect.end.x)
	stencilRoot.get_node("S").set_margin(MARGIN_TOP, rect.end.y)
	stencilRoot.get_node("CenterClickCatcher").set_margin(MARGIN_LEFT, rect.position.x)
	stencilRoot.get_node("CenterClickCatcher").set_margin(MARGIN_LEFT, rect.position.y)
	stencilRoot.get_node("CenterClickCatcher").set_margin(MARGIN_RIGHT, rect.end.x)
	stencilRoot.get_node("CenterClickCatcher").set_margin(MARGIN_BOTTOM, rect.end.y)
	stencilRoot.get_node("CenterClickCatcher").set_visible(!canClick)
func StencilNode(node, canClick=false):
	var r = Rect2(node.get_global_position(), node.get_size())
	StencilRect(r, canClick)
func StencilNone():
	StencilRect(Rect2(-50,-50,0,0))


func EndTutorial():
	editor.queue_free()
	
	var newEditor = Castagne.InstanceCastagneEditor()
	get_tree().get_root().add_child(newEditor)

func _on_DialogButton_pressed():
	scriptState = scriptState.resume()
