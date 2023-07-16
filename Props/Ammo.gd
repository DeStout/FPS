extends Node3D
class_name Ammo

@export_enum("Pistol", "Rifle") var weapon
@export var amount := 12
@export var respawn_time := 60
@export var available := true

var picked_up : Callable = _die


func _ready() -> void:
	match weapon:
		0:
			$Pistol.visible = true
		1:
			$Rifle.visible = true


func _body_entered(body) -> void:
	if body is CharacterBody3D:
		if body.has_method("add_ammo"):
			body.add_ammo(amount, weapon, picked_up)


func _die() -> void:
	available = false
	visible = false
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	await get_tree().create_timer(respawn_time).timeout
	_spawn()


func _spawn() -> void:
	available = true
	visible = true
	$Area3D/CollisionShape3D.disabled = false
