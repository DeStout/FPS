extends Node3D


@export var weapon_type : Globals.WEAPONS

var automatic := false
var shots_per_second : float
var max_ammo : int
var mag_size : int
var extra_ammo : int
var ammo_in_mag : int
var v_recoil : float
var h_recoil : float
var target_range : float
var anim_pos : Vector2

@onready var nozzle : Node3D = get_node("Mesh/Nozzle")

signal finished_reloading
var is_reloading := false



func _ready():
	match weapon_type:
		Globals.WEAPONS.SLAPPER:
			automatic = false
			shots_per_second = 1.0
			mag_size = 0
			v_recoil = 0
			h_recoil = 0
			target_range = 1.0
			anim_pos = Vector2(0, 1)
		Globals.WEAPONS.PISTOL:
			automatic = false
			shots_per_second = 7.143
			mag_size = 15
			v_recoil = 1.0
			h_recoil = 0.5
			target_range = 5.0
			anim_pos = Vector2(-1, -1)
		Globals.WEAPONS.RIFLE:
			automatic = true
			shots_per_second = 9.0
			mag_size = 32
			v_recoil = 2.0
			h_recoil = 1.0
			target_range = 7.5
			anim_pos = Vector2(1, -1)

	$ShotTimer.wait_time = 1.0 / shots_per_second
	reset()


func reset() -> void:
	max_ammo = mag_size * 4
	extra_ammo = max_ammo - mag_size
	ammo_in_mag = mag_size


func can_shoot() -> bool:
	var _can_shoot : bool = ammo_in_mag > 0 and !is_reloading and !$ShotTimer.time_left
	return _can_shoot


func shoot() -> void:
	ammo_in_mag -= 1
	$ShootAudio.play()
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


func can_pick_up_ammo() -> bool:
	return extra_ammo < max_ammo - mag_size


func add_ammo(new_ammo : int) -> void:
	extra_ammo = min(extra_ammo + new_ammo, max_ammo - mag_size)
