extends Node3D


var travel_speed := 100
var travel_time := 0.0
var time := 0.0
var to := Vector3.ZERO


func _ready() -> void:
	set_process(false)


func _process(delta) -> void:
	position = position.lerp(to, time / travel_time)
	time += delta
	if time > travel_time:
		queue_free()


func align_and_scale(nozzle_point : Vector3, collision_point : Vector3) -> void:
	global_position = nozzle_point
	to = collision_point
	basis = basis.looking_at(to_local(collision_point))
	travel_time = (nozzle_point - collision_point).length() / travel_speed
	
	set_process(true)
