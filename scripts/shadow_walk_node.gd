extends Node2D

var activated:bool = false
var can_teleport:bool = false
var teleport_pos:Vector2
var temp_speed = 900

@onready var parent: CharacterBody2D = $".."
@onready var in_shadow: CollisionShape2D = $range/in_shadow
@onready var of_shadow: CollisionShape2D = $range/of_shadow
@onready var actual_range: CollisionShape2D


@onready var light_source: PointLight2D = $"../../PointLight2D"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var teleport_delay: Timer = $teleport_delay
@onready var auto_path: NavigationAgent2D = $"../auto_path"


func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	setup_range()


func setup_range():
	var in_shadow_bool:bool = parent.in_shadow
	if in_shadow_bool:
		in_shadow.disabled = false
		of_shadow.disabled = true
		actual_range = in_shadow
	elif not in_shadow_bool:
		in_shadow.disabled = true
		of_shadow.disabled = false
		actual_range = of_shadow


func verify_body_in_pos(pos):
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	var space_state = get_world_2d().direct_space_state

	var result = space_state.intersect_point(query)
	return result

func _input(event: InputEvent) -> void:
	if not activated:
		return
	if event is InputEventMouseButton and event.pressed:
		var world_position =get_global_mouse_position()

		if teleport_delay.is_stopped():
			teleport_delay.start()
			teleport_pos = world_position
	return
func verify_body(click_pos: Vector2) -> bool:
	var is_in_range:bool = false
	var is_shadow:bool = false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = click_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	# Access the parent Area2D
	var parent_area = actual_range.get_parent()
	if not parent_area is Area2D:
		return false
	query.collision_mask = parent_area.collision_layer
	var results = space_state.intersect_point(query)
	for result in results:
		if result.collider == parent_area:
			is_in_range = true
		if result.collider.is_in_group("shadow"):
			is_shadow = true
		if is_in_range and is_shadow:
			break
	if is_in_range and is_shadow:
		return true
	return false
		
func teleport_to_area():
	if not verify_body(teleport_pos):
		return
	parent.player_state = 'shadow_walk'
	parent.skill_info.target_position = teleport_pos
	parent.skill_info.temp_speed = temp_speed


func _on_teleport_delay_timeout() -> void:
	teleport_to_area()
