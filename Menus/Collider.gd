extends Area3D
class_name Menu2D


func my_input_event(event : InputEvent, position : Vector3):
	var mouse_pos3d := position
	mouse_pos3d = global_transform.affine_inverse() * mouse_pos3d
	var mouse_pos2d := Vector2(mouse_pos3d.x, -mouse_pos3d.y)
	
	mouse_pos2d.x += $Mesh.mesh.size.x / 2
	mouse_pos2d.y += $Mesh.mesh.size.y / 2
	mouse_pos2d.x = mouse_pos2d.x / $Mesh.mesh.size.x
	mouse_pos2d.y = mouse_pos2d.y / $Mesh.mesh.size.y
	mouse_pos2d.x = mouse_pos2d.x * $Mesh/Viewport.size.x
	mouse_pos2d.y = mouse_pos2d.y * $Mesh/Viewport.size.y
	
	event.position = mouse_pos2d
	event.global_position = mouse_pos2d

	$Mesh/Viewport.get_viewport().push_input(event)
