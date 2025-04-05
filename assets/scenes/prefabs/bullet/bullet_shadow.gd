extends Node2D

@export_range(0.5, 2.5) var shadow_incoming_time: float = 1.0
@onready var init_shadow_incoming_time = shadow_incoming_time

var parent_fight_area = null

func set_shadow_time(st):
	shadow_incoming_time = st
	init_shadow_incoming_time = st

func set_parent_fight_area(b):
	parent_fight_area = b

func _physics_process(delta: float) -> void:
	var t = shadow_incoming_time / init_shadow_incoming_time
	$ColorRect.color.a = t / 2
	print(t)
	shadow_incoming_time -= delta
	scale.x = 1 + t
	scale.y = 1 + t
	rotate(delta * 8)
	if shadow_incoming_time <= 0:
		parent_fight_area.create_bullet(Vector2.ZERO, Vector2.ZERO, false, false, 0,  global_position.x, global_position.y, 1)
		print(global_position)
		queue_free()
