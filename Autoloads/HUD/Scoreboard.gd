extends Control


var locked = false

var characters := {}
var teams := {}


func _input(_event : InputEvent) -> void:
	if !HUD.game_over and !locked:
		if Input.is_action_just_pressed("ScoreBoard"):
			visible = true
		elif Input.is_action_just_released("ScoreBoard"):
			visible = false
		elif Input.is_action_just_pressed("Pause"):
			visible = false


func add_character(new_character_name : String, team : Color) -> void:
	characters[new_character_name] = [$List.item_count / 3, 0, 0]
	$List.add_item(new_character_name)
	$List.set_item_custom_fg_color(-1, team)
	$List.add_item(str(0))
	$List.add_item(str(0))
	
	if !teams.has(team):
		teams[team] = 0


func add_kill(character, points := 1) -> void:
	var list_index = (characters[character.name][0] * 3) + 1
	var num_kills = characters[character.name][1] + points
	characters[character.name][1] = num_kills
	$List.set_item_text(list_index, str(num_kills))
	
	teams[character.mode_func.team] += points
	if Globals.game.bot_sim_settings.score_to_win > 0:
		_check_win()


func add_death(character_name) -> void:
	var list_index = (characters[character_name][0] * 3) + 2
	var num_deaths = characters[character_name][2] + 1
	characters[character_name][2] = num_deaths
	$List.set_item_text(list_index, str(num_deaths))


func get_leader_list() -> Dictionary:
	return teams


func _check_win() -> void:
	for team in teams:
		if teams[team] >= Globals.game.bot_sim_settings.score_to_win:
			Globals.game.map.end_match()
