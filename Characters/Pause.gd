extends Node


func _ready() -> void:
	await owner.ready
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("Pause"):
			get_tree().paused = !get_tree().paused

			if get_tree().paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
