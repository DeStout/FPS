extends Timer

signal respawn

var character : CharacterBase


func _respawn() -> void:
	respawn.emit(character)
