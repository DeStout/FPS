class_name PickUp
extends Node3D


signal removed(source)

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
	removed.emit(self)

	if respawn:
		$Respawn.start(respawn_time)


# Signaled by $Respawn Timer
func _respawn() -> void:
	#print(name, " Respawn")
	visible = true
	$Area/Collision.set_deferred("disabled", false)
	
	await get_tree().physics_frame
	if $Area.has_overlapping_bodies():
		_body_entered($Area.get_overlapping_bodies()[0])


func is_available() -> bool:
	if $Respawn.time_left:
		return false
	return true
