class_name BulletWeapon
extends Weapon


@export var properties : BulletWeaponProperties = null
var extra_ammo : int
var ammo_in_mag : int
@onready var variance := properties.default_variance


func _ready() -> void:
	super()
	$FireTimer.wait_time = 1.0 / properties.shots_per_second


func _process(delta: float) -> void:
	if variance > properties.default_variance:
		var reset_amt := properties.max_variance - properties.default_variance
		reset_amt = reset_amt * (delta / properties.variance_reset)
		variance = max(properties.default_variance, variance - reset_amt)


func reset() -> void:
	ammo_in_mag = properties.mag_size
	extra_ammo = properties.max_ammo - properties.mag_size


func can_fire() -> bool:
	return (ammo_in_mag > 0 and !is_reloading) and super()


func fire() -> void:
	super()
	ammo_in_mag -= 1
	
	for shot in range(properties.num_shots):
		var target_pos := Vector3.FORWARD * float(properties.dmg_falloff[1])
		wielder.shoot_cast.target_position = target_pos
		wielder.shoot_cast.rotate_x(randf_range(0 , variance))
		wielder.shoot_cast.rotate_z(randf_range(-PI, PI))
		
		_check_shot_collision()
		
		wielder.shoot_cast.rotation = Vector3.ZERO
	variance = min(properties.max_variance, variance + properties.variance_build)
	
	if !properties.automatic:
		wielder.trigger_pulled = false


func get_variance_perc() -> float:
	return (variance - properties.default_variance) / \
						(properties.max_variance - properties.default_variance)


func _check_shot_collision() -> void:
	wielder.shoot_cast.force_raycast_update()
	var level := wielder.current_level
	var nozzle_pos := wielder.nozzle.global_position
	
	if wielder.shoot_cast.is_colliding():
		var shot_collider := wielder.shoot_cast.get_collider()
		level.spawn_shot_trail(nozzle_pos, wielder.shoot_cast.get_collision_point())
		if shot_collider is BodySeg:
			shot_collider.body_seg_shot(calculate_damage(shot_collider), wielder)
		else:
			level.spawn_bullet_hole(wielder.shoot_cast.get_collision_point(),
									wielder.shoot_cast.get_collision_normal(),
									shot_collider)
	else:
		level.spawn_shot_trail(nozzle_pos, \
				wielder.shoot_cast.to_global(wielder.shoot_cast.target_position))


func calculate_damage(body_seg : BodySeg) -> int:
	var damage : int = properties.body_dmg[body_seg.body_seg]
	
	var shot_dist := wielder.global_position.distance_to(body_seg.global_position)
	if shot_dist >= properties.dmg_falloff[0]:
		damage = int(remap(shot_dist, properties.dmg_falloff[0], \
										properties.dmg_falloff[1], \
										damage, damage / 3))
	return damage


func can_reload() -> bool:
	return extra_ammo > 0 and ammo_in_mag < properties.mag_size


func reload() -> void:
	if can_reload():
		is_reloading = true
		$ReloadAudio.play()
		await $ReloadAudio.finished

		var ammo_to_add = properties.mag_size - ammo_in_mag
		ammo_in_mag += min(ammo_to_add, extra_ammo)
		extra_ammo = max(extra_ammo - ammo_to_add, 0)

		is_reloading = false


func can_pick_up_ammo() -> bool:
	return extra_ammo < properties.max_ammo - properties.mag_size


func add_ammo(new_ammo : int) -> void:
	extra_ammo = min(extra_ammo + new_ammo, properties.max_ammo - properties.mag_size)


func has_ammo() -> bool:
	return ammo_in_mag + extra_ammo > 0
