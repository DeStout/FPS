extends Area3D


@export var body_seg : Globals.BODY_SEGS

signal take_damage

# Called from shooter CharacterBase
func body_seg_shot(body_seg_dmg : Dictionary, shooter : CharacterBase) -> void:
	# Signal to CharacterBase take_damage()
	take_damage.emit(self, body_seg_dmg[body_seg], shooter)
