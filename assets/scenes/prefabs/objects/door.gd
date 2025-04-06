extends Node2D

@onready var player = get_tree().current_scene.find_child("Player")
@export var interact_cue = "Otwórz drzwi"

var isOpen = false

func _ready():
	if Persistent.opened_gate_level_0:
		open()

func get_interact_cue():
	if isOpen:
		return ""
	if Util.ITEMS.KEY in player.items:
		return interact_cue
	return "#Potrzebujesz klucza"

func interact():
	if $StaticBody2D and not $StaticBody2D.is_queued_for_deletion() and Util.ITEMS.KEY in player.items:
		player.set_state(Util.PLAYER_STATES.DOOR_OPEN)

func open():
	Audio.play_other("dzwi2.wav")
	isOpen = true
	Persistent.opened_gate_level_0 = true
	$Closed.hide()
	$Open.show()
	$StaticBody2D.queue_free()
