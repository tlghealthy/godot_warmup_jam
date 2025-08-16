extends Node

var audio_player: AudioStreamPlayer

func _ready():
	# Create the audio player
	audio_player = AudioStreamPlayer.new()
	var music_stream = load("res://[Holocure OST] Suspect [9GpG5npZ5eU].mp3")
	audio_player.stream = music_stream
	add_child(audio_player)
	audio_player.play()

func is_playing() -> bool:
	return audio_player.playing

func get_playback_position() -> float:
	return audio_player.get_playback_position()
