extends CharacterBase


signal weapon_picked_up

@onready var fp_weapon : Node3D = $AimHelper/FPWeapons/Slapper

const MOUSE_HORZ_SENSITIVITY := -0.002
const MOUSE_VERT_SENSITIVITY := -0.002
const LOOK_SENSITIVITY := 0.05


func _ready() -> void:
	super()
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	#weapons.append(Globals.WEAPONS.RIFLE)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
	#weapons.append(Globals.WEAPONS.SHOTGUN)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
	#_equip_weapon($Weapons/Slapper)
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


func _input(event) -> void:
	if Input.is_action_just_pressed("Shoot"):
		trigger_pulled = true
	elif Input.is_action_just_released("Shoot"):
		trigger_pulled = false
		
	if Input.is_action_just_pressed("Reload"):
		_reload()
		
	# Mouse Look
	if event is InputEventMouseMotion:
		$AimHelper.rotate_x(MOUSE_HORZ_SENSITIVITY * event.relative.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(MOUSE_HORZ_SENSITIVITY * event.relative.x)
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
			if _have_weapon(Globals.WEAPONS.RIFLE):
				weapon_held.interrupt_reload()
				_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
		elif Input.is_action_just_pressed("Weapon4"):
			if _have_weapon(Globals.WEAPONS.SHOTGUN):
				weapon_held.interrupt_reload()
				_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
		
		elif Input.is_action_just_pressed("SwitchLevel"):
			print("why")
			match get_tree().current_scene.name:
				"Level1":
					get_tree().change_scene_to_file("res://Levels/Level2.tscn")
				"Level2":
					get_tree().change_scene_to_file("res://Levels/Level1.tscn")


	if event is InputEventJoypadButton:
		# Controller weapon switching
		if Input.is_action_just_pressed("SwitchWeapon"):
			if weapon_held:
				weapon_held.interrupt_reload()
				for weapon_type in range(Globals.WEAPONS.size()):
					weapon_type += weapon_held.stats.weapon_type + 1
					weapon_type %= Globals.WEAPONS.size()
					for weapon in weapons:
						if weapon == weapon_type:
							_switch_weapon(_get_weapon(weapon))
							return


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
	_update_UI()


# Signal from Weapon.finished_reloading
func _update_UI() -> void:
	if weapon_held:
		%AmmoInMag.text = str(weapon_held.ammo_in_mag) + \
							" / " + str(weapon_held.get_mag_size())
		%ExtraAmmo.text = str(weapon_held.extra_ammo)
	%Health.text = str(health)
	%Armor.text = str(armor)
	%Armor.visible = armor


func _pick_up_weapon(new_weapon) -> Node3D:
	var added_weapon = super(new_weapon)
	if added_weapon:
		# Signal to Debug
		weapon_picked_up.emit(added_weapon)

		_update_UI()
	return added_weapon


func _pick_up_ammo(new_ammo : Node3D) -> void:
	super(new_ammo)
	_update_UI()


func _pick_up_health(new_health : Node3D) -> void:
	super(new_health)
	_update_UI()


func _take_damage(damage : int, shooter : CharacterBase) -> void:
	damage *= (2.0/3.0)
	super(damage, shooter)
	_update_UI()


func _die() -> void:
	super()
	%Camera.current = false
	last_shot_by.set_current_camera(true)
	print("Death cam on ", last_shot_by.name)
	$CanvasLayer/UI.visible = false


func respawn() -> void:
	super()
	%Camera.current = true
	last_shot_by.set_current_camera(false)
	$CanvasLayer/UI.visible = true
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	weapon_held.reset()
	_update_UI()


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
	#if new_weapon != null and !switching_weapons and weapon_held != new_weapon:
	super(new_weapon)
	_update_UI()


func _unequip_weapon(old_weapon) -> void:
	%FPAnimator.play(old_weapon.stats.unequip_anim)
	await %FPAnimator.animation_finished
	get_fp_weapon(old_weapon).visible = false


func _equip_weapon(new_weapon) -> void:
	fp_weapon = get_fp_weapon(new_weapon)
	fp_weapon.visible = true
	nozzle = fp_weapon.nozzle
	%FPAnimator.play(new_weapon.stats.equip_anim)
	await %FPAnimator.animation_finished
	super(new_weapon)
