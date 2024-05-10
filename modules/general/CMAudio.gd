# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends "../CastagneModule.gd"


func ModuleSetup():
	RegisterModule("Audio", null)
	RegisterBaseCaspFile("res://castagne/modules/general/Base-Audio.casp")
	RegisterSpecblock("AudioSFX", "res://castagne/modules/general/CMAudioSBSFX.gd")
	
	RegisterCategory("Audio", {"Description":"General audio parameters."})
	RegisterConfig("AudioVolumeMaster",1000, {
		"Flags":["Beginner"],
		"Description":"Relative audio level for sound in general in permil."}
		)
	RegisterConfig("AudioBusNameMaster", "Master", {
		"Flags":["Advanced"],
		"Description":"Name of the audio bus used for the master castagne volume."}
		)
	
	RegisterCategory("Sound Effects", {"Description":"General parameters for sound effects. They are setup per character."})
	RegisterConfig("AudioVolumeSFX",1000, {
		"Flags":["Beginner"],
		"Description":"Relative audio level of sound effects in permil."}
		)
	RegisterConfig("AudioBusNameSFX", "SFX", {
		"Flags":["Advanced"],
		"Description":"Name of the audio bus used for the castagne SFX volume."}
		)
	
	RegisterFunction("SFXPlay", [1], null, {
		"Description":"Plays a sound effect by its name. They have been setup beforehand in the Sound Effects specblock.",
		"Arguments":["SFX Name"],
		"Flags":["Beginner"],
		"Types":["str"],
	})
	RegisterFunction("SFXParam", [1, 2], null, {
		"Description":"Sets up a parameter for the next SFX.",
		"Arguments":["Parameter Name", "Value"],
		"Flags":["Beginner"],
		"Types":["str", "int"],
	})
	RegisterVariableEntity("_SFXParams", {}, ["ResetEachFrame"], {
		"Description": "Hold the current SFX param data.",
	})
	
	RegisterCategory("Music", {"Description":"Management of background music for stages."})
	RegisterConfig("AudioVolumeMusic",1000, {
		"Flags":["Beginner"],
		"Description":"Relative audio level of music in permil."}
		)
	RegisterConfig("AudioBusNameMusic", "Music", {
		"Flags":["Advanced"],
		"Description":"Name of the audio bus used for the castagne music volume."}
		)
	RegisterConfig("MusicData",[], {
		"Flags":["Hidden"],
		"Description":"Array of dictionaries containing the data needed for music."}
		)
	RegisterCustomConfig("Music Settings", "MusicSettings", {"Flags":["LockBack"]})


func BattleInit(stateHandle, battleInitData):
	SetupBuses(stateHandle.ConfigData())
	var musicID = battleInitData["music"]
	var musicDataAll = stateHandle.ConfigData().Get("MusicData")
	if(musicID < 0 || musicID >= len(musicDataAll) + 1):
		musicID = 0
	if(musicID == 0):
		return
	
	var musicData = musicDataAll[musicID-1]
	var musicPlayer = AudioStreamPlayer.new()
	var musicPlayerScript = load("res://castagne/modules/general/CMAudio_MusicPlayer.gd")
	musicPlayer.set_script(musicPlayerScript)
	stateHandle.Engine().add_child(musicPlayer)
	musicPlayer.InitFromData(musicData)
	musicPlayer.set_bus(stateHandle.ConfigData().Get("AudioBusNameMusic"))
	musicPlayer.play()

func InitPhaseStartEntity(stateHandle):
	var audioData = stateHandle.IDEntityGet("TD_AudioSFX")
	for sfxName in audioData["SFX"]:
		var filepath = audioData["SFX"][sfxName]["Filepath"]
		Castagne.Loader.Load(filepath)

func SFXParam(args, stateHandle):
	var paramName = ArgStr(args, stateHandle, 0)
	var paramValue = ArgInt(args, stateHandle, 1)
	var data = stateHandle.EntityGet("_SFXParams")
	data[paramName] = paramValue

func SFXPlay(args, stateHandle):
	var sfxName = ArgStr(args, stateHandle, 0)
	var audioData = stateHandle.IDEntityGet("TD_AudioSFX")["SFX"]
	if(!audioData.has(sfxName)):
		ModuleError("SFXPlay: SFX "+str(sfxName)+" not found!", stateHandle)
	var sfxParams = stateHandle.EntityGet("_SFXParams")
	SFXPlay_Callback(stateHandle, audioData[sfxName], sfxParams)

func SFXPlay_Callback(stateHandle, sfxData, sfxParams):
	var soundStream = Castagne.Loader.Load(sfxData["Filepath"])
	var soundNode = AudioStreamPlayer.new()
	soundNode.set_stream(soundStream)
	soundNode.set_bus(stateHandle.ConfigData().Get("AudioBusNameSFX"))
	soundNode.set_volume_db(PermilToDecibel(sfxData["Volume"]))
	stateHandle.Engine().add_child(soundNode)
	soundNode.play()

func SetupBuses(configData):
	var masterBusName = configData.Get("AudioBusNameMaster")
	SetupSingleBus(masterBusName, configData.Get("AudioVolumeMaster"), null)
	SetupSingleBus(configData.Get("AudioBusNameMusic"), configData.Get("AudioVolumeMusic"), masterBusName)
	SetupSingleBus(configData.Get("AudioBusNameSFX"), configData.Get("AudioVolumeSFX"), masterBusName)

func SetupSingleBus(busName, volumePermil, targetBusName):
	var busID = AudioServer.get_bus_index(busName)
	
	if(busID == -1):
		busID = AudioServer.get_bus_count()
		AudioServer.add_bus()
		AudioServer.set_bus_name(busID, busName)
		if(targetBusName != null):
			AudioServer.set_bus_send(busID, targetBusName)
	
	var volumeDB = PermilToDecibel(volumePermil)
	print(str(busID)+"BUS "+str(busName)+" VOLUME "+str(volumeDB))
	AudioServer.set_bus_volume_db(busID, volumeDB)
	AudioServer.set_bus_mute(busID, volumePermil <= 0)

func PermilToDecibel(permil):
	## TODO: Godot docs say that -6db is halved, while internet says -3db is halved ?
	var t = max(permil, 1) / 1000.0
	return 10 * ( log(t) / log(10) )
