extends ColorRect

var bullet_speed = 500.0;
var bullet_angle = 0.0;
var bullet_set_angle = false;
var bullet_velocity = Vector2(1,0);

signal Bullet_destroy;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function bod
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(!bullet_set_angle):
		bullet_angle += (randf()*2 -1)*45;
		rotation = deg_to_rad(bullet_angle);
		bullet_set_angle = true;
	else:
		position += bullet_velocity.rotated((rotation))*bullet_speed*delta;
	
	pass
