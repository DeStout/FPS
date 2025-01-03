extends BotSimCharacter


@onready var fp_animator : AnimationPlayer = $AimHelper/FirstPerson/AnimationPlayer
@onready var fp_weapon_meshes := [[null],
				[$AimHelper/FirstPerson/Mannequin/Skeleton3D/PistolMag/PistolMag, 
				$AimHelper/FirstPerson/Mannequin/Skeleton3D/PistolBody/PistolBody],
				[$AimHelper/FirstPerson/Mannequin/Skeleton3D/SMGMag/SMGMag,
				$AimHelper/FirstPerson/Mannequin/Skeleton3D/SMGBody/SMGBody],
				[$AimHelper/FirstPerson/Mannequin/Skeleton3D/RifleBody/RifleBody,
				$AimHelper/FirstPerson/Mannequin/Skeleton3D/RifleMag/RifleMag],
			[$AimHelper/FirstPerson/Mannequin/Skeleton3D/ShotgunBody/ShotgunBody,
			 $AimHelper/FirstPerson/Mannequin/Skeleton3D/ShotgunPump/ShotgunPump,
			 $AimHelper/FirstPerson/Mannequin/Skeleton3D/ShotgunShell/ShotgunShell],
					[null]]


func _ready() -> void:
	super()
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)
	weapon_state_machine.travel("Alert")
	nozzle = $AimHelper/FirstPerson/Nozzle
	


func set_color(new_color : Color) -> void:
	super(new_color)
	var fp_mat : BaseMaterial3D = mat.duplicate()
	$AimHelper/FirstPerson/Mannequin/Skeleton3D/MannySurface \
										.set_surface_override_material(0, fp_mat)
	fp_mat.albedo_color = new_color


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
		
		if !weapon_held.is_fire_anim(fp_animator.current_animation) and \
							!weapon_held.is_reloading and !switching_weapons:
			fp_animator.play(weapon_held.get_anim("Run"))
	else:
		tween.tween_property(anim_tree, lower_blend_pos, Vector2.ZERO, 0.1)
		tween.tween_property(anim_tree, weapon_blend_pos, -1, 0.1)
		
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
		if ladder:
			velocity.y = move_toward(velocity.y, 0, deaccel * delta)
		
		if fp_animator.current_animation == weapon_held.get_anim("Run") or \
							!fp_animator.is_playing() and !switching_weapons:
			fp_animator.play(weapon_held.get_anim("Idle"))
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


func _fire() -> void:
	if weapon_held is BulletWeapon and weapon_held.ammo_in_mag == 0:
		_reload()
		return
	if weapon_held.can_fire() and !switching_weapons:
		weapon_held.fire()
		if fp_animator.is_playing() and !weapon_held.is_reloading:
			fp_animator.stop()
		fp_animator.play(weapon_held.get_anim("Shoot"))
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, \
						weapon_held.properties.mag_size, weapon_held.extra_ammo)
		HUD.bloom_reticle(weapon_held.get_variance_perc())


func _zoom() -> void:
	super()
	var zoom_level := 1.0
	var zoom_time := 0.075
	var cam = $AimHelper/Camera
	var fps_cam = $FPCanvas/SubViewportContainer/SubViewport/FPCamera
	if zoomed:
		zoom_level = weapon_held.properties.zoom_level
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cam, "fov", 75 / zoom_level, zoom_time)
		tween.tween_property(fps_cam, "fov", 75 / zoom_level, zoom_time)
		Globals.zoom_sensitibity = 0.5
		$Weapons.visible = false
		$AimHelper/FPWeapons.visible = false
		HUD.zoom_crosshairs(true)
	else:
		HUD.zoom_crosshairs(false)
		Globals.zoom_sensitibity = 1.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cam, "fov", 75, zoom_time)
		tween.tween_property(fps_cam, "fov", 75, zoom_time)
		$Weapons.visible = true
		$AimHelper/FPWeapons.visible = true


