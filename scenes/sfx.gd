extends Node

@onready var player: CharacterBody2D = $"../basechar"
@onready var level_calm_: AudioStreamPlayer = $"Level(calm)"
@onready var level_fast_: AudioStreamPlayer = $"Level(fast)"

var last_time: float
var tween: Tween

func _ready():
	# Obter referência ao Tween
	tween = get_tree().create_tween()

	# Conectar sinais
	var characters = $"../NavigationRegion2D/enemies".get_children()
	for character in characters:
		character.connect("chasing", Callable(self, "chase_music"))
		character.connect("stop_chasing", Callable(self, "calm_music"))

func chase_music():
	if not level_calm_.playing:
		return
	
	last_time = level_calm_.get_playback_position()
	
	level_calm_.stop()
	level_fast_.play()

func calm_music():
	if level_calm_.playing or player.chasing_level > 0:
		return
	level_fast_.stop()
	level_calm_.play(last_time)

func fade_out(audio_player: AudioStreamPlayer, duration: float):
	tween.tween_property(audio_player, "volume_db", -80.0, duration)
	tween.set_trans(Tween.TransitionType.TRANS_LINEAR).set_ease(Tween.EaseType.EASE_IN_OUT)
	await tween.finished 
	audio_player.stop()

func fade_in(audio_player: AudioStreamPlayer, duration: float):
	audio_player.play()
	audio_player.volume_db = -80.0
	tween.tween_property(audio_player, "volume_db", 0.0, duration)
	tween.set_trans(Tween.TransitionType.TRANS_LINEAR).set_ease(Tween.EaseType.EASE_IN_OUT)
