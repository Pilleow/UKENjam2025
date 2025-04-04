extends CharacterBody2D

const SPEED = 300.0

@onready var player_master = get_tree().current_scene.find_child("Player")

func _physics_process(delta: float) -> void:
	if player_master.player_state != Util.PLAYER_STATES.DOWN:
		return

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
