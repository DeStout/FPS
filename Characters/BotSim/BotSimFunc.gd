class_name BotSimFunc extends Node


signal died
signal add_score

@export var character : CharacterBase

var mat : BaseMaterial3D = load("res://Characters/BotSim/BotSimMat.tres")
var team : Color


func new_name(new_name : String) -> void:
	character.name = new_name
	character.name_label.text = new_name


func set_color(new_color : Color) -> void:
	team = new_color
	var team_mat : BaseMaterial3D = mat.duplicate()
	character.surface_mesh.set_surface_override_material(0, team_mat)
	team_mat.albedo_color = new_color


func _ready() -> void:
	await character.ready
	#character.add_weapon(Globals.weapons[character.rand_weapon()].instantiate())


func switch_weapon(new_weapon : Weapon) -> void:
	character.weapon_state_machine.travel("Alert")
	

func take_damage(shooter : CharacterBase) -> bool:
	if !Globals.game.bot_sim_settings.friendly_fire and !character.is_enemy(shooter):
		return false
	return true


func die() -> void:
	# Signal to PlayerContainer.add_to_scoreboard
	add_score.emit(character, character.last_shot_by)
	
	if character.weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		var weapon_info := [character.weapon_held.weapon_type,
								character.weapon_held.extra_ammo,
								character.weapon_held.ammo_in_mag]
		character.current_level.spawn_weapon_pick_up( \
										character.global_position, weapon_info)
	await character.die()
	
	# Signal to PlayersContainer.character_killed
	died.emit(character)


func respawn() -> void:
	character.global_position = \
							character.current_level.get_spawn_point().position
	character.aim_helper.rotation = Vector3.ZERO
	character.visible = true
	character.health = 100
	character.set_processing(true)
	character._disable_collisions(false)
	
	character.reset_weapons()
	await get_tree().process_frame
	character.add_weapon(Globals.weapons[character.rand_weapon()].instantiate())
	character.trigger_pulled = false


func set_current_camera(is_current : bool) -> void:
	#%Camera.current = is_current
	pass
