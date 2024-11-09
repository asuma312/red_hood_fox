extends Node2D

var activated:bool = false
var can_teleport:bool = false
var teleport_pos:Vector2
var temp_speed = 700
var current_tween:Tween
var search_radius: float = 200.0
var search_step: float = 20.0
@onready var parent: CharacterBody2D = $"../.."
@onready var in_shadow: CollisionShape2D = $range/in_shadow
@onready var of_shadow: CollisionShape2D = $range/of_shadow
@onready var actual_range: CollisionShape2D


@onready var light_source: PointLight2D = $"../../PointLight2D"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var teleport_delay: Timer = $teleport_delay
@onready var auto_path: NavigationAgent2D = $"../auto_path"

@onready var shadow_verifier_small: RayCast2D = $navigation/shadow_verifyer_small
@onready var shadow_verifier_big: RayCast2D = $navigation/shadow_verifier_big
@onready var shadow_verifier: RayCast2D = shadow_verifier_big
@onready var shadow_pos: ColorRect = $shadow_pos
var angle

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	setup_range()
	verify_shadow_teleport()


func setup_range():
	var in_shadow_bool:bool = parent.in_shadow
	if in_shadow_bool:
		in_shadow.disabled = false
		of_shadow.disabled = true
		actual_range = in_shadow
		shadow_verifier = shadow_verifier_big
	elif not in_shadow_bool:
		in_shadow.disabled = true
		of_shadow.disabled = false
		actual_range = of_shadow
		shadow_verifier = shadow_verifier_small
		
func verify_shadow_teleport():
	return true
		
		

func verify_body(click_pos: Vector2) -> bool:
	var is_in_range: bool = false
	var is_shadow: bool = false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = click_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
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
	return is_in_range and is_shadow

func verify_body_in_pos(pos):
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	var space_state = get_world_2d().direct_space_state

	var result = space_state.intersect_point(query)
	return result

func _input(event: InputEvent) -> void:
	if not activated:
		return
	if event.is_action_pressed("do_action"):
		if not shadow_pos.visible:
			return
		var world_position =shadow_pos.global_position

		if teleport_delay.is_stopped():
			teleport_delay.start()
			teleport_pos = world_position
	return
	

func teleport_to_area():
	parent.player_state = 'shadow_walk'
	parent.skill_info.target_position = teleport_pos
	parent.skill_info.temp_speed = temp_speed


func _on_teleport_delay_timeout() -> void:
	teleport_to_area()

func find_nearest_shadow(start_pos: Vector2):
	var space_state = get_world_2d().direct_space_state
	for radius in range(0, int(search_radius / search_step)):
		var current_radius = radius * search_step
		var num_samples = 8
		for i in range(num_samples):
			var angle = (2 * PI / num_samples) * i
			var sample_pos = start_pos + Vector2(cos(angle), sin(angle)) * current_radius
			if verify_body(sample_pos):
				return sample_pos
	return null
