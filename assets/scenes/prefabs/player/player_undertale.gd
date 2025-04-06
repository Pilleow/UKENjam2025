extends CharacterBody2D

const SPEED = 250.0
const NOTIFY_AFK_AFTER_SECONDS = 2.0

var time_since_player_moved : float = 0.0
var notified = false

var max_hp = 3
var hp = max_hp

var init_position = null

var locked_movement = false

@onready var wrapper = get_parent()
@onready var player_master = get_tree().current_scene.find_child("Player")

func lock_movement():
	locked_movement = true

func unlock_movement():
	locked_movement = false

func _ready():
	init_position = position
	SignalBus.player_lock_input.connect(lock_movement)
	SignalBus.player_unlock_input.connect(unlock_movement)

func take_damage(dmg: int):
	hp -= dmg
	modulate.a = float(hp) / float(max_hp)
	if hp <= 0:
		hp = 0

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
	
	if locked_movement:
		return
	
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
	
	var dx = init_position.x - position.x
	wrapper.rotation = -dx / 10000.0
	wrapper.position = Vector2(
		init_position.x - position.x,
		init_position.y - position.y - 100
	) / 5.0
	
	move_and_slide()
