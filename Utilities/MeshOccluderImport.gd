@tool
extends EditorScenePostImport


func _pre_process(scene: Node) -> Node:
	for child in scene.get_children():
		if child is MeshInstance3D:
			child.set("generate/occluder", 1)
	return scene
