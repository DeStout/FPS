extends HSlider


const MAX_VOL := 15
const MIN_VOL := -55

@export var bus_name : String = ""
@export var default_value := 0.0
var bus_index : int = 0


func _ready() -> void:
	assert(bus_name != "", "Audio slider bus undefined")
	bus_index = AudioServer.get_bus_index(bus_name)
	default()


func update() -> void:
	value = _bus_to_slider(AudioServer.get_bus_volume_db(bus_index))


func default() -> void:
	audio_level_changed(default_value)


func _bus_to_slider(new_volume : float) -> int:
	var bus_percent : float = new_volume / (MAX_VOL - MIN_VOL)
	var slide_range : float = max_value - min_value
	return int((slide_range * bus_percent) + min_value)


func _slider_to_bus(new_value : int) -> float:
	var slide_percent : float = new_value / (max_value - min_value)
	var bus_range : float = MAX_VOL - MIN_VOL
	return float((bus_range * slide_percent) + MIN_VOL)


func audio_level_changed(new_value : int) -> void:
	value = new_value
	var new_level : float = _slider_to_bus(new_value)
	new_level = clamp(new_level, MIN_VOL, MAX_VOL)
	
	AudioServer.set_bus_volume_db(bus_index, new_level)
	AudioServer.set_bus_mute(bus_index, new_level == min_value)
