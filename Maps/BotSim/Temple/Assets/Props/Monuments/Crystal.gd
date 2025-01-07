extends Node3D


@onready var crystal := $Crystal
@onready var crystal_start_pos : Vector3 = $Crystal.global_position
@export var osc_height := 0.5
@export var osc_time := 8.0
@export var rotate_time := 20.0

var time := randf() * TAU


func _ready() -> void:
	crystal.rotate_y(time)


func _process(delta: float) -> void:
	var osc_offset = (osc_height / 2.0) * sin((time * TAU) / osc_time)
	crystal.global_position.y = crystal_start_pos.y + osc_offset
	crystal.rotate_y((TAU / rotate_time) * delta)
	
	time += delta
