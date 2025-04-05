extends Node2D

@onready var player = get_tree().current_scene.find_child("Player")
@export var interact_cue = "Zniszcz barykadę"

func get_interact_cue():
	if Util.ITEMS.CROWBAR in player.items:
		return interact_cue
	return "#Potrzebujesz łomu"

func interact():
	if Util.ITEMS.CROWBAR in player.items:
		player.set_state(Util.PLAYER_STATES.BREAK_BARRICADE)

func break_down():
	queue_free()
