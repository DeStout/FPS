@tool
extends PickUp


var grenade_ := load("res://Props/Weapons/Grenade/GrenadeBase.tscn")

@export var weapon_type : Globals.WEAPONS : set = _set_model
@export var weapon_model : MeshInstance3D
var rotate_rate := 2.0


func _process(delta) -> void:
	$Model.rotate_y(rotate_rate * delta)


func _set_model(new_ammo_type : int) -> void:
	var child_count = $Model.get_children()
	weapon_type = new_ammo_type
	match weapon_type:
		Globals.WEAPONS.GRENADE:
			weapon_model = grenade_.instantiate()
		_:
			weapon_type = Globals.WEAPONS.GRENADE
			assert(false, "AmmoPickUp._set_model: Not an available ammo type")
			
	if $Model.get_child_count() > 0:
		$Model.get_child(0).replace_by(weapon_model)
