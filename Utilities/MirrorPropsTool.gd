@tool
extends Node3D


@export var run_mirror : bool = false : set = _mirror
@export var mirror_node : Node3D = null


func _mirror(run : bool) -> void:
	for child in get_children():
		if !mirror_node.find_child(child.name):
			var temp_node := Node3D.new()
			temp_node.name = child.name
			mirror_node.add_child(temp_node)
			temp_node.owner = child.owner
		
		var mirror_child = mirror_node.find_child(child.name)
		for prop_child in child.get_children():
			if !mirror_child.find_child(prop_child.name):
				var temp_prop = prop_child.duplicate()
				mirror_child.add_child(temp_prop)
				
				temp_prop.global_position.x = -temp_prop.global_position.x
				#temp_prop.global_rotate(Vector3.UP, PI)
				temp_prop.owner = prop_child.owner
