class_name BodySeg
extends Area3D


@export var body_seg : Globals.BODY_SEGS

signal take_damage

# Called from BulletWeapon._check_shot_collision()
func body_seg_shot(damage : Damage) -> void:
	# Signal to CharacterBase.take_damage()
	take_damage.emit(damage)
