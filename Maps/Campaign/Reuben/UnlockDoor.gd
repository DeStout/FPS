extends EventScript


func trigger() -> void:
	resources[0].locked = !resources[0].locked
