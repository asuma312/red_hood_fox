extends Node

@export var from_center:bool = true
@export var hover_scale:Vector2 = Vector2(1,1)
@export var time:float = 0.1
@export var transition_type:Tween.TransitionType
@onready var hover_button: AudioStreamPlayer = $"../hover_button"


var target: Control
var default_scale : Vector2


func _ready() -> void:
	target = get_parent()
	connect_sig()
	call_deferred("setup")
	
	
func connect_sig() -> void:
	target.mouse_entered.connect(on_hover)
	target.mouse_exited.connect(off_hover)
	

func setup()->void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func on_hover() -> void:
	add_tween("scale",hover_scale,time)
	hover_button.play()
	

func off_hover()->void:
	add_tween("scale", default_scale, time)

func add_tween(property:String, value, seconds: float) -> void:
	if not get_tree():
		return
	var tween = get_tree().create_tween()	
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)
