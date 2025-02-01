class_name CharacterBase
extends CharacterBody3D


signal defeated
signal respawned

@export var current_level : Node3D
@export var mode_func : Node
@export var enemies : Array[CharacterBase] = []
var last_damage : Damage = null

# Movement
const ACCEL := 80
const DEACCEL := 35
const AIR_ACCEL := 10.5
const AIR_DEACCEL := 1.5
const FORE_SPEED := 5.5
const STRIFE_SPEED := 4.75
const BACK_SPEED := 3.5
const ZOOM_SPEED := 3.5
const LADDER_SPEED := 4.0
const JUMP_VELOCITY := 6.0
const THROW_STRENGTH := 350

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var was_on_floor := false
var ladder : Area3D = null
var accel := ACCEL
var deaccel := DEACCEL
var speed := FORE_SPEED
var step_height := 0.0

# Health
const MAX_HEALTH := 100
const MAX_ARMOR := 50
var health := 100 : set = _set_health
var armor := 0

# Body segments / Skeleton
@onready var skeleton := $Mannequin/Mannequin/Skeleton3D
const BodySeg := preload("res://Characters/BodySeg.gd")
@onready var surface_mesh := $Mannequin/Mannequin/Skeleton3D/Surface
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

# Weapons
const MAX_GRENADES := 4
var grenade_count := 4

@export var camera : Camera3D
@onready var aim_helper := $AimHelper
@onready var weapons := $Mannequin/Mannequin/Skeleton3D/R_Hand/Weapons
@onready var weapon_held : Node3D = null
@onready var nozzle : Node3D = $Mannequin/Nozzle
@onready var shoot_cast : RayCast3D = $AimHelper/ShootCast
var trigger_pulled := false
var alt_pulled := false
var zoomed := false
var default_shot_target := Vector3(0, 0, -99)
var switching_weapons := false
var v_recoil := 0.0
var h_recoil := 0.0
var t_recoil := 0.0

#Animation
@onready var anim_tree := $Mannequin/AnimTree
@onready var upper_state_machine = $Mannequin/AnimTree["parameters/Upper/playback"]
@onready var lower_state_machine = $Mannequin/AnimTree["parameters/Lower/playback"]
@onready var weapon_state_machine : AnimationNodeStateMachinePlayback = null
var lower_blend_pos := "parameters/Lower/RunIdle/blend_position"


func _ready() -> void:
	_set_slapper()
	set_processing(false)
	for body_seg in body_segs:
		shoot_cast.add_exception(body_seg)


func _screen_entered() -> void:
	anim_tree.process_mode = Node.PROCESS_MODE_INHERIT

func _screen_exited() -> void:
	anim_tree.process_mode = Node.PROCESS_MODE_DISABLED


func set_processing(new_process) -> void:
	set_process(new_process)
	set_physics_process(new_process)
	set_process_input(new_process)


func _process(delta) -> void:
	if weapon_held:
		if trigger_pulled:
			_fire()
		elif alt_pulled:
			_gun_alt()


func _physics_process(delta) -> void:
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
	if weapon_held.weapon_type == Globals.WEAPONS.SLAPPER:
		trigger_pulled = true
		return
	elif weapon_held is BulletWeapon and weapon_held.has_ammo():
		trigger_pulled = true
		if weapon_held.ammo_in_mag > 0:
			return
		_reload()
		return
	_switch_to_next_weapon()


func _throw() -> void:
	if grenade_count > 0:
		var throw_from := $Mannequin/Mannequin/Skeleton3D/R_Hand/HandArea
		current_level.spawn_grenade(self, global_basis, throw_from.global_position, \
									-$AimHelper.global_basis.z, THROW_STRENGTH)
		grenade_count -= 1


func set_on_ladder(new_ladder : Area3D) -> void:
	ladder = new_ladder


func _pull_alt() -> void:
	alt_pulled = true


func _fire() -> void:
	if weapon_held is BulletWeapon and weapon_held.ammo_in_mag == 0:
		_reload()
		return
	weapon_held.fire()


func _gun_alt() -> void:
	weapon_held.fire_alt()
	alt_pulled = false
	if weapon_held.weapon_type == Globals.WEAPONS.SNIPER:
		zoom()


func zoom() -> void:
	zoomed = !zoomed


