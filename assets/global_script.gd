extends Node

var actual_life = 3
var max_life = 3

var base_light_value = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func verify_distance_to_the_player(body):
	var distance = body.global_position.distance_to(body.to_global(body.player_finder.target_position))
	if distance > 1500:
		body.can_move = false
		return body.can_move
	body.can_move = true
	return body.can_move
