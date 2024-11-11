extends Area2D
@onready var light_finder: RayCast2D = $light_finder

@onready var black: Node2D = $black
@onready var white: Node2D = $white
var light_level:int = 0
var thread1: Thread

func _ready() -> void:
	self.add_to_group("ground")


func find_obstructed_light(body):
	"""this function verify if theres an collision between this body and the specific body, check the collision layers to make see what it will collide"""
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.new()
	query.from = self.global_position
	query.to = body.global_position
	query.exclude = [self]
	query.collide_with_bodies = true
	query.collide_with_areas = true
	query.collision_mask = 4

	var result = space_state.intersect_ray(query)

	if result:
		return true
	else:
		return false



	
func draw_on_light(body):
	"this just draw the black/white one"

	if find_obstructed_light(body):
		return false
	light_level +=1
	black.visible = true
	white.visible = false
	return true
	
func draw_of_light():
	light_level -= 1
	"this just draw the white/black one"
	if light_level > 0:
		return
	black.visible = false
	white.visible = true
