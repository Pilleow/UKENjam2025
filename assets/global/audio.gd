extends Node2D

var speak_beat = []
var speak_beat_path = "res://assets/sounds/sfx/speak_beat/"

var steps = {
	"jaskinia": [],
	"pokoj": [],
	"klif": []
}
var steps_path_jaskinia = "res://assets/sounds/sfx/step/jaskinia/"
var steps_path_pokoj = "res://assets/sounds/sfx/step/pokoj/"
var steps_path_klif = "res://assets/sounds/sfx/step/klif/"

var ambient = {
	"jaskinia": [],
	"pokoj": [],
	"klif": []
}
var ambient_jaskinia = "res://assets/sounds/ambient/jaskinia/"
var ambient_pokoj = "res://assets/sounds/ambient/pokoj/"
var ambient_klif = "res://assets/sounds/ambient/klif/"

var step_crack = []
var step_crack_path = "res://assets/sounds/sfx/step/stepcrack/"

var bgm = {}
var bgm_path = "res://assets/sounds/bgm/"

func set_pos(pos):
	global_position = pos

func _ready():
	speak_beat = load_path(speak_beat_path, 10.0)
	step_crack = load_path(step_crack_path, 10.0)
	
	steps['jaskinia'] = load_path(steps_path_jaskinia, 10.0)
	steps['pokoj'] = load_path(steps_path_pokoj, 10.0)
	steps['klif'] = load_path(steps_path_klif, 10.0)
	
	ambient['jaskinia'] = load_path(ambient_jaskinia, 4.0)
	ambient['pokoj'] = load_path(ambient_pokoj, 4.0)
	ambient['klif'] = load_path(ambient_klif, 4.0)
	
	bgm = load_path(bgm_path, -6.0, true)
	bgm['before_undertale_intro.wav'].volume_db = -10.0
	bgm['ambient_beat_intro.wav'].volume_db = -10.0
	bgm['ambient_beat_main.wav'].volume_db = -10.0
	for b in bgm.values():
		b.finished.connect(SignalBus.BgmFinished.emit)

func load_path(dir_pa, v_db = 0, named=false):
	var dir = DirAccess.open(dir_pa)
	var out = []
	if named:
		out = {}
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			file_name = file_name.replace(".import", "")
			if not dir.current_is_dir() and (file_name.ends_with(".ogg") or file_name.ends_with(".wav") or file_name.ends_with(".mp3")):
				var stream = load(dir_pa + file_name)
				if stream:
					var asp = AudioStreamPlayer2D.new()
					asp.volume_db = v_db
					asp.stream = stream
					if named:
						print(file_name)
						out[file_name] = asp
					else:
						out.append(asp)
					add_child(asp)
			file_name = dir.get_next()
		dir.list_dir_end()
		return out

func ensure_bgm_playing(bgm_nm):
	var nm = get_tree().current_scene.name
	if bgm_nm in bgm and not bgm[bgm_nm].playing:
		bgm[bgm_nm].playing = true
		stop_all_other_bgm(bgm[bgm_nm])
	if len(bgm_nm) < 1:
		stop_all_other_bgm(null)

func stop_all_other_bgm(amb):
	for k in bgm.keys():
		if bgm[k] != amb:
			print(amb)
			bgm[k].playing = false

func ensure_ambient_playing():
	var nm = get_tree().current_scene.name
	var amb = null
	match nm:
		"Level0", "Level2":
			amb = ambient['jaskinia'][0]
		"Level1":
			amb = ambient['pokoj'][0]
		"Level3":
			amb = ambient['klif'][0]
	if amb and not amb.playing:
		amb.playing = true
		stop_all_other_ambient(amb)

func stop_all_other_ambient(amb):
	for k in ambient.keys():
		for a in ambient[k]:
			if amb != a:
				a.playing = false

func play_step_sound():
	var nm = get_tree().current_scene.name
	match nm:
		"Level0", "Level2":
			play_random(Util.RANDOM_AUDIO_STREAMS.STEP, 0)
		"Level1":
			play_random(Util.RANDOM_AUDIO_STREAMS.STEP, 1)
		"Level3":
			play_random(Util.RANDOM_AUDIO_STREAMS.STEP, 2)

func play_random(u, t=null):
	match u:
		Util.RANDOM_AUDIO_STREAMS.SPEAK_BEAT:
			speak_beat.pick_random().playing = true
		Util.RANDOM_AUDIO_STREAMS.STEP:
			match t:
				0:
					steps['jaskinia'].pick_random().playing = true
				1:
					steps['pokoj'].pick_random().playing = true
					if randf() < 0.2:
						step_crack.pick_random().playing = true
				2:
					steps['klif'].pick_random().playing = true
		
