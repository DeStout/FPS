extends HSlider

const MAX_MOUSE_SENS := 0.01
const MIN_MOUSE_SENS := 0.0005
const MAX_CONTROLLER_SENS := 0.2
const MIN_CONTROLLER_SENS := 0.01

@export_enum("Mouse", "Controller") var io := 0
@export var default_value := 0


func _ready() -> void:
	default()


func update() -> void:
	match io:
		0:
			value = _sens_to_slider(Globals.mouse_sensitivity)
		1:
			value = _sens_to_slider(Globals.controller_sensitivity)


func default() -> void:
	_sensitivity_changed(default_value)


func _sens_to_slider(new_sens_val) -> int:
	var range : float
	var percentage : int
	match io:
		0:
			range = MAX_MOUSE_SENS - MIN_CONTROLLER_SENS
			percentage = (new_sens_val - MIN_CONTROLLER_SENS) / range
		1:
			range = MAX_CONTROLLER_SENS - MIN_CONTROLLER_SENS
			percentage = (new_sens_val - MIN_MOUSE_SENS) / range
	return int((percentage * (max_value - min_value)) + min_value)


func _slider_to_sens(new_slider_val) -> float:
	var range : int = max_value - min_value
	var steps : int = range / step
	var step_val : float
	match io:
		0:
			step_val = (MAX_MOUSE_SENS - MIN_MOUSE_SENS) / steps
			return float(new_slider_val * step_val)
		1:
			step_val = (MAX_CONTROLLER_SENS - MIN_CONTROLLER_SENS) / steps
			return float(new_slider_val * step_val)
		_:
			return 0.0


func _sensitivity_changed(new_value : int = 0) -> void:
	#print("New Value: ", new_value)
	value = new_value
	match io:
		0:
			Globals.mouse_sensitivity = _slider_to_sens(new_value)
		1:
			Globals.controller_sensitivity = _slider_to_sens(new_value)
