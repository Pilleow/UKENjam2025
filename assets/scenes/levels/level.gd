extends Node2D

@export_range(10.0, 150.0) var rotation_dampener: float = 150.0

func _ready():
	call_deferred("_ready_fframe")

func _ready_fframe():
	get_tree().current_scene.find_child("Player").rotation_dampener = rotation_dampener
