extends Control


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			visible = false
		else:
			visible = true
