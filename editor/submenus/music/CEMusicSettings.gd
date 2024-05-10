# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneEditorSubmenu.gd"


var selectedTrackID = -1

var isCurrentTrackPlayable = false
var currentTrackLength = 0.0
var currentTrackPosition = 0.0
var isCurrentlyScrollingTrack = false

var musicData

onready var cMusicList = $LeftPanel/MusicList
onready var cMusicPlayer = $MusicInfo/Audio
onready var cMusicBar = $MusicInfo/PlaySlider
onready var cMusicPlay = $MusicInfo/MusicControls/MusicPlay
onready var cMusicLoop = $MusicInfo/MusicControls/MusicLoop

func Enter():
	musicData = editor.configData.Get("MusicData")
	RecreateTrackList()

func _on_Confirm_pressed():
	editor.configData.Set("MusicData", musicData)
	Exit(OK)

func RecreateTrackList(focusOn = -1):
	cMusicList.clear()
	
	var i = 1
	for m in musicData:
		var n = m["Name"]
		cMusicList.add_item("["+str(i)+"] " + n)
		i += 1
	
	if(focusOn < 0):
		Unselect()
	else:
		LoadTrack(focusOn)

func Unselect():
	selectedTrackID = -1
	$MusicInfo.hide()
	MusicStop()
	cMusicList.unselect_all()
	$LeftPanel/Controls/MusicRemove.set_disabled(true)
	$LeftPanel/Controls/MusicUp.set_disabled(true)
	$LeftPanel/Controls/MusicDown.set_disabled(true)

func _process(delta):
	if(isCurrentTrackPlayable):
		if(cMusicPlay.is_pressed()):
			currentTrackPosition += delta
			var loopEnd = musicData[selectedTrackID]["LoopEnd"]
			var loopStart = musicData[selectedTrackID]["LoopStart"]
			if(loopEnd <= 0):
				loopEnd = currentTrackLength
			if(cMusicLoop.is_pressed()):
				if(currentTrackPosition >= loopEnd):
					currentTrackPosition -= loopEnd - loopStart
					cMusicPlayer.seek(currentTrackPosition)
			elif(currentTrackPosition >= currentTrackLength):
				currentTrackPosition = currentTrackLength
				cMusicPlayer.stop()
		#currentTrackPosition = cMusicBar.get_value()
		if(!isCurrentlyScrollingTrack):
			cMusicBar.set_value(currentTrackPosition)
		$MusicInfo/MusicLabels/LabelCurrent.set_text("Current: "+str(currentTrackPosition))

func MusicStop():
	cMusicPlayer.stop()

func LoadTrack(trackID):
	selectedTrackID = trackID
	MusicStop()
	cMusicList.select(trackID)
	$MusicInfo.show()
	$LeftPanel/Controls/MusicRemove.set_disabled(false)
	$LeftPanel/Controls/MusicUp.set_disabled(selectedTrackID == 0)
	$LeftPanel/Controls/MusicDown.set_disabled(selectedTrackID == len(musicData) - 1)
	
	var md = musicData[selectedTrackID]
	$MusicInfo/Title.set_text("Track #"+str(selectedTrackID+1) + " - "+md["Name"])
	$MusicInfo/Filepath/FilepathEdit.set_text(md["Filepath"])
	$MusicInfo/Name/NameEdit.set_text(md["Name"])
	$MusicInfo/LoopStart/LoopStartTime.set_value(md["LoopStart"])
	$MusicInfo/LoopEnd/LoopEndTime.set_value(md["LoopEnd"])
	$MusicInfo/AudioVolume/AudioVolumeValue.set_value(md["Volume"])
	cMusicPlayer.set_volume_db(md["Volume"])
	
	TryLoadMusic()

