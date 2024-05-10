# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends AudioStreamPlayer

var loopEnd = 0
var loopStart = 0

func InitFromData(musicData):
	var fp = musicData["Filepath"]
	var f = File.new()
	if(!f.file_exists(fp)):
		Castagne.Error("CMAudio_MusicPlayer: Couldn't find file "+str(fp))
		return
	var audioStream = load(fp)
	set_stream(audioStream)
	loopStart = musicData["LoopStart"]
	loopEnd = musicData["LoopEnd"]
	if(loopEnd <= 0):
		loopEnd = audioStream.get_length()
	set_volume_db(musicData["Volume"])

var currentPos = 0.0
func _process(delta):
	if(loopEnd > 0):
		currentPos += delta
		if(currentPos >= loopEnd):
			currentPos -= loopEnd - loopStart
			seek(currentPos)
