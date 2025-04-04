extends Node2D

var player_state: Util.PLAYER_STATES = Util.PLAYER_STATES.DOWN

var interactable_entities = []

@onready var player_down = $DownPlayer
@onready var player_undertale = $HUD/UndertaleWrapper/UpPlayer
@onready var hud = $HUD
@onready var camera = $DownPlayer/Camera2D

func _ready():
	hud.show()
	if player_state == Util.PLAYER_STATES.UNDERTALE:
		hud.offset.y = 0
	elif player_state == Util.PLAYER_STATES.DOWN:
		hud.offset.y = -500

func interact_with_first_on_list():
	for en in interactable_entities:
		if en.is_in_group("Interactable"):
			en.interact()
			hud.set_interacting_body(en)
			break
	hud.update_wrap_visibility()


func _physics_process(delta: float) -> void:
	var interact_pressed = Input.is_action_just_pressed("interact")
	if interact_pressed and player_state == Util.PLAYER_STATES.DOWN:
		call_deferred("interact_with_first_on_list")
	#if change_state_pressed:
		#if player_state == Util.PLAYER_STATES.DOWN:
			#player_state = Util.PLAYER_STATES.UNDERTALE
		#elif player_state == Util.PLAYER_STATES.UNDERTALE:
			#player_state = Util.PLAYER_STATES.DOWN
	
	if player_state != Util.PLAYER_STATES.DOWN:
		if player_state != Util.PLAYER_STATES.UNDERTALE:
			hud.interact()
		var bd = hud.get_node("Border")
		hud.offset.y = move_toward(hud.offset.y, 150, abs(150 - hud.offset.y) / 15.0)
		bd.color.a = move_toward(bd.color.a, 0.9, abs(0.9 - bd.color.a) / 8.0)
		camera.zoom.x = move_toward(camera.zoom.x, 15, abs(1 - camera.zoom.x) / 8.0)
		camera.zoom.y = move_toward(camera.zoom.y, 15, abs(1 - camera.zoom.y) / 8.0)
	else:
		var bd = hud.get_node("Border")
		hud.offset.y = move_toward(hud.offset.y, -500, abs(-500 - hud.offset.y) / 15.0)
		bd.color.a = move_toward(bd.color.a, 0.0, abs(bd.color.a) / 8.0)
		camera.zoom.x = move_toward(camera.zoom.x, 1.5, abs(1.5 - camera.zoom.x) / 8.0)
		camera.zoom.y = move_toward(camera.zoom.y, 1.5, abs(1.5 - camera.zoom.y) / 8.0)

func take_damage(dmg: float):
	match player_state:
		Util.PLAYER_STATES.UNDERTALE:
			player_undertale.take_damage(dmg)

func set_state(en: Util.PLAYER_STATES):
	player_state = en

func _on_interact_area_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body and body.is_in_group("Interactable"):
		interactable_entities.append(body)

func _on_interact_area_area_exited(area: Area2D) -> void:
	var body = area.get_parent()
	if body and body.is_in_group("Interactable"):
		interactable_entities.erase(body)
