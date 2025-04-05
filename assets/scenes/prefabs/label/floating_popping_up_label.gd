extends Node2D

@export var timer_pop_up: bool = true
@export_range(1, 8) var timer_seconds = 5
@export var texts: Array[String] = []

@onready var label = $Label
var init_y_label = 0.0

@onready var text_group = texts
var next_label_in:float = randf_range(1, timer_seconds)

func _ready():
	hide()
	init_y_label = label.position.y

func _physics_process(delta: float) -> void:
	next_label_in -= delta
	if label.modulate.a > 0:
		label.position.y -= 0.1
		if label.rotation < 0:
			rotate(-0.0001)
		else:
			rotate(0.0001)
	label.modulate.a = max(0, next_label_in - timer_seconds + 2)
	if next_label_in < 0:
		show()
		label.position.y = init_y_label
		label.rotation = randf_range(-PI/16, PI/16)
		next_label_in = timer_seconds
		var t = text_group.pick_random()
		label.text = t
