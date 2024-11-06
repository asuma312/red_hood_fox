extends CharacterBody2D

var speed = 50
var last_move = "up"
var last_index = 0
var actual_move
var enemy_state
var direction = Vector2.ZERO
var initial_position:Vector2

var vectors = {
	"up": Vector2(0, -1),
	"right": Vector2(1, 0),
	"down": Vector2(0, 1),
	"left": Vector2(-1, 0)
}

var last_position:Vector2
var stop_chase:bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_timer: Timer = $move_timer
@onready var fov: Area2D = $fov
@onready var player_finder: RayCast2D = $player_finder
@onready var player:CharacterBody2D
@onready var hiding_timer: Timer = $hiding_timer
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

var move_sequence: Array = [
	"up", "up", "up", "up", "up", "up", "up", "up", "up", "up",
	"right", "right", "right", "right", "right", "right", "right", "right", "right", "right", 
	"down", "down", "down", "down", "down", "down", "down", "down", "down", "down",  
	"left", "left", "left", "left", "left", "left", "left", "left", "left", "left"
]


func _ready() -> void:
	initial_position = global_position
	actual_move = last_move
	_movement_processor()

func _process(delta: float) -> void:
	player_anim_verifier(direction)
	detect_player()
	setup_target_ray()
	
	if navigation_agent_2d.is_navigation_finished() and stop_chase:
		print("returning to initial position")
		stop_chase = false
		enemy_state = 'returning'

	if enemy_state == 'chasing':
		move_timer.stop()
		chase_player()
		
	if enemy_state == 'chasing_ghost':
		move_timer.stop()
		chase_ghost()
	
	if enemy_state == 'returning':
		return_to_init()

	


		

func _movement_processor():
	var next_index = (last_index + 1) % move_sequence.size()

	actual_move = move_sequence[next_index]
	last_move = actual_move
	direction = vectors[actual_move]
	last_index +=1


func _on_move_timer_timeout() -> void:
	enemy_state = 'walking'
	_movement_processor()
	player_anim_verifier(direction)
	velocity = direction * speed
	move_and_slide()
	
func player_anim_verifier(dir: Vector2) -> void:
	if enemy_state in ['walking', 'chasing', 'chasing_ghost']:
		if not animated_sprite_2d.animation_finished:
			return

		if dir.x != 0 and dir.y != 0:
			if dir.x > 0:
				animated_sprite_2d.flip_h = false
			else:
				animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("walk_side")

		elif dir.y < 0:
			animated_sprite_2d.play("walk_up")

		elif dir.y > 0:
			animated_sprite_2d.play("walk_down")

		elif dir.x > 0:
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("walk_side")

		elif dir.x < 0:
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("walk_side")

	elif enemy_state == 'idle':
		animated_sprite_2d.play("idle_down")
		

func detect_player() -> void:
	for body in fov.get_overlapping_bodies():
		if body.is_in_group("followable"):
			if is_colliding():
				return
			if body.is_in_shadow():
				return 
			if not body.is_in_shadow():
				player = body
				enemy_state = 'chasing'
				return 
	return 

func move_nav_agent(pos):
	var curr_position = global_position
	navigation_agent_2d.set_target_position(pos)
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var distance = curr_position.distance_to(next_path_position)
	direction = curr_position.direction_to(next_path_position)

	velocity = curr_position.direction_to(next_path_position) * speed
	
	move_and_slide()

func setup_target_ray():
	if not player:
		return
	var player_pos = player.global_position
	player_finder.target_position = to_local(player_pos)


func chase_player():
	var player_pos = player.global_position
	
	move_nav_agent(player_pos)
	
	if is_colliding():
		if hiding_timer.is_stopped():
			hiding_timer.start()
		enemy_state = 'chasing_ghost'
		last_position = player_pos
	else:
		hiding_timer.stop()
		
func is_colliding()->bool:
	if player_finder.is_colliding() and not player_finder.get_collider().is_in_group("followable"):
		return true
	return false
		
func chase_ghost():
	move_nav_agent(last_position)
	if not is_colliding():
		enemy_state = 'chasing'
		hiding_timer.stop()
		
		
	
	
	
func return_to_init():
	move_nav_agent(initial_position)
	
	if navigation_agent_2d.is_navigation_finished():
		enemy_state = 'walking'
	

func _on_hiding_timer_timeout() -> void:
	stop_chase = true
