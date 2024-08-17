extends EventScript


func trigger() -> void:
	for door in resources:
		door.activate()
	print("Doors Opened")
