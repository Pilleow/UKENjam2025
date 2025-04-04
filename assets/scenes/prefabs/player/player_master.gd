extends Node2D

var player_state: Util.PLAYER_STATES = Util.PLAYER_STATES.DOWN

@onready var player_down = $DownPlayer
@onready var player_up = $HUD/UndertaleWrapper/UpPlayer
@onready var hud = $HUD

func _ready():
	if player_state == Util.PLAYER_STATES.UNDERTALE:
		hud.offset.y = 0
	elif player_state == Util.PLAYER_STATES.DOWN:
		hud.offset.y = -500

func _physics_process(delta: float) -> void:
	var change_state_pressed = Input.is_action_just_pressed("interact")
	if change_state_pressed:
		if player_state == Util.PLAYER_STATES.DOWN:
			player_state = Util.PLAYER_STATES.UNDERTALE
		elif player_state == Util.PLAYER_STATES.UNDERTALE:
			player_state = Util.PLAYER_STATES.DOWN
	
	if player_state == Util.PLAYER_STATES.UNDERTALE:
		var bd = hud.get_node("Border")
		hud.offset.y = move_toward(hud.offset.y, 150, abs(150 - hud.offset.y) / 15.0)
		bd.color.a = move_toward(bd.color.a, 0.9, abs(0.9 - bd.color.a) / 8.0)
	elif player_state == Util.PLAYER_STATES.DOWN:
		var bd = hud.get_node("Border")
		hud.offset.y = move_toward(hud.offset.y, -500, abs(-500 - hud.offset.y) / 15.0)
		bd.color.a = move_toward(bd.color.a, 0.0, abs(bd.color.a) / 8.0)
