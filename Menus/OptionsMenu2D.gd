extends Control


signal back_button

const MAX_MOUSE_SENS := 0.01
const MIN_MOUSE_SENS := 0.0005
const MAX_CONTROL_SENS := 0.2
const MIN_CONTROL_SENS := 0.01

@onready var mouse_slider = $TabContainer/Input/Input/Mouse/HSlider
@onready var control_slider = $TabContainer/Input/Input/Controller/HSlider
@onready var invert_button = $TabContainer/Input/Input/InvertY/Control/CheckBox


func _ready() -> void:
	mouse_slider.value = (Globals.mouse_sensitivity / \
				(MAX_MOUSE_SENS - MIN_MOUSE_SENS)) * mouse_slider.max_value
	control_slider.value = (Globals.controller_sensitivity / \
				(MAX_CONTROL_SENS - MIN_CONTROL_SENS)) * control_slider.max_value
	invert_button.button_pressed = Globals.invert_y_axis


func back_pressed() -> void:
	back_button.emit()


func mouse_sens_change(new_value) -> void:
	Globals.mouse_sensitivity = (((MAX_MOUSE_SENS - MIN_MOUSE_SENS) / \
				mouse_slider.max_value) * new_value) + MIN_MOUSE_SENS


func controller_sens_change(new_value) -> void:
	Globals.controller_sensitivity = (((MAX_CONTROL_SENS - MIN_CONTROL_SENS) / \
				control_slider.max_value) * new_value) + MIN_CONTROL_SENS


func invert_y_change(new_value) -> void:
	Globals.invert_y_axis = new_value
