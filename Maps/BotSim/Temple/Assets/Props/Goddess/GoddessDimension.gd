extends Area3D


@export var players : Node3D = null
@export var goddess_surface : MeshInstance3D = null
var _goddess_mat : ShaderMaterial = \
				load("res://Maps/BotSim/Temple/Assets/Materials/GoddessMat.tres")
@onready var _sfx_bus := AudioServer.get_bus_index("SFX")


func _ready() -> void:
	AudioServer.set_bus_effect_enabled(_sfx_bus, 0, false)
	AudioServer.set_bus_effect_enabled(_sfx_bus, 1, false)


func _player_entered(body_entered : BotSimCharacter) -> void:
	if body_entered == players.player:
		players.player.enable_screen_effect(true)
		goddess_surface.set_surface_override_material(0, null)
		AudioServer.set_bus_effect_enabled(_sfx_bus, 0, true)
		AudioServer.set_bus_effect_enabled(_sfx_bus, 1, true)


func _player_exited(body_exited : BotSimCharacter) -> void:
	if body_exited == players.player:
		players.player.enable_screen_effect(false)
		goddess_surface.set_surface_override_material(0, _goddess_mat)
		AudioServer.set_bus_effect_enabled(_sfx_bus, 0, false)
		AudioServer.set_bus_effect_enabled(_sfx_bus, 1, false)
