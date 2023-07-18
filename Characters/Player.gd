extends CharacterBase

const WEAPON_ALIGNMENTS := [Vector3(),
							Vector3(0.115, -0.14, -0.31), 		# Pistol
							Vector3(0.125, -0.21, -0.315)] 		# Rifle

const MOUSE_HORZ_SENSITIVITY := -0.002
const MOUSE_VERT_SENSITIVITY := -0.002
const LOOK_SENSITIVITY := 0.05


func _ready() -> void:
	super()
	var pistol = pick_up_weapon(Globals.WEAPONS.PISTOL)
	pick_up_weapon(Globals.WEAPONS.RIFLE)
	_switch_weapon(pistol)
	_update_UI()

func _physics_process(delta) -> void:
	super(delta)

	# Controller Look
	var look_dir = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")
	if look_dir:
		$AimHelper.rotate_x(LOOK_SENSITIVITY * -look_dir.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(LOOK_SENSITIVITY * -look_dir.x)
		rotation.z = 0

	var accel = ACCEL
	var deaccel = DEACCEL
	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = JUMP_VELOCITY
	else:
		accel = AIR_ACCEL
		deaccel = AIR_DEACCEL
	var input_dir = Input.get_vector("StrifeLeft", "StrifeRight", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction:
		state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel)
	else:
		state_machine.travel("Idle")
		velocity.x = move_toward(velocity.x, 0, deaccel)
		velocity.z = move_toward(velocity.z, 0, deaccel)
	move_and_slide()

#	if Input.is_action_pressed("Shoot"):
#		_shoot()
#		_update_UI()


func _input(event) -> void:
	# Mouse Look
	if event is InputEventMouseMotion:
		$AimHelper.rotate_x(MOUSE_HORZ_SENSITIVITY * event.relative.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(MOUSE_HORZ_SENSITIVITY * event.relative.x)
		rotation.z = 0


func _unhandled_input(event):
	if Input.is_action_just_pressed("Shoot"):
		trigger_pulled = true
	if Input.is_action_just_released("Shoot"):
		trigger_pulled = false

	if Input.is_action_just_pressed("Reload"):
		_reload()

	# Keyboard weapon switching
	if Input.is_action_just_pressed("Weapon1"):
		if _have_weapon(Globals.WEAPONS.RIFLE):
			weapon_held.interrupt_reload()
			_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
#			weapon_held = $AimHelper/FPWeapons/Pistol
#			$AimHelper/FPWeapons/Rifle.visible = false
#			$AimHelper/Weapons/Rifle.visible = false
#			$AimHelper/FPWeapons/Pistol.visible = true
#			$AimHelper/Weapons/Pistol.visible = true
#			_update_UI()
#			var tween = create_tween()
#			tween.tween_property(anim_tree, \
#				"parameters/Idle/IdleUpper_Blend/blend_position", \
#										Vector2(1.0, 1.0), 0.25)
#			tween.tween_property(anim_tree, \
#				"parameters/Run/RunUpper_Blend/blend_position", \
#										Vector2(1.0, 1.0), 0.25)
	elif Input.is_action_just_pressed("Weapon2"):
		if _have_weapon(Globals.WEAPONS.RIFLE):
			weapon_held.interrupt_reload()
			_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
#		if weapon_held != $AimHelper/FPWeapons/Rifle:
#			weapon_held.interrupt_reload()
#			weapon_held = $AimHelper/FPWeapons/Rifle
#			$AimHelper/FPWeapons/Pistol.visible = false
#			$AimHelper/Weapons/Pistol.visible = false
#			$AimHelper/FPWeapons/Rifle.visible = true
#			$AimHelper/Weapons/Rifle.visible = true
#			_update_UI()
#			var tween = get_tree().create_tween()
#			tween.tween_property(anim_tree, \
#				"parameters/Idle/IdleUpper_Blend/blend_position", \
#										Vector2(1.0, -1.0), 0.25)
#			tween.tween_property(anim_tree, \
#				"parameters/Run/RunUpper_Blend/blend_position", \
#										Vector2(1.0, -1.0), 0.25)
	elif Input.is_action_just_pressed("Weapon3"):
		pass

	# Controller weapon switching
	if Input.is_action_just_pressed("SwitchWeapon"):
		if weapon_held:
			weapon_held.interrupt_reload()
			for weapon_type in range(Globals.WEAPONS.size()):
				weapon_type += weapon_held.weapon_type + 1
				for weapon in weapons.get_children():
					if weapon.weapon_type == (weapon_type % Globals.WEAPONS.size()):
						_switch_weapon(weapon)
						return

#		if weapon_held == $AimHelper/FPWeapons/Rifle:
#			weapon_held.interrupt_reload()
#			weapon_held = $AimHelper/FPWeapons/Pistol
#			$AimHelper/FPWeapons/Rifle.visible = false
#			$AimHelper/Weapons/Rifle.visible = false
#			$AimHelper/FPWeapons/Pistol.visible = true
#			$AimHelper/Weapons/Pistol.visible = true
#			_update_UI()
#			var tween = create_tween()
#			tween.tween_property(anim_tree, \
#				"parameters/Idle/IdleUpper_Blend/blend_position", \
#										Vector2(1.0, 1.0), 0.25)
#			tween.tween_property(anim_tree, \
#				"parameters/Run/RunUpper_Blend/blend_position", \
#										Vector2(1.0, 1.0), 0.25)
#		elif weapon_held == $AimHelper/FPWeapons/Pistol:
#			weapon_held.interrupt_reload()
#			weapon_held = $AimHelper/FPWeapons/Rifle
#			$AimHelper/FPWeapons/Pistol.visible = false
#			$AimHelper/Weapons/Pistol.visible = false
#			$AimHelper/FPWeapons/Rifle.visible = true
#			$AimHelper/Weapons/Rifle.visible = true
#			_update_UI()
#			var tween = get_tree().create_tween()
#			tween.tween_property(anim_tree, \
#				"parameters/Idle/IdleUpper_Blend/blend_position", \
#										Vector2(1.0, -1.0), 0.25)
#			tween.tween_property(anim_tree, \
#				"parameters/Run/RunUpper_Blend/blend_position", \
#										Vector2(1.0, -1.0), 0.25)

func _shoot() -> void:
	super()
	_update_UI()


func _update_UI() -> void:
	if weapon_held:
		%AmmoInMag.text = str(weapon_held.ammo_in_mag) + \
							" / " + str(weapon_held.mag_size)
		%ExtraAmmo.text = str(weapon_held.extra_ammo)


func pick_up_weapon(new_weapon) -> Node3D:
	var added_weapon = super(new_weapon)
	if added_weapon:
		added_weapon.position = WEAPON_ALIGNMENTS[new_weapon]
	added_weapon.finished_reloading.connect(_update_UI)
	_update_UI()
	return added_weapon


func _switch_weapon(new_weapon) -> void:
	super(new_weapon)
	_update_UI()
