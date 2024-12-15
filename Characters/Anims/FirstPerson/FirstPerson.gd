extends Node3D


@export var player : CharacterBase = null


func _slap() -> void:
	player.slap()
