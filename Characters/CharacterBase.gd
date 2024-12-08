class_name CharacterBase
extends CharacterBody3D


signal defeated

@export var current_level : Node3D
@export var enemies : Array[CharacterBase] = []
var last_shot_by : CharacterBase = null

# Movement
const ACCEL := 80
const DEACCEL := 35
const AIR_ACCEL := 10.5
const AIR_DEACCEL := 1.5
const FORE_SPEED = 5.5
const STRIFE_SPEED = 4.75
const BACK_SPEED = 3.5
const ZOOM_SPEED = 3.5
const LADDER_SPEED = 4.0
const JUMP_VELOCITY = 6.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var was_on_floor := false
var ladder : Area3D = null
var accel := ACCEL
var deaccel := DEACCEL
var speed = FORE_SPEED
var step_height := 0.0

# Health
const MAX_HEALTH := 100
const MAX_ARMOR := 50
var health := 100 : set = _set_health
var armor := 0

# Body segments / Skeleton
@onready var skeleton := $Mannequin/Mannequin/Skeleton3D
const BodySeg := preload("res://Characters/BodySeg.gd")
@onready var body_segs : Array = [$Mannequin/Mannequin/Skeleton3D/Head/HeadArea,
						$Mannequin/Mannequin/Skeleton3D/Neck/NeckArea,
						$Mannequin/Mannequin/Skeleton3D/Chest/ChestArea,
						$Mannequin/Mannequin/Skeleton3D/Stomach/StomachArea,
						$Mannequin/Mannequin/Skeleton3D/Hips/HipsArea,
						$Mannequin/Mannequin/Skeleton3D/R_UpperArm/UpperArmArea,
						$Mannequin/Mannequin/Skeleton3D/R_Forearm/ForearmArea,
						$Mannequin/Mannequin/Skeleton3D/R_Hand/HandArea,
						$Mannequin/Mannequin/Skeleton3D/L_UpperArm/UpperArmArea,
						$Mannequin/Mannequin/Skeleton3D/L_Forearm/ForearmArea,
						$Mannequin/Mannequin/Skeleton3D/L_Hand/HandArea,
						$Mannequin/Mannequin/Skeleton3D/R_Thigh/ThighArea,
						$Mannequin/Mannequin/Skeleton3D/R_Shin/ShinArea,
						$Mannequin/Mannequin/Skeleton3D/R_Foot/FootArea,
						$Mannequin/Mannequin/Skeleton3D/L_Thigh/ThighArea,
						$Mannequin/Mannequin/Skeleton3D/L_Shin/ShinArea,
						$Mannequin/Mannequin/Skeleton3D/L_Foot/FootArea]
var last_body_seg_shot : BoneAttachment3D = null

# Weapons
#Globals.WEAPONS.SLAPPER
@onready var weapons := []
@onready var weapon_held : Node3D = null
@onready var nozzle : Node3D = null
var trigger_pulled := false
var alt_pulled := false
var zoomed := false
var default_shot_target := Vector3(0, 0, -99)
var switching_weapons := false
var v_recoil := 0.0
var h_recoil := 0.0
var t_recoil := 0.0

#Animation
@onready var anim_tree = $Mannequin/AnimTree
@onready var upper_state_machine = $Mannequin/AnimTree["parameters/Upper/playback"]
@onready var lower_state_machine = $Mannequin/AnimTree["parameters/Lower/playback"]
@onready var weapon_state_machine : AnimationNodeStateMachinePlayback = null
var lower_blend_pos := "parameters/Lower/RunIdle/blend_position"


func _ready() -> void:
	set_processing(false)
	for body_seg in body_segs:
		%ShootCast.add_exception(body_seg)


func set_processing(new_process) -> void:
	set_process(new_process)
	set_physics_process(new_process)
	set_process_input(new_process)
	#if new_process:
		#process_mode = PROCESS_MODE_INHERIT
	#else:
		#process_mode = PROCESS_MODE_DISABLED


func _process(delta) -> void:
	if weapon_held:
		if trigger_pulled:
			_shoot()
		elif alt_pulled:
			_gun_alt()


