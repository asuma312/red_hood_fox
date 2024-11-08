extends StaticBody2D

@onready var shadow: Area2D = $shadow


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shadow.add_to_group("shadow")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
