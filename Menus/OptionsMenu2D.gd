extends Control


signal back_button


func back_pressed() -> void:
	back_button.emit()
