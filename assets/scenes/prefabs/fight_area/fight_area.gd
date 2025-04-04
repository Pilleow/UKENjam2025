extends Node2D

@export_range(0.1, 1.0) var bullet_delay: float = 0.4
@export_range(1.0, 20.0) var bullet_speed: float = 5.0
@onready var player = get_tree().current_scene.find_child("Player")
@onready var player_undertale_box = player.find_child("UndertaleArea")
@export_file("*.tscn") var bullet_path = "res://assets/scenes/prefabs/bullet/bullet.tscn"
@onready var bullet = load(bullet_path)

func interact():
	player.set_state(Util.PLAYER_STATES.UNDERTALE)
	await get_tree().create_timer(2.0).timeout
	var unsent_bgroups = Util.BULLET_GROUPS.values()
	for i in 10:
		var bgroup = unsent_bgroups.pick_random()
		unsent_bgroups.erase(bgroup)
		launch_bullets_group(bgroup, false, false)
		if len(unsent_bgroups) == 0:
			unsent_bgroups = Util.BULLET_GROUPS.values()

func create_bullet(posr: Vector2, velocity: Vector2, flip_h: bool = false, flip_v: bool = false, speed: float = bullet_speed):
	var pos = Vector2(
		player_undertale_box.size.x * posr.x,
		player_undertale_box.size.y * posr.y
	)
	if posr.x == 0:
		pos.x -= 100
	elif posr.x == 1:
		pos.x += 100
	if posr.y == 0:
		pos.y -= 100
	elif posr.y == 1:
		pos.y += 100
	var inst = bullet.instantiate()
	if flip_h:
		pos.x = 1 - pos.x
		velocity.x *= -1
	if flip_v:
		pos.y = 1 - pos.y
		velocity.y *= -1
	inst.set_initial(pos, velocity, speed)
	player_undertale_box.add_child(inst)
	

func launch_bullets_group(groupName: Util.BULLET_GROUPS, flip_h: bool, flip_v: bool):
	match groupName:
		Util.BULLET_GROUPS.HORIZONTAL_CONVERGING:
			for i in range(1, 6):
				var t = i / 6.0
				create_bullet(Vector2(0, t), Vector2(1, 0), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
				create_bullet(Vector2(1, 1 - t), Vector2(-1, 0), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
		Util.BULLET_GROUPS.VERTICAL_CONVERGING:
			for i in range(1, 6):
				var t = i / 6.0
				create_bullet(Vector2(0, t), Vector2(1, 0), flip_h, flip_v)
				await get_tree().create_timer(bullet_delay).timeout
				create_bullet(Vector2(1, 1 - t), Vector2(-1, 0), flip_h, flip_v)
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
