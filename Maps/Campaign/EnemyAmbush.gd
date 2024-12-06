extends EventScript


var ambush_timer := Timer.new()
var ambush_time := 30.0


func _ready() -> void:
	add_child(ambush_timer)
	ambush_timer.timeout.connect(ambush_finished)
	ambush_timer.one_shot = true


func trigger() -> void:
	resources[7].play()
	await resources[7].finished
	await get_tree().create_timer(1.5).timeout
	resources[8].play()
	await resources[8].finished
	
	ambush_timer.start(ambush_time)
	
	# Alarm / Lights
	resources[3].set_activated(true)
	
	#Doors
	resources[0].locked = true
	resources[0].open(false)
	resources[1].locked = true
	resources[1].open(false)
	resources[2].locked = true
	resources[2].open(false)
	
	# Spawners
	resources[4].enemies_defeated.connect(enemies_defeated)
	resources[5].enemies_defeated.connect(enemies_defeated)
	resources[4].set_spawning(true)
	resources[5].set_spawning(true)


func ambush_finished() -> void:
	print("Ambush finished")
	resources[3].set_activated(false)
	resources[4].set_spawning(false)
	resources[5].set_spawning(false)
	if resources[4].is_enemies_defeated() and resources[5].is_enemies_defeated():
		end_ambush()


func enemies_defeated() -> void:
	if ambush_timer.is_stopped():
		if resources[4].enemies.size() == 0 and resources[5].enemies.size() == 0:
			end_ambush()


func end_ambush() -> void:
	resources[0].locked = false
	resources[1].locked = false
	resources[2].locked = false
	resources[6].locked = false
