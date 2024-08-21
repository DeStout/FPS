extends Control


func start_button() -> void:
	$"..".play_select()
	
	Globals.load_single_player()


func back_button() -> void:
	$"..".play_select()
	visible = false
