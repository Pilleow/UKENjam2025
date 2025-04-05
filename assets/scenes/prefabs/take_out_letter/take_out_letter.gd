extends Node2D

@onready var player = get_tree().current_scene.find_child("Player")
@export var interact_cue = "Otwórz szufladę"

func get_interact_cue():
	return interact_cue

func interact():
	player.set_state(Util.PLAYER_STATES.TAKE_OUT_LETTER)

func enable_ritual():
	queue_free()
