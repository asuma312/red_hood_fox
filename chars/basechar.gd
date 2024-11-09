extends CharacterBody2D

var speed = 100
var player_state = 'idle'
var direction
var last_direction

var in_shadow:bool = true
var is_writing:bool = true
var is_cheat_text_reset:bool = false
var can_write:bool = true

var skill_info:Dictionary = {}

@onready var white_sprite: AnimatedSprite2D = $white_sprite
@onready var black_sprite: AnimatedSprite2D = $black_sprite
@onready var current_sprite:AnimatedSprite2D = $white_sprite

@onready var ui: CanvasLayer = $Camera2D/UI


@onready var shadow_animation: AnimatedSprite2D = $shadow_checker/shadow
@onready var shadow_collision: CollisionPolygon2D = $shadow_checker/shadow_collision
@onready var shadow_checker: Area2D = $shadow_checker

@onready var light_source: PointLight2D = $"../lightsources/PointLight2D"
@onready var light_source_finder: RayCast2D = $light_source_finder
@onready var cheat_code: RichTextLabel = $cheat_code
@onready var auto_path: NavigationAgent2D = $auto_path

@onready var shadow_walk_node: Node2D = $shadow_walk_node

@onready var cheat_node
@onready var codes ={
	"sh4d0":shadow_walk_node
}

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("leftarrow","rightarrow","uparrow","downarrow")
	
	if player_state in ["idle","walking"] and direction != Vector2(0,0):
		if direction.x != 0 or direction.y != 0:
			player_state = "walking"
		
		velocity = direction*speed
		move_and_slide()
		last_direction = direction
	elif player_state == "shadow_walk":
		shadow_walk()
	elif direction == Vector2(0,0):
		player_state = 'idle'
		
	
	light_verifier()
	
func is_in_shadow()->bool:
	return in_shadow
	
func _ready() -> void:
	GlobalScript.actual_life= 3
	add_to_group("followable")


func _process(delta: float) -> void:
	if direction:
		if direction.x == 0 or direction.y == 0:
			player_state == 'idle'
	player_anim_verifier()



	
func shadow_walk():
	print("moving")
	var pos = skill_info.target_position
	var temp_speed = skill_info.temp_speed
	move_nav_agent(pos,temp_speed)
	if auto_path.is_navigation_finished():
		player_state = 'idle'
		return
	
func move_nav_agent(pos,temp_speed=null):
	if not temp_speed:
		temp_speed = speed
	var curr_position = global_position
	auto_path.set_target_position(pos)
	var next_path_position = auto_path.get_next_path_position()
	var distance = curr_position.distance_to(next_path_position)
	direction = curr_position.direction_to(next_path_position)

	velocity = curr_position.direction_to(next_path_position) * temp_speed
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed==true:
		cheat_code.visible = is_writing
		if event.is_action("startwriting"):
			is_writing = true
			is_cheat_text_reset = true
			cheat_code.text = 'Insert a code'
			if cheat_node:
				cheat_node.visible = false
				cheat_node.activated = false
				can_write = true
				cheat_node = null
				return _input(event)
			return
		
		if is_writing and can_write:
			if event.unicode == 0 and not event.keycode  == KEY_BACKSPACE and not event.keycode == KEY_DELETE:
				return
			
			if is_cheat_text_reset:
				cheat_code.text = ''
				is_cheat_text_reset = false
				
			if event.keycode  == KEY_BACKSPACE or event.keycode == KEY_DELETE:
				if cheat_code.text.length() > 0:
					cheat_code.text = cheat_code.text.substr(0, cheat_code.text.length() - 1)
				return
			

			var text = char(event.unicode)
			
			
			cheat_code.text += text
		
			cheat_code.custom_minimum_size = Vector2(cheat_code.get_content_width(), cheat_code.get_content_height())
			
			if len(cheat_code.text) == 5:
				cheat_code.text = detect_code(cheat_code.text)
				is_cheat_text_reset = true

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
	
	if player_state == 'walking':
		if direction.y == -1:
			current_sprite.play("walk_up")
			shadow_animation.play("walk_up")
		if direction.y == 1:
			current_sprite.play("walk_down")
			shadow_animation.play('walk_down')
		if direction.x == 1:
			current_sprite.flip_h = false
			current_sprite.play("walk_side")
			shadow_animation.play('walk_side')
			shadow_animation.flip_h = false
		if direction.x == -1:
			current_sprite.flip_h = true
			current_sprite.play("walk_side")
			shadow_animation.play("walk_side")
			shadow_animation.flip_h = true

	elif player_state == 'idle':
		current_sprite.play("idle_down")
		shadow_animation.play("idle_down")
		
func light_verifier():
	for area in shadow_checker.get_overlapping_areas():
		if not area.is_in_group("shadow"):
			continue
		in_shadow = true
		shadow_checker.visible = false
		return
	in_shadow = false
	shadow_checker.visible = true


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event)


func take_damage(dir_damage):

	var knockback_direction = -self.global_position.direction_to(dir_damage)
	var knockback_strength = 50

	self.global_position += knockback_direction * knockback_strength
	ui.lost_health()
	
	

	
