extends ShapeCast3D


const MAX_DAMAGE := 75
const MIN_DAMAGE := 15

@onready var radius : float = $Mesh.mesh.radius
var thrower : CharacterBase = null


func _explosion() -> void:
	force_update_transform()
	
	for collision in get_collision_count():
		var character = get_collider(collision)
		if !character.has_method("take_damage"):
			return
			
		var dist = character.global_position + Vector3(0, 1.8/2, 0)
		dist = global_position.distance_to(dist)
		var damage = int(max(MIN_DAMAGE ,remap(dist, 0.0, radius, MAX_DAMAGE, MIN_DAMAGE)))
		character.take_damage(damage, thrower)
		
	await $Explosion.finished
	queue_free()
