extends Label3D


@export_exp_easing("positive_only") var easing
var start_pos := Vector3.ZERO
var dir_vector := Vector3.FORWARD
var rand_dir := randf_range(-PI, PI)
var rand_vel := randf_range(0.75, 1.5)


func _ready() -> void:
	dir_vector = dir_vector.rotated(Vector3.UP, rand_dir)


func _process(_delta) -> void:
	# Position change broken into individual axes because Label is top level
	position.x = start_pos.x + (ease($Despawn.wait_time - $Despawn.time_left, easing) * \
					rand_vel * dir_vector.x)
	position.y = start_pos.y + ease($Despawn.wait_time - $Despawn.time_left, easing) * \
					rand_vel
	position.z = start_pos.z + (ease($Despawn.wait_time - $Despawn.time_left, easing) * \
					rand_vel * dir_vector.z)


func set_txt_and_pos(pos : Vector3, dmg_txt : String) -> void:
	global_position = pos
	text = dmg_txt
	start_pos = position