func TryLoadMusic():
	var fp = musicData[selectedTrackID]["Filepath"]
	var f = File.new()
	if(f.file_exists(fp)):
		isCurrentTrackPlayable = true
		$MusicInfo/FilepathFeedback.set_text("File is valid!")
		var audioStream = load(fp)
		currentTrackPosition = 0.0
		currentTrackLength = audioStream.get_length()
		cMusicPlayer.set_stream(audioStream)
		cMusicBar.set_editable(true)
		cMusicBar.set_max(currentTrackLength)
		$MusicInfo/MusicLabels/LabelDuration.set_text("Duration: "+str(currentTrackLength))
		$MusicInfo/MusicLabels/LabelCurrent.set_text("Current: "+str(currentTrackPosition))
		$MusicInfo/MusicControls/MusicPlay.set_pressed_no_signal(false)
		$MusicInfo/MusicControls/MusicLoop.set_pressed_no_signal(true)
	else:
		isCurrentTrackPlayable = false
		currentTrackPosition = 0.0
		currentTrackLength = 0.0
		MusicStop()
		cMusicBar.set_editable(false)
		$MusicInfo/FilepathFeedback.set_text("File not found, please check the path and press [Reload].")
		$MusicInfo/MusicLabels/LabelDuration.set_text("Duration: -")
		$MusicInfo/MusicLabels/LabelCurrent.set_text("Current: -")

func _on_MusicAdd_pressed():
	musicData += [{
		"Filepath": "res://",
		"Name": "Track "+str(len(musicData)+1),
		"Volume": 0.0,
		"LoopStart": 0.0,
		"LoopEnd": 0.0,
	}]
	
	RecreateTrackList(len(musicData) - 1)
	


func _on_MusicRemove_pressed():
	if(selectedTrackID >= 0):
		musicData.remove(selectedTrackID)
		RecreateTrackList()


func _on_MusicUp_pressed():
	if(selectedTrackID >= 1):
		var md = musicData[selectedTrackID]
		musicData.remove(selectedTrackID)
		musicData.insert(selectedTrackID - 1, md)
		RecreateTrackList(selectedTrackID - 1)


func _on_MusicDown_pressed():
	if(selectedTrackID >= 0 and selectedTrackID < len(musicData) - 1):
		var md = musicData[selectedTrackID]
		musicData.remove(selectedTrackID)
		musicData.insert(selectedTrackID + 1, md)
		RecreateTrackList(selectedTrackID + 1)


func _on_FilepathReload_pressed():
	TryLoadMusic()


func _on_NameEdit_text_changed(new_text):
	musicData[selectedTrackID]["Name"] = new_text
	$MusicInfo/Title.set_text("Track #"+str(selectedTrackID+1) + " - "+musicData[selectedTrackID]["Name"])
	cMusicList.set_item_text(selectedTrackID, "["+str(selectedTrackID+1) + "] "+musicData[selectedTrackID]["Name"])


func _on_MusicPlay_toggled(button_pressed):
	if(button_pressed):
		cMusicPlayer.play(currentTrackPosition)
	else:
		cMusicPlayer.stop()


func _on_MusicLoop_toggled(button_pressed):
	pass # Replace with function body.



func _on_PlaySlider_drag_started():
	isCurrentlyScrollingTrack = true
func _on_PlaySlider_drag_ended(value_changed):
	isCurrentlyScrollingTrack = false
	currentTrackPosition = cMusicBar.get_value()
	$MusicInfo/MusicLabels/LabelCurrent.set_text("Current: "+str(currentTrackPosition))
	cMusicPlayer.seek(currentTrackPosition)


func _on_TestLoopStart_pressed():
	if(isCurrentTrackPlayable):
		currentTrackPosition = musicData[selectedTrackID]["LoopStart"]
		cMusicPlay.set_pressed_no_signal(true)
		cMusicPlayer.play(currentTrackPosition)


func _on_TestLoopEnd_pressed():
	if(isCurrentTrackPlayable):
		currentTrackPosition = musicData[selectedTrackID]["LoopEnd"] - 1.0
		cMusicPlay.set_pressed_no_signal(true)
		cMusicPlayer.play(currentTrackPosition)


func _on_LoopStartTime_value_changed(value):
	musicData[selectedTrackID]["LoopStart"] = value


func _on_LoopEndTime_value_changed(value):
	musicData[selectedTrackID]["LoopEnd"] = value


func _on_MusicList_item_selected(index):
	LoadTrack(index)


func _on_AudioVolumeValue_value_changed(value):
	musicData[selectedTrackID]["Volume"] = value
	cMusicPlayer.set_volume_db(value)


func _on_FilepathEdit_text_changed(new_text):
	musicData[selectedTrackID]["Filepath"] = new_text
	$MusicInfo/FilepathFeedback.set_text("- Press [Reload] to test changes -")

