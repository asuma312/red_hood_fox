extends NavigationRegion2D

@onready var ground: Node2D = $ground
const TILESET = preload("res://objects/tileset.tscn")
const ROW_TILESET = preload("res://objects/row_tileset.tscn")
func _ready():
	pass

func create_map():
	var nav_bounds = get_navigation_region_bounds()
	var nav_position = nav_bounds.position
	var nav_size = nav_bounds.size

	var tile_scene = ROW_TILESET
	var tile_size = get_tile_size(tile_scene) / 20
	if tile_size == Vector2.ZERO:
		push_error("Tile size is zero. Check tile setup.")
		return

	var tiles_x = int(ceil(nav_size.x / tile_size.x))
	var tiles_y = int(ceil(nav_size.y / tile_size.y))

	for x in range(tiles_x):
		for y in range(tiles_y):
			var tile_instance = tile_scene.instantiate()
			ground.add_child(tile_instance)
			var tile_position = nav_position + Vector2(x * tile_size.x, y * tile_size.y)
			tile_instance.global_position = tile_position

func get_navigation_region_bounds():
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF

	if navigation_polygon:
		var vertices = navigation_polygon.vertices
		for polygon in navigation_polygon.polygons:
			for vertex_index in polygon:
				var vertex = vertices[vertex_index]
				var global_vertex = to_global(vertex)
				min_x = min(min_x, global_vertex.x)
				min_y = min(min_y, global_vertex.y)
				max_x = max(max_x, global_vertex.x)
				max_y = max(max_y, global_vertex.y)
		var position = Vector2(min_x, min_y)
		var size = Vector2(max_x - min_x, max_y - min_y)
		return Rect2(position, size)
	else:
		push_error("NavigationPolygon not found in NavigationRegion2D")
		return Rect2()

func get_tile_size(tile_scene):
	var tile_instance = tile_scene.instantiate()
	var sprite = tile_instance.get_node("tileset/black/blacktileset")  # Adjust the path if necessary
	if sprite and sprite.texture:
		var texture_size = sprite.texture.get_size()
		var scaled_size = texture_size * sprite.scale
		tile_instance.queue_free()  # Clean up the instance
		return scaled_size
	else:
		push_error("Sprite2D or its texture not found in tile scene")
		tile_instance.queue_free()
		return Vector2.ZERO
