class_name Weapon extends Node3D


@export var weapon_type : Globals.WEAPONS
@export var wielder : CharacterBase = null
var fp_weapon : FPWeapon = null
@export var impulse := 150

var fire_time := 0.0

var is_reloading := false
var is_throwing := false


func _process(delta: float) -> void:
	if fire_time > 0.0:
		fire_time = max(0.0, fire_time - delta)


func _ready():
	reset()


func reset() -> void:
	pass


func has_ammo():
	pass


func can_fire() -> bool:
	return fire_time == 0.0 and !is_throwing


func fire() -> void:
	$FireAudio.play()


func fire_alt() -> void:
	pass


func can_reload():
	pass


func reload() -> void:
	pass


func interrupt_reload() -> void:
	if is_reloading:
		wielder.interrupt_reload()
		$ReloadAudio.stop()
		is_reloading = false


func get_anim(anim : String) -> String:
	return Globals.WEAPON_NAMES[weapon_type] + anim


func is_fire_anim(anim : String) -> bool:
	return anim.contains("Shoot")
