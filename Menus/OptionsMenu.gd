extends Control


const INVERT_DEFAULT := false

@export var master_slider : HSlider
@export var music_slider : HSlider
@export var sfx_slider : HSlider
@export var mouse_slider : HSlider
@export var controller_slider : HSlider
@export var invert_y_box : CheckBox


func _ready() -> void:
	update()


func update() -> void:
	master_slider.update()
	music_slider.update()
	sfx_slider.update()
	mouse_slider.update()
	controller_slider.update()
	invert_y_change(Globals.invert_y_axis)


func invert_y_change(new_value : bool) -> void:
	invert_y_box.button_pressed = new_value
	$"..".play_select()
	Globals.invert_y_axis = new_value


func default_button() -> void:
	$"..".play_select()
	master_slider.default()
	music_slider.default()
	sfx_slider.default()
	mouse_slider.default()
	controller_slider.default()
	invert_y_change(INVERT_DEFAULT)
	


func back_button() -> void:
	$"..".play_select()
	visible = false
