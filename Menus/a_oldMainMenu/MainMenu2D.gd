extends VBoxContainer


signal play_button
signal options_button


func play_pressed() -> void:
	play_button.emit()
	$Select.play()


func options_pressed() -> void:
	options_button.emit()
	$Select.play()


func play_boop() -> void:
	$Boop.play()


func quit() -> void:
	$Select.play()
	await $Select.finished
	get_tree().quit()
