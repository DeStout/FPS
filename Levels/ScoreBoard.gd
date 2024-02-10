extends Control


var characters := {}


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ScoreBoard"):
		get_parent().visible = true
	elif Input.is_action_just_released("ScoreBoard"):
		get_parent().visible = false
	elif Input.is_action_just_pressed("Pause"):
		get_parent().visible = false


func add_character(new_character_name : String) -> void:
	characters[new_character_name] = [$List.item_count / 3, 0, 0]
	$List.add_item(new_character_name)
	$List.add_item(str(0))
	$List.add_item(str(0))


func add_kill(character_name) -> void:
	var list_index = (characters[character_name][0] * 3) + 1
	var num_kills = characters[character_name][1] + 1
	characters[character_name][1] = num_kills
	print(characters[character_name])
	$List.set_item_text(list_index, str(num_kills))


func add_death(character_name) -> void:
	var list_index = (characters[character_name][0] * 3) + 2
	var num_deaths = characters[character_name][2] + 1
	characters[character_name][2] = num_deaths
	print(characters[character_name])
	$List.set_item_text(list_index, str(num_deaths))
