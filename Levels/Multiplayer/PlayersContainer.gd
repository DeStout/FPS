extends Node3D


var player_ = preload("res://Characters/Player.tscn")
var simple_enemy_ = preload("res://Characters/SimpleEnemy.tscn")
var ffa_enemy_ = preload("res://Characters/FFAEnemy.tscn")
var team_enemy_ = preload("res://Characters/TeamEnemy.tscn")

var respawn_timer_ = preload("res://Levels/Multiplayer/RespawnTimer.tscn")

var level 
var player : CharacterBase
var enemies := []
var respawn_timers := []
var score_tracker := {}


func set_up() -> void:
	player = player_.instantiate()

	var used_spawns := []
	var spawn_point = level.get_spawn_point()
	used_spawns.append(spawn_point)

	%Score.add_character(player.name)
	spawn_character(player, spawn_point)
	connect_signals(player)
	
	match Globals.game_settings.game_mode:
		0:				# Lone Wolf
			print("Game Type: Lone Wolf")
			for x in range(Globals.game_settings.num_ai):
				var enemy = simple_enemy_.instantiate()
				enemies.append(enemy)
				enemy.new_name("Enemy" + str(x+1))
				enemy.player = player

				while(used_spawns.has(spawn_point)):
					spawn_point = level.get_spawn_point()
				used_spawns.append(spawn_point)

				%Score.add_character(enemy.name)
				spawn_character(enemy, spawn_point)
				connect_signals(enemy)
		
		1:				# FFA
			print("Game Type: Free For All")
			enemies.append(player)
			for x in range(Globals.game_settings.num_ai):
				var enemy = ffa_enemy_.instantiate()
				enemies.append(enemy)
				enemy.new_name("Enemy" + str(x+1))
				
				while(used_spawns.has(spawn_point)):
					spawn_point = level.get_spawn_point()
				used_spawns.append(spawn_point)

				%Score.add_character(enemy.name)
				spawn_character(enemy, spawn_point)
				connect_signals(enemy)
			
			for enemy in enemies:
				if enemy != player:
					enemy.set_enemies(enemies)
		
		2:				# Teams
			print("Game Type: Team Battle")


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


func add_to_score_board(killed, killer) -> void:
	%Score.add_death(killed.name)
	%Score.add_kill(killer.name)


func character_killed(character) -> void:
	remove_child(character)

	for enemy in enemies:
		enemy.character_killed(character)

	for respawn_timer in respawn_timers:
		if respawn_timer.character == character:
			respawn_timer.start()
			return

func respawn_character(character) -> void:
	add_child(character)
	character.respawn()
	
	for enemy in enemies:
		enemy.character_spawned(character, player == character)
