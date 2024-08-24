# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control

var nextVersionData
var branch
var downloadAddress
onready var httpRequest = $HTTPRequest

onready var lErrors = $Progress/Error
var lErrorsT = "Log:\n"
var hadErrors = false

# TODO: Store version as castagne/castagne-version.json and load from it at startup or during the updater
# TODO: Download the zip, unzip, then delete

# Start
# Download zip
# Unzip
# Save and restart
# Restart
#

func CUPLog(t):
	print("[Updater] " + str(t))
	lErrorsT += str(t) + "\n"
	lErrors.set_text(lErrorsT)
func CUPError(t):
	CUPLog(t)
	lErrors.show()
	hadErrors = true
	$Progress/RestartButton.set_text("Update failed, click to close")
func _ready():
	# Temp since I didn't figure out the process lol
	#Castagne.baseConfigData.Set("Updater-Branch", branch)
	#Castagne.baseConfigData.Set("Updater-LastUpdate", nextVersionData["version"])
	#Castagne.baseConfigData.SaveConfigFile()
	lErrors.hide()
	
	$Progress/Data.set_text("New Version: "+str(nextVersionData["version-name"])+" / ["+str(branch)+"]"+
		"\nPrevious Version: "+str(Castagne.versionInfo["version-name"])+" / ["+str(Castagne.baseConfigData.Get("Updater-Branch"))+"]")
	
	downloadAddress = Castagne.baseConfigData.Get("Updater-Source") + "castagne-patch-"+branch.to_lower()+".zip"
	$Progress/DownloadFrom.set_text("Downloading "+str(downloadAddress))

func StartUpdate():
	$Progress/StartUpdate.set_disabled(true)
	$Progress/RestartButton.set_disabled(true)
	
	print("[Updater] Starting update process")
	CUPLog("Requesting last ["+branch+"] version at "+str(downloadAddress))
	
	var error = httpRequest.request(downloadAddress)
	if error != OK:
		CUPError("An error occurred in the HTTP request init. Code: " + str(error))

func EndButton():
	get_tree().quit()
	# TODO: Save current version. Or use version file ? as castagne/castagne-version.json


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if(result != HTTPRequest.RESULT_SUCCESS or response_code != 200):
		CUPError("HTTP Request error: " + str(result) + " / Code " + str(response_code))
		return
	
	CUPLog("File obtained!")
	$Progress/ProgressBarDownload.set_value(100.0)
	
	var zipFile = File.new()
	zipFile.open("user://castagnepatch.zip", File.WRITE)
	zipFile.store_buffer(body)
	zipFile.close()
	CUPLog("Saved file.")
	
	var gdunzip = load("res://castagne/external/gdunzip/gdunzip.gd").new()
	var loaded = gdunzip.load("user://castagnepatch.zip")
	
	var nbFilesExtracted = 0
	var nbFilesTotal = gdunzip.files.size()
	CUPLog("Zip has "+str(nbFilesTotal)+" files.")
	var rootUncompressFolder = "res://"
	var d = Directory.new()
	d.make_dir(rootUncompressFolder)
	for compressedFileName in gdunzip.files:
		nbFilesExtracted += 1
		$Progress/ApplyLabel.set_text("Updating... ("+str(nbFilesExtracted)+"/"+str(nbFilesTotal)+")")
		var targetPath = rootUncompressFolder + compressedFileName
		print(compressedFileName + " -> " + targetPath)
		$Progress/ProgressBarApply.set_value(100.0*float(nbFilesExtracted-1)/nbFilesTotal)
		if(compressedFileName.ends_with("/")):
			# folder
			print(d.make_dir_recursive(targetPath))
			continue
		var uncompressed = gdunzip.uncompress(compressedFileName)
		var f = File.new()
		print(f.open(targetPath, File.WRITE))
		f.store_buffer(uncompressed)
		f.close()
		#print(f['file_name'])
	$Progress/ProgressBarApply.set_value(100.0)
	$Progress/RestartButton.set_disabled(false)

var updateHTTPBar = false
var updateZipBar = false
func _progress(delta):
	pass


func _on_LinkButton_pressed():
	OS.shell_open("http://castagneengine.com/builds/Castagne-"+str(branch)+"-Patch.zip")
