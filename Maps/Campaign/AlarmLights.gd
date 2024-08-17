@tool
extends Node3D


var SPIN_SPEED := 5.0


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	rotate_y(5.0 * delta)


func activate() -> void:
	$Light1.visible = true
	$Light2.visible = true
	$Siren.play()
	set_physics_process(true)
