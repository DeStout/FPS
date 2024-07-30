extends Node3D
class_name MultiplayerLevel


var rag_doll_ := preload("res://Characters/RagDoll.tscn")
var shot_trail_ := preload("res://Props/ShotTrail.tscn")
var bullet_hole_ := preload("res://Props/BulletHole.tscn")
var damage_label_ := preload("res://Characters/DamageLabel.tscn")
var weapon_pick_up_ := preload("res://Props/PickUps/WeaponPickUp.tscn")


func _ready():
	$Players.level = self
	$Players.set_up()


# Called from CharacterBase.shoot()
func spawn_shot_trail(nozzle_point, collision_point) -> void:
	var shot_trail = shot_trail_.instantiate()
	$FX.add_child(shot_trail)
	shot_trail.align_and_scale(nozzle_point, collision_point)


# Called from CharacterBase.shoot()
func spawn_bullet_hole(pos : Vector3, normal : Vector3) -> void:
	var bullet_hole := bullet_hole_.instantiate()
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
func spawn_rag_doll(dead_skel : Skeleton3D,
							dead_trans : Transform3D, shooter : CharacterBase,
							body_seg_shot : String, body_color : Color) -> void:
	var rag_doll = rag_doll_.instantiate()
	$FX.add_child(rag_doll)
	rag_doll.set_color(body_color)
	rag_doll.match_pose_transform(dead_skel, dead_trans)
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
