extends RigidBody3D


@export var fuse_time := 1.25
var thrower : CharacterBase = null


func _ready() -> void:
	$Explode.start(fuse_time)


func _explode() -> void:
	thrower.current_level.spawn_explosion(thrower, global_position)
	queue_free()
