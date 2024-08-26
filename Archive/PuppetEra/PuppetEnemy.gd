extends MultiplayerPuppet


@onready var nav_agent := $NavAgent
var last_position := Vector3.ZERO
var stuck_length := 2.0
var stuck_times := 0

var enemies_vis : Array = []
var target : CharacterBody3D = null
var target_i := -1
var target_vis_threshold := 0.45
var target_dist := 2.5
var shoot_accuracy_threshold := 0.9
var shoot_speed_mod := 1.0/1.75
var shoot_speed_variance := Vector2(0.3, 1.0)

var move_speed_mod := 0.8
const TURN_SPEED := 6.0
const AIM_SPEED := 6.0


func set_enemies(new_enemies):
	super(new_enemies)
	for x in range(enemies.size()):
		enemies_vis.append(false)
	
	
func _ready() -> void:
	super()


func _process(delta: float) -> void:
	super(delta)
	_look(delta)


func _physics_process(delta):
	super(delta)

	var input_dir = Vector2.ZERO
	var next_path_pos := Vector3.ZERO
	check_enemies_visible()
	
	# Select new target if no target selected or target isn't visible but
	# an enemy is visible
	if enemies_vis.has(true) and (!target or !enemies_vis[target_i]):
		find_new_target()
	# Set nav point to target if one is selected and it's visible or the
	# search timer is still going
	if target and (enemies_vis[target_i] or !$TargetTimer.is_stopped()):
		if target.is_inside_tree():
			var short_target = _get_short_target(target.global_position)
			nav_agent.target_position = short_target
			
	if !nav_agent.is_navigation_finished():
		next_path_pos = nav_agent.get_next_path_position()
		next_path_pos.y = position.y
	else:
		_new_rand_nav_point()
	
	var back_up = target and -basis.z.dot(next_path_pos - global_position) <= 0
	if next_path_pos and !transform.origin.is_equal_approx(next_path_pos):
		var new_transform : Transform3D
		if back_up:
			input_dir = Vector2.DOWN
			var temp_pos := target.global_position; temp_pos.y = global_position.y
			new_transform = transform.looking_at(temp_pos)
		else:
			input_dir = Vector2.UP
			new_transform = transform.looking_at(next_path_pos)
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			anim_state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel * delta)
	else:
		anim_state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()

	# Check if AI is stuck
	if abs(position.length_squared() - last_position.length_squared()) < stuck_length:
		if $StuckTimer.is_stopped() and $TargetTimer.is_stopped() and \
											!nav_agent.is_target_reached():
			$StuckTimer.start()
#			print("Maybe Stuck")
	elif !$StuckTimer.is_stopped():
		$StuckTimer.stop()
#		print("Not stuck")
	last_position = position

	# Aim and fire or reload
	if target and target.is_inside_tree():
		_aim(delta)
	if weapon_held.stats.weapon_type != Globals.WEAPONS.SLAPPER:
		if target and enemies_vis[target_i] and target.is_inside_tree():
			var target_pos = target.global_position + Vector3(0, 0.7, 0)
			var local_player_pos = %ShootCast.to_local(target_pos).normalized()
			var local_ray_collision = %ShootCast.to_local(\
								%ShootCast.get_collision_point()).normalized()
			if local_player_pos.dot(local_ray_collision) > shoot_accuracy_threshold:
				if $ShootTimer.is_stopped():
					_pull_trigger()
	else:
		if target and enemies_vis[target_i]:
			if target.global_position.distance_to(global_position) < 1.0:
				if $ShootTimer.is_stopped():
					_pull_trigger()


func check_enemies_visible() -> void:
	var offset := Vector3(0, 0.9, 0)
	var temp_vis := enemies_vis.duplicate()
	for i in enemies.size():
		var enemy = enemies[i]
		enemies_vis[i] = false
		if enemy.is_inside_tree():
			var target_pos = %TargetCast.to_local(enemy.global_position) + offset
			%TargetCast.target_position = target_pos
			%TargetCast.force_raycast_update()
			
			if %TargetCast.is_colliding():
				var collider = %TargetCast.get_collider()
				var enemy_dot_prod := to_local(%TargetCast.get_collision_point()) \
												.normalized().dot(Vector3.FORWARD)
				if collider == enemy and enemy_dot_prod > target_vis_threshold:
					enemies_vis[i] = true
	if target and temp_vis[target_i] != enemies_vis[target_i]:
		_target_vis_change(enemies_vis[target_i])


