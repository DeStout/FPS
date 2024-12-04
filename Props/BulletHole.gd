extends Decal


signal exiting

const RICOCHET_CHANCE := 10
const LINGER_TIME := 30.0
const FADE_OUT_TIME := 5.0

var fade := false
var fade_time := 0.0


func _ready() -> void:
	$FadeTimer.start(LINGER_TIME)
	if randi_range(0, RICOCHET_CHANCE) == 0:
		$Ricochet.pitch_scale += randf_range(-0.2, 0.2)
		$Ricochet.play()


func _process(delta) -> void:
	if fade:
		modulate.a = 1.0 - (fade_time / FADE_OUT_TIME)
		fade_time += delta
		
		if modulate.a <= 0:
			exiting.emit(self)
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


func set_fade() -> void:
	fade = true
	$FadeTimer.stop()
