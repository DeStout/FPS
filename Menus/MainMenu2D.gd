extends VBoxContainer


signal play_button
signal options_button


func play_pressed() -> void:
	play_button.emit()


func options_pressed() -> void:
	options_button.emit()


func quit() -> void:
	get_tree().quit()
