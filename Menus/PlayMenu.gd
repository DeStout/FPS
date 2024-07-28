extends Control

@export var game_mode : OptionButton
@export var map : OptionButton
@export var num_bots : OptionButton
@export var ff : OptionButton


func start_button() -> void:
	$"..".play_select()
	
	var match_settings : MatchSettings = MatchSettings.new()
	match_settings.game_mode = game_mode.selected
	match_settings.map = map.selected
	match_settings.num_bots = num_bots.selected
	match_settings.friendly_fire = ff.selected
	Globals.set_match_settings(match_settings)
	
	Globals.start_game()


func back_button() -> void:
	$"..".play_select()
	visible = false
