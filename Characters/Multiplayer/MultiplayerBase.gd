class_name MultiplayerBase
extends CharacterBase


signal died
signal add_score

var team : Color


func new_name(new_name_ : String) -> void:
	name = new_name_
	$NameLabel.text = name


func set_color(new_color : Color) -> void:
	team = new_color
	var mat = $Puppet/Skeleton3D/Body.get_surface_override_material(0)
	mat.albedo_color = new_color


func set_processing(new_process) -> void:
	set_process(new_process)
	set_physics_process(new_process)


func _ready() -> void:
	super()
	current_level = get_parent().get_parent()
	set_processing(false)
	
	_starting_weapons()


func _starting_weapons() -> void:
	var starting_weapon = _rand_weapon()
	weapons.append(starting_weapon)
	_switch_weapon(_get_weapon(starting_weapon))
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))
	#weapons.append(Globals.WEAPONS.SMG)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SMG))
	#weapons.append(Globals.WEAPONS.RIFLE)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.RIFLE))
	#weapons.append(Globals.WEAPONS.SHOTGUN)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SHOTGUN))
	#weapons.append(Globals.WEAPONS.SNIPER)
	#_switch_weapon(_get_weapon(Globals.WEAPONS.SNIPER))


func take_damage(body_seg : Area3D, damage : int, shooter : CharacterBase) -> void:
	if !Globals.bot_sim_settings.friendly_fire and !is_enemy(shooter):
		return
	
	super(body_seg, damage, shooter)


func _die() -> void:
	super()
	
	# Signal to PlayerContainer.add_to_score_board
	add_score.emit(self, last_shot_by)
	
	if weapon_held.stats.weapon_type != Globals.WEAPONS.SLAPPER:
		var weapon_info := [weapon_held.stats.weapon_type,
								weapon_held.extra_ammo,
								weapon_held.ammo_in_mag]
		current_level.spawn_weapon_pick_up(global_position, weapon_info)
	armor = 0
	weapons = [Globals.WEAPONS.SLAPPER]
	_switch_weapon(_get_weapon(Globals.WEAPONS.SLAPPER))
	
	# Do this now and in respawn() because Godot has priority issues
	global_position = current_level.get_spawn_point().position
	await get_tree().physics_frame
	
	# Signal to PlayersContainer.character_killed
	died.emit(self)


func respawn() -> void:
	# Do this now and in _die() because Godot has priority issues
	global_position = current_level.get_spawn_point().position
	await get_tree().physics_frame
	
	visible = true
	health = 100
	set_physics_process(true)
	_disable_collisions(false)
	
	var spawn_weapon = _rand_weapon()
	weapons.append(spawn_weapon)
	_switch_weapon(_get_weapon(spawn_weapon))
	#weapons.append(Globals.WEAPONS.PISTOL)
	#_get_weapon(Globals.WEAPONS.PISTOL).reset()
	#_switch_weapon(_get_weapon(Globals.WEAPONS.PISTOL))


func set_current_camera(is_current : bool) -> void:
	%Camera.current = is_current


func _rand_weapon() -> int:
	var spawn_weapon = randf_range(1, pow(Globals.WEAPONS.size(), 2))
	spawn_weapon = int(sqrt(spawn_weapon))
	return Globals.WEAPONS.size() - spawn_weapon


func character_killed(deceased) -> void:
	pass


func character_spawned(just_born, is_player) -> void:
	pass
