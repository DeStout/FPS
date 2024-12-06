@tool
extends Node3D


@export var alarm_time := 10.0
var SPIN_SPEED := 5.0


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	rotate_y(5.0 * delta)


func set_activated(activated) -> void:
	$Light1.visible = activated
	$Light2.visible = activated
	set_physics_process(activated)
	if activated:
		$Siren.play()
		$SirenTimer.start(alarm_time)
	else:
		$Siren.stop()
		$SirenTimer.stop()


func alarm_timeout() -> void:
	$Siren.stop()
