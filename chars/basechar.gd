extends CharacterBody2D

@export var speed:int = 100
@export var knockback_strenght:int = 50
@export var start_life:int = 3

var player_state = 'idle'
var direction
var last_direction

var in_shadow:bool = true
var is_cheat_text_reset:bool = false
var can_write:bool = true

var skill_info:Dictionary = {}
var old_collisions:Array = []


var prefix:String
var sufix:String

@onready var white_sprite: AnimatedSprite2D = $white_sprite


@onready var shadow_animation: AnimatedSprite2D = $shadow_checker/shadow
@onready var shadow_collision: CollisionShape2D = $shadow_checker/shadow_collision
@onready var shadow_checker: Area2D = $shadow_checker

@onready var ui: CanvasLayer = $Camera2D/UI
@onready var black_blur:ColorRect = $"Camera2D/UI/black_blur"



@onready var cheat_code: RichTextLabel = $cheat_code
@onready var auto_path: NavigationAgent2D = $auto_path
@onready var shadow_walk_node: Node2D = $rotators/shadow_walk_node
@onready var cheat_node
@onready var codes ={
	"sh4d0":shadow_walk_node
}

	
func _ready() -> void:
	GlobalScript.actual_life= start_life
	add_to_group("followable")

func _process(delta: float) -> void:
	change_others()
	player_anim_verifier()
	state_manager()
	light_verifier()


func _physics_process(delta: float) -> void:
	'''
	physics_process should only work when player has the command
	'''
	if player_state == 'shadow_walk':
		return
	
	direction = Input.get_vector("leftarrow","rightarrow","uparrow","downarrow")
	
	if player_state in ["idle","walking"] and direction != Vector2(0,0):
		if direction.x != 0 or direction.y != 0:
			player_state = "walking"
		
		velocity = direction*speed
		rotate_necessary(direction)
		move_and_slide()
		last_direction = direction
	elif direction == Vector2(0,0):
		player_state = 'idle'

	
	
	
func state_manager():
	if player_state == "shadow_walk":
		shadow_walk()

func change_others():
	"this just checks if its in shadow and changes the things visible to the player"
	if in_shadow:
		prefix = "black"
	if not in_shadow:
		prefix = 'white'

func is_in_shadow()->bool:
	return in_shadow

func move_nav_agent(pos,temp_speed=null):
	'''
	this move_nav_agent is specifically for the shadow_walk
	it works using nav_agent
	'''
	if not temp_speed:
		temp_speed = speed
	var curr_position = global_position
	auto_path.set_target_position(pos)
	var next_path_position = auto_path.get_next_path_position()
	var distance = curr_position.distance_to(next_path_position)
	direction = curr_position.direction_to(next_path_position)

	velocity = curr_position.direction_to(next_path_position) * temp_speed
	
	move_and_slide()
	
func rotate_necessary(dir):
	var rotators: Node2D = $rotators
	var angle = dir.angle()
	rotators.rotation = angle
	
func shadow_walk():
	'''
	the shadow walk removes collision but the nav agent itself 
	moves around the objects, is just for making sure the player doesnt
	get stuck
	'''
	var pos = skill_info.target_position
	var temp_speed = skill_info.temp_speed
	if old_collisions.size() == 0:
		old_collisions = [self.collision_layer,self.collision_mask]
	collision_layer = 0
	collision_mask = 0
	move_nav_agent(pos,temp_speed)
	if auto_path.is_navigation_finished():
		player_state = 'idle'
		collision_layer = old_collisions[0]
		collision_mask = old_collisions[1]
		old_collisions = []		
		return
	

func write_cheat_codes(event):
	'''
	this is for writing the cheatcodeds
	the can_write will be bool if for some reason
	the player cant write anything in the cheatcodes
	
	'''
	if not can_write:
		return
	
	if event.unicode == 0 and not event.keycode  == KEY_BACKSPACE and not event.keycode == KEY_DELETE:
		return
		
	if event.keycode  == KEY_BACKSPACE or event.keycode == KEY_DELETE:
		if cheat_code.text.length() > 0:
			cheat_code.text = cheat_code.text.substr(0, cheat_code.text.length() - 1)
		return
	
	if len(cheat_code.text) >= 5:
		reset_cheat_code()

	var text = char(event.unicode)
	
	
	cheat_code.text += text

	cheat_code.custom_minimum_size = Vector2(cheat_code.get_content_width(), cheat_code.get_content_height())
	
	if len(cheat_code.text) == 5:
		var text_cheat_code = detect_code(cheat_code.text)
		cheat_code.text = text_cheat_code
		


func reset_cheat_code():
	cheat_code.text = ''
	can_write = true


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed==true:
		if event.is_action("startwriting"):
			reset_cheat_code()
			return
		write_cheat_codes(event)

func detect_code(text):
	if not codes.get(text):
		return "WRONG CODE"
	else:
		can_write = false
		cheat_node = codes.get(text)
		cheat_node.visible = true
		cheat_node.activated = true
		return text


func player_anim_verifier():
	'''
	this is just a func to verify the animations based on the states
	'''
	match player_state:
		'walking':
			match direction:
				Vector2.UP:
					sufix = "up"
				Vector2.DOWN:
					sufix = "down"
				Vector2.RIGHT:
					sufix = "side"
					white_sprite.flip_h = false
				Vector2.LEFT:
					sufix = "side"
					white_sprite.flip_h = true
		'idle':
			sufix = "down"
	var full_animation:String = prefix+"_"+player_state+"_"+sufix
	if "shadow_walk" in full_animation:
		return
	white_sprite.play(full_animation)
	
	
func light_verifier():
	'''
	this verify if any of the bodys is light, if it is then change
	the in_shadow var
	'''
	for area in shadow_checker.get_overlapping_areas():
		if not area.is_in_group("light"):
			return
		in_shadow = false
		return

	in_shadow = true
	




func take_damage(dir_damage):

	var knockback_direction = -self.global_position.direction_to(dir_damage)

	self.global_position += knockback_direction * knockback_strenght
	ui.lost_health()
