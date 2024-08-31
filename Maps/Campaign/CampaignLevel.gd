extends Node3D
class_name CampaignLevel


@export var player : CharacterBase

var rag_doll_ := preload("res://Characters/RagDoll.tscn")
var shot_trail_ := preload("res://Props/ShotTrail.tscn")
var bullet_hole_ := preload("res://Props/BulletHole.tscn")
var damage_label_ := preload("res://Characters/DamageLabel.tscn")
var weapon_pick_up_ := preload("res://Props/PickUps/WeaponPickUp.tscn")

func _ready() -> void:
	Debug.player = player
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func open() -> void:
	$MusicPlayer.play()
	
	$FX/FadeLayer/FadeInOut.visible = true
	$FX/FadeLayer/FadeInOut.color.a = 1
	var open_time = 3.0
	var tween = create_tween()
	tween.tween_property($FX/FadeLayer/FadeInOut, "color:a", 0, open_time)
	await tween.finished
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	for char in $Players.get_children():
		char.set_processing(true)


# Called by LevelFinish.level_finished()
func level_finished() -> void:
	var post_time := 2.0
	var timer = get_tree().create_timer(post_time, false, false, true)
	var tween = create_tween().set_parallel()
	tween.tween_property(Engine, "time_scale", 0.1, post_time)
	tween.tween_property($FX/FadeLayer/FadeInOut, "color:a", 1.2, post_time)
	await tween.finished
	
	Globals.quit_single_player()


func end_game() -> void:
	$KillArea.monitoring = false
	for char in $Players.get_children():
		char.set_processing(false)


func spawn_shot_trail(nozzle_point, collision_point) -> void:
	var shot_trail = shot_trail_.instantiate()
	$FX.add_child(shot_trail)
	shot_trail.align_and_scale(nozzle_point, collision_point)


func spawn_bullet_hole(pos : Vector3, normal : Vector3, \
												parent : Node3D = $FX) -> void:
	var bullet_hole := bullet_hole_.instantiate()
	parent.add_child(bullet_hole)
	bullet_hole.global_position = pos
	bullet_hole.project_to(normal)


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
													body_color : Color) -> void:
	var rag_doll = rag_doll_.instantiate()
	$FX.add_child(rag_doll)
	rag_doll.set_color(body_color)
	rag_doll.match_pose_transform(dead_skel, dead_trans, body_seg_shot)
	rag_doll.add_impulse(shooter.global_position, body_seg_shot,
											shooter.weapon_held.stats.impulse)


func spawn_weapon_pick_up(dropped_position : Vector3, weapon_info : Array) -> void:
	var new_pick_up = weapon_pick_up_.instantiate()
	$Pickups.add_child(new_pick_up)
	new_pick_up.set_up_drop(dropped_position, weapon_info)


# Signaled by KillArea.body_exited
func character_out_of_bounds(body : Node3D) -> void:
	if body == player and $KillArea.monitoring:
		Globals.reset_single_player()
		return
	body.queue_free()
