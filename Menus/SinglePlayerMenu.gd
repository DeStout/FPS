extends Control


@export var main_menu : Control = null


func start_button() -> void:
	$"..".play_select()
	
	main_menu.game.load_single_player()


func back_button() -> void:
	$"..".play_select()
	visible = false
