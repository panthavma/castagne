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

var tutorialFolderRoot = "user://tutorial/"
func TutorialSetupBasic(basicConfigFile, filesToCopy = []):
	filesToCopy.push_front(basicConfigFile)
	filesToCopy += ["res://castagne/editor/tutorials/assets/TutorialBaston.casp"]
	
	var dir = Directory.new()
	if(!dir.dir_exists(tutorialFolderRoot)):
		dir.make_dir_recursive(tutorialFolderRoot)
	dir.open(tutorialFolderRoot)
	dir.list_dir_begin(true)
	
	var fpath = dir.get_next()
	while !fpath.empty():
		dir.remove(fpath)
		fpath = dir.get_next()
	
	
	var configDstPath = null
	for srcPath in filesToCopy:
		var fileName = srcPath.right(srcPath.rfind("/")+1)
		var dstPath = tutorialFolderRoot + fileName
		
		if(configDstPath == null):
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


func PressButton(node):
	node.emit_signal("pressed")

func ContinueNextFrame():
	call_deferred("Continue")

var codeReset_CodeFile = ""
func StartCoding(instructions, codeReset):
	editor.get_node("CharacterEdit/Popups/Window/Tutorial/Text").set_text(instructions)
	codeReset_CodeFile = codeReset
	hide()
	ResetCode()
	#editor.get_node("CharacterEdit")._on_Reload_pressed()

func ResetCode():
	SetCode(codeReset_CodeFile)
func SetCode(code):
	var characterEditor = editor.get_node("CharacterEdit")
	var fileData = characterEditor.character[characterEditor.character["NbFiles"]-1]
	var filePath = fileData["Path"]
	
	var file = File.new()
	file.open(fileData["Path"], File.WRITE)
	file.store_string(code)
	file.close()
	editor.get_node("CharacterEdit")._on_Reload_pressed()

func StopCoding():
	ResetCode()
	Continue()

func EndTutorial():
	editor.queue_free()
	
	var newEditor = Castagne.InstanceCastagneEditor()
	get_tree().get_root().add_child(newEditor)

func Continue():
	show()
	scriptState = scriptState.resume()

func _on_DialogButton_pressed():
	Continue()
