extends Node3D


var bullet_hole_ := preload("res://Props/BulletHole.tscn")
var damage_label_ := preload("res://Characters/DamageLabel.tscn")


#func _ready():
#	%Player.current_level = self


func spawn_bullet_hole(pos : Vector3, normal : Vector3) -> void:
	var bullet_hole := bullet_hole_.instantiate()
	$FX.add_child(bullet_hole)
	bullet_hole.global_position = pos
	bullet_hole.project_to(normal)


func spawn_damage_label(pos : Vector3, dmg : String) -> void:
	print("Taking damage")
	var damage_label = damage_label_.instantiate()
	$FX.add_child(damage_label)
	damage_label.set_txt_and_pos(pos, dmg)
