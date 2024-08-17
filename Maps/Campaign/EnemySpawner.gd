extends Node3D


signal enemies_defeated

var enemy_ = preload("res://Characters/Campaign/CampaignEnemy.tscn")

@export var players_node : Node3D = null
@export var spawn_time := 2.0
@export var spawn_num := 1
@export var spawn_radius := 3.0
@export var frame_check_interval := 30
@export var door : Node3D = null

var enemies : Array[CharacterBase] = []
var ready_to_spawn := false


func _ready() -> void:
	set_process(false)


func set_spawning(new_spawning : bool) -> void:
	set_process(new_spawning)
	$SpawnArea.monitoring = new_spawning
	ready_to_spawn = new_spawning
	if new_spawning:
		$SpawnTimer.start(spawn_time)
	else:
		$SpawnTimer.stop()


func _process(delta: float) -> void:
	if get_tree().get_frame() % frame_check_interval == 0:
		if ready_to_spawn and is_enemies_defeated() and _is_door_closed():
			_spawn()
			ready_to_spawn = false


func _spawn() -> void:
	for i in range(spawn_num):
		var enemy = enemy_.instantiate()
		enemy.starting_weapon = Globals.WEAPONS.PISTOL
		enemy.current_level = Globals.map
		enemy.enemies.append(Globals.map.player)
		
		var spawn_point = Vector3(0, 0, randf_range(0.25, spawn_radius))
		spawn_point = spawn_point.rotated(Vector3.UP, randf() * TAU)
		enemy.position = global_position + spawn_point
		
		enemies.append(enemy)
		players_node.add_child(enemy)
		enemy.target = Globals.map.player
		enemy.state_machine.current_state.alert()
		enemy.alert = true
		enemy.state_machine.set_physics_process(true)
		enemy.defeated.connect(enemy_defeated)


func set_ready_to_spawn() -> void:
	ready_to_spawn = true


func _is_door_closed() -> bool:
	return door.closed and !door.moving


func enemy_defeated(enemy) -> void:
	enemies.erase(enemy)
	if is_enemies_defeated():
		enemies_defeated.emit()


func is_enemies_defeated() -> bool:
	return enemies.size() == 0


func char_entered(_body) -> void:
	door.open(true)
	door.auto_close = false


func char_exited(_body) -> void:
	if !$SpawnArea.has_overlapping_bodies():
		door.open(false)
		door.auto_close = true
