extends EventScript


func trigger() -> void:
	#Doors
	resources[0].locked = true
	resources[0].open(false)
	resources[1].set_auto_close(false)
	resources[1].locked = true
	resources[1].open(true)
	resources[2].set_auto_close(false)
	resources[2].locked = true
	resources[2].open(true)
	
	# Alarm
	#resources[3].activate()
	
	# Spawners
	resources[4].spawn(2)
	resources[5].spawn(2)
	
	print("Doors Closed and Locked")
	print("Alarm Activated")
