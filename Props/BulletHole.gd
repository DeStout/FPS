extends Decal

var start_alpha := 1.0
var linger_time := 120.0
var fade_out_time := 5.0
var fade_time := 0.0


func _ready() -> void:
	if randi_range(0, 7) == 0:
		$Ricochet.pitch_scale += randf_range(-0.2, 0.2)
		$Ricochet.play()


func _process(delta) -> void:
	fade_time += delta
	if fade_time >= linger_time:
		modulate.a = start_alpha - (start_alpha * ((fade_time - linger_time)/ fade_out_time))
	if modulate.a <= 0:
		queue_free()


func project_to(surf_norm : Vector3):
	var tangent : Vector3
	if surf_norm.abs().is_equal_approx(Vector3.UP):
		tangent = Vector3.FORWARD
	else:
		tangent = Vector3.UP

	var bitangent : Vector3 = surf_norm.cross(tangent)
	tangent = surf_norm.cross(bitangent)
	global_transform.basis.y = surf_norm
	global_transform.basis.z = bitangent
	global_transform.basis.x = tangent

	rotate(surf_norm, randf() * 2 * PI)
