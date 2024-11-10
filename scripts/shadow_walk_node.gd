extends Node2D

var activated:bool = false
var can_teleport:bool = false
var teleport_pos:Vector2
var temp_speed = 700
var current_tween:Tween

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
@onready var shadow_pos_size = shadow_pos.get_rect().size
var angle

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	setup_range()
	setup_shadow_pos()

func setup_shadow_pos():
	shadow_pos.position = shadow_verifier.target_position - (shadow_pos_size / 2)

func setup_range():
	var in_shadow_bool:bool = parent.in_shadow
	if in_shadow_bool:
		actual_range = in_shadow
		shadow_verifier = shadow_verifier_big
	elif not in_shadow_bool:
		actual_range = of_shadow
		shadow_verifier = shadow_verifier_small
		
func verify_shadow_teleport():

	
	var pos = shadow_verifier.to_global(shadow_verifier.target_position)
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result = space_state.intersect_point(query)

	for item in result:
		var collider = item.collider
		if collider.is_in_group("light"):
			return false
	return true


func _input(event: InputEvent) -> void:
	if not activated:
		return
	if event.is_action_pressed("do_action"):
		if shadow_verifier.is_colliding():
			shadow_pos.position = to_local(shadow_verifier.get_collision_point()) - (shadow_pos_size / 2)
		if not shadow_pos.visible:
			return
		
		var center_local = shadow_pos.position + (shadow_pos.size / 2)
		
		var world_position = to_global(center_local)
		if teleport_delay.is_stopped():
			teleport_delay.start()
			teleport_pos = world_position
		return
	

func teleport_to_area():
	if not verify_shadow_teleport():
		return
	parent.player_state = 'shadow_walk'
	parent.skill_info.target_position = teleport_pos
	parent.skill_info.temp_speed = temp_speed


func _on_teleport_delay_timeout() -> void:
	teleport_to_area()
