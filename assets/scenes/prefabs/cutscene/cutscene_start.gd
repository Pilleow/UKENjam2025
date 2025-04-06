extends Node2D

@onready var sprite = $CanvasLayer/Wrapper/Sprite2D
@onready var label = $CanvasLayer/Wrapper/Label
@onready var box_fade = $CanvasLayer/Wrapper/FgFade

var main_menu_path = "res://assets/scenes/levels/end.tscn"

@export var chosen_cutscene: Util.CUTSCENES = Util.CUTSCENES.NONE
@export var interact_cue = ""

@onready var player = get_tree().current_scene.find_child("Player")

@export var item: String = ""

var to_print_to_label = ""
var fade_to = 0
var started = false
var finished = false
var write_delay = 0.0
var activate = false
var current_index: int = -1

func get_next():
	var sc = get_script_csn()
	current_index += 1
	if current_index >= len(sc):
		return null
	return sc[current_index]
	
func get_interact_cue():
	return interact_cue

func _on_fade_finish():
	if activate:
		run_cutscene()

func _ready():
	SignalBus.fade_finish.connect(_on_fade_finish)
	box_fade.color.a = 1

func _physics_process(delta: float) -> void:
	if not (finished or started):
		return
	write_delay -= delta
	if len(to_print_to_label) > 0 and write_delay < 0:
		write_delay = 0.1
		Audio.play_random(Util.RANDOM_AUDIO_STREAMS.SPEAK_BEAT)
		label.text += to_print_to_label.substr(0, min(5, len(to_print_to_label)))
		to_print_to_label = to_print_to_label.substr(min(5, len(to_print_to_label)))
	elif fade_to != box_fade.color.a:
		box_fade.color.a = move_toward(box_fade.color.a, fade_to, delta)
	elif finished:
			queue_free()

func process_as_flag(n):
	match n:
		Util.CUTSCENE_FLAGS.FADE_OUT:
			fade_to = 1
			return true
		Util.CUTSCENE_FLAGS.FADE_IN:
			fade_to = 0
			return true
		Util.CUTSCENE_FLAGS.TO_MAIN_MENU:
			get_tree().change_scene_to_file(main_menu_path)
			return true
	return false


func interact():
	SignalBus.player_lock_input.emit()
	player.hud.fade_out = true
	activate = true

func run_cutscene():
	started = true
	box_fade.show()
	$CanvasLayer.show()
	$CanvasLayer/Wrapper.show()
	var next = 1
	while next != null:
		next = get_next()
		if not await process_as_flag(next):
			if typeof(next) == TYPE_INT or typeof(next) == TYPE_FLOAT:
				await get_tree().create_timer(next).timeout
			elif typeof(next) == TYPE_STRING:
				if next.ends_with(".png"):
					sprite.texture = load(next)
				else:
					label.text = ""
					to_print_to_label = next
	SignalBus.player_unlock_input.emit()
	player.hud.fade_out = false
	if len(item) > 1:
		player.items.append(Util.ITEMS.get(item))
	finished = true

func get_script_csn():
	match chosen_cutscene:
		Util.CUTSCENES.NONE:
			return []
		Util.CUTSCENES.TUTORIAL:
			return [
				Util.CUTSCENE_FLAGS.FADE_IN,
				1.2,
				"res://assets/graphics/cutscenes/img/cutscene1.png",
				"Przez cały czas spędzony w naszym klasztorze nauczyłeś się wszystkiego, co wiemy o klątwach.",
				4.0,
				"Większość twoich braci nie wytrzymała próby, ale ty pozostałeś niezłomny.",
				4.0,
				"Teraz nadszedł czas twojego ostatecznego chrztu.",
				4.0,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0,
				"Twoje poświęcenie nie zostanie zapomniane.",
				3.0,
				"res://assets/graphics/cutscenes/img/cutscene2.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				1.2,
				"Weź ten klucz i okiełznaj klątwę w pobliskiej celi.",
				4.0,
				"Pozbądź się jej z naszego świata, a zyskasz swoje pierwsze prawdziwe zlecenie.",
				4.0,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0
			]
		Util.CUTSCENES.LEVEL1:
			Persistent.level1 = true
			return [
				"res://assets/graphics/cutscenes/img/cutscene1.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				1.2,
				"Pokonałeś pierwszą z klątw. To dowód odwagi i determinacji.",
				3.0,
				"Lecz wraz z tym zwycięstwem klątwa zamieszka w tobie, powoli zabijając ciebie.",
				3.0,
				"Od dziś znany jest dzień twojej śmierci.",
				2.5,
				"Pozbądź się plugastwa żyjącego na ziemi.",
				2.5,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0,
				"Nie zmarnuj swojego życia.",
				2.5,
				"res://assets/graphics/cutscenes/deadon/dead_in_12.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				2.5,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0,
				"Czeka na ciebie nowe zlecenie.",
				3.0,
				"res://assets/graphics/cutscenes/img/cutscene3.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				1.2,
				"Dom wygląda na pusty, ale w skrzynce wciąż lądują listy.",
				3.0,
				"Pisane ręką młodego chłopaka, który zmarł na początku wojny.",
				3.0,
				"Matkę pochowali na dniach, gdy żyła nie było możliwości zająć się klątwą.",
				3.0,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0
			]
		Util.CUTSCENES.LEVEL2:
			Persistent.level2 = true
			return [
				"res://assets/graphics/cutscenes/deadon/dead_in_5.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				2.5,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0,
				"Czeka na ciebie nowe zlecenie.",
				3.0,
				"res://assets/graphics/cutscenes/img/cutscene5.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				1.2,
				"Przed laty w kopalni doszło do wypadku, tunel zawalił się na pracujących górników.",
				3.5,
				"Wypadki się zdarzają, ale ten był inny.",
				2.5,
				"Jednego z nich można dalej usłyszeć jak pracuje w kopalni, niektórzy nawet mówili że go widzieli.",
				3.5,
				"Przed laty w kopalni doszło do wypadku, tunel zawalił się na pracujących górników.",
				3.0,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0,
				"To ten tunel, stąd pójdziesz już samemu. Nie chce mieć z tym nic wspólnego.",
				3.0
			]
		Util.CUTSCENES.LEVEL3:
			Persistent.level3 = true
			return [
				"res://assets/graphics/cutscenes/deadon/dead_in_0.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				2.5,
				"",
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0,
				"Czeka na ciebie nowe zlecenie.",
				3.0,
				"res://assets/graphics/cutscenes/img/cutscene4.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				1.2,
				"To był mój dom rodzinny.",
				2.5,
				"Nasza rodzina rozpadła się po śmierci mojego brata, spadł on z klifu za naszym domem.",
				3.5,
				"Ojciec widział to na własne oczy, od tamtej pory cały czas siedział na klifie.",
				3.5,
				"Po latach wróciłam zobaczyć co się stało z domem, ale zobaczyłam że ojciec dalej tam stoi...",
				3.5,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				1.0,
				"Nie jest już człowiekiem.",
				2.5
			]
		Util.CUTSCENES.AFTER_FINAL_BOSS:
			return [
				"res://assets/graphics/cutscenes/img/cutscene7.png",
				Util.CUTSCENE_FLAGS.FADE_IN,
				1.2,
				"You win!",
				3.0,
				Util.CUTSCENE_FLAGS.FADE_OUT,
				2.5,
				Util.CUTSCENE_FLAGS.TO_MAIN_MENU
			]
