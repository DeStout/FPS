extends CanvasLayer


func _ready() -> void:
	$OptionsMenu.update()


func _input(event) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		if Input.is_action_just_pressed("Pause"):
			_toggle_pause()


func _toggle_pause() -> void:
	get_tree().paused = !get_tree().paused

	if get_tree().paused:
		if Globals.map is MultiplayerLevel:
			%Players.player.update_health_UI()
		elif Globals.map is CampaignLevel:
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


func close_button() -> void:
	_toggle_pause()


func quit_button() -> void:
	if Globals.map is MultiplayerLevel:
		Globals.quit_bot_sim()
	elif Globals.map is CampaignLevel:
		Globals.quit_single_player()
