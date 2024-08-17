extends EventScript


func trigger() -> void:
	
	# Alarm
	#resources[3].activate()
	
	#Doors
	resources[0].locked = true
	resources[0].open(false)
	resources[1].set_auto_close(false)
	resources[1].locked = true
	resources[1].open(false)
	resources[2].set_auto_close(false)
	resources[2].locked = true
	resources[2].open(false)
	
	# Spawners
	resources[4].enemies_defeated.connect(enemies_defeated)
	resources[5].enemies_defeated.connect(enemies_defeated)
	resources[4].spawn_sequence(2, 2)
	resources[5].spawn_sequence(2, 2)
	
	print("Doors Closed and Locked")
	print("Alarm Activated")


func enemies_defeated() -> void:
	pass