func _set_slapper() -> void:
	weapon_held = _get_weapon(Globals.WEAPONS.SLAPPER)
	weapon_state_machine = $Mannequin/AnimTree["parameters/Upper/Slapper/playback"]
	weapon_state_machine.travel("Alert")
	upper_state_machine.travel(Globals.WEAPON_NAMES[weapon_held.weapon_type])


func slap() -> void:
	var slappable = _get_weapon(Globals.WEAPONS.SLAPPER).slappable
	for character in slappable:
		if character != self:
			var chest_seg : Area3D = null
			for body_seg in character.body_segs:
				if body_seg.name == "ChestArea":
					chest_seg = body_seg
			assert(chest_seg != null, "Character does not have Chest")
			
			var damage := Damage.new()
			damage.attacker = self
			damage.attacker_cam = camera
			damage.damage_type = Damage.DAMAGE_TYPES.SLAP
			damage.attacking_weapon = Globals.WEAPONS.SLAPPER
			damage.body_seg_damaged = chest_seg
			damage.damage_amount = weapon_held.damage
			damage.global_position = weapon_held.global_position
			damage.impulse = weapon_held.impulse
			
			character.take_damage(damage)
			$Slapped.play()

func _reload() -> void:
	if weapon_held and !weapon_held.is_reloading and !switching_weapons:
		await weapon_held.reload()


func interrupt_reload() -> void:
	pass


func shell_loaded() -> void:
	pass


# Signaled from BodySeg / Explosion
func take_damage(damage : Damage) -> void:
	last_damage = damage
	
	# Check if friendly fire is turned on
	if mode_func != null and mode_func.has_method("take_damage"):
		if !mode_func.take_damage(damage.attacker):
			return
		
	_subtract_health(damage.damage_amount)
	if health > 0:
		$Voice.get_hurt_sfx().play()
	if current_level != null:
		current_level.spawn_damage_label(damage, $DmgLbl.global_position)


func _subtract_health(damage : int) -> void:
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


# Setter function of health
func _set_health(new_health) -> void:
	health = max(0, new_health)
	if health == 0:
		mode_func.die()


func set_enemies(new_enemies : Array[CharacterBase]):
	enemies = new_enemies.duplicate()
	if enemies.has(self):
		enemies.erase(self)


func is_enemy(character):
	return enemies.has(character)


# Called from mode_func.die() / CampaignEnemy.die()
func die() -> void:
	var death_sfx = $Voice.get_death_sfx()
	death_sfx.play()
	
	if zoomed:
		zoom()
	visible = false
	_disable_collisions(true)
	set_processing(false)
	armor = 0
	
	var body_mat = surface_mesh.mesh.surface_get_material(0)
	if surface_mesh.get_surface_override_material(0):
		body_mat = surface_mesh.get_surface_override_material(0)
	current_level.spawn_rag_doll(skeleton, global_transform, last_damage, body_mat)
	
	await death_sfx.finished
	#print("death audio: ", name)
	if !is_inside_tree():
		breakpoint
	global_position = Vector3(0, -10, 0)
	return


func respawn() -> void:
	pass


func _disable_collisions(is_disabled : bool) -> void:
	$Collision.disabled = is_disabled
	for body_seg in body_segs:
		body_seg.get_node("Shape").disabled = is_disabled


func pick_up(new_pick_up : PickUp) -> void:
	match new_pick_up.pick_up_type:
		Globals.PICK_UPS.WEAPON:
			_pick_up_weapon(new_pick_up)
		Globals.PICK_UPS.AMMO:
			_pick_up_ammo(new_pick_up)
		Globals.PICK_UPS.HEALTH:
			_pick_up_health(new_pick_up)


func _pick_up_health(new_pick_up : PickUp) -> void:
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


func _pick_up_weapon(new_pick_up : PickUp) -> Weapon:
	if !_have_weapon(new_pick_up.weapon_type):
		var new_weapon : Weapon = \
						Globals.weapons[new_pick_up.weapon_type].instantiate()
		if new_pick_up.weapon_info.size() > 0:
			new_weapon.extra_ammo = new_pick_up.weapon_info[1]
			new_weapon.ammo_in_mag = new_pick_up.weapon_info[2]
		add_weapon(new_weapon)
		if new_pick_up is PickUp:
			new_pick_up.picked_up()
		return new_weapon
	else:
		_pick_up_ammo(new_pick_up)
		
	return null


