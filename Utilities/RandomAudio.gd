extends Node3D


@onready
var audio_list := get_children()


func play() -> void:
	audio_list[randi() % audio_list.size()].play()
