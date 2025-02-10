extends Node3D


const SENSITIVITY := 0.005

@onready var cam := $Camera

var pivot := false
var zoom := false


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SHIFT and !zoom:
			zoom = true
		elif !event.pressed and event.keycode == KEY_SHIFT and zoom:
			zoom = false
			
	elif event is InputEventMouse:
		if event is InputEventMouseMotion:
			if pivot and zoom:
				cam.fov = clamp(cam.fov + event.relative.y, 1, 179)
			elif pivot:
				rotation.x -= event.relative.y * SENSITIVITY
				rotation.x = clamp(rotation.x, -PI / 2, PI / 2)
				rotation.y -= event.relative.x * SENSITIVITY
				rotation.z = 0
		elif event is InputEventMouseButton:
			if event.pressed and event.button_index == 3 and !pivot:
				pivot = true
			elif !event.pressed and event.button_index == 3 and pivot:
				pivot = false
