class_name SeekState
extends State


var update_interval := 10


func enter() -> void:
	#print(enemy.name, ": Enter EngageState")
	
	if !enemy.target and enemy.check_enemies_visible():
		enemy.set_closest_to_target()


func exit() -> void:
	pass


func update(_delta) -> void:
	if enemy.check_enemies_visible():
		enemy.set_closest_to_target()
	
	if !enemy.target:
		transition.emit(self, "SeekState")


func physics_update(delta) -> void:
	_aim(delta)
	_move_to_target(delta)


func _aim(delta) -> void:
	if enemy.target and enemy.enemies_vis[enemy.enemies.find(enemy.target)]:
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
		enemy.trigger_pulled = true
	
	# Start timer to switch to GuardState if no target visible
	if !enemy.is_enemy_visible(enemy.target) and enemy.target_timer.is_stopped():
		enemy.target_timer.start(5.0)
	
	# Set the desired destination
	var next_path_pos := Vector3.ZERO
	enemy.nav_agent.target_position = enemy.target.global_position
	next_path_pos = enemy.nav_agent.get_next_path_position()
	next_path_pos.y = enemy.global_position.y
	
	# Set Input_dir based on direction to next_path_pos
	var input_dir := Vector2.ZERO
	var range : float = enemy.weapon_held.stats.range
	var dist_to = enemy.global_position.distance_to(enemy.target.global_position)
	if ((dist_to > range) and enemy.is_enemy_visible(enemy.target)) or \
									!enemy.is_enemy_visible(enemy.target):
		input_dir = Vector2.UP
	
	## Turn to look at the target
	var new_transform : Transform3D
	new_transform = enemy.transform.looking_at(next_path_pos)
	enemy.transform = enemy.transform. \
						interpolate_with(new_transform, enemy.TURN_SPEED * delta)
#
	## Move
	var direction = (enemy.transform.basis * \
								Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var tween = create_tween()
	var weapon_blend_pos : String = "parameters/Upper/" + \
						enemy.weapon_held.stats.state_name + "/Alert/blend_position"
	if direction:
		enemy.speed = enemy.SPEED
		var dir2 := Vector2(input_dir.x, input_dir.y)
		tween.tween_property(enemy.anim_tree, enemy.lower_blend_pos, dir2, 0.1)
		tween.tween_property(enemy.anim_tree, weapon_blend_pos, 1, 0.1)
		
		enemy.velocity.x = move_toward(enemy.velocity.x, \
								direction.x * enemy.speed, enemy.accel * delta)
		enemy.velocity.z = move_toward(enemy.velocity.z, \
								direction.z * enemy.speed, enemy.accel * delta)
	else:
		tween.tween_property(enemy.anim_tree, enemy.lower_blend_pos, Vector2.ZERO, 0.1)
		tween.tween_property(enemy.anim_tree, weapon_blend_pos, -1, 0.1)
		
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.deaccel * delta)
		enemy.velocity.z = move_toward(enemy.velocity.z, 0, enemy.deaccel * delta)
	enemy.velocity.x *= enemy.move_speed_mod
	enemy.velocity.z *= enemy.move_speed_mod
	enemy.move_and_slide()
