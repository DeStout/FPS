extends Resource
class_name WeaponStats


@export var weapon_type : Globals.WEAPONS
@export var automatic : bool
@export var shots_per_second : float
@export var max_ammo : int
@export var mag_size : int
@export var v_recoil : float
@export var h_recoil : float
@export var anim_pos : Vector2
@export var body_dmg : Dictionary = {Globals.BODY_SEGS.HEAD : 0, \
									Globals.BODY_SEGS.TORSO : 0, \
									Globals.BODY_SEGS.LIMB : 0}
