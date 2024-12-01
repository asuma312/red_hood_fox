extends Node2D
const WON = preload("res://scenes/won.tscn")
const LOSE = preload("res://scenes/lose.tscn")
const DARK_MAP = preload("res://objects/dark_map.tscn")
const _1 = preload("res://scenes/levels/1.tscn")
@onready var mainmenu: Node2D = $mainmenu
var mainmenu_node:Node2D
var saved_children = []
var on_menu:bool = false
func _ready() -> void:
	mainmenu.base_menu.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and self.get_child(0).name!="mainmenu":
		if not on_menu:
			save_and_remove_children()
			self.add_child(mainmenu_node)
			mainmenu_node.get_node("MENUS/INGAME_MENU").visible = true
			mainmenu_node.name = "game_mainmenu"
			on_menu = true
		else:
			restore_children()

		
func restore_children():
	self.remove_child(self.get_child(0))
	on_menu = false
	for child in saved_children:
		add_child(child)
	saved_children.clear()
func save_and_remove_children():
	for child in get_children():
		saved_children.append(child)
		remove_child(child)

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
	var temp_map = _1.instantiate()
	self.add_child(temp_map)

func won():
	reset_main_node()
	var temp_won = WON.instantiate()
	self.add_child(temp_won)
