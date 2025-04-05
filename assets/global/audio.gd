extends Node

var speak_beat = []
var speak_beat_path = "res://assets/sounds/sfx/speak_beat/"

func _ready():
	speak_beat = load_path(speak_beat_path)

func load_path(dir_pa):
	var dir = DirAccess.open(dir_pa)
	var out = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			file_name = file_name.replace(".import", "")
			if not dir.current_is_dir() and (file_name.ends_with(".ogg") or file_name.ends_with(".wav") or file_name.ends_with(".mp3")):
				var stream = load(dir_pa + file_name)
				if stream:
					var asp = AudioStreamPlayer2D.new()
					asp.volume_db = 10.0
					asp.stream = stream
					out.append(asp)
					add_child(asp)
			file_name = dir.get_next()
		dir.list_dir_end()
		return out

func play_random(u):
	match u:
		Util.RANDOM_AUDIO_STREAMS.SPEAK_BEAT:
			speak_beat.pick_random().playing = true
