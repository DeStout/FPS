extends ShapeCast3D


const MAX_DAMAGE := 75
const MIN_DAMAGE := 15

var thrower : CharacterBase = null
@onready var radius : float = shape.radius
var impulse := 500


func _explosion() -> void:
	force_update_transform()
	
	for collision in get_collision_count():
		var character = get_collider(collision)
		if !character.has_method("take_damage") or !character.is_inside_tree():
			continue
			
		var dist = character.global_position + Vector3(0, 1.8/2, 0)
		dist = global_position.distance_to(dist)
		
		var head_seg : Area3D = null
		for body_seg in character.body_segs:
			if body_seg.name == "HeadArea":
				head_seg = body_seg
		assert(head_seg != null, "Character does not have Head")
		
		var damage : Damage = Damage.new()
		damage.attacker = thrower
		damage.attacker_cam = thrower.camera
		damage.damage_type = Damage.DAMAGE_TYPES.EXPLOSIVE
		damage.body_seg_damaged = head_seg
		damage.damage_amount = int(max(MIN_DAMAGE ,\
								remap(dist, 0.0, radius, MAX_DAMAGE, MIN_DAMAGE)))
		damage.global_position = global_position
		damage.impulse = impulse
		
		character.take_damage(damage)
		
	await $Explosion.finished
	queue_free()
