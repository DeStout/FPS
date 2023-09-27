extends Area3D

@export var body_seg : Globals.BODY_SEGS

signal take_damage


# Signal to CharacterBase _take_damage
func body_seg_shot(weapon_dmg) -> void:
	if weapon_dmg is int:
		take_damage.emit(Globals.BODY_DMG[weapon_dmg][body_seg])
	elif weapon_dmg is Dictionary:
		take_damage.emit(weapon_dmg[body_seg])
