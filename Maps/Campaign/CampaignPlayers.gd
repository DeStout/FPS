extends Node3D


@export var level : CampaignLevel
@export var player : CharacterBase
@export var enemies : Array[CharacterBase]


func _ready() -> void:
	player.set_processing(true)
	for enemy in enemies:
		enemy.set_processing(true)
