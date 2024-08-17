extends EventScript


var ambush_timer := Timer.new()
var ambush_time := 30.0


func _ready() -> void:
	add_child(ambush_timer)
	ambush_timer.timeout.connect(ambush_finished)


func trigger() -> void:
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
	resources[4].set_spawning(true)
	resources[5].set_spawning(true)
	
	print("Doors Closed and Locked")
	print("Alarm Activated")


func ambush_finished() -> void:
	resources[4].set_spawning(false)
	resources[5].set_spawning(false)
	if resources[4].is_enemies_defeated() and resources[5].is_enemies_defeated():
		end_ambush()


func enemies_defeated() -> void:
	if ambush_timer.is_stopped():
		end_ambush()


func end_ambush() -> void:
	print("abush finished")
	resources[3].set_activated(false)
	resources[0].locked = false
	resources[1].locked = false
	resources[2].locked = false
	resources[6].locked = false
