extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func reset_tile_map_layer():
	var used_cells = self.get_used_cells()
	for cell in used_cells:
		self.set_cell(cell, 1, Vector2i(39,17))

func _on_reset_timer_timeout() -> void:
	reset_tile_map_layer()
