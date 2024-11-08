extends Node2D


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_trapdoor_body_entered(body: Node2D) -> void:
	if body.name == 'basechar':
		self.get_parent().win_level()
