extends Area3D

@export var body_seg : Globals.BODY_SEGS

signal take_damage


# Signal to CharacterBase _take_damage
func body_seg_shot(body_seg_dmg : Dictionary) -> void:
	take_damage.emit(body_seg_dmg[body_seg])
