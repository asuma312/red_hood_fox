extends Node2D
@onready var parent:Node2D = self.get_parent()
@onready var music_player: AudioStreamPlayer = $music
@onready var base_menu: Node2D = $MENUS/BASE_MENU
@onready var configs_menu: Node2D = $MENUS/CONFIGS_MENU
@onready var ingame_menu: Node2D = $MENUS/INGAME_MENU
@onready var menus: Node2D = $MENUS
var old_menu
@onready var click_button: AudioStreamPlayer = $click_button
@onready var hover_button: AudioStreamPlayer = $hover_button


var music_fadeout:Tween
const _1 = preload("res://scenes/levels/1.tscn")

func _ready() -> void:
	parent.mainmenu_node = self

func play_sound() -> void:
	var duration = 1
	click_button.play()

	var tween = create_tween()
	tween.tween_property(
		music_player,
		"volume_db",
		-30,  
		duration  
	).set_trans(Tween.TransitionType.TRANS_LINEAR).set_ease(Tween.EaseType.EASE_IN_OUT)
	
	await tween.finished

func _on_start_button_pressed() -> void:
	await play_sound()
	reset_menus()

	var childrens = parent.get_children()
	for children in childrens:
		parent.remove_child(children)

	var map1 = _1.instantiate()
	parent.add_child(map1)
func reset_menus():
	for menu in menus.get_children():
		menu.visible = false

func _on_edit_configs_pressed() -> void:
	for menu in [base_menu,ingame_menu]:
		if menu.visible:
			old_menu = menu
			break
	reset_menus()

	configs_menu.visible = true


func _on_back_button_pressed() -> void:
	reset_menus()
	old_menu.visible = true
	old_menu = null


func _on_resume_button_pressed() -> void:
	reset_menus()
	parent.restore_children()
