extends CharacterBody2D

@export var tile_map_layer:TileMapLayer
@export var perma_player:CharacterBody2D
@export var speed:int = 95
@export var mov_value:float = 0.1
@export var torch_intensity:int = 20
@export var found_phrase:String = "FOUND YOU LITTLE RAT!"
var awareness_level:int = 0


var last_index_movement_index = 0
var actual_move
var direction:Vector2 = Vector2.ZERO
var initial_position:Vector2
var last_position_sight_player:Vector2



var enemy_state
var vectors = {
	"up": Vector2(0, -1),
	"right": Vector2(1, 0),
	"down": Vector2(0, 1),
	"left": Vector2(-1, 0)
}

var stop_chase:bool = false
var is_player_in_vision:bool = false
@onready var light_collision: Area2D = $torch/light/light_collision

@onready var animated_sprite_2d: AnimatedSprite2D = $animation


@onready var fovs: Node2D = $fovs
@onready var current_fovs: Array[CollisionPolygon2D]
@onready var fov_player_vision: Polygon2D = $fovs/fov_vision

@onready var fov_range_big: CollisionPolygon2D = $fovs/fov_range_big/collision_body
@onready var fov_range_medium: CollisionPolygon2D = $fovs/fov_range_medium/collision_body
@onready var fov_range_small: CollisionPolygon2D = $fovs/fov_range_small/collision_body
@onready var fov: Area2D = $fovs/fov_range_big

@onready var fov_polyon_checkers_big: Node2D = $fovs/fov_polyon_checkers_big
@onready var fov_polyon_checkers_small: Node2D = $fovs/fov_polyon_checkers_small
@onready var fov_polyon_checkers:Node2D = fov_polyon_checkers_big



@onready var player_finder: RayCast2D = $navigation/player_finder
@onready var player:CharacterBody2D
@onready var navigation_agent_2d: NavigationAgent2D = $navigation/NavigationAgent2D
@onready var light_source_finder: RayCast2D = $navigation/light_source_finder

@onready var sight_timer: Timer = $timers/sight_timer
@onready var move_timer: Timer = $timers/move_timer
@onready var searching_timer: Timer = $timers/searching_timer
@onready var look_timer: Timer = $timers/look_timer
@onready var attack_timer: Timer = $timers/attack_timer
@onready var player_detection_timer: Timer = $timers/player_detection_timer

signal chasing
signal stop_chasing


@onready var shadow_animation: AnimatedSprite2D = $shadow_checker/shadow
@onready var shadow_collision: CollisionShape2D = $shadow_checker/shadow_collision
@onready var shadow_checker: Area2D = $shadow_checker

var in_shadow:bool = true
var can_move:bool = true
@export_enum("left", "right", "up", "down") var move_sequence: Array[String]
var last_move = "up"
		
func _ready() -> void:
	initial_position = global_position
	actual_move = last_move
	idle_movement_processor()

func _process(delta: float) -> void:
	player_finder.target_position = to_local(perma_player.global_position)
	if not GlobalScript.verify_distance_to_the_player(self):
		return
	_state_manager()
	anim_verifier(direction)
	_rotate_fov_to_dir(direction)
	setup_target_ray()
	light_verifier()
	deal_damage()
	
	
func _physics_process(delta: float) -> void:
	pass
	

		
func _state_manager():
	if not can_move:
		return
	if enemy_state == 'chasing':
		move_timer.stop()
		animated_sprite_2d.speed_scale = 2
		player.chasing_level += 1
		chasing.emit()
		chase_player()
		
	elif enemy_state == 'chasing_ghost':
		move_timer.stop()
		animated_sprite_2d.speed_scale = 1
		chase_ghost()
	
	elif enemy_state == 'returning':
		player.chasing_level -= 1
		stop_chasing.emit()
		return_to_init()
	
	elif enemy_state == 'searching':
		animated_sprite_2d.play("idle_side")
		search()
	elif enemy_state == 'look' or enemy_state == 'look_reverse':
		look_around()

	elif enemy_state == 'waiting_to_run':
		pass
	
	elif enemy_state == 'idle':
		pass
	
	elif enemy_state == 'walking':
		animated_sprite_2d.speed_scale = 0.5
	

func change_state(state:String):
	enemy_state = state
	
