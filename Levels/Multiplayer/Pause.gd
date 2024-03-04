extends CanvasLayer


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		if Input.is_action_just_pressed("Pause"):
			get_tree().paused = !get_tree().paused

			if get_tree().paused:
				if %Players:
					%Players.player.update_health_UI()
				else:
					%Characters.player.update_health_UI()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				visible = true
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				visible = false
		
		elif Input.is_action_just_pressed("SwitchLevel"):
			Globals.switch_levels()


func quit_button() -> void:
	get_tree().paused = false
	Globals.quit_game()
