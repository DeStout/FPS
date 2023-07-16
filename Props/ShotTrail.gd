extends Node3D

var color : Color

var start_alpha := 0.05
var fade_out_time := 0.35
var fade_time := 0.0


func _process(delta) -> void:
	color = $Mesh.get_active_material(0).albedo_color
	fade_time += delta
	color.a = start_alpha - (start_alpha * (fade_time / fade_out_time))
	$Mesh.get_active_material(0).albedo_color = color


	if color.a <= 0:
		queue_free()


func align_and_scale(nozzle_point : Vector3, collision_point : Vector3) -> void:
	global_position = (nozzle_point + collision_point) / 2
	$Mesh.mesh.height = (nozzle_point - collision_point).length()
