extends Control


@export var main_menu : Control = null

@export var game_mode : OptionButton
@export var map : OptionButton
@export var score_to_win : OptionButton
@export var time_m : OptionButton
@export var time_s : OptionButton
@export var num_bots : OptionButton
@export var ff : OptionButton


func start_button() -> void:
	main_menu.play_select()
	
	var bot_sim_settings : BotSimSettings = BotSimSettings.new()
	bot_sim_settings.game_mode = game_mode.selected
	bot_sim_settings.map = map.selected
	bot_sim_settings.score_to_win = _get_win_score()
	bot_sim_settings.time = _convert_time()
	bot_sim_settings.num_bots = num_bots.selected
	bot_sim_settings.friendly_fire = ff.selected
	main_menu.game.set_bot_sim_settings(bot_sim_settings)
	
	main_menu.game.load_bot_sim_game()


func _get_win_score() -> int:
	var score_i = score_to_win.selected
	return score_to_win.get_item_id(score_i)


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
	main_menu.play_select()
	visible = false
