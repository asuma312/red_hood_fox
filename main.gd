extends Node2D
const WON = preload("res://scenes/won.tscn")
const LOSE = preload("res://scenes/lose.tscn")
const DARK_MAP = preload("res://objects/dark_map.tscn")
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_main_node():
	for node in self.get_children():
		print(node.name)
		self.remove_child(node)

func lose_screen():
	reset_main_node()
	print(self)
	var temp_lose = LOSE.instantiate()
	self.add_child(temp_lose)

func restart():
	reset_main_node()
	var temp_map = DARK_MAP.instantiate()
	self.add_child(temp_map)
