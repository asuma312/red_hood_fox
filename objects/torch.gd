extends Node2D

@onready var parent = self.get_parent()
@onready var tilemap_range = $tilemap_range
@onready var collision_polygon_2d: CollisionPolygon2D = $torch_range/CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $Polygon2D

#test room modif@onready var tile_map_layer = parent.tile_map_layer
@onready var torch_sprite: AnimatedSprite2D = $torch_sprite

func _ready() -> void:
	torch_sprite.play("fire")

func _process(delta: float) -> void:
	pass




func new_torch_polygons():
	'''
	this is the function to change the side of the cone of vision of the enemy
	for some rason the target_position is a local position but the collision point is global
	**THIS IS NOT THE CONE OF VISION OF THE ENEMY, JUST THE VISUALISATION FOR THE PLAYER ON THE "fov_vision" NODE**
	'''
	
	var array_vector = []
	var global_vector = []
	var polygon_checkers:Array = tilemap_range.get_children()
	for polygon:RayCast2D in polygon_checkers:
		var _position
		var _global_position
		if not polygon.is_colliding():
			_position = polygon.target_position
			_global_position = to_global(_position)
			array_vector.append(_position)
			global_vector.append(_global_position)
		else:
			_position = polygon.get_collision_point()
			_global_position = _position
			_position = polygon.to_local(_position)
			array_vector.append(_position)
			global_vector.append(_global_position)
	collision_polygon_2d.polygon = array_vector
	polygon_2d.polygon = array_vector
	
func paint_polygon_with_terrain(polygon_points):


	for i in range(len(polygon_points)):
		if typeof(polygon_points[i]) != TYPE_VECTOR2:
			polygon_points[i] = Vector2(polygon_points[i][0], polygon_points[i][1])
	var rect = get_bounding_rect(polygon_points)
#test	var tileset = tile_map_layer.tile_set
#test	var tile_size = tileset.tile_size
#test	var start_x = int(floor(rect.position.x / tile_size.x))
#test	var end_x = int(ceil((rect.position.x + rect.size.x) / tile_size.x))
#test	var start_y = int(floor(rect.position.y / tile_size.y))
#test	var end_y = int(ceil((rect.position.y + rect.size.y) / tile_size.y))

#test	var tile_info = get_tile_with_terrain(tileset)
#test	if tile_info == null:
#test		push_error("No tile found with terrain: ")
#test		return
#test	var source_id = tile_info["source_id"]
#test	var atlas_coords = tile_info["atlas_coords"]

#test	for x in range(start_x, end_x):
#test		for y in range(start_y, end_y):
#test			var tile_pos = Vector2i(x, y)
#test			var tile_world_pos = tile_map_layer.map_to_local(tile_pos)
#test			var tile_center = tile_world_pos + Vector2(tile_size) / 2
#test			if Geometry2D.is_point_in_polygon(tile_center, polygon_points):
#test				tile_map_layer.set_cell(tile_pos,source_id,atlas_coords)
				
func get_bounding_rect(points):
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	for point in points:
		if point.x < min_x:
			min_x = point.x
		if point.x > max_x:
			max_x = point.x
		if point.y < min_y:
			min_y = point.y
		if point.y > max_y:
			max_y = point.y
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
	
func get_tile_with_terrain(tileset:TileSet):
	var source_count = tileset.get_source_count()
	for source_index in range(source_count):
		var source_id = tileset.get_source_id(source_index)
		var source = tileset.get_source(source_id)
		if source is TileSetAtlasSource:
			var atlas_source:TileSetAtlasSource = source
			for tile_id in range(atlas_source.get_tiles_count()):
				return {"source_id":source_id,"atlas_coords":Vector2(39,36)}
	return null


#testfunc _on_light_timer_timeout() -> void:
	#testif not parent.can_move:
	#test	return
	#testnew_torch_polygons()
