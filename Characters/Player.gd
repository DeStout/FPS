extends CharacterBase

const MOUSE_HORZ_SENSITIVITY := -0.002
const MOUSE_VERT_SENSITIVITY := -0.002
const LOOK_SENSITIVITY := 0.05


func _ready() -> void:
	super()
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
		if weapon_held != $AimHelper/FPWeapons/Pistol:
			weapon_held.interrupt_reload()
			weapon_held = $AimHelper/FPWeapons/Pistol
			$AimHelper/FPWeapons/Rifle.visible = false
			$AimHelper/Weapons/Rifle.visible = false
			$AimHelper/FPWeapons/Pistol.visible = true
			$AimHelper/Weapons/Pistol.visible = true
			anim_tree["parameters/Idle/IdleUpper_Blend/blend_position"] = \
														Vector2(1.0, 1.0)
			anim_tree["parameters/Run/RunUpper_Blend/blend_position"] = \
														Vector2(1.0, 1.0)
			_update_UI()
	elif Input.is_action_just_pressed("Weapon2"):
		if weapon_held != $AimHelper/FPWeapons/Rifle:
			weapon_held.interrupt_reload()
			weapon_held = $AimHelper/FPWeapons/Rifle
			$AimHelper/FPWeapons/Pistol.visible = false
			$AimHelper/Weapons/Pistol.visible = false
			$AimHelper/FPWeapons/Rifle.visible = true
			$AimHelper/Weapons/Rifle.visible = true
			anim_tree["parameters/Idle/IdleUpper_Blend/blend_position"] = \
														Vector2(1.0, -1.0)
			anim_tree["parameters/Run/RunUpper_Blend/blend_position"] = \
														Vector2(1.0, -1.0)
			_update_UI()
	elif Input.is_action_just_pressed("Weapon3"):
		pass

	# Controller weapon switching
	if Input.is_action_just_pressed("SwitchWeapon"):
		if weapon_held == $AimHelper/FPWeapons/Pistol:
			weapon_held.interrupt_reload()
			weapon_held = $AimHelper/FPWeapons/Rifle
			$AimHelper/FPWeapons/Pistol.visible = false
			$AimHelper/Weapons/Pistol.visible = false
			$AimHelper/FPWeapons/Rifle.visible = true
			$AimHelper/Weapons/Rifle.visible = true
			_update_UI()
			anim_tree["parameters/Idle/IdleUpper_Blend/blend_position"] = \
														Vector2(1.0, -1.0)
			anim_tree["parameters/Run/RunUpper_Blend/blend_position"] = \
														Vector2(1.0, -1.0)
		elif weapon_held == $AimHelper/FPWeapons/Rifle:
			weapon_held.interrupt_reload()
			weapon_held = $AimHelper/FPWeapons/Pistol
			$AimHelper/FPWeapons/Rifle.visible = false
			$AimHelper/Weapons/Rifle.visible = false
			$AimHelper/FPWeapons/Pistol.visible = true
			$AimHelper/Weapons/Pistol.visible = true
			_update_UI()
			anim_tree["parameters/Idle/IdleUpper_Blend/blend_position"] = \
														Vector2(1.0, 1.0)
			anim_tree["parameters/Run/RunUpper_Blend/blend_position"] = \
														Vector2(1.0, 1.0)

func _shoot() -> void:
	super()
	_update_UI()


func _update_UI() -> void:
	%AmmoInMag.text = str(weapon_held.ammo_in_mag) + \
						" / " + str(weapon_held.mag_size)
	%ExtraAmmo.text = str(weapon_held.extra_ammo)
