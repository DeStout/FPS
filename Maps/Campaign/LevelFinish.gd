extends Area3D


@export var current_level : CampaignLevel = null


func level_finished(body) -> void:
	if body == Globals.game.map.player:
		current_level.level_finished()