func _pick_up_ammo(new_pick_up : PickUp) -> void:
	if _have_weapon(new_pick_up.weapon_type):
		var weapon_for = _get_weapon(new_pick_up.weapon_type)
		if weapon_for is BulletWeapon and weapon_for.can_pick_up_ammo():
			weapon_for.add_ammo(_get_weapon(new_pick_up.weapon_type) \
															.properties.mag_size)
			new_pick_up.picked_up()


func rand_weapon() -> int:
	var weight := 3.0
	var spawn_weapon = randf_range(1, (Globals.WEAPONS.size()) ** weight)
	spawn_weapon = int(pow(spawn_weapon, 1.0 / weight))
	spawn_weapon = Globals.WEAPONS.size() - spawn_weapon
	return spawn_weapon


func reset_weapons() -> void:
	for weapon in weapons.get_children():
		if weapon.weapon_type != Globals.WEAPONS.SLAPPER:
			weapon.queue_free()
	weapon_held = _get_weapon(Globals.WEAPONS.SLAPPER)
	
	grenade_count = MAX_GRENADES


func sort_weapons(weapon1 : Weapon, weapon2 : Weapon) -> bool:
	return weapon1.weapon_type < weapon2.weapon_type


func add_weapon(new_weapon : Weapon) -> void:
	if _have_weapon(new_weapon.weapon_type):
		return
		
	new_weapon.wielder = self
	weapons.add_child(new_weapon)
	
	# Arrange weapons in tree lowest to highest
	for i in range(Globals.WEAPONS.size()):
		for weapon in weapons.get_children():
			if weapon.weapon_type == i:
				weapons.move_child(weapon, min(i, weapons.get_child_count()))
				break
	
	if new_weapon is BulletWeapon:
		new_weapon.position = new_weapon.properties.pos_offset
		new_weapon.rotation = new_weapon.properties.rot_offset
	
	if new_weapon.weapon_type > weapon_held.weapon_type:
		_switch_weapon(new_weapon)


func _have_weapon(weapon_type : int ) -> bool:
	for weapon in weapons.get_children():
		if weapon.weapon_type == weapon_type:
			return true
	return false


func _get_weapon(weapon_type : int) -> Weapon:
	var return_weapon : Weapon = null
	for weapon in weapons.get_children():
		if weapon.weapon_type == weapon_type:
			return_weapon = weapon
	return return_weapon


func _switch_to_next_weapon() -> void:
	#-- weapons backwards = snopaew --#
	var snopaew := []
	for weapon in weapons.get_children():
		snopaew.append(weapon.weapon_type)
	snopaew.reverse()
	for weapon_i in snopaew:
		var nopaew : Weapon  = _get_weapon(weapon_i)
		if nopaew.has_ammo() or weapon_i == Globals.WEAPONS.SLAPPER:
			_switch_weapon(nopaew)


func _switch_weapon(new_weapon : Weapon) -> void:
	assert(new_weapon != null, "CharacterBase._switch_weapon(): " \
														+ "new_weapon is null")
	if weapon_held != new_weapon and !switching_weapons:
		switching_weapons = true
		var old_weapon : Weapon = weapon_held
		if weapon_held:
			weapon_held.interrupt_reload()
		weapon_held = new_weapon
		weapon_state_machine = $Mannequin/AnimTree["parameters/Upper/" + \
				Globals.WEAPON_NAMES[new_weapon.weapon_type] + "/playback"]
		
		await _anim_weapon_switch(old_weapon, weapon_held)
		switching_weapons = false
		
		if mode_func is BotSimFunc:
			mode_func.switch_weapon(new_weapon)


func _anim_weapon_switch(old_weapon : Weapon, new_weapon : Weapon) -> void:
	upper_state_machine.travel("Holster")
	await _unequip_weapon(old_weapon)
	upper_state_machine.travel(Globals.WEAPON_NAMES[new_weapon.weapon_type])
	await _equip_weapon(new_weapon)
	return


func _unequip_weapon(_old_weapon : Weapon) -> void:
	pass


func _equip_weapon(_new_weapon : Weapon) -> void:
	pass
