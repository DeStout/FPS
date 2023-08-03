extends CharacterBase


@onready var nav_agent := $NavAgent

var player : CharacterBody3D = null
var player_vis := false : set = _player_vis_change

const TURN_SPEED := 5.0


func _physics_process(delta):
	super(delta)

	var temp_player_vis = player and %PlayerCast.is_colliding() and \
									%PlayerCast.get_collider() == player
	if player_vis != temp_player_vis:
		player_vis = temp_player_vis

	var input_dir = Vector2.ZERO
	var next_path_pos := Vector3.ZERO
#	if player and !nav_agent.is_navigation_finished():
#		if %PlayerCast.is_colliding() and %PlayerCast.get_collider() == player:
#			next_path_pos = nav_agent.get_next_path_position()
#			next_path_pos.y = position.y
#			input_dir = Vector2(0, -1)
	if player_vis:
		nav_agent.target_position = player.global_position

	if !nav_agent.is_navigation_finished():
		next_path_pos = nav_agent.get_next_path_position()
		next_path_pos.y = position.y
		input_dir = Vector2.UP

	if !player_vis and nav_agent.is_navigation_finished():
		var new_nav_point = current_level.get_nav_point().position
#		print(new_nav_point)
		nav_agent.target_position = new_nav_point


	if next_path_pos:
		$NavTarget.global_position = next_path_pos
		var new_transform := transform.looking_at(next_path_pos)
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	var accel = ACCEL
	var deaccel = DEACCEL
	if !is_on_floor():
		accel = AIR_ACCEL
		deaccel = AIR_DEACCEL
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel)
	else:
		state_machine.travel("Idle")
		velocity.x = move_toward(velocity.x, 0, deaccel)
		velocity.z = move_toward(velocity.z, 0, deaccel)
	move_and_slide()

	%PlayerCast.target_position = %PlayerCast.to_local(player.global_position) + \
									Vector3(0, 0.9, 0)


func _die() -> void:
	health = 100


func _player_vis_change(new_player_vis) -> void:
	player_vis = new_player_vis
	if player_vis:
		nav_agent.target_position = player.global_position
	else:
		var new_nav_point = current_level.get_nav_point().position
#		print(new_nav_point)
		nav_agent.target_position = new_nav_point
