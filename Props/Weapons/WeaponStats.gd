extends Resource
class_name WeaponStats


@export var weapon_type : Globals.WEAPONS
@export var automatic : bool
@export var can_zoom : bool
@export var zoom_level := 1.0
@export var burst_fire : bool
@export var burst_num : int
@export var burst_variance : float
@export var shots_per_second : float
@export var max_ammo : int
@export var mag_size : int
@export var v_recoil : float
@export var h_recoil : float
@export var body_dmg : Dictionary = {Globals.BODY_SEGS.HEAD : 0, \
									Globals.BODY_SEGS.TORSO : 0, \
									Globals.BODY_SEGS.LIMB : 0}
@export var dmg_falloff := Vector2(10, 30)
@export var range : float
@export var impulse := 0.0
@export var pos_offset : Vector3
@export var rot_offset : Vector3
@export var anim_pos : Vector2
@export var equip_anim : String
@export var unequip_anim : String
@export var shoot_anim : String
@export var reload_anim : String
