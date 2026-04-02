extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var master_volume: float = 100.0

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	set_master_volume(master_volume)


func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.play()
	
func set_master_volume(value: float) -> void:
	master_volume = value
	
	var bus_index = AudioServer.get_bus_index("Master")
	
	if value <= 0:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 100.0))
