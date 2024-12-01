extends Node3D
class_name BotSimLevel


var rag_doll_ := load("res://Characters/RagDoll.tscn")
var mat_ := load("res://Characters/BotSim/BotSimMat.tres")
var shot_trail_ := load("res://Props/ShotTrail.tscn")
var bullet_hole_ := load("res://Props/BulletHole.tscn")
var damage_label_ := load("res://Characters/DamageLabel.tscn")
var weapon_pick_up_ := load("res://Props/PickUps/WeaponPickUp.tscn")


func _ready() -> void:
	if Globals.game.bot_sim_settings.time != 0:
		$MatchTime.start(Globals.game.bot_sim_settings.time)
		$MatchTime.paused = true
	%Players.set_up()
	HUD.setup_bot_sim()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func open() -> void:
	#$MusicPlayer.play()
	await  HUD.fade_in()
	
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
func spawn_shot_trail(nozzle_point, collision_point) -> void:
	var shot_trail = shot_trail_.instantiate()
	$FX.add_child(shot_trail)
	shot_trail.align_and_scale(nozzle_point, collision_point)


# Called from CharacterBase.shoot()
func spawn_bullet_hole(pos : Vector3, normal : Vector3, \
												parent : Node3D = $FX) -> void:
	var bullet_hole = bullet_hole_.instantiate()
	$FX.add_child(bullet_hole)
	bullet_hole.global_position = pos
	bullet_hole.project_to(normal)


# Called from CharacterBase.take_damage()
func spawn_damage_label(body_seg_type : int, pos : Vector3, dmg : String) -> void:
	var damage_label = damage_label_.instantiate()
	$FX.add_child(damage_label)
	var color : Color
	match body_seg_type:
		Globals.BODY_SEGS.HEAD:
			color = Color.GOLD
		_:
			color = Color.BROWN
	damage_label.set_txt_pos_color(pos, dmg, color)


# Called from CharacterBase.die()
func spawn_rag_doll(dead_skel : Skeleton3D, dead_trans : Transform3D, \
							shooter : CharacterBase, body_seg_shot : String, \
											body_mat : BaseMaterial3D) -> void:
	var rag_doll = rag_doll_.instantiate()
	var temp_mat = mat_.duplicate()
	temp_mat.albedo_color = body_mat.albedo_color
	$FX.add_child(rag_doll)
	rag_doll.set_material(temp_mat)
	await rag_doll.match_pose_transform(dead_skel, dead_trans, body_seg_shot)
	rag_doll.add_impulse(shooter.global_position, body_seg_shot,
											shooter.weapon_held.stats.impulse)


func spawn_weapon_pick_up(dropped_position : Vector3, weapon_info : Array) -> void:
	var new_pick_up = weapon_pick_up_.instantiate()
	$Pickups.add_child(new_pick_up)
	new_pick_up.set_up_drop(dropped_position, weapon_info)


func get_spawn_point() -> Marker3D:
	return $Spawns.get_children().pick_random()


func get_nav_point() -> Node3D:
	var nav_points : Array = $NavPoints.get_children() + $Pickups.get_children()
	return nav_points.pick_random()
