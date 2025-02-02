class_name Player extends CharacterBase

@onready var cam := $AimHelper/Camera
@onready var fp_cam := $AimHelper/FirstPerson/FPCanvas/SubVpContainer/SubVp/FPCamera
@onready var fp_shader : MeshInstance3D = $AimHelper/FirstPerson/FPCanvas/ \
											SubVpContainer/SubVp/FPCamera/Shader
@onready var first_person := $AimHelper/FirstPerson

@export var has_start_weapon := false
@export var start_weapon : Globals.WEAPONS


func _ready() -> void:
	super()
	
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)
	HUD.update_grenades(grenade_count)
	nozzle = $AimHelper/FirstPerson/Nozzle
	
	if has_start_weapon:
		add_weapon(Globals.weapons[start_weapon].instantiate())


func _process(delta: float) -> void:
	super(delta)
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.bloom_reticle(weapon_held.get_variance_perc())


func _physics_process(delta) -> void:
	super(delta)

	# Controller Look
	var look_dir = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")
	if look_dir:
		$AimHelper.rotate_x(-Globals.invert_y_to_int() * \
							Globals.controller_sensitivity * \
							Globals.zoom_sensitibity * -look_dir.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(Globals.controller_sensitivity * Globals.zoom_sensitibity * \
																-look_dir.x)
		rotation.z = 0

	if Input.is_action_just_pressed("Jump"):
		jump()
		
	var input_dir = Input.get_vector("StrifeLeft", "StrifeRight", "Forward", "Backward")
	var direction := basis * Vector3(input_dir.x, 0, input_dir.y)
		
	var tween = create_tween()
	var weapon_blend_pos : String = "parameters/Upper/" + \
			Globals.WEAPON_NAMES[weapon_held.weapon_type] + "/Alert/blend_position"
			
	_set_speed(input_dir)
	if direction:
		tween.tween_property(anim_tree, lower_blend_pos, input_dir, 0.1)
		tween.tween_property(anim_tree, weapon_blend_pos, 1, 0.1)
		
		if ladder:
			velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
			velocity.y = move_toward(velocity.y, \
							-ladder.basis.z.dot(direction) * speed, accel * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
		else:
			velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
		
		if !weapon_held.is_fire_anim(first_person.animator.current_animation) and \
							!weapon_held.is_reloading and !switching_weapons:
			first_person.animator.play(weapon_held.get_anim("Run"))
	else:
		tween.tween_property(anim_tree, lower_blend_pos, Vector2.ZERO, 0.1)
		tween.tween_property(anim_tree, weapon_blend_pos, -1, 0.1)
		
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
		if ladder:
			velocity.y = move_toward(velocity.y, 0, deaccel * delta)
		
		if first_person.animator.current_animation == weapon_held.get_anim("Run") \
					or !first_person.animator.is_playing() and !switching_weapons:
			first_person.animator.play(weapon_held.get_anim("Idle"))
	move_and_slide()


func _input(event) -> void:
	if Input.is_action_just_pressed("Shoot"):
		_pull_trigger()
	elif Input.is_action_just_released("Shoot"):
		trigger_pulled = false

	if Input.is_action_just_pressed("GunAlt"):
		_pull_alt()
	elif Input.is_action_just_released("GunAlt"):
		alt_pulled = false

	if Input.is_action_just_pressed("Reload"):
		_reload()
	
	if Input.is_action_just_pressed("Throw"):
		_throw()

	# Mouse Look
	if event is InputEventMouseMotion:
		$AimHelper.rotate_x(Globals.invert_y_to_int() * \
							Globals.mouse_sensitivity * \
							Globals.zoom_sensitibity * event.relative.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(-Globals.mouse_sensitivity * Globals.zoom_sensitibity * \
															event.relative.x)
		rotation.z = 0

	# Weapon Switching
	if event is InputEventKey or event is InputEventJoypadButton or \
												event is InputEventMouseButton:
		if Input.is_action_just_pressed("Weapon1"):
			if _have_weapon(Globals.WEAPONS.SLAPPER):
				weapon_held.interrupt_reload()
				_switch_weapon(_get_weapon(Globals.WEAPONS.SLAPPER))
		elif Input.is_action_just_pressed("Weapon2"):
			if _have_weapon(Globals.WEAPONS.PISTOL):
				weapon_held.interrupt_reload()
				_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
		elif Input.is_action_just_pressed("Weapon3"):
			if _have_weapon(Globals.WEAPONS.SMG):
				weapon_held.interrupt_reload()
				_switch_weapon(_get_weapon(Globals.WEAPONS.SMG))
		elif Input.is_action_just_pressed("Weapon4"):
			if _have_weapon(Globals.WEAPONS.RIFLE):
				weapon_held.interrupt_reload()
				_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
		elif Input.is_action_just_pressed("Weapon5"):
			if _have_weapon(Globals.WEAPONS.SHOTGUN):
				weapon_held.interrupt_reload()
				_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
		elif Input.is_action_pressed("CycleWeapon") or \
									Input.is_action_pressed("WeaponUp") or \
										Input.is_action_pressed("WeaponDown"):
			if !Input.is_action_pressed("ScoreBoard"):
				_cycle_switch_weapon()


func enable_screen_effect(enable : bool) -> void:
	fp_shader.visible = enable


func _fire() -> void:
	if weapon_held is BulletWeapon and weapon_held.ammo_in_mag == 0:
		_reload()
		return
	if weapon_held.can_fire() and !switching_weapons:
		weapon_held.fire()
		if first_person.animator.is_playing() and !weapon_held.is_reloading:
			first_person.animator.stop()
		first_person.animator.play(weapon_held.get_anim("Shoot"))
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, weapon_held.extra_ammo)
		HUD.bloom_reticle(weapon_held.get_variance_perc())


func _throw() -> void:
	super()
	HUD.update_grenades(grenade_count)


func zoom() -> void:
	if !first_person.current_weapon.can_zoom:
		first_person.current_weapon.was_zoomed = !first_person.current_weapon.was_zoomed
		return
		
	super()
	var zoom_level := 1.0
	var zoom_time := 0.075
	if zoomed:
		zoom_level = weapon_held.properties.zoom_level
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cam, "fov", 75 / zoom_level, zoom_time)
		tween.tween_property(fp_cam, "fov", 75 / zoom_level, zoom_time)
		Globals.zoom_sensitibity = 0.2
		first_person.show_weapon(false)
		HUD.zoom_crosshairs(true)
	else:
		first_person.show_weapon(true)
		HUD.zoom_crosshairs(false)
		HUD.show_reticle(false)
		Globals.zoom_sensitibity = 1.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cam, "fov", 75, zoom_time)
		tween.tween_property(fp_cam, "fov", 75, zoom_time)


