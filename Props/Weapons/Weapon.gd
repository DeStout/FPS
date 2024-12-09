extends Node3D


@export var stats : Resource
var extra_ammo : int
var ammo_in_mag : int

var slappable := []

# Signal to Player._update_UI and Debug._inifite_ammo
var is_reloading := false


func _ready():
	$ShotTimer.wait_time = 1.0 / stats.shots_per_second
	reset()


func reset() -> void:
	ammo_in_mag = stats.mag_size
	extra_ammo = stats.max_ammo - stats.mag_size


func can_shoot() -> bool:
	var able_to_shoot : bool = ((ammo_in_mag > 0 and !is_reloading) or \
								stats.weapon_type == Globals.WEAPONS.SLAPPER) \
													and $ShotTimer.is_stopped()
	return able_to_shoot


func shoot() -> void:
	if stats.weapon_type != Globals.WEAPONS.SLAPPER:
		ammo_in_mag -= 1
	$ShootAudio.play()
	$ShotTimer.start()


func reload() -> void:
	if can_reload():
		is_reloading = true
		$ReloadAudio.play()
		await $ReloadAudio.finished

		var ammo_to_add = stats.mag_size - ammo_in_mag
		ammo_in_mag += min(ammo_to_add, extra_ammo)
		extra_ammo = max(extra_ammo - ammo_to_add, 0)

		is_reloading = false


func can_reload() -> bool:
	return extra_ammo > 0 and ammo_in_mag < stats.mag_size


func interrupt_reload() -> void:
	if is_reloading:
		$ReloadAudio.stop()
		is_reloading = false


func can_pick_up_ammo() -> bool:
	return extra_ammo < stats.max_ammo - stats.mag_size


func add_ammo(new_ammo : int) -> void:
	extra_ammo = min(extra_ammo + new_ammo, stats.max_ammo - stats.mag_size)


func has_ammo() -> bool:
	return ammo_in_mag + extra_ammo > 0


func _add_slappable(body: Node3D) -> void:
	if body.is_in_group("players"):
		slappable.append(body)


func _remove_slappable(body: Node3D) -> void:
	if slappable.has(body):
		slappable.erase(body)


func get_weapon_type() -> int:
	return stats.weapon_type


func is_automatic() -> bool:
	return stats.automatic


func is_burst_fire() -> bool:
	return stats.burst_fire


func get_burst_num() -> int:
	return stats.burst_num


func get_burst_variance() -> float:
	return stats.burst_variance


func get_mag_size() -> int:
	return stats.mag_size


func get_v_recoil() -> float:
	return stats.v_recoil


func get_h_recoil() -> float:
	return stats.h_recoil


func get_anim_pos() -> Vector2:
	return stats.anim_pos


func get_body_dmg() -> Dictionary:
	return stats.body_dmg


func is_shoot_anim(shoot_anim : String) -> bool:
	if stats.weapon_type == Globals.WEAPONS.SLAPPER:
		var slap_anims := ["SlapperSlap1", "SlapperSlap2"]
		return slap_anims.has(shoot_anim)
	else:
		return shoot_anim == stats.shoot_anim
