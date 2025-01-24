class_name FPWeapon extends Node3D


var first_person : Node3D = null
var weapon : Weapon = null

@export var weapon_type : Globals.WEAPONS
@export var weapon_mesh : Array[MeshInstance3D] = []
@onready var anim_player := $AnimationPlayer

var can_zoom := true
var was_zoomed := false


func show_mesh(show : bool) -> void:
	for mesh in weapon_mesh:
		mesh.visible = show


func _slap() -> void:
	first_person.slap()


func reload_ammo() -> void:
	weapon.reload_ammo()
	HUD.update_weapon(weapon.ammo_in_mag, weapon.extra_ammo)


func reload_finished() -> void:
	print("reload finished")
	weapon.is_reloading = false


func _shell_loaded() -> void:
	first_person.shell_loaded()


func _unzoom() -> void:
	if first_person.player.zoomed:
		was_zoomed = true
		first_person.player.zoom()
	can_zoom = false


func _rezoom() -> void:
	can_zoom = true
	if was_zoomed:
		was_zoomed = false
		first_person.player.zoom()
