extends CharacterBase


signal weapon_picked_up

@onready var fp_weapon : Node3D = $AimHelper/FPWeapons/Slapper

@export_exp_easing() var health_fade


func _ready() -> void:
	super()
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	#weapons.append(Globals.WEAPONS.SMG)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SMG))
	#weapons.append(Globals.WEAPONS.RIFLE)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
	#weapons.append(Globals.WEAPONS.SHOTGUN)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
	#_equip_weapon($Weapons/Slapper)
	update_UI()


func _process(delta: float) -> void:
	super(delta)
	_fade_dmg(delta)
	_fade_health(delta)


func _physics_process(delta) -> void:
	super(delta)

	# Controller Look
	var look_dir = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")
	if look_dir:
		$AimHelper.rotate_x(-Globals.invert_y_to_int() * Globals.controller_sensitivity * \
							-look_dir.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(Globals.controller_sensitivity * -look_dir.x)
		rotation.z = 0

	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("StrifeLeft", "StrifeRight", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction:
		if is_on_floor():
			state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel * delta)
	else:
		state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	move_and_slide()


func _input(event) -> void:
	if Input.is_action_just_pressed("Shoot"):
		_pull_trigger()
	elif Input.is_action_just_released("Shoot"):
		trigger_pulled = false
		
	if Input.is_action_pressed("ScoreBoard"):
		%HealthMod.color.a = 1
		
	if Input.is_action_just_pressed("Reload"):
		_reload()
		
	# Mouse Look
	if event is InputEventMouseMotion:
		$AimHelper.rotate_x(Globals.invert_y_to_int() * Globals.mouse_sensitivity * \
							event.relative.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(-Globals.mouse_sensitivity * event.relative.x)
		rotation.z = 0

	if event is InputEventKey or event is InputEventJoypadButton:
	# Keyboard weapon switching
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
	elif event is InputEventJoypadButton or event is InputEventMouseButton:
		_cycle_switch_weapon()


func _swing() -> void:
	super()
	if %FPAnimator.is_playing():
		%FPAnimator.stop()
	%FPAnimator.play("Slap")


func _shoot() -> void:
	var can_shoot : bool = weapon_held.can_shoot()
	super()
	if can_shoot and weapon_held.get_weapon_type() != Globals.WEAPONS.SLAPPER \
			and !switching_weapons:
		if %FPAnimator.is_playing():
			%FPAnimator.stop()
		%FPAnimator.play(weapon_held.stats.shoot_anim)
	update_UI()


# Signal from Weapon.finished_reloading
func update_UI() -> void:
	if weapon_held:
		%AmmoInMag.text = str(weapon_held.ammo_in_mag) + \
							" / " + str(weapon_held.get_mag_size())
		%ExtraAmmo.text = str(weapon_held.extra_ammo)


func _pick_up_weapon(new_weapon) -> Node3D:
	var added_weapon = super(new_weapon)
	if added_weapon:
		# Signal to Debug
		weapon_picked_up.emit(added_weapon)

		update_UI()
	return added_weapon


func _pick_up_ammo(new_ammo : Node3D) -> void:
	super(new_ammo)
	update_UI()


func _pick_up_health(new_health : Node3D) -> void:
	super(new_health)
	update_health_UI()


func take_damage(body_seg : Area3D, damage : int,
												shooter : CharacterBase) -> void:
	damage *= (2.0/3.0)
	super(body_seg, damage, shooter)
	_show_damage(shooter)
	update_health_UI()


func update_health_UI() -> void:
	%HealthMod.color.a = 1
	
	# Health Boxes
	var box_count := %HealthMod/HealthBar.get_child_count()
	var health_per_box : int = MAX_HEALTH / box_count
	var filled_boxes : int = health / health_per_box
	for box_num in range(0, box_count):
		var box : ColorRect = %HealthMod/HealthBar.get_child(box_count - box_num - 1)
		if box_num < filled_boxes:
			box.color.a = 1
		elif box_num == filled_boxes:
			box.color.a = fmod(health, health_per_box) / float(health_per_box)
		else:
			box.color.a = 0

	# Armor Boxes
	box_count = %HealthMod/ArmorBar.get_child_count()
	var armor_per_box : int = MAX_ARMOR / box_count
	filled_boxes = armor / armor_per_box
	for box_num in range(0, box_count):
		var box : ColorRect = %HealthMod/ArmorBar.get_child(box_count - box_num - 1)
		if box_num < filled_boxes:
			box.color.a = 1
		elif box_num == filled_boxes:
			box.color.a = fmod(armor, armor_per_box) / float(armor_per_box)
		else:
			box.color.a = 0


func _fade_health(delta) -> void:
	if %HealthMod.color.a > 0:
		%HealthMod.color.a -= delta


func _show_damage(shooter : CharacterBase) -> void:
	var dmg_dir := Vector2(to_local(shooter.global_position).x, 
								-to_local(shooter.global_position).z).normalized()
	
	if dmg_dir.y > 0:
		$FPCanvas/UI/DMG_Up.modulate.a = dmg_dir.y
	else:
		$FPCanvas/UI/DMG_Down.modulate.a = abs(dmg_dir.y)
	if dmg_dir.x > 0:
		$FPCanvas/UI/DMG_Right.modulate.a = dmg_dir.x
	else:
		$FPCanvas/UI/DMG_Left.modulate.a = abs(dmg_dir.x)


func _fade_dmg(delta) -> void:
	if $FPCanvas/UI/DMG_Up.modulate.a > 0:
		$FPCanvas/UI/DMG_Up.modulate.a -= delta
	if $FPCanvas/UI/DMG_Left.modulate.a > 0:
		$FPCanvas/UI/DMG_Left.modulate.a -= delta
	if $FPCanvas/UI/DMG_Down.modulate.a > 0:
		$FPCanvas/UI/DMG_Down.modulate.a -= delta
	if $FPCanvas/UI/DMG_Right.modulate.a > 0:
		$FPCanvas/UI/DMG_Right.modulate.a -= delta


func _die() -> void:
	super()
	%Camera.current = false
	last_shot_by.set_current_camera(true)
	#print("Death cam on ", last_shot_by.name)
	$FPCanvas/UI.visible = false


func respawn() -> void:
	super()
	%Camera.current = true
	last_shot_by.set_current_camera(false)
	$FPCanvas/UI.visible = true
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	weapon_held.reset()
	update_UI()


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
	super(new_weapon)
	update_UI()


func _cycle_switch_weapon() -> void:
	#print("cycle")
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
	
	
		# Controller weapon switching
		#if Input.is_action_just_pressed("SwitchWeapon"):
			#if weapon_held:
				#weapon_held.interrupt_reload()
				#for weapon_type in range(Globals.WEAPONS.size()):
					#weapon_type += weapon_held.stats.weapon_type + 1
					#weapon_type %= Globals.WEAPONS.size()
					#for weapon in weapons:
						#if weapon == weapon_type:
							#_switch_weapon(_get_weapon(weapon))
							#return


func _unequip_weapon(old_weapon) -> void:
	%FPAnimator.play(old_weapon.stats.unequip_anim)
	await %FPAnimator.animation_finished
	old_weapon.visible = false
	get_fp_weapon(old_weapon).visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
	fp_weapon = get_fp_weapon(new_weapon)
	fp_weapon.visible = true
	nozzle = fp_weapon.nozzle
	%FPAnimator.play(new_weapon.stats.equip_anim)
	await %FPAnimator.animation_finished
	super(new_weapon)
