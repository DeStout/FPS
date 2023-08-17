extends Node3D


@export() var stats : Resource
var extra_ammo : int
var ammo_in_mag : int

@onready var nozzle : Node3D = get_node("Mesh/Nozzle")
var slappable := []

# Signal to Player._update_UI and Debug._inifite_ammo
signal finished_reloading
var is_reloading := false


func _ready():
	$ShotTimer.wait_time = 1.0 / stats.shots_per_second
	reset()


func reset() -> void:
	ammo_in_mag = stats.mag_size
	extra_ammo = stats.max_ammo - stats.mag_size


func can_shoot() -> bool:
	var can_shoot : bool = ((ammo_in_mag > 0 and !is_reloading) or \
		stats.weapon_type == Globals.WEAPONS.SLAPPER) and $ShotTimer.is_stopped()
	return can_shoot


func shoot() -> void:
	if stats.weapon_type != Globals.WEAPONS.SLAPPER:
		ammo_in_mag -= 1
	$ShootAudio.play()
	$ShotTimer.start()


func reload() -> void:
	if extra_ammo > 0 and ammo_in_mag < stats.mag_size:
		is_reloading = true
		$ReloadAudio.play(0.0)
		await $ReloadAudio.finished

		var ammo_to_add = stats.mag_size - ammo_in_mag
		ammo_in_mag += min(ammo_to_add, extra_ammo)
		extra_ammo = max(extra_ammo - ammo_to_add, 0)

		is_reloading = false
		finished_reloading.emit()


func interrupt_reload() -> void:
	if is_reloading:
		$ReloadAudio.stop()
		is_reloading = false


func can_pick_up_ammo() -> bool:
	return extra_ammo < stats.max_ammo - stats.mag_size


func add_ammo(new_ammo : int) -> void:
	extra_ammo = min(extra_ammo + new_ammo, stats.max_ammo - stats.mag_size)


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


func get_mag_size() -> int:
	return stats.mag_size


func get_v_recoil() -> float:
	return stats.v_recoil


func get_h_recoil() -> float:
	return stats.h_recoil


func get_anim_pos() -> Vector2:
	return stats.anim_pos
