extends StaticBody2D

@onready var shadow: Area2D = $shadow
@onready var invisiblecollision: Area2D = $invisiblecollision


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	invisiblecollision.add_to_group("shadow")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_invisiblecollision_body_entered(body: Node2D) -> void:
	if body.name == self.name:
		return
	var node_tree = self.get_node("wall")
	node_tree.modulate = Color(1, 1, 1, 0.5)  # Set to 50% transparency
	var shadow_node_tree = self.get_node("shadow")

func _on_invisiblecollision_body_exited(body: Node2D) -> void:
	if body.name == self.name:
		return
	var node_tree = self.get_node("wall")
	node_tree.modulate = Color(1, 1, 1, 1) 
	var shadow_node_tree = self.get_node("shadow")
