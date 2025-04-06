extends CanvasLayer

@onready var player = get_parent()

@onready var wrap_undertale = $UndertaleWrapper

@onready var wrap_takeoutletter = $TakeOutLetterWrapper
var szuflada_y_init = 0
var szuflada_y = 0

@onready var wrap_breakBarricade = $BreakBarricadeWrapper
var break_barri_times_pressed = 0.0

@onready var wrap_doorOpen = $DoorOpenWrapper
var init_key_x_pos: float = 0.0
var turn_key = 0.0
var max_turn_key = 50.0
var fade_out = false

var interacting_with = null

func _ready():
	init_key_x_pos = $DoorOpenWrapper/KeySprite.global_position.x
	szuflada_y_init = $TakeOutLetterWrapper/SzufladaInner.global_position.y
	$Fade.show()
	#break_barri_times_pressed = 0
	#init_key_x_pos = 0.0
	#turn_key = 0.0
	#max_turn_key = 50.0
	#fade_out = false

func _physics_process(delta: float) -> void:
	if not fade_out:
		if $Fade.color.a != 0:
			$Fade.color.a = move_toward($Fade.color.a, 0, delta)
			if $Fade.color.a == 0:
				SignalBus.fade_finish.emit()
	else:
		if $Fade.color.a != 1:
			$Fade.color.a = move_toward($Fade.color.a, 1, delta)
			if $Fade.color.a == 1:
				SignalBus.fade_finish.emit()

func interact():
	match player.player_state:
		Util.PLAYER_STATES.DOOR_OPEN:
			interact_door_open()
		Util.PLAYER_STATES.BREAK_BARRICADE:
			interact_break_barricade()
		Util.PLAYER_STATES.TAKE_OUT_LETTER:
			interact_take_out_letter()

func set_interacting_body(b):
	interacting_with = b

func remove_interacting_body():
	interacting_with = null

func update_wrap_visibility():
	wrap_undertale.visible = (player.player_state == Util.PLAYER_STATES.UNDERTALE)
	wrap_doorOpen.visible = (player.player_state == Util.PLAYER_STATES.DOOR_OPEN)
	wrap_breakBarricade.visible = (player.player_state == Util.PLAYER_STATES.BREAK_BARRICADE)

func undertale_face_die():
	if find_child("UndertalePlayer").hp <= 0:
		return
	player.init_bgm = ""
	player.next_bgm = ""
	Audio.play_other("porazka.wav")
	$UndertaleWrapper/Eyes.play("dead")

func interact_take_out_letter():
	var w_pressed = Input.is_action_pressed("up")
	var s_pressed = Input.is_action_pressed("down")
	if w_pressed and s_pressed:
		pass
	elif s_pressed:
		szuflada_y = min(100, szuflada_y + 1)
	elif w_pressed:
		szuflada_y = max(0, szuflada_y - 1)
	$TakeOutLetterWrapper/SzufladaInner.global_position.y = szuflada_y_init + szuflada_y
	var d_pressed = Input.is_action_just_pressed("right")

func interact_break_barricade():
	var w_pressed = Input.is_action_pressed("up")
	
	if break_barri_times_pressed > 0:
		break_barri_times_pressed -= 0.1
	if break_barri_times_pressed > 10:
		interacting_with.break_down()
		player.player_state = Util.PLAYER_STATES.DOWN

func interact_door_open():
	var d_pressed = Input.is_action_pressed("right")
	var s_pressed = Input.is_action_pressed("down")
	var key_speed = 8.0 
	var key_inserted = $DoorOpenWrapper/KeySprite.global_position.x - init_key_x_pos > 250
	$DoorOpenWrapper/KeySprite.scale.y = 8 * (1 - turn_key * 2 / max_turn_key)
	if d_pressed:
		if not key_inserted:
			$DoorOpenWrapper/KeySprite.global_position.x += key_speed
	elif not (turn_key > 0) and init_key_x_pos < $DoorOpenWrapper/KeySprite.global_position.x:
		$DoorOpenWrapper/KeySprite.global_position.x -= key_speed
	if key_inserted:
		if s_pressed:
			if turn_key < max_turn_key:
				turn_key += 2.0
			else:
				interacting_with.open()
				player.player_state = Util.PLAYER_STATES.DOWN
		else:
			turn_key = max(turn_key - 2, 0)
