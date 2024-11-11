extends Sprite2D


@onready var torch_light: PointLight2D = $light
@onready var light_collision: Area2D = $light/light_collision


func _ready() -> void:
	setup_torch_range()
	light_collision.add_to_group("light")


func _process(delta: float) -> void:
	pass


func setup_torch_range():
	"""
	this create the torch radius, is a light2d for now but prob will change to something else in the future
	"""
	var base_light_multiplier = self.get_parent().torch_intensity
	torch_light.texture_scale = base_light_multiplier * GlobalScript.base_light_value
	
	if torch_light.texture:
		var base_radius = torch_light.texture.get_size().x / 2
		var scaled_radius = base_radius * (base_light_multiplier * GlobalScript.base_light_value)
		
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = scaled_radius
		
		collision_shape.shape = circle_shape
		torch_light.get_node("light_collision").add_child(collision_shape)
