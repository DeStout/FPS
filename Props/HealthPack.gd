extends Node3D
class_name HealthPack

var picked_up : Callable = _die

@export_range(0, 100) var health := 50
@export var respawn_time := 60
@export var available := true
var rotation_speed := 1.8


func _process(delta) -> void:
	$Spinner.rotate_y(rotation_speed * delta)


func _body_entered(body) -> void:
	if body is CharacterBody3D:
		if body.has_method("add_health"):
			body.add_health(health, picked_up)


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
