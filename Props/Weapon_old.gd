extends Node3D
class_name Weapon

@export var is_automatic := false
@export var max_ammo := 21
@export var mag_size := 7
@export var rps : float = 1.0
@export var v_recoil := 0.1
@export var h_recoil := 0.1
@export var consec_shots := 4.0
@export var base_damage = 10.0

@onready var pickup_sfx := $PickupSFX
@onready var pickup_sfx_3d := $PickupSFX3D
@onready var shoot_sfx := $ShootSFX
@onready var shoot_sfx_3d := $ShootSFX3D
@onready var reload_sfx := $ReloadSFX
@onready var reload_sfx_3d := $ReloadSFX3D
@onready var ammo_sfx := $AmmoSFX
@onready var ammo_sfx_3d := $AmmoSFX3D
var current_sfx = null

signal slap
var can_shoot := false
var total_ammo : int
var ammo_in_mag : int


func _ready() -> void:
	total_ammo = max_ammo
	ammo_in_mag = mag_size


func shoot(shooter : CharacterBody3D) -> void:
#	play_sfx("Shoot", shooter is Enemy)
	if max_ammo > 0:
		ammo_in_mag -= 1
	can_shoot = false
	$CanShoot.start(1.0 / rps)


func _can_shoot() -> void:
	if ammo_in_mag > 0 or max_ammo == 0:
		can_shoot = true


func reload(reloader : CharacterBody3D) -> void:
	if total_ammo > mag_size - ammo_in_mag:
		total_ammo -= mag_size-ammo_in_mag
		ammo_in_mag = mag_size
	else:
		ammo_in_mag += total_ammo
		total_ammo = 0

	if ammo_in_mag > 0:
		can_shoot = true


func play(animation : String, reverse : bool = true) -> void:
	if !reverse:
		$AnimationPlayer.play(animation)
	else:
		$AnimationPlayer.play_backwards(animation)
	await $AnimationPlayer.animation_finished


func play_sfx(sfx : String, play_3d : bool) -> void:
	match sfx:
		"Pickup":
			match play_3d:
				true:
					current_sfx = pickup_sfx_3d.play_rand()
				false:
					current_sfx = pickup_sfx.play_rand()
		"Shoot":
			match play_3d:
				true:
					current_sfx = shoot_sfx_3d.play_rand()
				false:
					current_sfx = shoot_sfx.play_rand()
		"Reload":
			match play_3d:
				true:
					current_sfx = reload_sfx_3d.play_rand()
				false:
					current_sfx = reload_sfx.play_rand()
		"Ammo":
			match play_3d:
				true:
					current_sfx = ammo_sfx_3d.play_rand()
				false:
					current_sfx = ammo_sfx.play_rand()


func stop_sfx() -> void:
	if current_sfx:
		if !(shoot_sfx.has_sfx(current_sfx) or shoot_sfx_3d.has_sfx(current_sfx)):
			current_sfx.stop()


func add_ammo(amount : int, pick_up : Callable, is_enemy : CharacterBody3D) -> bool:
	if total_ammo < max_ammo:
#		play_sfx("Ammo", is_enemy is Enemy)
		pick_up.call()
		total_ammo = clamp(total_ammo + amount, 0, max_ammo)
		return true
	return false
