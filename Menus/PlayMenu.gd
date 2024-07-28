extends Control

@export var game_mode : OptionButton
@export var map : OptionButton
@export var num_bots : OptionButton
@export var ff : OptionButton


func start_button() -> void:
	$"..".play_select()
	
	var game_settings : GameSettings = GameSettings.new()
	game_settings.game_mode = game_mode.selected
	game_settings.map = map.selected
	game_settings.num_bots = num_bots.selected
	game_settings.friendly_fire = ff.selected
	Globals.set_game_settings(game_settings)
	
	Globals.start_game()


func back_button() -> void:
	$"..".play_select()
	visible = false
