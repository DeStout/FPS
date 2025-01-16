extends Node3D


@export var player : CharacterBase = null


func _slap() -> void:
	player.slap()


func _shell_loaded() -> void:
	player.shell_loaded()
