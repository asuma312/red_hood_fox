extends Node2D
const WON = preload("res://scenes/won.tscn")
const LOSE = preload("res://scenes/lose.tscn")
const Map = preload("res://objects/light_map.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func win_level():
	print("won")
	var childrens = self.get_children()
	for c in childrens:
		self.remove_child(c)
	var won_scene = WON.instantiate()
	self.add_child(won_scene)
	
func lose_screen():
	print("lose")
	var childrens = self.get_children()
	for c in childrens:
		self.remove_child(c)
	var lose_scene = LOSE.instantiate()
	self.add_child(lose_scene)
	
func restart():
	print("restarting")
	var childrens = self.get_children()
	for c in childrens:
		self.remove_child(c)
	var map_scene = Map.instantiate()
	self.add_child(map_scene)
