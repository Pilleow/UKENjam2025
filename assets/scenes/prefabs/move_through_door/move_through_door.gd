extends Node2D

@export var interact_cue = "Przejdź dalej"
@export_file("*.tscn") var move_to = ""

@onready var player = get_tree().current_scene.find_child("Player")

var has_wheel = false
var vel_x = 0.0

func get_interact_cue():
	return interact_cue
	
func interact():
	player.fade_out_and_change_scene_to(move_to)
	Audio.play_other("dzwi3.wav")

func _ready():
	global_position.x += vel_x
	vel_x /= 5
