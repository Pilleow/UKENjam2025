extends Node2D

@export_range(0.1, 0.5) var bullet_delay: float = 0.2
@export_range(0.1, 1.5) var bullet_group_delay: float = 0.7
@export_range(1.0, 7.0) var bullet_speed: float = 3.5
@export_range(3, 30) var bullet_groups_to_send = 10
@export_file("*.tscn") var move_to_scene = ""

@export var interact_cue = "Rozpocznij rytuał"

@onready var player = get_tree().current_scene.find_child("Player")
@onready var player_undertale = player.find_child("UndertalePlayer")
@onready var player_undertale_box = player.find_child("UndertaleArea")

@export_file("*.tscn") var bullet_path = "res://assets/scenes/prefabs/bullet/bullet.tscn"
@onready var bullet = load(bullet_path)
@export_file("*.tscn") var bullet_shadow_path = "res://assets/scenes/prefabs/bullet/bullet_shadow.tscn"
@onready var bullet_shadow = load(bullet_shadow_path)

var active = false
var bullet_groups_sent = 0

@export_category("Allowed enemy bullet groups")
@export var HORIZONTAL_CONVERGING: bool = true
@export var VERTICAL_CONVERGING: bool = true
@export var LEFT_ARRAY_FROM_TOP: bool = true
@export var RIGHT_ARRAY_FROM_TOP: bool = true
@export var LEFT_TOP_CORNER_ARRAY: bool = true
@export var CONVERGING_FROM_CORNERS: bool = true
@export var WALL_HORIZONTAL: bool = true
@export var WALL_VERTICAL: bool = true
#@export var DROPPING_RANDOM: bool = true

func _ready():
	SignalBus.undertale_player_not_moving.connect(_on_undertale_player_not_moving)

func _on_undertale_player_not_moving():
	if not (active and bullet_groups_sent < bullet_groups_to_send and bullet_groups_sent > 2):
		return
	var flip_v = player_undertale.global_position.y < player_undertale_box.size.y
	create_bullet(
		Vector2(0, 0), Vector2(0, 1), false, flip_v, bullet_speed,
		player_undertale.global_position.x - player_undertale_box.global_position.x,
		0, null, 10000
	)

func get_available_bullet_groups():
	var out = []
	for nm in Util.BULLET_GROUPS.keys():
		var b = get(nm)
		if b == true:
			out.append(Util.BULLET_GROUPS.get(nm))
	return out

func get_interact_cue():
	return interact_cue
	
func interact():
	player.set_state(Util.PLAYER_STATES.UNDERTALE)
	active = true
	await get_tree().create_timer(2.0).timeout
	var bgroup = get_available_bullet_groups()
	for i in bullet_groups_to_send:
		print(i)
		var b = bgroup.pick_random()
		bgroup.erase(b)
		bullet_groups_sent += 1
		player._on_bgm_finish()
		await launch_bullet_group(b, randf() > 0.5, randf() > 0.5)
		await get_tree().create_timer(bullet_group_delay).timeout  # tu zmieniać difficulty
		if len(bgroup) == 0:
			bgroup = get_available_bullet_groups()
			if len(bgroup) > 1:
				bgroup.erase(b)
	player.hud.undertale_face_die()
	await get_tree().create_timer(3.0).timeout
	active = false
	if len(move_to_scene) > 1:
		player.fade_out_and_change_scene_to(move_to_scene)
	player.set_state(Util.PLAYER_STATES.DOWN)

func create_bullet(posr: Vector2, velocity: Vector2, flip_h: bool = false, flip_v: bool = false, speed: float = bullet_speed, position_override_x = null, position_override_y = null, lifespan_override = null, damage_override = null):
	var pos = Vector2(
		player_undertale_box.size.x * posr.x,
		player_undertale_box.size.y * posr.y
	)
	if posr.x == 0:
		pos.x -= 120
	elif posr.x == 1:
		pos.x += 120
	if posr.y == 0:
		pos.y -= 120
	elif posr.y == 1:
		pos.y += 120
	var inst = bullet.instantiate()
	if flip_h:
		pos.x = 1 - pos.x
		velocity.x *= -1
		pos.x += player_undertale_box.size.x
	if flip_v:
		pos.y = 1 - pos.y
		velocity.y *= -1
		pos.y += player_undertale_box.size.y
	if position_override_x:
		pos.x = position_override_x
	if position_override_y:
		pos.y = position_override_y
	inst.set_initial(pos, velocity, speed)
	if lifespan_override:
		inst.lifespan = lifespan_override
	if damage_override:
		inst.damage = damage_override
	player_undertale_box.add_child(inst)

