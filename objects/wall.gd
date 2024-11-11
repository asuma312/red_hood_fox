extends StaticBody2D

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
	print("entered")
	var upper_wall = self.get_node("uper_body")
	upper_wall.modulate = Color(1, 1, 1, 0.5)

func _on_invisiblecollision_body_exited(body: Node2D) -> void:
	if body.name == self.name:
		return
	var upper_wall = self.get_node("uper_body")
	upper_wall.modulate = Color(1, 1, 1, 1) 
