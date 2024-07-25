extends VBoxContainer


signal options_button
signal back_button


func start_pressed() -> void:
	$Select.play()
	await $Select.finished
	Globals.start_game()


func options_pressed() -> void:
	$Select.play()
	options_button.emit()


func back_pressed() -> void:
	$Select.play()
	back_button.emit()


func play_boop() -> void:
	$Boop.play()
