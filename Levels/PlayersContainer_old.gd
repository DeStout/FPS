extends Node3D


@export_node_path("Node3D") var spawns_
@export_node_path("Node3D") var pickups_
@export_node_path("Node3D") var nav_points_
@export var respawn_time := 5.0
@export_range(0,64) var num_enemies := 5

var spawns : Node3D
#var pickups : Node3D
#var nav_points : Node3D
var player_ := preload("res://Characters/Player.tscn")
#var enemy_ := preload("res://Characters/TestEnemy.tscn")
var player : CharacterBody3D
#var enemies := []

var bullet_hole_ := load("res://Props/BulletHole.tscn")


func _ready() -> void:
	spawns = get_node(spawns_)
#	pickups = get_node(pickups_)
#	nav_points = get_node(nav_points_)
#	var occupied_spawns : Array = []
	player = player_.instantiate()
#	occupied_spawns.append(_spawn(player))

#	if num_enemies > spawns.get_child_count() - 1:
#		num_enemies = spawns.get_child_count() - 1
#	for i in range(num_enemies):
#		var enemy : CharacterBody3D = enemy_.instantiate()
#		var spawn = _spawn(enemy)
#		if occupied_spawns.has(spawn):
#			while(occupied_spawns.has(spawn)):
#				remove_child(enemy)
#				spawn = _spawn(enemy)
#		occupied_spawns.append(spawn)

#		enemy.player = player
#		enemy.pickups = pickups
#		enemy.nav_points = nav_points
#		enemy.name = "Enemy" + str(get_child_count() - 2)
#		enemy.target_location = Node3D.new()
#		add_child(enemy.target_location)
#		enemy.target_location.name = str(enemy.name) + "_target"
#		enemy.get_node("Label").text = str(enemy.name)

#		enemy.debug_label = Debug.add_enemy_behavior_label(enemy)

#		enemy.switch_goal()
#		enemies.append(enemy)

#	Debug.player = player


#func _spawn(character : CharacterBody3D) -> Node3D:
#	var spawn : Node3D = spawns.get_child(randi() % spawns.get_child_count())
#	character.global_transform = spawn.global_transform
#	add_child(character)
#	character.container = self
#	return spawn


#func remove_player(dead_player : CharacterBody3D, killer : Enemy = null) -> void:
#	dead_player.queue_free()
#	player = null
#	if killer != null:
#		killer.camera.current = true

#	for enemy in enemies:
#		enemy.player = null
#		enemy.player_is_seen()
#		enemy.switch_goal()

#	await get_tree().create_timer(respawn_time).timeout

#	player = player_.instantiate()
#	_spawn(player)
#	if killer != null:
#		killer.camera.current = false
#	for enemy in enemies:
#		enemy.player = player

#	Debug.player = player


#func remove_enemy(dead_enemy : CharacterBody3D) -> void:
#	var save_name : String = dead_enemy.name
#	var save_label : Label = dead_enemy.debug_label
#	var save_target : Node3D = dead_enemy.target_location
#	enemies.erase(dead_enemy)
#	dead_enemy.queue_free()
#
#	await get_tree().create_timer(respawn_time).timeout
#
#	var enemy : CharacterBody3D = enemy_.instantiate()
#	_spawn(enemy)
#	enemy.name = save_name
#	enemy.player = player
#	enemy.pickups = pickups
#	enemy.nav_points = nav_points
#	enemy.debug_label = save_label
#	enemy.target_location = save_target
#	enemy.switch_goal()
#	enemies.append(enemy)


#func drop_weapon() -> void:
#	pass


#func create_shot_trail(shoot_from : Vector3, shoot_to: Vector3) -> void:
#	var shot_trail : Node3D = shot_trail_.instantiate()
#	var shot_trail_mesh : CylinderMesh = shot_trail.get_node("Mesh").mesh
#
#	$FX.add_child(shot_trail)
#	shot_trail_mesh.height = shoot_from.distance_to(shoot_to)
#	shot_trail.look_at_from_position(shot_trail.to_local((shoot_from + shoot_to) * 0.5), shoot_to)


func create_bullet_hole(collision_point : Vector3, collision_normal : Vector3) -> void:
	var bullet_hole : Decal = bullet_hole_.instantiate()
	$FX.add_child(bullet_hole)
	bullet_hole.position = collision_point
	bullet_hole.project_to(collision_normal)
	bullet_hole.global_rotate(bullet_hole.basis.y, randf_range(-PI, PI))
