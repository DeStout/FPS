extends MeshInstance3D


var time := 0.0
@onready var start_pos := global_position


func _process(delta: float) -> void:
	global_position.x = start_pos.x + (5 * cos(time * 0.02))
	global_position.y = start_pos.y - (1.2 * sin(time * 0.08))
	global_position.z = start_pos.z + (1.2 * sin(time * 0.15))
	time += delta
