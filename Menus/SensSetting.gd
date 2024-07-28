extends HSlider

const MAX_MOUSE_SENS := 0.01
const MIN_MOUSE_SENS := 0.0005
const MAX_CONTROLLER_SENS := 0.2
const MIN_CONTROLLER_SENS := 0.01

@export_enum("Mouse", "Controller") var io := 0
@export var default_value := 0


func update() -> void:
	match io:
		0:
			value = _sens_to_slider(Globals.mouse_sensitivity)
		1:
			value = _sens_to_slider(Globals.controller_sensitivity)


func default() -> void:
	_sensitivity_changed(default_value)


func _sens_to_slider(new_sens : float) -> int:
	var slide_range : float = max_value - min_value
	var sens_percent : float
	match io:
		0:
			sens_percent = (new_sens - MIN_MOUSE_SENS) / \
											(MAX_MOUSE_SENS - MIN_MOUSE_SENS)
		1:
			sens_percent = (new_sens - MIN_CONTROLLER_SENS) / \
											(MAX_CONTROLLER_SENS - MIN_CONTROLLER_SENS)
	return int((slide_range * sens_percent) + min_value)


func _slider_to_sens(new_value : int) -> float:
	var slide_percent : float = new_value / (max_value - min_value)
	var sens_range := 0.0
	var min_sens := 0.0
	match io:
		0:
			sens_range = MAX_MOUSE_SENS - MIN_MOUSE_SENS
			min_sens = MIN_MOUSE_SENS
		1:
			sens_range = MAX_CONTROLLER_SENS - MIN_CONTROLLER_SENS
			min_sens = MIN_CONTROLLER_SENS
	return float((sens_range * slide_percent) + min_sens)


func _sensitivity_changed(new_value : int = 0) -> void:
	value = new_value
	match io:
		0:
			Globals.mouse_sensitivity = _slider_to_sens(new_value)
		1:
			Globals.controller_sensitivity = _slider_to_sens(new_value)
