extends Sprite2D

@onready var text: RichTextLabel = $text
@onready var enemy: CharacterBody2D = $".."
@onready var found_phrase = enemy.found_phrase
var state = "stop_fade"
var current_phrase = ""
var letter_index = 0

func _ready() -> void:
	self.visible = false
	enemy.connect("chasing", Callable(self, "chase_phrase"))
	enemy.connect("stop_chasing", Callable(self, "reset_phrase"))

func chase_phrase():
	if state != "stop_fade":
		return
	current_phrase = found_phrase
	text.text = ""  # Inicializa vazio
	letter_index = 0
	self.visible = true
	state = "fade_in"
	fade_in()

func reset_phrase():
	state = "stop_fade"

func fade_in():
	modulate.a = 0
	text.modulate.a = 0
	get_tree().create_timer(0.1).connect("timeout", Callable(self, "_fade_in_step"))

func _fade_in_step():
	if state != "fade_in":
		return
	if modulate.a < 1:
		modulate.a += 0.3
		text.modulate.a += 0.3
		get_tree().create_timer(0.1).connect("timeout", Callable(self, "_fade_in_step"))
	else:
		state = "show_text"
		_show_text()

func _show_text():
	if state != "show_text":
		return
	if letter_index < current_phrase.length():
		text.text += current_phrase[letter_index]
		letter_index += 1
		get_tree().create_timer(0.01).connect("timeout", Callable(self, "_show_text"))
	else:
		state = "fade_out"
		fade_out()

func fade_out():
	await get_tree().create_timer(1).timeout
	get_tree().create_timer(0.05).connect("timeout", Callable(self, "_fade_out_step"))

func _fade_out_step():
	if state != "fade_out":
		return
	if modulate.a > 0:
		modulate.a -= 0.3
		text.modulate.a -= 0.3
		get_tree().create_timer(0.1).connect("timeout", Callable(self, "_fade_out_step"))
	else:
		modulate.a = 0
		text.modulate.a = 0
		self.visible = false
		state = ""
