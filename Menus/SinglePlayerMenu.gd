extends Control


func start_button() -> void:
	$"..".play_select()
	
	Globals.load_game()


func back_button() -> void:
	$"..".play_select()
	visible = false
