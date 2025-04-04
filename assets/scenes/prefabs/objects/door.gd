extends Node2D

@onready var player = get_tree().current_scene.find_child("Player")

func interact():
	player.set_state(Util.PLAYER_STATES.DOOR_OPEN)

func open():
	queue_free()
