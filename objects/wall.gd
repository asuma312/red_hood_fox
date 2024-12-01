extends StaticBody2D
@export var tile_map_layer: TileMapLayer
@onready var invisiblecollision: Area2D = $invisiblecollision
@onready var player_finder: RayCast2D = $navigation/player_finder
@export var perma_player:CharacterBody2D
var can_move:bool = true
var in_shadow:bool = false

func _ready() -> void:
	invisiblecollision.add_to_group("shadow")


func _process(delta: float) -> void:
	player_finder.target_position = to_local(perma_player.global_position)
	if not GlobalScript.verify_distance_to_the_player(self):
		return
	detect_on_shadow()
	pass
func _on_invisiblecollision_body_entered(body: Node2D) -> void:
	if body.name == self.name:
		return
	self.modulate.a = 0.5

func _on_invisiblecollision_body_exited(body: Node2D) -> void:
	if body.name == self.name:
		return
	self.modulate.a = 1


func detect_on_shadow():
	for area in invisiblecollision.get_overlapping_areas():
		if not area.is_in_group("light"):
			continue
		in_shadow = false
		return
	in_shadow = true
	return
	
