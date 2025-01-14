@tool
extends MeshInstance3D


var flash_threshold := 0.98
var flash_limits := Vector2(0.01, 0.3)
var flash_length := 0.05
var flash_time := 0.0


func _process(delta: float) -> void:
	if !visible:
		var flash = randf()
		if flash >= flash_threshold:
			visible = true
			flash_length = randf_range(flash_limits.x, flash_limits.y)
	else:
		if flash_time >= flash_length:
			visible = false
			flash_time = 0.0
			return
		flash_time += delta
