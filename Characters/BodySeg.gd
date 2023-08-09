extends Area3D

@export var body_seg : Globals.BODY_SEGS

signal take_damage


# Signal to CharacterBase
func body_seg_shot() -> void:
	take_damage.emit(body_seg)
