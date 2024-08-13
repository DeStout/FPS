extends CharacterBase


@onready var nav_agent := $NavAgent
@export var guard_path : Node3D

var target : CharacterBase = null
var enemies_vis : Array[bool] = []

@export_exp_easing() var accuracy = 1.0
var shoot_speed_mod := 1.0/1.75
var shoot_speed_variance := Vector2(0.3, 1.0)

const GUARD_SPEED := 2.5
const TURN_SPEED := 6.0
const AIM_SPEED := 6.0
var move_speed_mod := 0.8


func _ready() -> void:
	super()
	
	if !guard_path:
		guard_path = Node3D.new()
		add_child(guard_path)
		guard_path.top_level = true
		guard_path.transform = transform
	
	enemies_vis.resize(enemies.size())
	enemies_vis.fill(false)
	
	weapons.append(Globals.WEAPONS.PISTOL)
	_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	#weapons.append(Globals.WEAPONS.SMG)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SMG))
	#weapons.append(Globals.WEAPONS.RIFLE)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
	#weapons.append(Globals.WEAPONS.SHOTGUN)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
	#weapons.append(Globals.WEAPONS.SNIPER)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SNIPER))


func _process(delta: float) -> void:
	super(delta)


func _physics_process(delta):
	super(delta)


func guard(delta) -> void:
	nav_agent.target_position = guard_path.global_position
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	next_path_pos.y = global_position.y
	
	var new_transform : Transform3D
	if nav_agent.is_navigation_finished():
		new_transform = guard_path.transform
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)
		state_machine.travel("IdleFall")
		return
	else:
		new_transform = transform.looking_at(next_path_pos)
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	# Move
	var input_dir := Vector2.ZERO
	if !nav_agent.is_navigation_finished():
		input_dir = Vector2.UP
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if global_position.distance_to(guard_path.global_position) < speed:
		speed = global_position.distance_to(guard_path.global_position)
	if direction:
		if is_on_floor():
			state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
	else:
		state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()
	speed = SPEED


func move_to_target(delta) -> void:
	if !target:
		return
	
	# Start timer to switch to GuardState if no target visible
	if !is_enemy_visible(target) and $TargetTimer.is_stopped():
		$TargetTimer.start(5.0)
	
	# Set the desired destination
	var next_path_pos := Vector3.ZERO
	nav_agent.target_position = target.global_position
	next_path_pos = nav_agent.get_next_path_position()
	next_path_pos.y = global_position.y
	
	$Debug/Box.global_position = next_path_pos
	
	# Set Input_dir based on direction to next_path_pos
	var input_dir := Vector2.ZERO
	var range : float = weapon_held.stats.range
	var dist_to = global_position.distance_to(target.global_position)
	if (dist_to > range) and is_enemy_visible(target) or !is_enemy_visible(target):
		input_dir = Vector2.UP
	
	# Turn to look at the target
	var new_transform : Transform3D
	new_transform = transform.looking_at(next_path_pos)
	transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	# Move
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
	else:
		state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()


func target_lost() -> void:
	target = null
	state_machine.travel("IdleFall")


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
	damage = 0
	if $StateMachine.current_state.name == "GuardState" and \
									$StateMachine.current_state.active == true:
		target = shooter
		$StateMachine.current_state.alert()
	super(body_seg, damage, shooter)


func _unequip_weapon(old_weapon) -> void:
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
