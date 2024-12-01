extends Node

@export var from_center: bool = true
@export var hover_scale: Vector2 = Vector2(1, 1)
@export var time: float = 0.1
@export var transition_type: Tween.TransitionType
@onready var hover_button: AudioStreamPlayer = $"../../../../hover_button"

var target: Control
var default_scale: Vector2

func _ready() -> void:
	target = get_parent()
	connect_sig()
	call_deferred("setup")

func connect_sig() -> void:
	target.mouse_entered.connect(on_hover)
	target.mouse_exited.connect(off_hover)

func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func on_hover() -> void:
	add_tween("scale", hover_scale, time)
	hover_button.play()

func off_hover() -> void:
	add_tween("scale", default_scale, time)

func add_tween(property: String, value, seconds: float) -> void:
	if not get_tree():
		return
	var tween = get_tree().create_tween()
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)

# Function to handle fade in
func fade_in() -> void:
	target.modulate = Color(1, 1, 1, 0)  # Set fully transparent
	var tween = get_tree().create_tween()
	tween.tween_property(target, "modulate:a", 1, time).set_trans(transition_type)

# Function to handle fade out
func fade_out() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(target, "modulate:a", 0, time).set_trans(transition_type)

# Example usage
func change_menu(new_menu: Control) -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(target, "modulate", Color(1, 1, 1, 0), time).set_trans(Tween.TransitionType.TRANS_LINEAR)

	tween.tween_callback(func() -> void:
		set_current_menu(new_menu)
	).after(time)

	tween.tween_property(new_menu, "modulate", Color(1, 1, 1, 1), time).after(time)


func set_current_menu(new_menu: Control) -> void:
	target.visible = false
	target = new_menu
	target.visible = true
	fade_in()
