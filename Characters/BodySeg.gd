extends Area3D

@export var body_seg : Globals.BODY_SEGS

signal take_damage


# Signal to CharacterBase
func body_seg_shot(weapon_type) -> void:
	take_damage.emit(Globals.BODY_DMG[weapon_type][body_seg])
