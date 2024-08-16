extends CharacterBase


@onready var state_machine := $StateMachine
@onready var nav_agent := $NavAgent
@export var guard_path : Node3D

var target : CharacterBase = null
var enemies_vis : Array[bool] = []

@export var starting_weapon : Globals.WEAPONS
var shoot_speed_mod := 1.0/2.5
var shoot_speed_variance := Vector2(0.3, 1.0)

const GUARD_SPEED := 3.0
const TURN_SPEED := 6.0
const AIM_SPEED := 1.0
var move_speed_mod := 0.8


func _ready() -> void:
	super()
	
	enemies_vis.resize(enemies.size())
	enemies_vis.fill(false)
	
	weapons.append(starting_weapon)
	_switch_weapon(_get_weapon(starting_weapon))
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	#weapons.append(Globals.WEAPONS.SMG)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SMG))
	#weapons.append(Globals.WEAPONS.RIFLE)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
	#weapons.append(Globals.WEAPONS.SHOTGUN)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
	#weapons.append(Globals.WEAPONS.SNIPER)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SNIPER))
	
	state_machine.set_physics_process(false)
	await NavigationServer3D.map_changed
	state_machine.set_physics_process(true)


func _process(delta: float) -> void:
	super(delta)


func _physics_process(delta):
	super(delta)


func guard(delta) -> void:
	if !guard_path:
		return
	if guard_path is Path3D:
		nav_agent.target_position = guard_path.path_follow.global_position
	else:
		nav_agent.target_position = guard_path.global_position
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	next_path_pos.y = global_position.y
	
	var new_transform : Transform3D
	if nav_agent.is_navigation_finished() and !(guard_path is Path3D):
		new_transform = guard_path.transform
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)
		anim_state_machine.travel("IdleFall")
		if is_on_floor():
			return
	else:
		new_transform = transform.looking_at(next_path_pos)
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)
	
	
	#var dist_to = global_position.distance_to(target.global_position)

	# Move
	var input_dir := Vector2.ZERO
	if !nav_agent.is_navigation_finished():
		input_dir = Vector2.UP
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			anim_state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
	else:
		anim_state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()


func aim(delta) -> void:
	if target and enemies_vis[enemies.find(target)]:
		var target_pos = target.global_position + Vector3(0, 1.2, 0)
		var new_trans : Transform3D = $AimHelper.global_transform.looking_at(target_pos)
		$AimHelper.global_transform = $AimHelper.global_transform.interpolate_with \
													(new_trans, AIM_SPEED * delta)
	else:
		$AimHelper.rotation = $AimHelper.rotation.lerp(Vector3.ZERO, AIM_SPEED * delta)
	$AimHelper.rotation.x = clamp($AimHelper.rotation.x, deg_to_rad(-90), rad_to_deg(90))
	$AimHelper.rotation.y = clamp($AimHelper.rotation.y, deg_to_rad(-80), rad_to_deg(80))
	$AimHelper.rotation.z = 0


func move_to_target(delta) -> void:
	if !target:
		return
	if is_enemy_visible(target) and $ShootTimer.is_stopped():
		trigger_pulled = true
	
	# Start timer to switch to GuardState if no target visible
	if !is_enemy_visible(target) and $TargetTimer.is_stopped():
		$TargetTimer.start(5.0)
	
	# Set the desired destination
	var next_path_pos := Vector3.ZERO
	nav_agent.target_position = target.global_position
	next_path_pos = nav_agent.get_next_path_position()
	next_path_pos.y = global_position.y
	
	# Set Input_dir based on direction to next_path_pos
	var input_dir := Vector2.ZERO
	var range : float = weapon_held.stats.range
	var dist_to = global_position.distance_to(target.global_position)
	if ((dist_to > range) and is_enemy_visible(target)) or !is_enemy_visible(target):
		input_dir = Vector2.UP
	
	# Turn to look at the target
	var new_transform : Transform3D
	new_transform = transform.looking_at(next_path_pos)
	transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	# Move
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			anim_state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
	else:
		anim_state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()


func target_lost() -> void:
	target = null
	anim_state_machine.travel("IdleFall")


func check_enemies_visible() -> bool:
	%TargetCast.target_position = Vector3.FORWARD
	enemies_vis.fill(false)
	var bodies = %VisionCone.get_bodies()
	for body in bodies:
		if enemies.has(body):
			%TargetCast.target_position = %TargetCast.to_local(\
										body.global_position + (Vector3.UP*1.5))
			%TargetCast.force_raycast_update()
			if %TargetCast.is_colliding() and %TargetCast.get_collider() == body:
				enemies_vis[enemies.find(body)] = true
	return enemies_vis.has(true)


func set_closest_to_target() -> void:
	if enemies.size() == 0:
		return
		
	target = enemies[0]
	var dist = global_position.distance_squared_to(target.global_position)
	for enemy in enemies:
		if enemy == target:
			continue
		var temp_dist = global_position.distance_squared_to(enemy.global_position)
		if temp_dist < dist:
			target = enemy
			dist = temp_dist


func is_enemy_visible(enemy) -> bool:
	return enemies.has(enemy) and enemies_vis[enemies.find(enemy)]


func _shoot() -> void:
	super()
	trigger_pulled = false
	var speed_variance = randf_range(shoot_speed_variance.x , shoot_speed_variance.y)
	var shoot_speed = weapon_held.stats.shots_per_second * shoot_speed_mod * speed_variance
	$ShootTimer.start(1.0 / shoot_speed)


func _swing() -> void:
	super()
	_slap()


func _jump() -> void:
	velocity.y = JUMP_VELOCITY


func take_damage(body_seg : Area3D, damage : int, shooter : CharacterBase) -> void:
	if $StateMachine.current_state.name == "GuardState" and \
									$StateMachine.current_state.active == true:
		target = shooter
		$StateMachine.current_state.alert()
	super(body_seg, damage*1.5, shooter)


func _die() -> void:
	super()
	
	if weapon_held.stats.weapon_type != Globals.WEAPONS.SLAPPER:
		var weapon_info := [weapon_held.stats.weapon_type,
								weapon_held.extra_ammo,
								weapon_held.ammo_in_mag]
		current_level.spawn_weapon_pick_up(global_position, weapon_info)
	
	call_deferred("queue_free")


func _unequip_weapon(old_weapon) -> void:
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