func _physics_process(delta) -> void:
	_apply_recoil(delta)
	
	if ladder:
		accel = ACCEL
		deaccel = DEACCEL
		lower_state_machine.travel("RunIdle")
	elif !is_on_floor():
		accel = AIR_ACCEL
		deaccel = AIR_DEACCEL
		velocity.y -= gravity * delta
		if was_on_floor:
			lower_state_machine.travel("Fall")
		was_on_floor = false
	elif is_on_floor() and !was_on_floor:
		accel = ACCEL
		deaccel = DEACCEL
		lower_state_machine.travel("RunIdle")
		was_on_floor = true


func _set_speed(input_dir : Vector2) -> void:
		if ladder:
			speed = LADDER_SPEED
			return
		if zoomed:
			speed = ZOOM_SPEED
			return
			
		var temp_speed := Vector2(input_dir.x * STRIFE_SPEED, 0)
		if input_dir.y < 0:
			temp_speed.y = input_dir.y * FORE_SPEED
		else:
			temp_speed.y = input_dir.y * BACK_SPEED
		speed = temp_speed.length()


func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _pull_trigger() -> void:
	if weapon_held.stats.weapon_type == Globals.WEAPONS.SLAPPER:
		trigger_pulled = true
		return
	elif weapon_held.has_ammo():
		trigger_pulled = true
		if weapon_held.ammo_in_mag > 0:
			return
		_reload()
		return
	_switch_to_next_weapon()


func set_on_ladder(new_ladder : Area3D) -> void:
	ladder = new_ladder


func _pull_alt() -> void:
	if weapon_held.stats.weapon_type == Globals.WEAPONS.SNIPER:
		alt_pulled = true


func _shoot() -> void:
	if weapon_held.can_shoot() and !switching_weapons:
		weapon_held.shoot()
		if weapon_held.get_weapon_type() == Globals.WEAPONS.SLAPPER:
			_swing()
		else:
			var num_shots : int = 1
			if weapon_held.is_burst_fire():
				num_shots = weapon_held.get_burst_num()
			for shot in range(num_shots):
				%ShootCast.target_position = Vector3.FORWARD * \
												weapon_held.stats.dmg_falloff[1]
				if weapon_held.is_burst_fire():
					%ShootCast.rotate_x(randf_range(-weapon_held.get_burst_variance(),
													weapon_held.get_burst_variance()))
					%ShootCast.rotate_z(randf_range(-PI, PI))
				%ShootCast.force_raycast_update()
				if %ShootCast.is_colliding():
					current_level.spawn_shot_trail(nozzle.global_position,
												%ShootCast.get_collision_point())
					if %ShootCast.get_collider() is BodySeg:
						%ShootCast.get_collider().body_seg_shot(
												weapon_held.get_body_dmg(), self)
					elif current_level != null:
						if %ShootCast.get_collider() is Door:
							pass
						else:
							current_level.spawn_bullet_hole(\
											%ShootCast.get_collision_point(), \
											%ShootCast.get_collision_normal(), \
											%ShootCast.get_collider())
				else:
					current_level.spawn_shot_trail(nozzle.global_position, \
							%ShootCast.to_global(%ShootCast.target_position))
				%ShootCast.rotation = Vector3(0, 0, 0)
				%ShootCast.target_position = Vector3.FORWARD * \
												weapon_held.stats.dmg_falloff[1]
			
			# set recoil
			v_recoil = ((randf() * 0.75) + 0.25) * weapon_held.get_v_recoil()
			#v_recoil = randf_range(-0.75, 1) * weapon_held.get_v_recoil()
			h_recoil = randf_range(-1, 1) * weapon_held.get_h_recoil()
			t_recoil = (1.0 / weapon_held.stats.shots_per_second) * .75
			if weapon_held.stats.weapon_type == Globals.WEAPONS.SHOTGUN or \
						weapon_held.stats.weapon_type == Globals.WEAPONS.SNIPER:
				t_recoil = 0.075
			v_recoil = deg_to_rad(v_recoil / weapon_held.stats.shots_per_second)
			h_recoil = deg_to_rad(h_recoil / weapon_held.stats.shots_per_second)
			
	elif weapon_held.ammo_in_mag == 0:
		_reload()

	if !weapon_held.is_automatic():
		trigger_pulled = false


