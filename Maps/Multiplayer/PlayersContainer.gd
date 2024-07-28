extends Node3D


var player_ = preload("res://Characters/Player.tscn")
var team_enemy_ = preload("res://Characters/TeamEnemy.tscn")

var respawn_timer_ = preload("res://Maps/Multiplayer/RespawnTimer.tscn")

var level 
var player : CharacterBase
var bots := []
var respawn_timers := []
var score_tracker := {}


func set_up() -> void:
	player = player_.instantiate()

	var used_spawns := []
	var spawn_point = level.get_spawn_point()
	used_spawns.append(spawn_point)

	%Score.add_character(player.name)
	player.set_color(Color.BLUE)
	spawn_character(player, spawn_point)
	connect_signals(player)
	
	match Globals.match_settings.game_mode:
		0:				# Lone Wolf
			_set_up_lone_wolf(used_spawns)
		
		1:				# FFA
			_set_up_ffa(used_spawns)
		
		2:				# Teams
			_set_up_team_battle(used_spawns)


func _set_up_lone_wolf(used_spawns : Array) -> void:
	#print("Game Type: Lone Wolf")
	var spawn_point = level.get_spawn_point()
	for x in range(Globals.match_settings.num_bots):
		var enemy = team_enemy_.instantiate()
		enemy.set_color(Color.RED)
		bots.append(enemy)
		enemy.new_name("Enemy" + str(x+1))
		enemy.set_enemies([player])

		while(used_spawns.has(spawn_point)):
			spawn_point = level.get_spawn_point()
		used_spawns.append(spawn_point)

		%Score.add_character(enemy.name)
		spawn_character(enemy, spawn_point)
		connect_signals(enemy)
	player.set_enemies(bots)


func _set_up_ffa(used_spawns : Array) -> void:
	#print("Game Type: Free For All")
	var spawn_point = level.get_spawn_point()
	var enemies := [player]
	for x in range(Globals.match_settings.num_bots):
		var enemy = team_enemy_.instantiate()
		enemy.set_color(Color.RED)
		enemies.append(enemy)
		bots.append(enemy)
		enemy.new_name("Enemy" + str(x+1))
		
		while(used_spawns.has(spawn_point)):
			spawn_point = level.get_spawn_point()
		used_spawns.append(spawn_point)

		%Score.add_character(enemy.name)
		spawn_character(enemy, spawn_point)
		connect_signals(enemy)
	
	for enemy in enemies:
		enemy.set_enemies(enemies)


func _set_up_team_battle(used_spawns) -> void:
	#print("Game Type: Team Battle")
	var spawn_point = level.get_spawn_point()
	var team1 := [player]
	var team2 := []
	for x in range(Globals.match_settings.num_bots):
		var bot = team_enemy_.instantiate()
		if x < Globals.match_settings.num_bots / 2:
			bot.set_color(Color.BLUE)
			team1.append(bot)
			bot.new_name("Ally" + str(x+1))
		else:
			bot.set_color(Color.RED)
			team2.append(bot)
			bot.new_name("Enemy" + str(x-(Globals.match_settings.num_bots / 2)+1))
		bots.append(bot)
		
		while(used_spawns.has(spawn_point)):
			spawn_point = level.get_spawn_point()
		used_spawns.append(spawn_point)

		%Score.add_character(bot.name)
		spawn_character(bot, spawn_point)
		connect_signals(bot)
	
	for ally in team1:
		ally.set_enemies(team2)
	for enemy in team2:
		enemy.set_enemies(team1)


func spawn_character(character : CharacterBase, spawn_point : Marker3D) -> void:
	character.transform = spawn_point.transform
	character.current_level = level
	add_child(character)

	var respawn_timer = respawn_timer_.instantiate()
	add_child(respawn_timer)
	respawn_timers.append(respawn_timer)
	respawn_timer.character = character
	respawn_timer.respawn.connect(respawn_character)


func connect_signals(character) -> void:
	character.died.connect(character_killed)
	character.add_score.connect(add_to_score_board)


# Signaled from CharacterBase._die()
func add_to_score_board(killed, killer) -> void:
	%Score.add_death(killed.name)
	if killer.is_enemy(killed):
		%Score.add_kill(killer.name)
	else:
		%Score.add_kill(killer.name, -1)


func character_killed(character) -> void:
	remove_child(character)

	for bot in bots:
		bot.character_killed(character)

	for respawn_timer in respawn_timers:
		if respawn_timer.character == character:
			respawn_timer.start()
			return

func respawn_character(character) -> void:
	add_child(character)
	character.respawn()
	
	for bot in bots:
		bot.character_spawned(character, player == character)
