extends Camera3D


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var collision = _cast_ray_to_position(get_viewport().get_mouse_position())
		if collision:
			collision.collider.my_input_event(event, collision.position)


func _cast_ray_to_position(target_pos : Vector2):
	var result : Array[Dictionary] = []
	var to = global_position + project_ray_normal(target_pos) * 999
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, to)
	query.collide_with_areas = true
	return space_state.intersect_ray(query)
