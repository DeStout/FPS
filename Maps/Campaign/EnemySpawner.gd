extends Node3D


signal enemies_defeated

var enemy_ = preload("res://Characters/Campaign/CampaignEnemy.tscn")

@export var players : Node3D = null
@export var spawn_radius := 3.0
var enemies : Array[CharacterBase] = []


func _process(delta: float) -> void:
	pass


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