func _gun_alt() -> void:
	if weapon_held.stats.weapon_type == Globals.WEAPONS.SNIPER:
		alt_pulled = false
		_zoom()


func _zoom() -> void:
	zoomed = !zoomed


func _apply_recoil(delta) -> void:
	if t_recoil > 0:
		rotation.y += h_recoil
		$AimHelper.rotation.x += v_recoil
		$AimHelper.rotation.x = min($AimHelper.rotation.x, deg_to_rad(89))
		t_recoil -= delta
	else:
		v_recoil = 0.0
		h_recoil = 0.0
		t_recoil = 0.0


func _swing() -> void:
	pass


func _slap() -> void:
	var slappable = _get_weapon(Globals.WEAPONS.SLAPPER).slappable
	for character in slappable:
		if character != self:
			var chest_seg : Area3D = null
			for body_seg in character.body_segs:
				if body_seg.name == "ChestArea":
					chest_seg = body_seg
			assert(chest_seg != null, "Character does not have Chest")
			character.take_damage(chest_seg, 
											weapon_held.stats.body_dmg[0], self)
			$Slapped.play()


func _reload() -> void:
	if weapon_held and !weapon_held.is_reloading:
		await weapon_held.reload()
	return


# Signaled from BodySeg
func take_damage(body_seg : Area3D, damage : int, shooter : CharacterBase) -> void:
	last_shot_by = shooter
	last_body_seg_shot = body_seg.get_parent()
	
	var shot_dist := global_position.distance_to(shooter.global_position)
	var dmg_falloff : Vector2 = shooter.weapon_held.stats.dmg_falloff
	if shot_dist >= dmg_falloff[0]:
		shot_dist -= dmg_falloff[0]
		var weight := shot_dist / (dmg_falloff[1] - dmg_falloff[0])
		damage = int(lerp(damage, damage / 2, weight))
	
	if armor > 0:
		var armor_dmg : int = damage / 2
		if armor > abs(armor_dmg):
			armor -= armor_dmg
			health -= damage - armor_dmg
		else:
			health -= damage - armor
			armor = 0
	else:
		health -= damage
		
	if health > 0:
		$Voice.get_hurt_sfx().play()
	
	if current_level != null:
		current_level.spawn_damage_label(body_seg.body_seg,
											$DmgLbl.global_position, str(damage))


func _set_health(new_health) -> void:
	health = max(0, new_health)
	if health == 0:
		_die()


func set_enemies(new_enemies : Array[CharacterBase]):
	enemies = new_enemies.duplicate()
	if enemies.has(self):
		enemies.erase(self)


func is_enemy(character):
	return enemies.has(character)


func _die() -> void:
	# No Connections
	defeated.emit(self)
	
	visible = false
	_disable_collisions(true)
	set_processing(false)
	
	var body_mat = $Mannequin/Mannequin/Skeleton3D/Surface.mesh.surface_get_material(0)
	if $Mannequin/Mannequin/Skeleton3D/Surface.get_surface_override_material(0):
		body_mat = $Mannequin/Mannequin/Skeleton3D/Surface.get_surface_override_material(0)
	current_level.spawn_rag_doll(skeleton, transform, \
						last_shot_by, last_body_seg_shot.name, body_mat)
	
	var death_sfx = $Voice.get_death_sfx()
	death_sfx.play()
	await death_sfx.finished


func _disable_collisions(is_disabled : bool) -> void:
	$Collision.disabled = is_disabled
	for body_seg in body_segs:
		body_seg.get_node("Shape").disabled = is_disabled


func pick_up(new_pick_up : Node3D) -> void:
	match new_pick_up.pick_up_type:
		Globals.PICK_UPS.WEAPON:
			_pick_up_weapon(new_pick_up)
		Globals.PICK_UPS.AMMO:
			_pick_up_ammo(new_pick_up)
		Globals.PICK_UPS.HEALTH:
			_pick_up_health(new_pick_up)


