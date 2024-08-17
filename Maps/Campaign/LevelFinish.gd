extends Area3D


func level_finished(body) -> void:
	if body == Globals.map.player:
		get_tree().quit()
