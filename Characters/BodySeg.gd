class_name BodySeg
extends Area3D


@export var body_seg : Globals.BODY_SEGS

signal take_damage

# Called from shooter CharacterBase
func body_seg_shot(damage : int, shooter : CharacterBase) -> void:
	# Signal to CharacterBase take_damage()
	take_damage.emit(damage, shooter, self)