func _pick_up_health(new_pick_up : Node3D) -> void:
	match new_pick_up.health_type:
		Globals.HEALTHS.HEALTH_PACK:
			if health < MAX_HEALTH:
				health += new_pick_up.health_amount
				health = min(health, MAX_HEALTH)
				new_pick_up.picked_up()
		Globals.HEALTHS.ARMOR:
			if armor < MAX_ARMOR:
				armor += new_pick_up.health_amount
				armor = min(armor, MAX_ARMOR)
				new_pick_up.picked_up()


func _pick_up_weapon(new_pick_up : Node3D) -> Node3D:
	if !_have_weapon(new_pick_up.weapon_type):
		var new_weapon : Node3D
		match new_pick_up.weapon_type:
			Globals.WEAPONS.SLAPPER:
				pass
			Globals.WEAPONS.PISTOL:
				new_weapon = %Weapons/Pistol
			Globals.WEAPONS.SMG:
				new_weapon = %Weapons/SMG
			Globals.WEAPONS.RIFLE:
				new_weapon = %Weapons/Rifle
			Globals.WEAPONS.SHOTGUN:
				new_weapon = %Weapons/Shotgun
			Globals.WEAPONS.SNIPER:
				new_weapon = %Weapons/Sniper
		if new_pick_up.weapon_info.size() == 0:
			new_weapon.reset()
		else:
			new_weapon.extra_ammo = new_pick_up.weapon_info[1]
			new_weapon.ammo_in_mag = new_pick_up.weapon_info[2]
				
		weapons.append(new_weapon.stats.weapon_type)
		weapons.sort()
		if new_weapon.stats.weapon_type > weapon_held.stats.weapon_type:
			_switch_weapon(new_weapon)
		if new_pick_up is PickUp:
			new_pick_up.picked_up()
		return new_weapon
	else:
		_pick_up_ammo(new_pick_up)
		
	return null


func _pick_up_ammo(new_pick_up : Node3D) -> void:
	if _have_weapon(new_pick_up.weapon_type):
		var weapon_for = _get_weapon(new_pick_up.weapon_type)
		if weapon_for.can_pick_up_ammo():
			weapon_for.add_ammo(weapon_held.get_mag_size())
			new_pick_up.picked_up()


func _have_weapon(weapon_type : int ) -> bool:
	return weapons.has(weapon_type)


func _get_weapon(weapon_type : int) -> Node3D:
	var new_weapon : Node3D = null
	for weapon in %Weapons.get_children():
		if weapon.get_weapon_type() == weapon_type:
			new_weapon = weapon
	return new_weapon


func _switch_to_next_weapon() -> void:
	# weapons backwards = snopaew
	var snopaew = weapons.duplicate()
	snopaew.reverse()
	for weapon_i in snopaew:
		var nopaew = _get_weapon(weapon_i)
		if nopaew.has_ammo() or weapon_i == Globals.WEAPONS.SLAPPER:
			_switch_weapon(nopaew)


func _switch_weapon(new_weapon : Node3D) -> void:
	if new_weapon != null:
		if weapon_held != new_weapon and !switching_weapons:
			switching_weapons = true
			var old_weapon : Node3D
			if weapon_held:
				weapon_held.interrupt_reload()
			old_weapon = weapon_held
			weapon_held = new_weapon
			nozzle = weapon_held.nozzle
			weapon_state_machine = $Mannequin/AnimTree["parameters/Upper/" + \
									weapon_held.stats.state_name + "/playback"]
			
			await _anim_weapon_switch(old_weapon, weapon_held)
			switching_weapons = false
	else:
		assert(new_weapon != null, "Cannot switch to a NULL weapon")
		if weapon_held:
			weapon_held.interrupt_reload()
			weapon_held.visible = false
		weapon_held = null
		nozzle = null


func _anim_weapon_switch(old_weapon, new_weapon) -> void:
	upper_state_machine.travel("Holster")
	await _unequip_weapon(old_weapon)
	upper_state_machine.travel(weapon_held.stats.state_name)
	await _equip_weapon(new_weapon)
	return


func _unequip_weapon(_old_weapon) -> void:
	pass


func _equip_weapon(_new_weapon) -> void:
	pass
