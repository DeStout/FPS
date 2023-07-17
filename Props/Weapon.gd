extends Node3D


@export_enum ("Slapper", "Pistol", "Rifle") var weapon_type : int


var automatic := false

var max_ammo : int
var mag_size : int
var extra_ammo : int
var ammo_in_mag : int
var v_recoil : float
var h_recoil : float

signal finished_reloading
var is_reloading := false

var shot_trail_ = preload("res://Props/ShotTrail.tscn")


func _ready():
	match weapon_type:
		0:
			pass
		1:
			automatic = false
			$ShotTimer.wait_time = 0.14
			max_ammo = 48
			mag_size = 12
			v_recoil = 1.0
			h_recoil = 0.5
		2:
			automatic = true
			$ShotTimer.wait_time = 0.10
			max_ammo = 96
			mag_size = 24
			v_recoil = 2.0
			h_recoil = 1.0

	extra_ammo = max_ammo - mag_size
	ammo_in_mag = mag_size


func can_shoot() -> bool:
	var can_shoot : bool = ammo_in_mag > 0 and !is_reloading and !$ShotTimer.time_left
	return can_shoot


func shoot(collisionPoint : Vector3) -> void:
	ammo_in_mag -= 1
	$ShootAudio.play()

	var shot_trail = shot_trail_.instantiate()
	add_child(shot_trail)
	shot_trail.align_and_scale($Nozzle.global_position, collisionPoint)

	$ShotTimer.start()


func reload() -> void:
	if extra_ammo > 0 and ammo_in_mag < mag_size:
		is_reloading = true
		$ReloadAudio.play(0.0)
		await $ReloadAudio.finished

		var ammo_to_add = mag_size - ammo_in_mag
		ammo_in_mag += min(ammo_to_add, extra_ammo)
		extra_ammo = max(extra_ammo - ammo_to_add, 0)

		is_reloading = false
		finished_reloading.emit()


func interrupt_reload() -> void:
	if is_reloading:
		$ReloadAudio.stop()
		is_reloading = false
