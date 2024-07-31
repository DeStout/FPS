extends Control

@export var game_mode : OptionButton
@export var map : OptionButton
@export var score_to_win : OptionButton
@export var time_m : OptionButton
@export var time_s : OptionButton
@export var num_bots : OptionButton
@export var ff : OptionButton


func start_button() -> void:
	$"..".play_select()
	
	var match_settings : MatchSettings = MatchSettings.new()
	match_settings.game_mode = game_mode.selected
	match_settings.map = map.selected
	match_settings.score_to_win = score_to_win.selected
	match_settings.time = _convert_time()
	match_settings.num_bots = num_bots.selected
	match_settings.friendly_fire = ff.selected
	Globals.set_match_settings(match_settings)
	
	Globals.start_game()


func _convert_time() -> int:
	if time_m.selected == 0:
		return 0;
	return ((time_m.selected - 1) * 60) + ((time_s.selected - 1) * 5)


func _set_time(new_time) -> void:
	if new_time == 0:
		time_m.selected = 0
		time_s.selected = 0
	elif time_s.selected == 1:
		if time_m.selected == 0 or time_m.selected == 1:
			time_m.selected = 2
	elif time_m.selected == 1:
		if time_s.selected == 0 or time_s.selected == 1:
			time_s.selected = 2
	else:
		if time_m.selected == 0:
			time_m.selected = 13
		elif time_s.selected == 0:
			time_s.selected = 1


func back_button() -> void:
	$"..".play_select()
	visible = false
