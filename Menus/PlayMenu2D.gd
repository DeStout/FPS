extends VBoxContainer


signal back_button


func start_pressed() -> void:
	$Select.play()
	await $Select.finished
	Globals.start_game()


func back_pressed() -> void:
	$Select.play()
	back_button.emit()


func play_boop() -> void:
	$Boop.play()
