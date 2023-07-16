extends Node3D
class_name WeaponPickup

@export_enum("Pistol", "Rifle") var weapon
var rifle_ := "res://Props/Rifle.tscn"
var pistol_ := "res://Props/Pistol.tscn"
var pickup : Resource

@export var respawn_time := 60
@export var available := true
var rotation_speed := 1.8

var picked_up : Callable = _picked_up


func _ready() -> void:
	match weapon:
		0:
			$Spinner/Pistol.visible = true
			$Area3D/CollisionShape3D.shape.radius = 0.5
			pickup = load(pistol_)
		1:
			$Spinner/Rifle.visible = true
			$Area3D/CollisionShape3D.shape.radius = 1.5
			pickup = load(rifle_)


func _process(delta) -> void:
	if $Area3D.get_overlapping_bodies().size():
		var body_index := 0
		var picked_up : bool = _body_entered($Area3D.get_overlapping_bodies()[body_index])
#		while(!picked_up):
#			body_index += 1
#			picked_up = _body_entered($Area3D.get_overlapping_bodies()[body_index])

		for body in $Area3D.get_overlapping_bodies():
			if _body_entered(body):
				break

	$Spinner.rotate_y(rotation_speed * delta)


func _body_entered(body) -> bool:
	if body is CharacterBody3D:
		if body.has_method("pickup_weapon"):
			return body.pickup_weapon(weapon, self, picked_up)
	return false


func _picked_up() -> void:
	available = false
	visible = false
	await get_tree().create_timer(respawn_time).timeout
	_spawn()


func _spawn() -> void:
	available = true
	visible = true
