extends Node2D

@export_range(0.1, 1.0) var bullet_delay: float = 0.2
@export_range(1.0, 20.0) var bullet_speed: float = 4.5
@export_range(3, 20) var bullet_groups_to_send = 10
@onready var player = get_tree().current_scene.find_child("Player")
@onready var player_undertale = player.find_child("UndertalePlayer")
@onready var player_undertale_box = player.find_child("UndertaleArea")
@export_file("*.tscn") var bullet_path = "res://assets/scenes/prefabs/bullet/bullet.tscn"
@onready var bullet = load(bullet_path)

var active = false
var bullet_groups_sent = 0

@export_category("Allowed enemy bullet groups")
@export var HORIZONTAL_CONVERGING: bool = true
@export var VERTICAL_CONVERGING: bool = true
@export var LEFT_ARRAY_FROM_TOP: bool = true
@export var RIGHT_ARRAY_FROM_TOP: bool = true
#@export var HORIZONTAL_CONVERGING: bool = true
#@export var HORIZONTAL_CONVERGING: bool = true
#@export var HORIZONTAL_CONVERGING: bool = true
#@export var HORIZONTAL_CONVERGING: bool = true
#@export var HORIZONTAL_CONVERGING: bool = true

func _ready():
	SignalBus.undertale_player_not_moving.connect(_on_undertale_player_not_moving)

func _on_undertale_player_not_moving():
	if not (active and bullet_groups_sent < bullet_groups_to_send):
		return
	var flip_v = player_undertale.global_position.y < player_undertale_box.size.y
	create_bullet(
		Vector2(0, 0), Vector2(0, 1), false, flip_v, bullet_speed * 3,
		player_undertale.global_position.x - player_undertale_box.global_position.x
	)

func get_available_bullet_groups():
	var out = []
	for nm in Util.BULLET_GROUPS.keys():
		var b = get(nm)
		if b == true:
			out.append(Util.BULLET_GROUPS.get(nm))
	return out

func interact():
	player.set_state(Util.PLAYER_STATES.UNDERTALE)
	active = true
	for i in bullet_groups_to_send:
		var bgroup = get_available_bullet_groups()
		var b = bgroup.pick_random()
		bgroup.erase(b)
		bullet_groups_sent += 1
		await launch_bullet_group(b, randf() > 0.5, randf() > 0.5)
		await get_tree().create_timer(0.4).timeout
		if len(bgroup) == 0:
			bgroup = get_available_bullet_groups()
	await get_tree().create_timer(3.0).timeout
	active = false
	player.set_state(Util.PLAYER_STATES.DOWN)

func create_bullet(posr: Vector2, velocity: Vector2, flip_h: bool = false, flip_v: bool = false, speed: float = bullet_speed, position_override_x = null, position_override_y = null):
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
	player_undertale_box.add_child(inst)

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
