extends Node3D


var shot_trail_ = preload("res://Props/ShotTrail.tscn")
var bullet_hole_ := preload("res://Props/BulletHole.tscn")
var damage_label_ := preload("res://Characters/DamageLabel.tscn")
var weapon_pick_up_ := preload("res://Props/PickUps/WeaponPickUp.tscn")

@export var num_enemies := 0


func _ready():
	$Players.level = self
	$Players.set_up()


func spawn_shot_trail(nozzle_point, collision_point) -> void:
	var shot_trail = shot_trail_.instantiate()
	$FX.add_child(shot_trail)
	shot_trail.align_and_scale(nozzle_point, collision_point)


func spawn_bullet_hole(pos : Vector3, normal : Vector3) -> void:
	var bullet_hole := bullet_hole_.instantiate()
	$FX.add_child(bullet_hole)
	bullet_hole.global_position = pos
	bullet_hole.project_to(normal)


func spawn_damage_label(pos : Vector3, dmg : String) -> void:
	var damage_label = damage_label_.instantiate()
	$FX.add_child(damage_label)
	damage_label.set_txt_and_pos(pos, dmg)


func spawn_weapon_pick_up(dropped_position : Vector3, weapon_info : Array) -> void:
	var new_pick_up = weapon_pick_up_.instantiate()
	$Pickups.add_child(new_pick_up)
	new_pick_up.set_up_drop(dropped_position, weapon_info)


func get_spawn_point() -> Marker3D:
	return $Spawns.get_children().pick_random()


func get_nav_point() -> Marker3D:
	return $NavPoints.get_children().pick_random()
