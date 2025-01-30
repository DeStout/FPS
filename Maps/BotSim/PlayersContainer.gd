extends Node3D


var player_ = load("res://Characters/Player/BotSimPlayer.tscn")
var bot_ = load("res://Characters/BotSim/BotSimEnemy.tscn")

var respawn_timer_ = load("res://Maps/BotSim/RespawnTimer.tscn")

@export var level : BotSimLevel = null
var player : CharacterBase = null
var bots : Array[CharacterBase] = []
var team_colors := [Color.BLUE, Color.RED, Color.GREEN, Color.YELLOW, \
	Color.MAGENTA, Color.CYAN, Color.ORANGE, Color.INDIGO, Color.ORANGE_RED, \
	Color.GREEN_YELLOW, Color.DARK_BLUE, Color.DARK_RED, Color.DARK_VIOLET, \
	Color.CORNFLOWER_BLUE, Color.DEEP_PINK, Color.SPRING_GREEN, Color.GOLD]
var respawn_timers := []
var score_tracker := {}


func set_up() -> void:
	player = player_.instantiate()

	var used_spawns := []
	var spawn_point : Marker3D = level.get_spawn_point()
	used_spawns.append(spawn_point)

	HUD.scoreboard.add_character(player.name, team_colors[0])
	spawn_character(player, spawn_point)
	player.mode_func.set_color(team_colors[0])
	connect_signals(player)
	
	match Globals.game.bot_sim_settings.game_mode:
		0:				# Lone Wolf
			_set_up_lone_wolf(used_spawns)
		
		1:				# FFA
			_set_up_ffa(used_spawns)
		
		2:				# Teams
			_set_up_team_battle(used_spawns)
	HUD.leader_list.update(HUD.scoreboard.get_leader_list())


func _set_up_lone_wolf(used_spawns : Array) -> void:
	#print("Game Type: Lone Wolf")
	var spawn_point : Marker3D = level.get_spawn_point()
	for x in range(Globals.game.bot_sim_settings.num_bots):
		var enemy = bot_.instantiate()
		bots.append(enemy)
		var temp : Array[CharacterBase] = [player]
		enemy.set_enemies(temp)

		while(used_spawns.has(spawn_point)):
			spawn_point = level.get_spawn_point()
		used_spawns.append(spawn_point)

		spawn_character(enemy, spawn_point)
		enemy.mode_func.new_name("Enemy" + str(x+1))
		enemy.mode_func.set_color(team_colors[1])
		
		HUD.scoreboard.add_character(enemy.name, team_colors[1])
		connect_signals(enemy)
	player.set_enemies(bots)


func _set_up_ffa(used_spawns : Array) -> void:
	#print("Game Type: Free For All")
	var spawn_point : Marker3D = level.get_spawn_point()
	var enemies : Array[CharacterBase] = [player]
	for x in range(Globals.game.bot_sim_settings.num_bots):
		var enemy = bot_.instantiate()
		enemies.append(enemy)
		bots.append(enemy)
		
		while(used_spawns.has(spawn_point)):
			spawn_point = level.get_spawn_point()
		used_spawns.append(spawn_point)

		spawn_character(enemy, spawn_point)
		enemy.mode_func.new_name("Enemy" + str(x+1))
		enemy.mode_func.set_color(team_colors[x+1])
		
		HUD.scoreboard.add_character(enemy.name, team_colors[x+1])
		connect_signals(enemy)
	
	for enemy in enemies:
		enemy.set_enemies(enemies)


func _set_up_team_battle(used_spawns) -> void:
	#print("Game Type: Team Battle")
	var spawn_point : Marker3D = level.get_spawn_point()
	var team1 : Array[CharacterBase] = [player]
	var team2 : Array[CharacterBase] = []
	var new_name : String
	var team_color : Color
	for x in range(Globals.game.bot_sim_settings.num_bots):
		var bot = bot_.instantiate()
		if x < Globals.game.bot_sim_settings.num_bots / 2:
			team_color = team_colors[0]
			team1.append(bot)
			new_name = "Ally" + str(x+1)
		else:
			team_color = team_colors[1]
			team2.append(bot)
			new_name = "Enemy" + \
						str(x-(Globals.game.bot_sim_settings.num_bots / 2)+1)
		bots.append(bot)
		
		while(used_spawns.has(spawn_point)):
			spawn_point = level.get_spawn_point()
		used_spawns.append(spawn_point)

		spawn_character(bot, spawn_point)
		bot.mode_func.new_name(new_name)
		bot.mode_func.set_color(team_color)
		
		HUD.scoreboard.add_character(bot.name, team_color)
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
	character.mode_func.died.connect(character_killed)
	character.mode_func.add_score.connect(add_to_scoreboard)
	
	if character is BotSimEnemy:
		for pickup in level.get_all_pickups():
			pickup.removed.connect(character.pickup_removed)


func set_characters_processing(new_process) -> void:
	var characters = bots.duplicate()
	characters.append(player)
	for character in characters:
		character.set_processing(new_process)


# Signaled from BotSimCharacter._die()
func add_to_scoreboard(killed, killer) -> void:
	HUD.scoreboard.add_death(killed.name)
	if killer.is_enemy(killed):
		HUD.scoreboard.add_kill(killer)
	else:
		HUD.scoreboard.add_kill(killer, -1)
	HUD.leader_list.update(HUD.scoreboard.get_leader_list())


# Signaled from BotSimCharacter.mode_func.die()
func character_killed(character) -> void:
	if !character.is_inside_tree():
		breakpoint
	remove_child(character)

	for bot in bots:
		bot.character_killed(character)

	for respawn_timer in respawn_timers:
		if respawn_timer.character == character:
			respawn_timer.start()
			return


func respawn_character(character) -> void:
	add_child(character)
	character.mode_func.respawn()
