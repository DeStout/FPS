@tool
extends BTAction
## MoveToInRange


var target := CharacterBody3D
var desired_range := Vector2.ZERO


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "MoveToInRange"


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	target = agent.target
	desired_range = agent.weapon_held.stats.desired_range
	print("Desired Range: ", desired_range)
	
	assert(target != null and agent.weapon_held != null, "Target or Agent Weapon
																cannot be null")


# Called each time this task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	turn_to_target(delta)
	move_to_target(delta)
	
	return RUNNING


func turn_to_target(delta : float) -> void:
	var distance : float = agent.global_position.distance_to(target.global_position)
	var target_pos := Vector3.ZERO
	if distance < desired_range.y:
		target_pos = agent.target.global_position
		target_pos.y = agent.global_position.y
	else:
		target_pos = agent.nav_agent.get_next_path_position()
		target_pos.y = agent.position.y
		
	if target_pos:
		var new_transform : Transform3D = agent.transform.looking_at(target_pos)
		agent.transform = agent.transform.interpolate_with(
										new_transform, agent.TURN_SPEED * delta)


func move_to_target(delta) -> void:
	var position : Vector3 = agent.global_position
	var target_pos : Vector3 = agent.target.global_position
	var distance : float = agent.global_position.distance_to(target_pos)
	#print("Distance: ", distance)
	
	if distance < desired_range.x:
		var move_to : Vector3 = position + (target_pos.direction_to(position) *
													(desired_range.x - distance))
		#move_to.y = agent.global_position.y
		agent.set_nav_target(move_to)
	elif distance < desired_range.y:
		agent.set_nav_target(position)
	else:
		var move_to : Vector3 = target_pos
		move_to.y = agent.position.y
		agent.set_nav_target(move_to)
	
	var speed : float = agent.SPEED * 0.75
	var direction := position.direction_to(agent.nav_agent.get_next_path_position())
	direction.y = 0
	print(direction)
	if direction:
		agent.velocity.x = move_toward(agent.velocity.x,
										direction.x * speed, agent.accel * delta)
		agent.velocity.z = move_toward(agent.velocity.z,
										direction.z * speed, agent.accel * delta)
	else:
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.deaccel * delta)
		agent.velocity.z = move_toward(agent.velocity.z, 0, agent.deaccel * delta)
	agent.move_and_slide()


# Strings returned from this method are displayed as warnings in the behavior tree
# editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings

