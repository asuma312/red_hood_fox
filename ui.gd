extends CanvasLayer
const HEARTH_CONTAINER = preload("res://ui/hearth_container.tscn")
@onready var flow_container: FlowContainer = $hearth_panel/hearth_containers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_hearth_containers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func generate_hearth_containers():
	for _life in range(GlobalScript.max_life):
		var hearh_container = HEARTH_CONTAINER.instantiate()
		flow_container.add_child(hearh_container)

func remove_health_container():
	var childrens = flow_container.get_children()
	var last_children = childrens[-1]
	flow_container.remove_child(last_children)
	
func lost_health(value=1):
	GlobalScript.actual_life -=1
	if GlobalScript.actual_life <1:
		var main = self.get_parent().get_parent().get_parent().get_parent()
		if not main:
			return
		main.lose_screen()
		return
	remove_health_container()
