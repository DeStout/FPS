class_name FPWeapon extends Node3D


@export var weapon_type : Globals.WEAPONS

@export var weapon_mesh : Array[MeshInstance3D] = []
@onready var anim_player := $AnimationPlayer


func show_mesh(show : bool) -> void:
	for mesh in weapon_mesh:
		mesh.visible = show