func find_new_target() -> void:
	var least_dist := 0.0
	for i in enemies_vis.size():
		if enemies[i].is_inside_tree() and enemies_vis[i]:
			var dist = global_position.distance_squared_to(enemies[i].global_position)
			if dist < least_dist or least_dist == 0.0:
				least_dist = dist
				target_i = i
	set_new_target(enemies[target_i], target_i)


func set_new_target(new_target, new_target_i) -> void:
	target = new_target
	target_i = new_target_i
	
	
func _get_short_target(target_pos) -> Vector3:
	var short_vect = (global_position - target_pos).normalized() * target_dist
	short_vect = (target_pos - global_position) + short_vect
	return short_vect + global_position


func _shoot() -> void:
	super()
	trigger_pulled = false
	var speed_variance = randf_range(shoot_speed_variance.x , shoot_speed_variance.y)
	var shoot_speed = weapon_held.stats.shots_per_second * shoot_speed_mod * speed_variance
	$ShootTimer.start(1.0 / shoot_speed)


func _swing() -> void:
	super()
	_slap()


func _aim(delta) -> void:
	if target and enemies_vis[target_i]:
		var target_pos = target.global_position + Vector3(0, 1.5, 0)
		var new_trans : Transform3D = $AimHelper.global_transform.looking_at(target_pos)
		$AimHelper.global_transform = $AimHelper.global_transform.interpolate_with \
													(new_trans, AIM_SPEED * delta)
	else:
		$AimHelper.rotation = $AimHelper.rotation.lerp(Vector3.ZERO, AIM_SPEED * delta)
	$AimHelper.rotation.x = clamp($AimHelper.rotation.x, deg_to_rad(-90), rad_to_deg(90))
	$AimHelper.rotation.y = clamp($AimHelper.rotation.y, deg_to_rad(-80), rad_to_deg(80))
	$AimHelper.rotation.z = 0


func _look(delta) -> void:
	if target and target.is_inside_tree() and enemies_vis[target_i]:
		var target_pos : Vector3 = $LookHelper.to_local(target.global_position
													+ Vector3(0, 1.5, 0))
		$LookHelper.basis = $LookHelper.basis.looking_at(target_pos)
		var temp_euler : Vector3 = $LookHelper.basis.get_euler() / (PI/2)
		var eulers := Vector2(-temp_euler.y, temp_euler.x)
		
		var torso : Vector2 = anim_tree["parameters/Run/TorsoRunBlend/blend_position"]
		torso = torso.lerp(eulers, AIM_SPEED * delta)
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].x = torso.x
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].y = torso.y
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].x = torso.x
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].y = torso.y
		$LookHelper.basis = Basis()
	else:
		var torso : Vector2 = anim_tree["parameters/Run/TorsoRunBlend/blend_position"]
		torso = torso.lerp(Vector2.ZERO, AIM_SPEED * delta)
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].x = torso.x
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].y = torso.y
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].x = torso.x
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].y = torso.y


func _target_vis_change(new_target_vis) -> void:
	if new_target_vis:
		$TargetTimer.stop()
	else:
		trigger_pulled = false
		$TargetTimer.start()


func target_lost() -> void:
	target = null
	target_i = -1
	_new_rand_nav_point()


func _new_rand_nav_point() -> void:
	var new_nav_point = current_level.get_nav_point()
	nav_agent.target_position = new_nav_point.position


func _stuck() -> void:
	if stuck_times < 1:
		_jump()
		stuck_times += 1
	else:
		_new_rand_nav_point()
		stuck_times = 0


func _jump() -> void:
	velocity.y = JUMP_VELOCITY


func take_damage(body_seg : Area3D, damage : int, shooter : PuppetCharacter) -> void:
	damage *= 2
	set_new_target(shooter, enemies.find(shooter))
	super(body_seg, damage, shooter)


func _die() -> void:
	super()
	target_lost()
	$TargetTimer.stop()


func character_killed(deceased) -> void:
	super(deceased)
	if target == deceased:
		target_lost()
		_new_rand_nav_point()


func character_spawned(just_born, is_player) -> void:
	super(just_born, is_player)


func respawn() -> void:
	super()
	_new_rand_nav_point()


func _unequip_weapon(old_weapon) -> void:
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
