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
	turn_to_target.call_deferred(delta)
	move_to_target.call_deferred(delta)
	
	if agent.is_target_vis():
		return SUCCESS
	return RUNNING


func turn_to_target(delta) -> void:
	var next_path_pos := Vector3.ZERO
	if !agent.nav_agent.is_navigation_finished():
		next_path_pos = agent.nav_agent.get_next_path_position()
		next_path_pos.y = agent.position.y
	if next_path_pos and agent.transform.origin != next_path_pos:
		var new_transform : Transform3D = agent.transform.looking_at(next_path_pos)
		agent.transform = agent.transform.interpolate_with(
										new_transform, agent.TURN_SPEED * delta)


func move_to_target(_delta) -> void:
	var temp_speed : float = agent.SPEED * 0.75
	var input_dir = Vector2.UP
	var direction = (agent.transform.basis * 
								Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		agent.velocity.x = move_toward(agent.velocity.x,
										direction.x * temp_speed, agent.accel)
		agent.velocity.z = move_toward(agent.velocity.z,
										direction.z * temp_speed, agent.accel)
	else:
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.deaccel)
		agent.velocity.z = move_toward(agent.velocity.z, 0, agent.deaccel)
	agent.move_and_slide()


# Strings returned from this method are displayed as warnings in the behavior
# tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings

