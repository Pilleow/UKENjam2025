extends Node2D

var lifetime: float = 0.0
var damage: float = 1.0
var target_v2: Vector2 = Vector2.ONE
@export_range(0, 5) var speed: float = 4
@export_range(0, 10.0) var lifespan: float = 3.0

func set_target(v2: Vector2):
	target_v2 = v2.normalized()

func set_initial(pos, velocity, sp):
	global_position = pos
	target_v2 = velocity
	speed = sp

func _ready():
	$ColorRect.modulate.a = 0

func _physics_process(delta: float) -> void:
	if lifetime < lifespan and $ColorRect.modulate.a < 1:
		$ColorRect.modulate.a = min(1, lifetime)
	if lifespan - lifetime < 1:
		$ColorRect.modulate.a = max(0, lifespan - lifetime) 
	rotate(delta * 8)
	global_position += target_v2 * speed
	lifetime += delta
	if lifetime >= lifespan:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("BlocksBullets"):
		queue_free()
	if body.is_in_group("ReceivesDamage"):
		body.take_damage(damage)
	if body.name.begins_with("BorderCollider") and lifetime > 1.0:
		lifetime = lifespan - 0.5
