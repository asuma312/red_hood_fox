extends Node2D
@onready var parent:Node2D = self.get_parent()
const TEMPMAP = preload("res://scenes/tempmap.tscn")
@onready var click_button: AudioStreamPlayer = $start_button/click_button
@onready var music_player: AudioStreamPlayer = $music
var music_fadeout:Tween

func _on_start_button_pressed() -> void:
	var duration = 1
	click_button.play()

	var tween = get_tree().create_tween()
	tween.tween_property(
		music_player,
		"volume_db",
		-30,  
		duration  
	).set_trans(Tween.TransitionType.TRANS_LINEAR).set_ease(Tween.EaseType.EASE_IN_OUT)
	await tween.finished


	var childrens = parent.get_children()
	for children in childrens:
		parent.remove_child(children)

	var map1 = TEMPMAP.instantiate()
	parent.add_child(map1)
