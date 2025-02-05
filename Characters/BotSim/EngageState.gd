class_name SeekState
extends State


var frame := 0
var next_path_pos := Vector3.ZERO

var move_dir := Vector2.ZERO
var move_timer := Timer.new()
var move_time := Vector2(0.25, 1.0)
var jump_probability := 300


func _ready() -> void:
	move_timer.one_shot = true
	add_child(move_timer)


func enter() -> void:
	#print(enemy.name, ": Enter EngageState")
	next_path_pos = Vector3.ZERO
	if !enemy.target and enemy.check_enemies_visible():
		enemy.set_closest_to_target()


func exit() -> void:
	pass


func update(_delta) -> void:
	frame = get_tree().get_frame()
	
	if enemy.check_enemies_visible():
		enemy.set_closest_to_target()
	
	if !enemy.target:
		transition.emit(self, "SeekState")


func physics_update(delta) -> void:
	_aim(delta)
	_move_to_target(delta)


func _aim(delta) -> void:
	if enemy.target and enemy.enemies_vis[enemy.enemies.find(enemy.target)]:
		#if !is_inside_tree() or !enemy.target.is_inside_tree():
			#breakpoint
		var target_pos = enemy.target.global_position + Vector3(0, 1.2, 0)
		var new_trans : Transform3D = enemy.aim_helper.global_transform.looking_at(target_pos)
		enemy.aim_helper.global_transform = enemy.aim_helper.global_transform.interpolate_with \
												(new_trans, enemy.AIM_SPEED * delta)
	else:
		enemy.aim_helper.rotation = \
					enemy.aim_helper.rotation.lerp(Vector3.ZERO, enemy.AIM_SPEED * delta)
	enemy.aim_helper.rotation.x = \
					clamp(enemy.aim_helper.rotation.x, deg_to_rad(-90), rad_to_deg(90))
	enemy.aim_helper.rotation.y = \
					clamp(enemy.aim_helper.rotation.y, deg_to_rad(-80), rad_to_deg(80))
	enemy.aim_helper.rotation.z = 0


func _move_to_target(delta) -> void:
	if !enemy.target or !enemy.target.is_inside_tree():
		return
	if enemy.is_enemy_visible(enemy.target) and enemy.shoot_timer.is_stopped():
		if randi() % 40 == 0:
			enemy._throw()
		else:
			enemy.trigger_pulled = true
	
	# Start or stop target timer based on target visibility
	if !enemy.is_enemy_visible(enemy.target) and enemy.target_timer.is_stopped():
		enemy.target_timer.start(enemy.target_seek_time)
	elif enemy.is_enemy_visible(enemy.target) and enemy.target_timer.time_left:
		enemy.target_timer.stop()
	
	# Set the desired destination
	if frame % enemy.update_interval == enemy.update_offset:
		enemy.nav_agent.target_position = enemy.target.global_position
		next_path_pos = enemy.nav_agent.get_next_path_position()
	next_path_pos.y = enemy.global_position.y
	
	var input_dir : Vector2 = set_input(next_path_pos)
	
	# Turn to look at the target or path based on target visibility
	var new_transform : Transform3D
	if !enemy.is_enemy_visible(enemy.target) and enemy.is_on_floor():
		if !enemy.transform.origin.is_equal_approx(next_path_pos):
			new_transform = enemy.transform.looking_at(next_path_pos)
	else:
		var temp_pos = enemy.target.global_position
		temp_pos.y = enemy.global_position.y
		#if !is_inside_tree() or !enemy.target.is_inside_tree() or enemy.transform.origin.is_equal_approx(temp_pos):
			#breakpoint
		new_transform = enemy.transform.looking_at(temp_pos)
	enemy.transform = enemy.transform. \
						interpolate_with(new_transform, enemy.TURN_SPEED * delta)

	# Move
	var direction = (enemy.transform.basis * \
								Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var tween = create_tween()
	var weapon_blend_pos : String = "parameters/Upper/" + \
						Globals.WEAPON_NAMES[enemy.weapon_held.weapon_type] + \
														"/Alert/blend_position"
	enemy._set_speed(input_dir)
	if direction:
		tween.tween_property(enemy.anim_tree, enemy.lower_blend_pos, input_dir, 0.1)
		tween.tween_property(enemy.anim_tree, weapon_blend_pos, 1, 0.1)
		
		var accel = enemy.accel * 0.5
		enemy.velocity.x = move_toward(enemy.velocity.x, \
								direction.x * enemy.speed, accel * delta)
		enemy.velocity.z = move_toward(enemy.velocity.z, \
								direction.z * enemy.speed, accel * delta)
	else:
		tween.tween_property(enemy.anim_tree, enemy.lower_blend_pos, Vector2.ZERO, 0.1)
		tween.tween_property(enemy.anim_tree, weapon_blend_pos, -1, 0.1)
		
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.deaccel * delta)
		enemy.velocity.z = move_toward(enemy.velocity.z, 0, enemy.deaccel * delta)
	enemy.velocity.x *= enemy.move_speed_mod
	enemy.velocity.z *= enemy.move_speed_mod
	
	enemy.move_and_slide()


func set_input(path_goal : Vector3) -> Vector2:
	if !enemy.is_enemy_visible(enemy.target):
		move_timer.stop()
		return Vector2.UP
	
	# Prioritize moving to within the current weapon's range of the target
	var dist_to_target := \
					enemy.global_position.distance_to(enemy.target.global_position)
	var range := Vector2(0.75, 1.0)
	if enemy.weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		range = enemy.weapon_held.properties.dmg_falloff
	if dist_to_target > range[1] / 2:
		move_dir = Vector2.ZERO
		return Vector2(enemy.to_local(path_goal).x, 
										enemy.to_local(path_goal).z).normalized()
	elif dist_to_target < range[0] / 2:
		move_dir = Vector2.ZERO
		return Vector2.DOWN
	
	# Move randomly if within an appropriate distance of the target
	if move_timer.is_stopped():
		move_timer.start(randf_range(move_time.x, move_time.y))
		move_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	if move_dir.length() > 1:
		move_dir = move_dir.normalized()
		
	# Randomly jump
	if randi() % jump_probability == 0:
		enemy.jump()
	
	return move_dir
