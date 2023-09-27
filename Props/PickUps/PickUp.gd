class_name PickUp
extends Node3D


@export var pick_up_type : Globals.PICK_UPS
@export var respawn : bool = true
@export var respawn_time : float = 30


func _body_entered(body):
	if body.is_in_group("players"):
		body.pick_up(self)


func picked_up() -> void:
	$PickUpAudio.play()
	visible = false
	$Area/Collision.set_deferred("disabled", true)

	if respawn:
		$Respawn.start(respawn_time)


# Signaled by $Respawn Timer
func _respawn():
	print(name, " Respawn")
	visible = true
	$Area/Collision.set_deferred("disabled", false)
