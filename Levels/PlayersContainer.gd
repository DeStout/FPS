extends Node3D


var player_ = preload("res://Characters/Player.tscn")
var enemy_ = preload("res://Characters/Enemy.tscn")
var respawn_timer_ = preload("res://Levels/RespawnTimer.tscn")

var level : Node3D
var player : CharacterBase
var enemies := []
var respawn_timers := []


func set_up() -> void:
	player = player_.instantiate()

	var used_spawns := []
	var spawn_point = level.get_spawn_point()
	used_spawns.append(spawn_point)

	spawn_character(player, spawn_point)
	connect_signals(player)

	for x in range(level.num_enemies):
		var enemy = enemy_.instantiate()
		enemies.append(enemy)
		enemy.new_name("Enemy" + str(x+1))
		enemy.player = player

		while(used_spawns.has(spawn_point)):
			spawn_point = level.get_spawn_point()
		used_spawns.append(spawn_point)

		spawn_character(enemy, spawn_point)
		connect_signals(enemy)


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


func character_killed(character) -> void:
	remove_child(character)

	if character == player:
		for enemy in enemies:
			enemy.player = null

	for respawn_timer in respawn_timers:
		if respawn_timer.character == character:
			respawn_timer.start()
			return


func respawn_character(character) -> void:
	add_child(character)
	character.respawn()

	if character == player:
		for enemy in enemies:
			enemy.player = player
