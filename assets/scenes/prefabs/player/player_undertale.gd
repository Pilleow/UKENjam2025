extends CharacterBody2D

const SPEED = 300.0
const NOTIFY_AFK_AFTER_SECONDS = 2.0

var time_since_player_moved : float = 0.0
var notified = false

var hp = 1.0

@onready var player_master = get_tree().current_scene.find_child("Player")

func take_damage(dmg: float):
	hp -= dmg
	if hp <= 0:
		hp = 0
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if player_master.player_state != Util.PLAYER_STATES.UNDERTALE:
		time_since_player_moved = 0
		return
		
	time_since_player_moved += delta
	if time_since_player_moved > NOTIFY_AFK_AFTER_SECONDS:
		if not notified:
			SignalBus.undertale_player_not_moving.emit()
			notified = true
	else:
		notified = false
	
	var direction_x := Input.get_axis("left", "right")
	if direction_x:
		velocity.x = direction_x * SPEED
		time_since_player_moved = 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var direction_y := Input.get_axis("up", "down")
	if direction_y:
		velocity.y = direction_y * SPEED
		time_since_player_moved = 0
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
