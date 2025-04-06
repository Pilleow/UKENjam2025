extends Node2D

var player_state: Util.PLAYER_STATES = Util.PLAYER_STATES.DOWN

var interactable_entities = []
var died_on = -1

var items = [
]

var last_anim_frame = 0
var next_scene_path = null

var rotation_dampener = 100.0

@export var show_battle_hints: bool = false
@export_file("*.wav") var init_bgm: String = ""
@export_file("*.wav") var next_bgm: String = ""
@export_file("*.wav") var fight_bgm = "res://assets/sounds/bgm/boss_main.wav"

@export var disable_lights = false
@export var anchor_camera = true
@export var init_x: float = 0
@export var init_x_on_replay: float = 0

@onready var player_down = $DownPlayer
@onready var player_undertale = $HUD/UndertaleWrapper/UndertalePlayer
@onready var hud = $HUD
@onready var camera = $Camera2D

func skip_cutscene_if_played():
	match get_tree().current_scene.name:
		"Level1":
			if Persistent.level1:
				init_x = init_x_on_replay
			Persistent.level1 = true
		"Level2":
			if Persistent.level2:
				init_x = init_x_on_replay
			Persistent.level2 = true
		"Level3":
			if Persistent.level3:
				init_x = init_x_on_replay
			Persistent.level3 = true

func _ready():
	skip_cutscene_if_played()
	
	init_bgm = init_bgm.split("/")[-1]
	next_bgm = next_bgm.split("/")[-1]
	fight_bgm = fight_bgm.split("/")[-1]
	
	if show_battle_hints:
		$HUD/UndertaleWrapper/HintsRight.show()
		$HUD/UndertaleWrapper/HintsRight2.show()
	$HUD/UndertaleWrapper/Eyes.offset.y = -500
	$HUD/Fade.show()
	if disable_lights:
		$DownPlayer/PointLight2D.energy = 0.1
		$DownPlayer/PointLight2D2.energy = 0.1
	show()
	player_down.global_position.x = init_x
	$InteractLabelWrapper.show()
	$HUD/DeadWrapper.hide()
	hud.show()
	SignalBus.fade_finish.connect(_on_fade_finish)
	SignalBus.BgmFinished.connect(_on_bgm_finish)
	if player_state == Util.PLAYER_STATES.UNDERTALE:
		hud.offset.y = 0
	elif player_state == Util.PLAYER_STATES.DOWN:
		hud.offset.y = -100

func _on_bgm_finish():
	if len(next_bgm) > 0:
		init_bgm = next_bgm
		next_bgm = ""

func _on_fade_finish():
	if next_scene_path:
		get_tree().change_scene_to_file(next_scene_path)

func interact_with_first_on_list():
	for en in interactable_entities:
		if en.is_in_group("Interactable"):
			en.interact()
			hud.set_interacting_body(en)
			break
	hud.update_wrap_visibility()

func fade_out_and_change_scene_to(path: String):
	next_scene_path = path
	hud.fade_out = true

