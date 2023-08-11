extends CharacterBase


@onready var nav_agent := $NavAgent
var last_position := Vector3.ZERO
var stuck_length := 2.0

var player : CharacterBody3D = null
var player_vis := false : set = _player_vis_change
var player_vis_threshold := 0.45
var shoot_accuracy_threshold := 0.4

var move_speed_mod := 0.8
const TURN_SPEED := 6.0
const AIM_SPEED := 8.0


func new_name(new_name : String) -> void:
	name = new_name
	$NameLabel.text = name


func _physics_process(delta):
	super(delta)

	# Check and set if player vis has changed
	var temp_player_vis = player and %PlayerCast.is_colliding() and \
						%PlayerCast.get_collider() == player and \
						to_local(%PlayerCast.get_collision_point()) \
						.normalized().dot(Vector3.FORWARD) > player_vis_threshold
	if player_vis != temp_player_vis:
		player_vis = temp_player_vis

	var input_dir = Vector2.ZERO
	var next_path_pos := Vector3.ZERO

	# Choose target
	if player and (player_vis or !$PlayerTimer.is_stopped()):
		nav_agent.target_position = player.global_position
	if !nav_agent.is_navigation_finished():
		next_path_pos = nav_agent.get_next_path_position()
		next_path_pos.y = position.y
		input_dir = Vector2.UP
	elif !player_vis and $PlayerTimer.is_stopped():
#		print("Nav point reached")
		_new_rand_nav_point()

	if next_path_pos and transform.origin != next_path_pos:
#		$NavTarget.global_position = next_path_pos
		var new_transform := transform.looking_at(next_path_pos)
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	# Accel and move
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
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()

	# Check if AI is stuck
	if abs(position.length_squared() - last_position.length_squared()) < stuck_length:
		if $StuckTimer.is_stopped() and $PlayerTimer.is_stopped() and \
											!nav_agent.is_target_reached():
			$StuckTimer.start()
#			print("Maybe Stuck")
	elif !$StuckTimer.is_stopped():
		$StuckTimer.stop()
#		print("Not stuck")
	last_position = position

	# Aim and fire or reload
	_aim(delta)
	if weapon_held:
		if weapon_held.ammo_in_mag == 0:
			_reload()
		elif player and player_vis:
			var player_pos := player.global_position + Vector3(0, 1.5, 0)
			var local_player_pos = %ShootCast.to_local(player_pos).normalized()
			var local_ray_collision = %ShootCast.to_local(\
								%ShootCast.get_collision_point()).normalized()
			if local_player_pos.dot(local_ray_collision) > shoot_accuracy_threshold:
				if $ShootTimer.is_stopped():
					trigger_pulled = true

	# Cast at Player for vis check
	if player:
		%PlayerCast.target_position = %PlayerCast.to_local(player.global_position) + \
									Vector3(0, 0.9, 0)


func _shoot() -> void:
	super()
	$ShootTimer.start(1.0 / (weapon_held.shots_per_second / 3.0))


func _aim(delta) -> void:
	if player and player_vis:
		var player_pos = player.global_position + Vector3(0, 1.5, 0)
		var new_trans :Transform3D = $AimHelper.global_transform.looking_at(player_pos)
		$AimHelper.global_transform = $AimHelper.global_transform.interpolate_with \
													(new_trans, AIM_SPEED * delta)
	else:
		$AimHelper.rotation = $AimHelper.rotation.lerp(Vector3.ZERO, AIM_SPEED * delta)
	$AimHelper.rotation.x = clamp($AimHelper.rotation.x, deg_to_rad(-90), rad_to_deg(90))
	$AimHelper.rotation.y = clamp($AimHelper.rotation.y, deg_to_rad(-80), rad_to_deg(80))
	$AimHelper.rotation.z = 0


func _player_vis_change(new_player_vis) -> void:
	player_vis = new_player_vis
	if player_vis:
#		print("Player seen")
		nav_agent.target_position = player.global_position
		$PlayerTimer.stop()
	else:
		trigger_pulled = false
#		print("Player not seen")
		$PlayerTimer.start()


func _new_rand_nav_point() -> void:
	var new_nav_point = current_level.get_nav_point()
#	print("New nav point: ", new_nav_point.name)
	nav_agent.target_position = new_nav_point.position


func _player_lost() -> void:
#	print("Player lost")
	_new_rand_nav_point()
	if weapon_held and weapon_held.ammo_in_mag == 0:
		_reload()


func _stuck() -> void:
#	print("Stuck")
	_new_rand_nav_point()


func _die() -> void:
	super()
	player_vis = false
	$PlayerTimer.stop()


func respawn() -> void:
	super()
	_new_rand_nav_point()
