@tool
extends BTAction
## MoveToTarget


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "MoveToTarget"


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	agent.set_animation("Run")


# Called each time this task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	agent.turn_to_target(delta)
	agent.move_to_target(delta)
	
	return SUCCESS


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings

