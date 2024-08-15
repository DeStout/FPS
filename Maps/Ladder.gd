extends Area3D


func body_entered(body : Node3D) -> void:
	if body is CharacterBase:
		body.set_on_ladder(true)


func body_exited(body : Node3D):
	if body is CharacterBase:
		body.set_on_ladder(false)
