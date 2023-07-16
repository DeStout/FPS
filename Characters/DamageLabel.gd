extends Label3D


@export_exp_easing("positive_only") var easing
var start_pos := 0.0


func _process(delta) -> void:
	position.y = start_pos + ease($Despawn.wait_time - $Despawn.time_left, easing)


func set_txt_and_pos(pos : Vector3, dmg_txt : String) -> void:
	global_position = pos
	text = dmg_txt
	start_pos = position.y
