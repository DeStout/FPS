extends Node


@export var character : CharacterBase


func _ready() -> void:
	await character.ready
