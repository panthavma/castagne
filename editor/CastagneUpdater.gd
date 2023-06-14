extends Popup

enum UPDATE_STATUS {
	NotStarted, Checking, NetworkIssue, NoNewUpdate, CanUpdate
}
var updateStatus = UPDATE_STATUS.NotStarted
onready var httpRequest = $HTTPRequest
onready var editorMenuButton = $"../Menu/Updater"
#onready var editorMenuButton = $"../Core/Menu/Castagne/Updater"
var currentBranch = "Main"
var originalBranch = "Main"

var nextVersionData = null

func _ready():
	originalBranch = Castagne.baseConfigData.Get("Updater-Branch")
	currentBranch = originalBranch
	if(Castagne.baseConfigData.Get("Updater-CheckOnStartup")):
		CheckForUpdates()
	UpdateDisplay()

func Open():
	CheckForUpdates()
	UpdateDisplay()
	popup_centered()

func CheckForUpdates(forceRetry = false):
	if(!forceRetry and updateStatus != UPDATE_STATUS.NotStarted):
		return
	
	httpRequest.cancel_request()
	
	updateStatus = UPDATE_STATUS.Checking
	var error = httpRequest.request(Castagne.baseConfigData.Get("Updater-Source") + "Castagne-"+currentBranch+"-Data.json")
	if error != OK:
		print("[Updater] An error occurred in the HTTP request.")
		updateStatus = UPDATE_STATUS.NetworkIssue
	
	UpdateDisplay()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS or response_code != 200):
		print("[Updater] HTTP Request error: " + str(result) + " / Code " + str(response_code))
		updateStatus = UPDATE_STATUS.NetworkIssue
		UpdateDisplay()
		return
	
	var text = body.get_string_from_utf8()
	print("[Updater] New version data: " + str(text))
	nextVersionData = {
		"version":null,
		"changelog":"[Changelog missing]",
	}
	var updateData = parse_json(text)
	Castagne.FuseDataOverwrite(nextVersionData, updateData)
	
	if(nextVersionData["version"] != null and (Castagne.baseConfigData.Get("Updater-LastUpdate") == null or nextVersionData["version"] > Castagne.baseConfigData.Get("Updater-LastUpdate"))):
		updateStatus = UPDATE_STATUS.CanUpdate
	else:
		updateStatus = UPDATE_STATUS.NoNewUpdate
	UpdateDisplay()


func UpdateDisplay():
	var statusTexts = {
		UPDATE_STATUS.NotStarted: "", UPDATE_STATUS.Checking: "[Checking for updates...]",
		UPDATE_STATUS.NetworkIssue: "[Can't reach the server]", UPDATE_STATUS.NoNewUpdate: "[No New Update]",
		UPDATE_STATUS.CanUpdate: "[Update Available !]"
	}
	editorMenuButton.set_text("Updater " + statusTexts[updateStatus])
	
	$Data/Branch/Current.set_text("Current Branch: ["+currentBranch+"]")
	var otherBranch = ("Dev" if currentBranch == "Main" else "Main")
	$Data/Branch/UpdaterChangeBranch.set_text("Switch to ["+otherBranch+"] branch")
	
	var curVersion = Castagne.baseConfigData.Get("Updater-LastUpdate")
	if(curVersion == null):
		curVersion = "[Never updated]"
	$Data/Versions/Current.set_text("Current Version: " + curVersion)
	var nextVersionText = "[Invalid]"
	if(updateStatus == UPDATE_STATUS.NotStarted or updateStatus == UPDATE_STATUS.NetworkIssue):
		nextVersionText = "[Unknown]"
	elif(updateStatus == UPDATE_STATUS.Checking):
		nextVersionText = "[Checking...]"
	elif(nextVersionData != null and nextVersionData["version"] != null):
		nextVersionText = nextVersionData["version"]
	$Data/Versions/Next.set_text("Next Version: " + nextVersionText)
	
	if(updateStatus == UPDATE_STATUS.CanUpdate):
		$Data/Changelog.set_text(nextVersionData["changelog"])
		$UpdaterUpdate.set_text("Update!")
		$UpdaterUpdate.set_disabled(false)
	elif(updateStatus == UPDATE_STATUS.NetworkIssue):
		$Data/Changelog.set_text(statusTexts[updateStatus])
		$UpdaterUpdate.set_text("Retry")
		$UpdaterUpdate.set_disabled(false)
	else:
		$Data/Changelog.set_text(statusTexts[updateStatus])
		$UpdaterUpdate.set_text(statusTexts[updateStatus])
		$UpdaterUpdate.set_disabled(true)




func _on_UpdaterUpdate_pressed():
	if(updateStatus == UPDATE_STATUS.CanUpdate):
		get_node("../../").queue_free()
		var patcher = load("res://castagne/devtools/updater/CastagneUpdatePatcher.tscn").instance()
		patcher.nextVersionData = nextVersionData
		patcher.branch = currentBranch
		get_node("/root").add_child(patcher)
	else:
		CheckForUpdates(true)


func _on_UpdaterChangeBranch_pressed():
	var otherBranch = ("Dev" if currentBranch == "Main" else "Main")
	currentBranch = otherBranch
	CheckForUpdates(true)
