extends CanvasLayer

@onready var wrap_undertale = $UndertaleWrapper
@onready var wrap_doorOpen = $DoorOpenWrapper
@onready var player = get_parent()

var interacting_with = null

func interact():
	match player.player_state:
		Util.PLAYER_STATES.DOOR_OPEN:
			interact_door_open()

func set_interacting_body(b):
	interacting_with = b

func remove_interacting_body():
	interacting_with = null

func update_wrap_visibility():
	wrap_undertale.visible = (player.player_state == Util.PLAYER_STATES.UNDERTALE)
	wrap_doorOpen.visible = (player.player_state == Util.PLAYER_STATES.DOOR_OPEN)

func interact_door_open():
	var interact_pressed = Input.is_action_just_pressed("interact")
	if interact_pressed:
		interacting_with.open()
		player.player_state = Util.PLAYER_STATES.DOWN
