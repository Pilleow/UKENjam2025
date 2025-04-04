extends CharacterBody2D

const SPEED = 300.0

@onready var player_master = get_tree().current_scene.find_child("Player")

func _physics_process(delta: float) -> void:
	if player_master.player_state != Util.PLAYER_STATES.UP:
		return
	
	var direction_x := Input.get_axis("left", "right")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var direction_y := Input.get_axis("up", "down")
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
