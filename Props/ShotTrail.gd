extends Node3D


var travel_speed := 200
var travel_time := 0.0
var time := 0.0
var from := Vector3.ZERO
var to := Vector3.ZERO


func _ready() -> void:
	set_process(false)


func _process(delta) -> void:
	if time > travel_time:
		call_deferred("queue_free")
	global_position = from.lerp(to, time / travel_time)
	time += delta


func align_and_scale(nozzle_point : Vector3, collision_point : Vector3) -> void:
	from = nozzle_point
	global_position = nozzle_point
	to = collision_point
	basis = basis.looking_at(to_local(to))
	travel_time = (from - to).length() / travel_speed
	
	set_process(true)
