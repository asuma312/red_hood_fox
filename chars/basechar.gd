extends CharacterBody2D

var speed = 100
var player_state
var direction
var last_direction
var in_shadow:bool = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var light_source: PointLight2D = $"../PointLight2D"
@onready var light_source_finder: RayCast2D = $light_source_finder

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("leftarrow","rightarrow","uparrow","downarrow")
	if direction.x ==0 and direction.y == 0:
		player_state = "idle"
	if direction.x != 0 or direction.y != 0:
		player_state = "walking"
	
	velocity = direction*speed
	move_and_slide()
	last_direction = direction
	light_verifier()
	
func is_in_shadow()->bool:
	return in_shadow
	
func _ready() -> void:
	add_to_group("followable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_anim_verifier()


func player_anim_verifier():
	
	if player_state == 'walking':
		
		if direction.y == -1:
			animated_sprite_2d.play("walk_up")
		if direction.y == 1:
			animated_sprite_2d.play("walk_down")
		if direction.x == 1:
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("walk_side")
		if direction.x == -1:
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("walk_side")

	elif player_state == 'idle':
		if not last_direction:
			animated_sprite_2d.play("idle_down")
			
func light_verifier():
	var light_pos = light_source.global_position
	light_source_finder.target_position = to_local(light_pos)
	if light_source_finder.is_colliding():
		in_shadow = true
	else:
		in_shadow = false
