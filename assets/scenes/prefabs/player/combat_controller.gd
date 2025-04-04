extends Node2D

@onready var player = get_tree().current_scene.find_child("Player")

var bullet_max_number = 50;
var bullet_iter = 0;
var Bullet = preload("res://assets/scenes/prefabs/objects/bullet.tscn");

var Bullets = [];
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace withvar player_state: Util.PLAYER_STATES = Util.PLAYER_STATES.DOWN function body.
	
func _spawn_bullet():
	if player.player_state == Util.PLAYER_STATES.UNDERTALE:
		print("PRESSED SPAWN\n");
		var obj = Bullet.instantiate();
		obj.position = Vector2(0,0);
		add_child(obj);
	pass
	
func _physics_process(delta: float) -> void:
	
	if(Input.is_action_pressed("bullet_spawn")):
		_spawn_bullet();		
	pass