func _reload() -> void:
	if weapon_held.can_reload() and !switching_weapons and !weapon_held.is_reloading:
		fp_animator.play(weapon_held.get_anim("Reload"))
	await super()
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, \
						weapon_held.properties.mag_size, weapon_held.extra_ammo)


func shell_loaded() -> void:
	if weapon_held.weapon_type == Globals.WEAPONS.SHOTGUN:
		weapon_held.load_shell()
		HUD.update_weapon(weapon_held.ammo_in_mag, \
					weapon_held.properties.mag_size, weapon_held.extra_ammo)
		if weapon_held.extra_ammo <= 0 or \
						weapon_held.ammo_in_mag >= weapon_held.properties.mag_size:
			return
		fp_animator.seek(0.4)
		fp_animator.play(weapon_held.get_anim("Reload"))


func _pick_up_weapon(new_weapon : PickUp) -> Weapon:
	var added_weapon = super(new_weapon)
	if added_weapon and weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, \
							weapon_held.properties.mag_size, weapon_held.extra_ammo)
		HUD.bloom_reticle(weapon_held.get_variance_perc())
	return added_weapon


func _pick_up_ammo(new_ammo : Node3D) -> void:
	super(new_ammo)
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, \
							weapon_held.properties.mag_size, weapon_held.extra_ammo)


func _pick_up_health(new_health : Node3D) -> void:
	super(new_health)
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)
	HUD.show_health()


func take_damage(body_seg : Area3D, damage : int, shooter : CharacterBase) -> void:
	damage *= (2.0/5.0)
	super(body_seg, damage, shooter)
	_show_damage(shooter)
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)
	HUD.show_health()


func _show_damage(shooter : CharacterBase) -> void:
	var dmg_dir := Vector2(to_local(shooter.global_position).x, 
								-to_local(shooter.global_position).z).normalized()
	HUD.show_damage(dmg_dir)


func respawn() -> void:
	super()
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)


func get_fp_weapon(weapon : int) -> Array:
	var new_fp_weapon : Array = [null]
	if weapon != null:
		for i in range(fp_weapon_meshes.size()):
			if i == weapon:
				new_fp_weapon = fp_weapon_meshes[i]
	return new_fp_weapon


func add_weapon(new_weapon : Weapon) -> void:
	if _have_weapon(new_weapon.weapon_type):
		return
	new_weapon.get_node("Mesh").cast_shadow = \
						GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	super(new_weapon)


func _switch_weapon(new_weapon : Weapon) -> void:
	if zoomed:
		_gun_alt()
	super(new_weapon)
	HUD.show_weapon_info(weapon_held.weapon_type != Globals.WEAPONS.SLAPPER)
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		HUD.update_weapon(weapon_held.ammo_in_mag, \
						weapon_held.properties.mag_size, weapon_held.extra_ammo)
		HUD.bloom_reticle(weapon_held.get_variance_perc())


func _reset_weapons() -> void:
	for weapon in weapons.get_children():
		if weapon.weapon_type != Globals.WEAPONS.SLAPPER:
			_show_fp_weapon(weapon.weapon_type, false)
	super()
	fp_animator.play("SlapperIdle")


func _show_fp_weapon(weapon_type : Globals.WEAPONS, show : bool) -> void:
	var fpweapon : Array = get_fp_weapon(weapon_type)
	if fpweapon[0] != null:
		for mesh in fpweapon:
			mesh.visible = show


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
	fp_animator.play(old_weapon.get_anim("Equip"))
	await fp_animator.animation_finished
	
	old_weapon.visible = false
	_show_fp_weapon(old_weapon.weapon_type, false)


func _equip_weapon(new_weapon : Weapon) -> void:
	if weapon_held.weapon_type == Globals.WEAPONS.SNIPER:
		HUD.show_reticle(false)
	else:
		HUD.show_reticle(true)
	
	new_weapon.visible = true
	_show_fp_weapon(new_weapon.weapon_type, true)
		
	fp_animator.play_backwards(new_weapon.get_anim("Equip"))
	weapon_state_machine.travel("Alert")
	await fp_animator.animation_finished
