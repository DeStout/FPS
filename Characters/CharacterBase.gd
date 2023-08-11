class_name CharacterBase
extends CharacterBody3D


signal spawn_shot_trail
signal spawn_bullet_hole
signal spawn_damage_label
signal died

# Movement
const ACCEL := 3.0
const DEACCEL := 1.0
const AIR_ACCEL := 0.2
const AIR_DEACCEL := 0.03
const SPEED = 6.5
const JUMP_VELOCITY = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Health
const MAX_HEALTH := 200
const MAX_ARMOR := 50
var health := 100 : set = _set_health
var armor := 0
var body_segs : Array = []

# Weapons
var weapon_held : Node3D = null
@onready var weapons := [Globals.WEAPONS.SLAPPER]
var nozzle : Node3D = null
var trigger_pulled := false

#Animation
@onready var anim_tree = $PuppetBase/AnimationTree
@onready var state_machine = $PuppetBase/AnimationTree["parameters/playback"]

# Level
var current_level : Node3D


func _ready() -> void:
	var temp_bodysegs = get_tree().get_nodes_in_group("body_segs")
	body_segs = temp_bodysegs.filter(func(body_seg): return is_ancestor_of(body_seg))
	for body_seg in body_segs:
		%ShootCast.add_exception(body_seg)


func _process(_delta) -> void:
	if trigger_pulled and weapon_held:
		_shoot()


func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _shoot() -> void:
	if weapon_held.can_shoot():
		weapon_held.shoot()
		spawn_shot_trail.emit(nozzle.global_position, %ShootCast.get_collision_point())
		if %ShootCast.is_colliding():
			if %ShootCast.get_collider().is_in_group("body_segs"):
				var collider = %ShootCast.get_collider()
				%ShootCast.get_collider().body_seg_shot(weapon_held.weapon_type)
			elif current_level != null:
				spawn_bullet_hole.emit(%ShootCast.get_collision_point(), \
									%ShootCast.get_collision_normal())
		# Add recoil
		var v_recoil : float = ((randf() * 0.75) + 0.25) * weapon_held.v_recoil
		$AimHelper.rotate_x(deg_to_rad(v_recoil))
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		var h_recoil : float = randf_range(-1, 1) * weapon_held.h_recoil
		rotate_y(deg_to_rad(h_recoil))
		$AimHelper.rotation.z = 0
	elif weapon_held.ammo_in_mag == 0:
		_reload()

	if !weapon_held.automatic:
		trigger_pulled = false


func _reload() -> void:
	if weapon_held and !weapon_held.is_reloading:
		weapon_held.reload()


# Signaled from BodySeg
func _take_damage(damage) -> void:
	if current_level != null:
		spawn_damage_label.emit($DmgLbl.global_position, str(damage))

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
		$HurtSFX.get_children().pick_random().play()


func _set_health(new_health) -> void:
	health = max(0, new_health)
	if health == 0:
		_die()


func _die() -> void:
	visible = false
	_switch_weapon(null)
	weapons = []
	armor = 0
	_disable_collisions(true)
	set_physics_process(false)

	var death_sfx = $DeathSFX.get_children().pick_random()
	death_sfx.play()
	await death_sfx.finished

	# Signal to Level
#	drop_weapon(current_weapon)

	died.emit(self)


func respawn() -> void:
	visible = true
	_disable_collisions(false)
	set_physics_process(true)
	global_position = current_level.get_nav_point().position
	health = 100
	weapons = [Globals.WEAPONS.SLAPPER]
	print(name, " Respawned")


func _disable_collisions(is_disabled : bool) -> void:
	$Collision.disabled = is_disabled
	for body_seg in body_segs:
		body_seg.get_node("Collision").disabled = is_disabled


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
				new_weapon = $Weapons/Pistol
			Globals.WEAPONS.RIFLE:
				new_weapon = $Weapons/Rifle
		weapons.append(new_weapon.weapon_type)
		new_weapon.reset()
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
			weapon_for.add_ammo(weapon_held.mag_size)
			new_pick_up.picked_up()


func _have_weapon(weapon_type : int ) -> bool:
	return weapons.has(weapon_type)


func _get_weapon(weapon_type : int) -> Node3D:
	var new_weapon : Node3D = null
	for weapon in $Weapons.get_children():
		if weapon.weapon_type == weapon_type:
			new_weapon = weapon
	return new_weapon


func _switch_weapon(new_weapon : Node3D) -> void:
	if new_weapon != null:
		if weapon_held != new_weapon:
			if weapon_held:
				weapon_held.interrupt_reload()
				weapon_held.visible = false
			weapon_held = new_weapon
			weapon_held.visible = true
			nozzle = weapon_held.nozzle

			var tween = get_tree().create_tween()
			tween.tween_property(anim_tree, \
				"parameters/Idle/UpperIdle/blend_position", \
										weapon_held.anim_pos, 0.15)
			tween.tween_property(anim_tree, \
				"parameters/Run/UpperRun/blend_position", \
										weapon_held.anim_pos, 0.15)
	else:
		if weapon_held:
			weapon_held.interrupt_reload()
			weapon_held.visible = false
		weapon_held = null
		nozzle = null

		var tween = get_tree().create_tween()
		tween.tween_property(anim_tree, \
			"parameters/Idle/UpperIdle/blend_position", \
									Vector2(0, 1), 0.15)
		tween.tween_property(anim_tree, \
			"parameters/Run/UpperRun/blend_position", \
									Vector2(0, 1), 0.15)
