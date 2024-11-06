extends CharacterBody2D

var speed = 150
var last_move = "up"
var last_index = 0
var actual_move
var enemy_state
var direction = Vector2.ZERO

var vectors = {
	"up": Vector2(0, -1),
	"right": Vector2(1, 0),
	"down": Vector2(0, 1),
	"left": Vector2(-1, 0)
}

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_timer: Timer = $move_timer

var move_sequence: Array = [
	"up", "up", "up", "up", "up", "up", "up", "up", "up", "up",  # 10 steps up
	"right", "right", "right", "right", "right", "right", "right", "right", "right", "right",  # 10 steps right
	"down", "down", "down", "down", "down", "down", "down", "down", "down", "down",  # 10 steps down
	"left", "left", "left", "left", "left", "left", "left", "left", "left", "left"  # 10 steps left
]


func _ready() -> void:
	actual_move = last_move
	_movement_processor()

func _process(delta: float) -> void:
	if enemy_state == 'chasing':
		move_timer.stop()

func _movement_processor():
	var next_index = (last_index + 1) % move_sequence.size()

	actual_move = move_sequence[next_index]
	last_move = actual_move
	direction = vectors[actual_move]
	last_index +=1


func _on_move_timer_timeout() -> void:
	enemy_state = 'walking'
	_movement_processor()
	player_anim_verifier()
	velocity = direction * speed
	move_and_slide()


func player_anim_verifier():
	
	if enemy_state == 'walking':
		
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

	elif enemy_state == 'idle':
		animated_sprite_2d.play("idle_down")
