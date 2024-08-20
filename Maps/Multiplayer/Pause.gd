extends CanvasLayer


func _ready() -> void:
	$OptionsMenu.update()


func _input(event) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		if Input.is_action_just_pressed("Pause"):
			get_tree().paused = !get_tree().paused

			if get_tree().paused:
				if %Players:
					%Players.player.update_health_UI()
				else:
					get_parent().player.update_health_UI()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				visible = true
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				visible = false


func play_boop(t := 0) -> void:
	$Boop.play()


func play_select(t := 0) -> void:
	$Select.play()


func quit_button() -> void:
	Globals.quit_bot_sim()
