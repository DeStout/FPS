@tool
extends PickUp


@export var weapon_type : Globals.WEAPONS : set = _set_model
var weapon_model : Node3D
var pistol_ := preload("res://Props/Weapons/Pistol/PistolBase.tscn")
var rifle_ := preload("res://Props/Weapons/Rifle/RifleBase.tscn")
var shotgun_ := preload("res://Props/Weapons/Shotgun/ShotgunBase.tscn")


func _set_model(new_weapon_type) -> void:
	var child_count = $Model.get_children()
	weapon_type = new_weapon_type
	match weapon_type:
		Globals.WEAPONS.SLAPPER:
			weapon_type = Globals.WEAPONS.PISTOL
		Globals.WEAPONS.PISTOL:
			weapon_model = pistol_.instantiate()
			weapon_model.scale = Vector3.ONE
			weapon_model.position = Vector3.ZERO
		Globals.WEAPONS.RIFLE:
			weapon_model = rifle_.instantiate()
			weapon_model.scale = Vector3(0.5, 0.5, 0.5)
			weapon_model.position = Vector3(0, -0.025, 0.1)
		Globals.WEAPONS.SHOTGUN:
			weapon_model = shotgun_.instantiate()
			weapon_model.scale = Vector3(0.676, 0.676, 0.676)
			weapon_model.position = Vector3(0.0, -0.027, 0.026)
	if $Model.get_child_count() > 0:
		$Model.get_child(0).replace_by(weapon_model)
