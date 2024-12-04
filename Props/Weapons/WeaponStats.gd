extends Resource
class_name WeaponStats

## The weapon the stats will define
@export var weapon_type : Globals.WEAPONS
## Does the weapon fire in automatic style
@export var automatic : bool
## Does the weapon have zoom functionality
@export var can_zoom : bool
## If zoomable, the level of magnification the weapon has
@export var zoom_level := 1.0
## Does the weapon fire multiple shots in one fire
@export var burst_fire : bool
## If burst fire, how many shots are calculated in one fire
@export var burst_num : int
## If burst fire, how much spread does each shot have? (Typically between 0.0 and 0.15)
@export var burst_variance : float
## How fast can the weapon be fired
@export var shots_per_second : float
## The maximum amount of ammo that can be held for the weapon, including what's in the magazine
@export var max_ammo : int
## How many shots can be fired before the weapon must be reloaded
@export var mag_size : int
## The maximum amount of recoil that is added vertically on each shot.
@export var v_recoil : float
## The maximum amount of recoil that is added horizontally on each shot
@export var h_recoil : float
## The maximum amount of damage the weapon deals to each body segment
## (0: Head,
## 1: Torso,
## 2: Limbs)
@export var body_dmg : Dictionary = {Globals.BODY_SEGS.HEAD : 0, \
									Globals.BODY_SEGS.TORSO : 0, \
									Globals.BODY_SEGS.LIMB : 0}
## The distance where the damage begins falling off, and the max distance the weapon can reach
@export var dmg_falloff := Vector2(10, 30)
## The strength of the kick given to rag dolls
@export var impulse := 0.0
## Position for lining up the weapon
@export var pos_offset : Vector3
## Rotation for lining up the weapon
@export var rot_offset : Vector3

## Name of the state to travel to in the Upper State Machine
@export var state_name : String
## Name of the first person animation to equip the weapon
@export var equip_anim : String
## Name of the first person animation to idle with this weapon equipped
@export var idle_anim : String
## Name of the first person animation to run with this weapon equipped
@export var run_anim : String
## Name of the first person animation to shoot this weapon while equipped
@export var shoot_anim : String
## Name of the first person animation for reload this weapon while equipped
@export var reload_anim : String
