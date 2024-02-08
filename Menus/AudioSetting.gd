extends HSlider


const MAX_VOL := 5.0
const MIN_VOL := -25.0

@export var bus_name : String = ""
@export var default_value := 0.0
var bus_index : int = 0


func _ready() -> void:
	assert(bus_name != "", "Audio slider bus undefined")
	bus_index = AudioServer.get_bus_index(bus_name)
	value = default_value
	var default_level : float = (((MAX_VOL - MIN_VOL) / max_value) * default_value) + MIN_VOL
	AudioServer.set_bus_volume_db(bus_index, default_level)


func audio_level_changed(new_value) -> void:
	var new_level : float = (((MAX_VOL - MIN_VOL) / max_value) * new_value) + MIN_VOL
	AudioServer.set_bus_volume_db(bus_index, new_level)
	AudioServer.set_bus_mute(bus_index, new_level == MIN_VOL)
