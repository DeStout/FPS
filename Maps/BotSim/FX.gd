extends Node3D


var bullet_hole_ := load("res://Props/BulletHole.tscn")

const MAX_BULLET_HOLES := 256
const MAX_RAG_DOLLS := 16

var bullet_holes := []
var rag_dolls := []


func add_bullet_hole(pos : Vector3, normal : Vector3, parent : Node3D) -> void:
	var bullet_hole = bullet_hole_.instantiate()
	if !parent:
		add_child(bullet_hole)
	else:
		parent.add_child(bullet_hole)
	bullet_hole.global_position = pos
	bullet_hole.project_to(normal)
	
	bullet_holes.push_back(bullet_hole)
	if bullet_holes.size() > MAX_BULLET_HOLES:
		bullet_hole = bullet_holes.pop_front()
		if bullet_hole.is_inside_tree():
			bullet_hole.set_fade()


func add_rag_doll() -> void:
	pass
