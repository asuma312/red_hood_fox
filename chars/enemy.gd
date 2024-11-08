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
@onready var fov: Area2D = $fov
@onready var fov_range_big: CollisionShape2D = $fov/fov_range_big
@onready var fov_range_medium: CollisionShape2D = $fov/fov_range_medium
@onready var fov_range_small: CollisionShape2D = $fov/fov_range_small


@onready var current_fov: CollisionShape2D
@onready var player_finder: RayCast2D = $player_finder
@onready var player:CharacterBody2D
@onready var perma_player:CharacterBody2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var cheat_code: RichTextLabel = $cheat_code

@onready var sight_timer: Timer = $sight_timer
@onready var move_timer: Timer = $move_timer
@onready var searching_timer: Timer = $searching_timer
@onready var look_timer: Timer = $look_timer

@onready var light_source: PointLight2D = $"../PointLight2D"
@onready var light_source_finder: RayCast2D = $light_source_finder

var in_shadow:bool = false


var move_sequence: Array = [
	"up", "up", "up", "up", "up", "up", "up", "up", "up", "up",
	"right", "right", "right", "right", "right", "right", "right", "right", "right", "right", 
	"down", "down", "down", "down", "down", "down", "down", "down", "down", "down",  
	"left", "left", "left", "left", "left", "left", "left", "left", "left", "left"
]


func light_verifier():
	var light_pos = light_source.global_position
	light_source_finder.target_position = to_local(light_pos)
	if light_source_finder.is_colliding():
		in_shadow = true
		fov_range_small.disabled = false
		
		fov_range_big.disabled = true
		fov_range_medium.disabled = true
		current_fov = fov_range_small
		
	else:
		in_shadow = false
		fov_range_big.disabled = false
		fov_range_medium.disabled = false

		fov_range_small.disabled = true
		current_fov = fov_range_big
		
		
func _rotate_fov_to_dir(direction:Vector2):
	if not direction:
		return
	if direction.length() > 0:
		direction = direction.normalized()

		var angle = direction.angle()

		fov.rotation = angle
	else:
		print("Erro: vetor de direção inválido")

		
func _ready() -> void:
	initial_position = global_position
	actual_move = last_move
	_movement_processor()

func _process(delta: float) -> void:
	player_anim_verifier(direction)
	_rotate_fov_to_dir(direction)
	detect_player()
	setup_target_ray()
	light_verifier()
	



	if enemy_state == 'chasing':
		move_timer.stop()
		chase_player()
		
	elif enemy_state == 'chasing_ghost':
		move_timer.stop()
		chase_ghost()
	
	elif enemy_state == 'returning':
		return_to_init()
	
	elif enemy_state == 'searching':
		search()
	elif enemy_state == 'look' or enemy_state == 'look_reverse':
		look_around()


	


		

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
				
			if body.is_in_shadow() and enemy_state == 'walking':
				return 
				
			player = body
			perma_player = player
			if sight_timer.is_stopped() and enemy_state not in ["chasing","chasing_ghost","waiting_to_run"]:
				move_timer.stop()
				enemy_state = 'waiting_to_run'
				sight_timer.start()
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
	if not perma_player:
		return
	var player_pos = perma_player.global_position
	player_finder.target_position = to_local(player_pos)


func is_in_vision(search_body):
	for body in fov.get_overlapping_bodies():
		if body != search_body:
			continue
		print("***__***")
		print(search_body.global_position)
		print(body)
		if body.is_in_group("followable"):
			return true
	return false
func chase_player():
	var player_pos = player.global_position

	
	move_nav_agent(player_pos)
	if is_colliding():
		enemy_state = 'chasing_ghost'
		last_position = player_pos
		return
	if not is_in_vision(player):
		enemy_state = 'chasing_ghost'
		last_position = player_pos
		print("not in vision")
		return
		
func is_colliding()->bool:
	if player_finder.is_colliding() and not player_finder.get_collider().is_in_group("followable"):
		return true
	return false
		
func chase_ghost():
	move_nav_agent(last_position)
	if not is_colliding() and is_in_vision(player):
		enemy_state = 'chasing'
	if navigation_agent_2d.is_navigation_finished():
		enemy_state = 'searching'
		
		
	
func search():
	enemy_state = 'look'
	if look_timer.is_stopped():
		print("starting look timer")
		look_timer.start(0.5)

func look_around():
	if enemy_state == 'look':
		if look_timer.is_stopped():
			enemy_state = 'look_reverse'
			look_timer.start(0.5)
	
	if enemy_state == 'look_reverse':
		print("look_reverse")
		if look_timer.is_stopped() and searching_timer.is_stopped():
			direction = -direction
			print("look_timer is stoped")
			if searching_timer.is_stopped():
				print("searching_timer is stoped")
				searching_timer.start(1)
				enemy_state = 'look_reverse_sleep'


	


func return_to_init():
	move_nav_agent(initial_position)
	if navigation_agent_2d.is_navigation_finished():
		enemy_state = 'walking'
		move_timer.start()

	


func _on_sight_timer_timeout() -> void:
	player = null
	detect_player()
	print(enemy_state)
	if player:
		enemy_state = 'chasing' 
	else:
		enemy_state = "returning"


func _on_searching_timer_timeout() -> void:
	print("searching_timer_timeout")
	enemy_state = 'returning'
