extends Control

var nextVersionData
var branch
onready var l = $Label
var lt = "Castagne is updating...\n"
onready var httpRequest = $HTTPRequest

func CUPLog(t):
	print("[Updater] " + str(t))
	lt += str(t) + "\n"
	l.set_text(lt)
func _ready():
	# Temp since I didn't figure out the process lol
	Castagne.baseConfigData.Set("Updater-Branch", branch)
	Castagne.baseConfigData.Set("Updater-LastUpdate", nextVersionData["version"])
	Castagne.baseConfigData.SaveConfigFile()
	return
	
	print("[Updater] Starting update process")
	CUPLog("Requesting last ["+branch+"] version...")
	var error = httpRequest.request(Castagne.configData["Updater-Source"] + "Castagne-"+branch+"-Patch.pck")
	if error != OK:
		CUPLog("An error occurred in the HTTP request init. Code: " + str(error))

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS or response_code != 200):
		CUPLog("HTTP Request error: " + str(result) + " / Code " + str(response_code))
		CUPLog("Update failed.")
		return
	
	CUPLog("Found patch.")
	var file = File.new()
	file.open("user://castagnepatch.pck", File.WRITE)
	file.store_buffer(body)
	file.close()
	CUPLog("Saved patch to disk. Starting update...")
	
	var success = ProjectSettings.load_resource_pack("user://castagnepatch.pck")
	if(success):
		CUPLog("Updated Castagne! Please restart the program to enjoy the new version!")
	else:
		CUPLog("Update failed.")


func _on_LinkButton_pressed():
	OS.shell_open("http://castagneengine.com/builds/Castagne-"+str(branch)+"-Patch.zip")