#func create_bullet_shadow(posr: Vector2, shadow_time: float = 0):
	#var pos = Vector2(
		#player_undertale_box.size.x * posr.x,
		#player_undertale_box.size.y * posr.y
	#)
	#var inst = bullet_shadow.instantiate()
	#inst.global_position = pos
	#if shadow_time > 0:
		#inst.set_shadow_time(shadow_time)
	#inst.set_parent_fight_area(self)
	#player_undertale_box.add_child(inst)

func launch_bullet_group(groupName: Util.BULLET_GROUPS, flip_h: bool, flip_v: bool):
	match groupName:
		Util.BULLET_GROUPS.HORIZONTAL_CONVERGING:
			for i in range(1, 5):
				var t = i / 5.0
				create_bullet(Vector2(0, t), Vector2(1, 0), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
				create_bullet(Vector2(1, 1 - t), Vector2(-1, 0), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
		Util.BULLET_GROUPS.VERTICAL_CONVERGING:
			for i in range(1, 5):
				var t = i / 5.0
				create_bullet(Vector2(t, 0), Vector2(0, 1), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
				create_bullet(Vector2(1 - t, 1), Vector2(0, -1), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
		Util.BULLET_GROUPS.LEFT_ARRAY_FROM_TOP:
			for i in range(1, 4):
				var t = i / 4.0
				create_bullet(Vector2(0, t), Vector2(1, 0), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
		Util.BULLET_GROUPS.RIGHT_ARRAY_FROM_TOP:
			for i in range(1, 4):
				var t = i / 4.0
				create_bullet(Vector2(1, t), Vector2(-1, 0), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
		Util.BULLET_GROUPS.LEFT_TOP_CORNER_ARRAY:
			for i in range(1, 5):
				var t = i / 5.0
				create_bullet(Vector2( t / 2 + 1, t - 1), Vector2(-1, 0.7), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
		Util.BULLET_GROUPS.CONVERGING_FROM_CORNERS:
				var rand_angle = randf_range(0.6, 0.85)
				create_bullet(Vector2(0, 0), Vector2(1, rand_angle), false, false)
				create_bullet(Vector2(0, 1), Vector2(1, -rand_angle), false, false)
				create_bullet(Vector2(1, 1), Vector2(-1, -rand_angle), false, false)
				create_bullet(Vector2(1, 0), Vector2(-1, rand_angle), false, false)
				await get_tree().create_timer(bullet_delay).timeout
		Util.BULLET_GROUPS.WALL_HORIZONTAL:
			var rand_inv = randi_range(2, 8)
			for i in range(1, 9):
				var flip_h_i = flip_h
				var t = i / 9.0
				if rand_inv == i or rand_inv == i + 1:
					continue
				create_bullet(Vector2(t, 0), Vector2(0, 1), flip_h_i, false, bullet_speed * 0.7)
			await get_tree().create_timer(bullet_delay * 2).timeout
		Util.BULLET_GROUPS.WALL_VERTICAL:
			var rand_inv = randi_range(2, 6)
			for i in range(1, 7):
				var flip_h_i = flip_h
				var t = i / 7.0
				if rand_inv == i or rand_inv == i + 1:
					continue
				create_bullet(Vector2(0, t), Vector2(1, 0), false, flip_h_i, bullet_speed * 0.9)
			await get_tree().create_timer(bullet_delay * 2).timeout
		#Util.BULLET_GROUPS.DROPPING_RANDOM:
			#for i in range(1, 7):
				#var rand_x = randi_range(0.05, 0.95)
				#var rand_y = randf_range(0.05, 0.95)
				#create_bullet_shadow(Vector2(rand_x, rand_y))
			#await get_tree().create_timer(bullet_delay * 2).timeout
