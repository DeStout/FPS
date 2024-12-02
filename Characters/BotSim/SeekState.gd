class_name EngageState
extends State


var update_interval := 10
var interval_offset := randi_range(0, update_interval)
var goal : Node3D = null

const HEALTH_THRESHOLD := 33
const ARMOR_THRESHOLD := 25
const ARMOR_RANGE := 10.0


func enter() -> void:
	#print(enemy.name, ": Enter SeekState")
	pass


func exit() -> void:
	pass


func update(_delta) -> void:
	pass


func physics_update(delta) -> void:
	if get_tree().get_frame() % update_interval == interval_offset:
		if enemy.check_enemies_visible():
			transition.emit(self, "EngageState")
			return
	if goal == null:
		set_goal()
	if goal != null:
		_seek_goal(delta)


func _seek_goal(delta : float) -> void:
	enemy.nav_agent.target_position = goal.global_position
	var next_path_pos : Vector3 = enemy.nav_agent.get_next_path_position()
	next_path_pos.y = enemy.global_position.y
	
	if !enemy.global_position.is_equal_approx(next_path_pos):
		var new_transform : Transform3D = enemy.transform.looking_at(next_path_pos)
		enemy.transform = \
					enemy.transform.interpolate_with(new_transform, enemy.TURN_SPEED * delta)
		
	# Move
	var input_dir := Vector2.ZERO
	if !enemy.nav_agent.is_navigation_finished():
		input_dir = Vector2.UP
	if enemy.bot_blocking and get_tree().get_frame() % update_interval == interval_offset:
		input_dir.x = (randi_range(0, 1) * 2) - 1
		enemy.bot_blocking = false
	var direction = (enemy.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var tween := create_tween().set_parallel()
	var weapon_blend_pos : String = "parameters/Upper/" + \
						enemy.weapon_held.stats.state_name + "/Guard/blend_position"
	if direction:
		var dir2 := Vector2(input_dir.x, input_dir.y)
		tween.tween_property(enemy.anim_tree, enemy.lower_blend_pos, dir2, 0.1)
		tween.tween_property(enemy.anim_tree, weapon_blend_pos, 1, 0.1)
		
		enemy.velocity.x = \
					move_toward(enemy.velocity.x, direction.x * enemy.speed, enemy.accel * delta)
		enemy.velocity.z = \
					move_toward(enemy.velocity.z, direction.z * enemy.speed, enemy.accel * delta)
	else:
		tween.tween_property(enemy.anim_tree, enemy.lower_blend_pos, Vector2.ZERO, 0.1)
		tween.tween_property(enemy.anim_tree, weapon_blend_pos, -1, 0.1)
		
		enemy.velocity.x = move_toward(enemy.velocity.x, 0, enemy.deaccel * delta)
		enemy.velocity.z = move_toward(enemy.velocity.z, 0, enemy.deaccel * delta)
	enemy.velocity.x *= enemy.move_speed_mod
	enemy.velocity.z *= enemy.move_speed_mod
	enemy.move_and_slide()


func alert() -> void:
	transition.emit(self, "EngageState")


func set_goal() -> void:
	if enemy.health <= HEALTH_THRESHOLD:
		var health_loc = enemy.get_closest_healths(Globals.HEALTHS.HEALTH_PACK)
		if health_loc and health_loc.is_available():
			goal = health_loc
			return
	
	if enemy.weapon_held:
		if enemy.weapon_held.stats.weapon_type <= Globals.WEAPONS.PISTOL:
			var new_weapon : Globals.WEAPONS = Globals.WEAPONS.SMG
			var weapon_loc : Node3D = null
			while !weapon_loc or new_weapon == Globals.WEAPONS.size():
				weapon_loc = enemy.get_closest_weapon(new_weapon)
				new_weapon += 1
			if weapon_loc and weapon_loc.is_available():
				goal = weapon_loc
				return
		
		if enemy.weapon_held.extra_ammo == 0:
			var ammo_loc = \
						enemy.get_closest_weapon(enemy.weapon_held.stats.weapon_type)
			if ammo_loc and ammo_loc.is_available():
				goal = ammo_loc
				return
	
	var closest_armor = enemy.get_closest_healths(Globals.HEALTHS.ARMOR)
	if closest_armor and enemy.armor < ARMOR_THRESHOLD:
		if closest_armor.is_available() and enemy.global_position.distance_to \
									(closest_armor.global_position) < ARMOR_RANGE:
			goal = closest_armor
			return
	
	goal = enemy.current_level.get_nav_point()
	return


func check_pickup(pickup) -> void:
	if pickup == goal:
		set_goal()
