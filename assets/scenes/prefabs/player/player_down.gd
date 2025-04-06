extends CharacterBody2D

const SPEED = 80.0

@onready var player_master = get_tree().current_scene.find_child("Player")

var locked_movement = false

func lock_movement():
	locked_movement = true
	$AnimatedSprite2D.play("standing")

func unlock_movement():
	locked_movement = false
	$AnimatedSprite2D.play("standing")

func _ready():
	SignalBus.player_lock_input.connect(lock_movement)
	SignalBus.player_unlock_input.connect(unlock_movement)

func _physics_process(delta: float) -> void:
	if player_master.player_state != Util.PLAYER_STATES.DOWN:
		return

	if locked_movement:
		return

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED / 10.0)
		if direction > 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
		if $AnimatedSprite2D.animation != "down":
			$AnimatedSprite2D.play("walking")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 10.0)
		if $AnimatedSprite2D.animation != "down":
			$AnimatedSprite2D.play("standing")
		
	move_and_slide()
