extends Area3D


@export var current_level : CampaignLevel = null


func level_finished(body) -> void:
	if body == current_level.player:
		current_level.level_finished()