func fov_polygons():
	'''
	this is the function to change the side of the cone of vision of the enemy
	**THIS IS NOT THE CONE OF VISION OF THE ENEMY, JUST THE VISUALISATION FOR THE PLAYER ON THE "fov_vision" NODE**
	'''
	var array_vector = []
	array_vector.append(Vector2(0,0))
	var polygon_checkers:Array = fov_polyon_checkers.get_children()
	for polygon:RayCast2D in polygon_checkers:
		var _position
		if not polygon.is_colliding():
			_position = polygon.target_position
			array_vector.append(_position)
		else:
			_position = polygon.get_collision_point()
			_position = polygon.to_local(_position)
			array_vector.append(_position)
	
	array_vector.append(Vector2(0,0))
	fov_player_vision.polygon = array_vector

func in_shadow_fov():
	fov_range_small.disabled = false
	fov_range_big.disabled = true
	fov_range_medium.disabled = true
	current_fovs = [fov_range_small]
	fov_polyon_checkers = fov_polyon_checkers_small
	
func outside_shadow_fov():
	fov_range_big.disabled = false
	fov_range_medium.disabled = false
	fov_range_small.disabled = false
	#the biggest FOV should always be on the first index
	current_fovs = [fov_range_big,fov_range_medium,fov_range_small]
	fov_polyon_checkers = fov_polyon_checkers_big

func light_verifier():	
	'''
	this verify if any of the bodys is light, if it is then change
	the in_shadow var
	'''
	fov_polygons()
	for area in shadow_checker.get_overlapping_areas():
		if not area.is_in_group("light"):
			continue
		in_shadow = false
		return
	in_shadow = true
	
func change_state_others():
	"this just checks if its in shadow and changes the things visible to the player"
	if in_shadow:
		shadow_checker.visible = true
		in_shadow_fov()
	if not in_shadow:
		shadow_checker.visible = false
		outside_shadow_fov()
	#gets the biggest FOV
	fov = current_fovs[0].get_parent()

				
func _rotate_fov_to_dir(direction:Vector2):
	'''
	this just rotates the fov to be in the direction that the enemy is looking
	'''
	if direction.length() > 0:
		direction = direction.normalized()
		var angle = direction.angle()
		fovs.rotation = angle
	else:
		print("Erro: vetor de direção inválido")



func deal_damage():
	'''
	this is the damage function
	'''
	if get_slide_collision_count()>0:
		for collide in range(get_slide_collision_count()):
			var body_collided = get_slide_collision(collide).get_collider()
			if body_collided is CharacterBody2D:
				if body_collided.name == 'basechar' and attack_timer.is_stopped():
					body_collided.take_damage(global_position)
					attack_timer.start(0.5)

	


		

func idle_movement_processor():
	"""
	the movemennt before finding a player, so the base movement
	"""	
	var next_index = (int(last_index_movement_index) + 1) % move_sequence.size()

	actual_move = move_sequence[next_index]
	last_move = actual_move
	direction = vectors[actual_move]
	last_index_movement_index += mov_value



func _on_move_timer_timeout() -> void:
	"""
	this is the timer that the enemy is walking
	"""
	change_state("walking")
	idle_movement_processor()
	velocity = direction * speed
	move_and_slide()
	
func anim_verifier(dir: Vector2) -> void:
	if enemy_state in ['walking', 'chasing', 'chasing_ghost']:
		return walk_anim(dir)
	
	elif enemy_state == 'idle':
		return animated_sprite_2d.play("idle_down")


		
func walk_anim(dir):
	"""responsible to walk animation itself, the enemy has lot more stats than the player so only he needs this abstraction for now"""
	if not animated_sprite_2d.animation_finished:
		return

	match dir:
		Vector2.UP:
			animated_sprite_2d.play("walk_up")

		Vector2.DOWN:
			animated_sprite_2d.play("walk_down")

		Vector2.RIGHT:
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("walk_side")

		Vector2.LEFT:
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("walk_side")

		_:
			#this is the chasing animation
			if dir.x != 0:
				animated_sprite_2d.flip_h = dir.x < 0
				if enemy_state in ['chasing','chasing_ghost']:
					animated_sprite_2d.play("run_side")
					return
				animated_sprite_2d.play("walk_side")
			elif dir.y > 0:
				if enemy_state in ['chasing','chasing_ghost']:
					animated_sprite_2d.play("run_down")
					return
				animated_sprite_2d.play("walk_down")
			elif dir.y < 0 :
				if enemy_state in ['chasing','chasing_ghost']:
					animated_sprite_2d.play("run_up")
					return
				animated_sprite_2d.play("walk_up")



