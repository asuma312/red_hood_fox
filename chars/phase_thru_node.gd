extends Node2D
var activated:bool = false
var running:bool = false
@onready var basechar: CharacterBody2D = $"../.."
var old_collision_masks = {}

func _process(delta: float) -> void:
	if not activated and running:
		reset_all()
		return
	if not activated:
		return
	if running:
		return
	set_collision_to_layer_3()
	running = true

func save_collision_masks():
	old_collision_masks["collision_layer"] = basechar.collision_layer
	old_collision_masks["collision_mask"] = basechar.collision_mask
	old_collision_masks["modulate"] = basechar.modulate

func reset_collision_masks():
	if "collision_layer" in old_collision_masks and "collision_mask" in old_collision_masks:
		basechar.collision_layer = old_collision_masks["collision_layer"]
		basechar.collision_mask = old_collision_masks["collision_mask"]
		basechar.modulate = old_collision_masks["modulate"]

func set_collision_to_layer_3():
	save_collision_masks()
	#basechar.collision_layer = 1 << 2
	basechar.collision_mask = 1 << 2
	basechar.modulate.a = 0.5

func reset_all():
	reset_collision_masks()
	basechar.modulate.a = 1.0
	running = false
