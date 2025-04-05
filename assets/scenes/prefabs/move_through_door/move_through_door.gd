extends Node2D

@export var interact_cue = "Przejdź dalej"
@export_file("*.tscn") var move_to = ""

@onready var player = get_tree().current_scene.find_child("Player")

var has_wheel = false
var vel_x = 0.0

func get_interact_cue():
	return interact_cue
	
func interact():
	if has_wheel:
		vel_x = 300.0
	else:
		player.fade_out_and_change_scene_to(move_to)

func _ready():
	global_position.x += vel_x
	vel_x /= 5