func change_awareness_level(value:int):
	awareness_level += value

func reset_araweness_level():
	awareness_level = 0


func detect_player() -> void:
	"""
	this function is responsible to detect the player itself
	first it verifies if the player is in the FOV range
	if it is then verify if theres any collision between them
	if not then verifies if hes in shadow and the enemy is not chasing
	if the enemy is chasing or the player isnt in shadow, it continues/starts chasing
	"""
	if is_in_vision():
		if sight_timer.is_stopped() and enemy_state not in ["chasing","chasing_ghost","waiting_to_run"]:
			move_timer.stop()
			change_state("waiting_to_run")
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
	"""
	this setups the target_ray to verifiy if theres any collision between the player and the enemy, it uses the perma_player variable for debugging purposes but we can let it in that way if we want
	"""
	if not perma_player:
		return
	var player_pos = perma_player.global_position


func is_in_vision(search_body=null) -> bool:
	is_player_in_vision = false
	for body in fov.get_overlapping_bodies():
		if body.name == 'basechar':
			if search_body:
				if body != search_body:
					continue
			
			if is_colliding():
				return false
			if body.is_in_shadow() and enemy_state != 'chasing':
				return false
			reset_araweness_level()

			player = body
			#this perma player is just that keeps finding the player
			#for future plans, maybe we use maybe not
			perma_player = player
			var player_distance = player_finder.to_local(player.global_position)
			for temp_fov in current_fovs:
				var parent_area = temp_fov.get_parent()
				if player in parent_area.get_overlapping_bodies():
					change_awareness_level(1)
			is_player_in_vision = true
			return true
	return false
	
func chase_player():
	"""
	if i have enough time i can make it not use the is_in_vision function, but it just make it easier checking if the player is in vision 2 times per frame
	"""
	var player_pos = perma_player.global_position

	
	move_nav_agent(player_pos)
	#if not is_in_vision(player):
	if is_player_in_vision:
		enemy_state = 'chasing_ghost'
		last_position_sight_player = player_pos
		return

func chase_ghost():
	"""
	the chase_player but only works based on the enemy_state on ghost
	"""
	move_nav_agent(last_position_sight_player)
	if not is_colliding() and is_in_vision(player):
		enemy_state = 'chasing'
	if navigation_agent_2d.is_navigation_finished():
		enemy_state = 'searching'

func is_colliding()->bool:
	"""quick function to use less lines"""
	if player_finder.is_colliding() and not player_finder.get_collider().is_in_group("followable"):
		return true
	return false
		

		
		
	
func search():
	"""this and the look_around funcs r the enemise look around"""
	change_state('look')
	if look_timer.is_stopped():
		look_timer.start(0.5)

func look_around():
	if enemy_state == 'look':
		if look_timer.is_stopped():
			change_state('look_reverse')
			look_timer.start(0.5)
	
	if enemy_state == 'look_reverse':
		if look_timer.is_stopped() and searching_timer.is_stopped():
			direction = -direction
			animated_sprite_2d.flip_h = true if not animated_sprite_2d.flip_h else false
			if searching_timer.is_stopped():
				searching_timer.start(1)
				change_state('look_reverse_sleep')



	


func return_to_init():
	"""function to the enemy return to initial position"""
	move_nav_agent(initial_position)
	walk_anim(direction)
	if navigation_agent_2d.is_navigation_finished():
		change_state('walking')
		move_timer.start()

	


func _on_sight_timer_timeout() -> void:
	"""function to the enemy stop verifiy if the player is there and if its not, just starts walking"""
	player = null
	if is_player_in_vision:
		change_state('chasing')
	else:
		#change_state("walking")
		pass


func _on_searching_timer_timeout() -> void:
	change_state('returning')

func _on_player_detection_timer_timeout() -> void:
	if not can_move:
		return
	detect_player()


func _on_light_collision_body_entered(body: Node2D) -> void:
	for _body in light_collision.get_overlapping_bodies():
		print(_body)
