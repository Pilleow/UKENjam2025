extends AnimatedSprite2D

@onready var player = get_tree().current_scene.find_child("Player").get_node("DownPlayer")

func _physics_process(delta: float) -> void:
	flip_h = false
	if player.global_position.x < global_position.x:
		flip_h = true
