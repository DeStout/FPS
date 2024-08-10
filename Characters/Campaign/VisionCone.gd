extends Area3D


@export var parent : CharacterBase

var bodies_vis : Array[CharacterBase] = []


func _body_entered(body : Node3D) -> void:
	if body is CharacterBase and !bodies_vis.has(body):
		if body != parent:
			bodies_vis.append(body)


func _body_exited(body: Node3D) -> void:
	if body is CharacterBase and bodies_vis.has(body):
		bodies_vis.erase(body)