func _physics_process(delta: float) -> void:
	Audio.ensure_bgm_playing(init_bgm)
	Audio.ensure_ambient_playing()
	if $DownPlayer/AnimatedSprite2D.animation == "standing":
		last_anim_frame = -1
	if $DownPlayer/AnimatedSprite2D.frame % 2 == 1 and $DownPlayer/AnimatedSprite2D.animation == 'walking' and last_anim_frame != $DownPlayer/AnimatedSprite2D.frame:
		last_anim_frame = $DownPlayer/AnimatedSprite2D.frame
		Audio.play_step_sound()
	
	if len(interactable_entities) == 0 or player_state != Util.PLAYER_STATES.DOWN:
		$InteractLabelWrapper/InteractLabel.global_position.y = move_toward(
			$InteractLabelWrapper/InteractLabel.global_position.y, -45, 
			abs($InteractLabelWrapper/InteractLabel.global_position.y + 45) / 10.0
		)
	elif len(interactable_entities[0].get_interact_cue()) > 0:
		var text = interactable_entities[0].get_interact_cue()
		if text.begins_with("#"):
			text = text.substr(1)
			$InteractLabelWrapper/InteractLabel.text = text
		else:
			$InteractLabelWrapper/InteractLabel.text = "[E] " + text
		$InteractLabelWrapper/InteractLabel.global_position.y = move_toward(
			$InteractLabelWrapper/InteractLabel.global_position.y, 60, 
			abs($InteractLabelWrapper/InteractLabel.global_position.y - 60) / 10.0
		)
	
	$DownPlayer/PointLight2D.rotate(delta / 4.0)
	$DownPlayer/PointLight2D2.rotate(delta / 12.0)
	var interact_pressed = Input.is_action_just_pressed("interact")
	if interact_pressed and player_state == Util.PLAYER_STATES.DOWN:
		call_deferred("interact_with_first_on_list")
	#if change_state_pressed:
		#if player_state == Util.PLAYER_STATES.DOWN:
			#player_state = Util.PLAYER_STATES.UNDERTALE
		#elif player_state == Util.PLAYER_STATES.UNDERTALE:
			#player_state = Util.PLAYER_STATES.DOWN
	
	if player_undertale.hp <= 0:
		if died_on == -1:
			init_bgm = ""
			next_bgm = ""
			$HUD/DeadWrapper.show()
			died_on = Time.get_ticks_msec()
			hud.offset.y = 0
		var t = Time.get_ticks_msec() - died_on
		if t > 40:
			$HUD/DeadWrapper/Overlay.color.v = 0
			$HUD/DeadWrapper/Overlay.color.s = 0
			$HUD/DeadWrapper/Overlay.color.a = min(1, 1 - (t / 2000.0))
		if t >= 4000:
			get_tree().reload_current_scene()
	elif player_state != Util.PLAYER_STATES.DOWN:
		if player_state != Util.PLAYER_STATES.UNDERTALE:
			hud.interact()
		$HUD/UndertaleWrapper/Eyes.offset.y = move_toward($HUD/UndertaleWrapper/Eyes.offset.y, 0, abs($HUD/UndertaleWrapper/Eyes.offset.y) / 50.0)
		var bd = hud.get_node("Border")
		hud.offset.y = move_toward(hud.offset.y, 150, abs(150 - hud.offset.y) / 15.0)
		bd.color.a = move_toward(bd.color.a, 0.9, abs(0.9 - bd.color.a) / 8.0)
		camera.zoom.x = move_toward(camera.zoom.x, 15, abs(1 - camera.zoom.x) / 8.0)
		camera.zoom.y = move_toward(camera.zoom.y, 15, abs(1 - camera.zoom.y) / 8.0)
	else:
		var bd = hud.get_node("Border")
		hud.offset.y = move_toward(hud.offset.y, -500, abs(-500 - hud.offset.y) / 15.0)
		bd.color.a = move_toward(bd.color.a, 0.0, abs(bd.color.a) / 8.0)
		var tc = player_down.velocity.normalized().x * 25
		if anchor_camera:
			camera.offset.x = player_down.global_position.x / 10.0
		else:
			camera.offset.x = player_down.global_position.x
		camera.zoom.x = move_toward(camera.zoom.x, 2.2, abs(1.5 - camera.zoom.x) / 8.0)
		camera.zoom.y = move_toward(camera.zoom.y, 2.2, abs(1.5 - camera.zoom.y) / 8.0)

	camera.rotation = sin(Time.get_ticks_msec() / 1500.0) / rotation_dampener

func take_damage(dmg: float):
	match player_state:
		Util.PLAYER_STATES.UNDERTALE:
			player_undertale.take_damage(dmg)

func set_state(en: Util.PLAYER_STATES):
	player_state = en

func _on_interact_area_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body and body.is_in_group("Interactable"):
		if body.is_in_group("FightArea"):
			init_bgm = "boss_intro.wav"
			next_bgm = fight_bgm
		if body.is_in_group("AutoInteract"):
			body.interact()
			hud.set_interacting_body(body)
		else:
			interactable_entities.append(body)

func _on_interact_area_area_exited(area: Area2D) -> void:
	var body = area.get_parent()
	if body and body.is_in_group("Interactable"):
		interactable_entities.erase(body)