func _set_slapper() -> void:
	super()
	first_person.add_weapon(weapon_held)
	first_person.animator.play(weapon_held.get_anim("Idle"))
	HUD.show_weapon_info(weapon_held.weapon_type != Globals.WEAPONS.SLAPPER)


func _reload() -> void:
	if weapon_held.can_reload() and !switching_weapons and !weapon_held.is_reloading:
		first_person.animator.play(weapon_held.get_anim("Reload"))
	super()


func shell_loaded() -> void:
	if weapon_held.weapon_type == Globals.WEAPONS.SHOTGUN:
		weapon_held.load_shell()
		HUD.update_weapon(weapon_held.ammo_in_mag, weapon_held.extra_ammo)
		if weapon_held.extra_ammo <= 0 or \
						weapon_held.ammo_in_mag >= weapon_held.properties.mag_size:
			return
		first_person.animator.seek(0.4)
		first_person.animator.play(weapon_held.get_anim("Reload"))


func _pick_up_weapon(new_weapon : PickUp) -> Weapon:
	var added_weapon = super(new_weapon)
	if added_weapon and weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, weapon_held.extra_ammo)
		HUD.bloom_reticle(weapon_held.get_variance_perc())
	return added_weapon


func _pick_up_ammo(new_ammo : PickUp) -> void:
	super(new_ammo)
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, weapon_held.extra_ammo)


func _pick_up_health(new_health : PickUp) -> void:
	super(new_health)
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)
	HUD.show_health()


func take_damage(damage : Damage) -> void:
	damage.damage_amount *= (2.0/5.0)
	super(damage)
	_show_damage(damage.attacker)
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)
	HUD.show_health()


func _show_damage(shooter : CharacterBase) -> void:
	if !shooter or !is_inside_tree():
		return
	var dmg_dir := Vector2(to_local(shooter.global_position).x, 
								-to_local(shooter.global_position).z).normalized()
	HUD.show_damage(dmg_dir)


func die() -> void:
	await super()
	last_damage.attacker_cam.current = true


func respawn() -> void:
	super()
	camera.current = true
	current_level.players.reset_cameras()


func reset_weapons() -> void:
	super()
	first_person.reset_weapons()
	first_person.animator.play("SlapperIdle")
	
	HUD.update_grenades(grenade_count)


func add_weapon(new_weapon : Weapon) -> void:
	if _have_weapon(new_weapon.weapon_type):
		return
	super(new_weapon)
	if new_weapon.weapon_type != Globals.WEAPONS.SLAPPER:
		new_weapon.get_node("Mesh").cast_shadow = \
						GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY


func _switch_weapon(new_weapon : Weapon) -> void:
	if zoomed:
		_gun_alt()
	super(new_weapon)
	HUD.show_weapon_info(weapon_held.weapon_type != Globals.WEAPONS.SLAPPER)
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, weapon_held.extra_ammo)
		HUD.bloom_reticle(weapon_held.get_variance_perc())


func _cycle_switch_weapon() -> void:
	var cycle_dir := int(Input.is_action_just_pressed("CycleWeapon") or \
									Input.is_action_just_pressed("WeaponUp"))
	cycle_dir = -int(Input.is_action_just_pressed("WeaponDown")) + cycle_dir
	if cycle_dir != 0 and weapon_held:
		weapon_held.interrupt_reload()
		
		var from; var to
		if cycle_dir > 0: from = 0; to = Globals.WEAPONS.size()
		else: from = Globals.WEAPONS.size(); to = 0
		for weapon_type in range(from, to, cycle_dir):
			weapon_type += weapon_held.weapon_type + cycle_dir
			weapon_type %= Globals.WEAPONS.size()
			for weapon in weapons.get_children():
				if weapon.weapon_type == weapon_type:
					_switch_weapon(_get_weapon(weapon.weapon_type))
					return


func _unequip_weapon(old_weapon : Weapon) -> void:
	if old_weapon == null:
		return
	
	await first_person.remove_weapon(old_weapon)
	old_weapon.visible = false


func _equip_weapon(new_weapon : Weapon) -> void:
	if weapon_held.weapon_type == Globals.WEAPONS.SNIPER or \
							weapon_held.weapon_type == Globals.WEAPONS.SLAPPER:
		HUD.show_reticle(false)
	else:
		HUD.show_reticle(true)
	
	first_person.add_weapon(new_weapon)
	
	weapon_state_machine.travel("Alert")
	new_weapon.visible = true
	await first_person.animator.animation_finished
