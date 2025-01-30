class_name Damage extends Resource


enum DAMAGE_TYPES { SLAP, BULLET, EXPLOSIVE }

var attacker : CharacterBase = null
var attacker_cam : Camera3D = null
var damage_type : DAMAGE_TYPES
var attacking_weapon : Globals.WEAPONS
var body_seg_damaged : BodySeg = null
var damage_amount := 0
var global_position := Vector3.ZERO
var impulse := 0
