extends CharacterBase


@onready var nav_agent := $NavAgent

@export var player : CharacterBase
var target : CharacterBase = null
var look_target := Vector3.ZERO
var enemies_vis : Array[bool] = []

var in_range := false
var shoot_accuracy_threshold := 0.9
var shoot_speed_mod := 1.0/1.75
var shoot_speed_variance := Vector2(0.3, 1.0)

var move_speed_mod := 0.8
const TURN_SPEED := 6.0
const AIM_SPEED := 6.0
#var input_dir := Vector2.ZERO

var action := Callable()
	
	
func _ready() -> void:
	super()
	
	enemies_vis.resize(enemies.size())
	enemies_vis.fill(false)
	
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	#weapons.append(Globals.WEAPONS.SMG)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SMG))
	weapons.append(Globals.WEAPONS.RIFLE)
	_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
	#weapons.append(Globals.WEAPONS.SHOTGUN)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
	#weapons.append(Globals.WEAPONS.SNIPER)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SNIPER))


func _process(delta: float) -> void:
	super(delta)


func _physics_process(delta):
	super(delta)


func move_to_nav_target(delta) -> void:
	if !target:
		return
	
	# Switch to GuardState if navigation has been completed
	var next_path_pos := Vector3.ZERO
	if nav_agent.is_navigation_finished() and !is_enemy_visible(target):
		if $TargetTimer.is_stopped():
			$TargetTimer.start(3.0)
		state_machine.travel("IdleFall")
		return
	
	# Set the desired destination
	if is_enemy_visible(target):
		nav_agent.target_position = target.global_position
	next_path_pos = nav_agent.get_next_path_position()
	next_path_pos.y = global_position.y
	
	# Set where the bot will be looking by setting the look target.
	if target:
		look_target = target.global_position
		if !is_enemy_visible(target):
			look_target = next_path_pos
	look_target.y = global_position.y
	
	# Adjust desired destination based on current_weapons desired range
	#if target and is_enemy_visible(target):
		#var desired_range : Vector2 = weapon_held.stats.desired_range
		#var temp_path_pos := next_path_pos
		#temp_path_pos.y = target.global_position.y
		#var dist_to = temp_path_pos.distance_to(target.global_position)
		#if dist_to < desired_range.x:
			#var dir_from := target.position.normalized()
			#next_path_pos += (dir_from * (desired_range.x - dist_to))
			#next_path_pos += dir_from
	
	$Debug/Box.global_position = next_path_pos
	
	var input_dir := Vector2.ZERO
	# Set Input_dir based on direction to next_path_pos
	var desired_range : Vector2 = weapon_held.stats.desired_range
	var dist_to = global_position.distance_to(target.global_position)
	if (dist_to > desired_range.y) and is_enemy_visible(target):
		input_dir = Vector2.UP
	
	# Turn to look the look target
	var new_transform : Transform3D
	new_transform = transform.looking_at(look_target)
	transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel * delta)
	else:
		state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()


func target_lost() -> void:
	target = null



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
	super(body_seg, damage, shooter)


func _unequip_weapon(old_weapon) -> void:
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
