extends CharacterBase


signal weapon_picked_up

@onready var fp_animator : AnimationPlayer = $AimHelper/FPView/FPAnimator
@onready var fp_weapon : Node3D = %FPWeapons/SMG


func _ready() -> void:
	super()
	current_level = Globals.game.map
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	nozzle = fp_weapon.nozzle
	update_weapon_UI()


func _process(delta: float) -> void:
	super(delta)


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

	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("StrifeLeft", "StrifeRight", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction:
		if on_ladder:
			anim_state_machine.travel("Run")
			velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
			velocity.y = move_toward(velocity.y, direction.z * speed, accel * delta)
		else:
			if is_on_floor():
				anim_state_machine.travel("Run")
			velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
			velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)
	else:
		anim_state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
		if on_ladder:
			velocity.y = move_toward(velocity.y, 0, deaccel * delta)
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

	if Input.is_action_pressed("ScoreBoard"):
		%HealthMod.color.a = 1

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


func _swing() -> void:
	super()
	if fp_animator.is_playing():
		fp_animator.stop()
	fp_animator.play("Slap")


func _shoot() -> void:
	var can_shoot : bool = weapon_held.can_shoot()
	super()
	if can_shoot and weapon_held.get_weapon_type() != Globals.WEAPONS.SLAPPER \
			and !switching_weapons:
		if fp_animator.is_playing():
			fp_animator.stop()
		fp_animator.play(weapon_held.stats.shoot_anim)
	update_weapon_UI()


func _zoom() -> void:
	super()
	var zoom_level := 1.0
	var zoom_time := 0.075
	var cam = $AimHelper/Camera
	var fps_cam = $FPCanvas/SubViewportContainer/SubViewport/FPCamera
	if zoomed:
		zoom_level = weapon_held.stats.zoom_level
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cam, "fov", 75 / zoom_level, zoom_time)
		tween.tween_property(fps_cam, "fov", 75 / zoom_level, zoom_time)
		Globals.zoom_sensitibity = 0.5
		$Weapons.visible = false
		$AimHelper/FPWeapons.visible = false
		_zoom_crosshairs(true)
	else:
		_zoom_crosshairs(false)
		Globals.zoom_sensitibity = 1.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cam, "fov", 75, zoom_time)
		tween.tween_property(fps_cam, "fov", 75, zoom_time)
		$Weapons.visible = true
		$AimHelper/FPWeapons.visible = true


# Signal from Weapon.finished_reloading
func update_weapon_UI() -> void:
	if weapon_held:
		HUD.update_weapon(weapon_held.ammo_in_mag, weapon_held.stats.mag_size, \
														weapon_held.extra_ammo)


func _show_crosshairs(show) -> void:
	$FPCanvas/UI/Crosshair.visible = show


func _zoom_crosshairs(show) -> void:
	$FPCanvas/UI/Scope.visible = show


func update_leaders_UI(team_list) -> void:
	#print(team_list)
	%LeaderList.update(team_list)


func _pick_up_weapon(new_weapon) -> Node3D:
	var added_weapon = super(new_weapon)
	if added_weapon:
		# Signal to Debug
		weapon_picked_up.emit(added_weapon)

		update_weapon_UI()
	return added_weapon


func _pick_up_ammo(new_ammo : Node3D) -> void:
	super(new_ammo)
	update_weapon_UI()


func _pick_up_health(new_health : Node3D) -> void:
	super(new_health)
	update_health_UI()


func take_damage(body_seg : Area3D, 
								damage : int, shooter : CharacterBase) -> void:
	damage *= (2.0/5.0)
	super(body_seg, damage, shooter)
	_show_damage(shooter)
	update_health_UI()


func update_health_UI() -> void:
	HUD.update_health(MAX_HEALTH, MAX_ARMOR, health, armor)


func _show_damage(shooter : CharacterBase) -> void:
	var dmg_dir := Vector2(to_local(shooter.global_position).x, 
								-to_local(shooter.global_position).z).normalized()
	HUD.show_damage(dmg_dir)


func _die() -> void:
	super()


func get_fp_weapon(weapon : Node3D) -> MeshInstance3D:
	var new_fp_weapon : MeshInstance3D = null
	if weapon != null:
		var fp_weapons := $AimHelper/FPWeapons.get_children()
		fp_weapons.erase($AimHelper/FPWeapons/FPAnimator)
		for fpweapon in fp_weapons:
			if fpweapon.weapon_type == weapon.get_weapon_type():
				new_fp_weapon = fpweapon
	return new_fp_weapon


func _switch_weapon(new_weapon) -> void:
	if zoomed:
		_gun_alt()
	super(new_weapon)
	update_weapon_UI()


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
			weapon_type += weapon_held.stats.weapon_type + cycle_dir
			weapon_type %= Globals.WEAPONS.size()
			for weapon in weapons:
				if weapon == weapon_type:
					_switch_weapon(_get_weapon(weapon))
					return


func _unequip_weapon(old_weapon) -> void:
	fp_animator.play(old_weapon.stats.unequip_anim)
	await fp_animator.animation_finished
	old_weapon.visible = false
	get_fp_weapon(old_weapon).visible = false


func _equip_weapon(new_weapon) -> void:
	if weapon_held.stats.weapon_type == Globals.WEAPONS.SNIPER:
		_show_crosshairs(false)
	else:
		_show_crosshairs(true)
		
	fp_animator.play(new_weapon.stats.equip_anim)
	await get_tree().process_frame
	fp_weapon = get_fp_weapon(new_weapon)
	new_weapon.visible = true
	fp_weapon.visible = true
	nozzle = fp_weapon.nozzle
	await fp_animator.animation_finished
	super(new_weapon)
