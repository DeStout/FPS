extends EventScript


var ambush_timer := Timer.new()
var ambush_time := 30.0

@onready var key_sfx : AudioStreamPlayer = resources[10]
@onready var error_sfx : AudioStreamPlayer = resources[11]
@onready var success_sfx : AudioStreamPlayer = resources[12]

@onready var entry_door : Door = resources[0]
@onready var exit_door : Door = resources[5]
@onready var spawner_doors := [resources[1], resources[2], resources[3], resources[4]]
@onready var spawners := [resources[6], resources[7], resources[8], resources[9]]


func _ready() -> void:
	add_child(ambush_timer)
	ambush_timer.timeout.connect(ambush_finished)
	ambush_timer.one_shot = true
	
	for spawner in spawners:
		spawner.enemies_defeated.connect(enemies_defeated)


func trigger() -> void:
	key_sfx.play()
	await key_sfx.finished
	await get_tree().create_timer(0.75).timeout
	error_sfx.play()
	await error_sfx.finished
	
	ambush_timer.start(ambush_time)
	
	# Alarm / Lights
	#resources[3].set_activated(true)
	
	#Lock Door
	entry_door.locked = true
	entry_door.open(false)
	
	# Spawners
	_set_spawning(true)


func _set_spawning(spawning : bool) -> void:
	for spawner in spawners:
		spawner.set_spawning(spawning)


# Signaled by ambush_timer.timeout
func ambush_finished() -> void:
	_set_spawning(false)
	if _check_enemies_defeated():
		end_ambush()


# Signaled by EnemySpawner.enemies_defeated
func enemies_defeated() -> void:
	if ambush_timer.is_stopped() and _check_enemies_defeated():
		end_ambush()


func _check_enemies_defeated() -> bool:
	for spawner in spawners:
		if !spawner.is_enemies_defeated():
			return false
	return true


func end_ambush() -> void:
	for door in spawner_doors:
		door.locked = false
	
	await get_tree().create_timer(1.0).timeout
	success_sfx.play()
	#exit_door.locked = false
	exit_door.open(true)
