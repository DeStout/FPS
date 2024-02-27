extends VBoxContainer


signal back_button


func start_pressed() -> void:
	Globals.start_game()


func back_pressed() -> void:
	back_button.emit()


func play_boop() -> void:
	$Boop.play()
