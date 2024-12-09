class_name Weapon
extends Node3D


@export var weapon_type : Globals.WEAPONS
@export var wielder : CharacterBase = null

# Signal to Player._update_UI and Debug._inifite_ammo
var is_reloading := false


func _ready():
	reset()


func reset() -> void:
	pass


func has_ammo():
	pass


func can_fire() -> bool:
	return $FireTimer.is_stopped()


func fire() -> void:
	$FireAudio.play()
	$FireTimer.start()


func fire_alt() -> void:
	pass


func can_reload():
	pass


func reload() -> void:
	pass


func interrupt_reload() -> void:
	if is_reloading:
		$ReloadAudio.stop()
		is_reloading = false


func get_anim(anim : String) -> String:
	return Globals.WEAPON_NAMES[weapon_type] + anim


func is_fire_anim(anim : String) -> bool:
	return anim.contains(Globals.WEAPON_NAMES[weapon_type]) and anim.contains("Shoot")
