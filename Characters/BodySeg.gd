extends Area3D

@export_enum("HEAD", "TORSO", "LIMB") var body_seg : int

signal take_damage


func body_seg_shot() -> void:
	take_damage.emit(body_seg)
