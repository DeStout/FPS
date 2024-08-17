extends Node3D


signal enemies_defeated

var enemy_ = preload("res://Characters/Campaign/CampaignEnemy.tscn")

@export var door : Door = null
var waiting_for_door := false
@export var players : Node3D = null
@export var spawn_radius := 3.0
var enemies : Array[CharacterBase] = []


func spawn_sequence(num_seq, num_spawns):
	door.finished.connect(door_finished)
	for seq in num_seq:
		await wait_for_door()
		print("door finished")


func spawn(num_enemies : int) -> void:
	for i in range(num_enemies):
		var enemy = enemy_.instantiate()
		enemy.starting_weapon = Globals.WEAPONS.PISTOL
		enemy.current_level = owner
		enemy.enemies.append(%Player)
		
		var spawn_point = Vector3(0, 0, randf_range(0.25, spawn_radius))
		spawn_point = spawn_point.rotated(Vector3.UP, randf() * TAU)
		enemy.position = global_position + spawn_point
		
		enemies.append(enemy)
		players.add_child(enemy)
		enemy.target = %Player
		enemy.state_machine.current_state.alert()
		enemy.alert = true
		enemy.state_machine.set_physics_process(true)
		enemy.tree_exited.connect(enemy_killed)


func enemy_killed() -> void:
	for enemy in enemies:
		if !enemy:
			continue
		return
	enemies = []
	enemies_defeated.emit()


func wait_for_door() -> void:
	if door.closed and !door.moving:
		return
	door.open(false)
	waiting_for_door = true
	while(waiting_for_door):
		if !$Area3D.has_overlapping_bodies():
			if !door.closed or !door.moving:
				door.open(false)
		else:
			if door.closed or !door.moving:
				door.open(true)
	return


func door_finished(open) -> void:
	if !open:
		waiting_for_door = false


func body_in_space(body) -> void:
	pass


func body_left_space(body) -> void:
	pass
