extends RigidBody3D


@export var fuse_time := 1.25
var thrower : CharacterBase = null


func _ready() -> void:
	angular_velocity.z = 1080
	angular_velocity *= thrower.transform
	
	$Explode.start(fuse_time)


func _explode() -> void:
	thrower.current_level.spawn_explosion(thrower, global_position)
	queue_free()
