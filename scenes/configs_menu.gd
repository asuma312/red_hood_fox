extends Node2D
var music_bus_index:int
var sfx_bux_index:int

func _ready() -> void:
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bux_index = AudioServer.get_bus_index("SFX")





func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		music_bus_index,
		linear_to_db(value)
	)
	



func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		sfx_bux_index,
		linear_to_db(value)
	)
