extends Node3D
class_name BotSimLevel


var weapon_pick_up_ := load("res://Props/PickUps/WeaponPickUp.tscn")

@export var nav_region : NavigationRegion3D = null
@onready var players := $Players
@onready var fx := $FX


func _ready() -> void:
	if Globals.game.bot_sim_settings.time != 0:
		$MatchTime.start(Globals.game.bot_sim_settings.time)
		$MatchTime.paused = true
	players.set_up()
	HUD.setup_bot_sim()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func open() -> void:
	Engine.time_scale = 1.0
	$MusicPlayer.play()
	await HUD.fade_in()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_start_match()


func _process(delta: float) -> void:
	HUD.match_timer.set_time(int($MatchTime.time_left))


func _start_match() -> void:
	$Players.set_characters_processing(true)
	$MatchTime.paused = false


func get_match_time() -> int:
	return int($MatchTime.time_left)


# Called by $MatchTime.timeout and ScoreBoard._check_win()
func end_match() -> void:
	HUD.set_game_over()
	HUD.fade_out()
	
	var post_time := 2.0
	var timer = get_tree().create_timer(post_time, false, false, true)
	
	var tween = create_tween().set_parallel()
	tween.tween_property(Engine, "time_scale", 0.1, post_time)
	await tween.finished
	
	Globals.game.quit_bot_sim()


# Called from CharacterBase.shoot()
func spawn_shot_trail(nozzle_point : Vector3, collision_point : Vector3) -> void:
	fx.add_shot_trail(nozzle_point, collision_point)


# Called from CharacterBase.shoot()
func spawn_bullet_hole(pos : Vector3, normal : Vector3, parent : Node3D = null) -> void:
	fx.add_bullet_hole(pos, normal, parent)


func spawn_grenade(thrower, spawn_basis : Basis, spawn_point : Vector3, \
								spawn_dir : Vector3, throw_strength : float) -> void:
	fx.add_grenade(thrower, spawn_basis, spawn_point, spawn_dir, throw_strength)


func spawn_explosion(thrower : CharacterBase, spawn_pos : Vector3) -> void:
	fx.add_explosion(thrower, spawn_pos)


# Called from CharacterBase.take_damage()
func spawn_damage_label(body_seg_type : int, pos : Vector3, dmg : String) -> void:
	fx.add_damage_label(body_seg_type, pos, dmg)


# Called from CharacterBase.die()
func spawn_rag_doll(dead_skel : Skeleton3D, dead_trans : Transform3D, \
							shooter : CharacterBase, body_seg_shot : String, \
											body_mat : BaseMaterial3D) -> void:
	fx.add_rag_doll(dead_skel, dead_trans, shooter, body_seg_shot, body_mat)


func spawn_weapon_pick_up(dropped_position : Vector3, weapon_info : Array) -> void:
	var new_pick_up = weapon_pick_up_.instantiate()
	$Pickups.add_child(new_pick_up)
	new_pick_up.set_up_drop(dropped_position, weapon_info)


func get_spawn_point() -> Marker3D:
	return $Spawns.get_children().pick_random()


func get_all_pickups() -> Array:
	return $Pickups.get_children()


func get_healths_pickups(healths_type : Globals.HEALTHS) -> Array:
	return $Pickups.get_children().filter(
		func(healths) -> bool:
			return healths.pick_up_type == Globals.PICK_UPS.HEALTH and \
					healths.health_type == healths_type
			)


func get_weapon_pickups(weapon_type : Globals.WEAPONS) -> Array:
	return $Pickups.get_children().filter(
		func(weapon) -> bool:
			return weapon.pick_up_type == Globals.PICK_UPS.WEAPON and \
					weapon.weapon_type == weapon_type
	)


func get_nav_point() -> Node3D:
	var nav_points : Array = $NavPoints.get_children() + $Pickups.get_children()
	return nav_points.pick_random()
