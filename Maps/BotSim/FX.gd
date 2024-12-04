extends Node3D


var shot_trail_ := load("res://Props/ShotTrail.tscn")
var bullet_hole_ := load("res://Props/BulletHole.tscn")
var damage_label_ := load("res://Characters/DamageLabel.tscn")
var rag_doll_ := load("res://Characters/RagDoll.tscn")
var mat_ := load("res://Characters/BotSim/BotSimMat.tres")

const MAX_BULLET_HOLES := 256
const MAX_RAG_DOLLS := 8

var bullet_holes := []
var rag_dolls := []


func add_shot_trail(nozzle_point : Vector3, collision_point : Vector3) -> void:
	var shot_trail = shot_trail_.instantiate()
	add_child(shot_trail)
	shot_trail.align_and_scale(nozzle_point, collision_point)


func add_bullet_hole(pos : Vector3, normal : Vector3, parent : Node3D) -> void:
	var bullet_hole = bullet_hole_.instantiate()
	bullet_hole.exiting.connect(remove_bullet_hole)
	if !parent:
		add_child(bullet_hole)
	else:
		parent.add_child(bullet_hole)
	bullet_hole.global_position = pos
	bullet_hole.project_to(normal)
	
	bullet_holes.push_back(bullet_hole)
	if bullet_holes.size() > MAX_BULLET_HOLES:
		bullet_hole = bullet_holes.pop_front()
		if bullet_hole != null:
			bullet_hole.set_fade()


func add_damage_label(body_seg_type : int, pos : Vector3, dmg : String):
	var damage_label = damage_label_.instantiate()
	add_child(damage_label)
	var color : Color
	match body_seg_type:
		Globals.BODY_SEGS.HEAD:
			color = Color.GOLD
		_:
			color = Color.BROWN
	damage_label.set_txt_pos_color(pos, dmg, color)


func add_rag_doll(dead_skel : Skeleton3D, dead_trans : Transform3D, \
							shooter : CharacterBase, body_seg_shot : String, \
											body_mat : BaseMaterial3D) -> void:
	var rag_doll = rag_doll_.instantiate()
	var temp_mat = mat_.duplicate()
	temp_mat.albedo_color = body_mat.albedo_color
	rag_doll.exiting.connect(remove_rag_doll)
	add_child(rag_doll)
	rag_doll.set_material(temp_mat)
	await rag_doll.match_pose_transform(dead_skel, dead_trans, body_seg_shot)
	rag_doll.add_impulse(shooter.global_position, body_seg_shot,
											shooter.weapon_held.stats.impulse)
	
	rag_dolls.push_back(rag_doll)
	if rag_dolls.size() > MAX_RAG_DOLLS:
		rag_doll = rag_dolls.pop_front()
		if rag_doll != null:
			rag_doll.set_fadeout()


func remove_bullet_hole(bullet_hole) -> void:
	if bullet_holes.has(bullet_hole):
		bullet_holes.erase(bullet_hole)


func remove_rag_doll(rag_doll) -> void:
	if rag_dolls.has(rag_doll):
		rag_dolls.erase(rag_doll)
