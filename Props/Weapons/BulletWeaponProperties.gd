extends Resource
class_name BulletWeaponProperties


## Does the weapon fire in automatic style
@export var automatic : bool

## Does the weapon have zoom functionality
@export var can_zoom : bool
## If zoomable, the level of magnification the weapon has
@export var zoom_level := 1.0

## If burst fire, how many shots are calculated in one fire
@export var num_shots : int = 1
## How fast can the weapon be fired
@export var shots_per_second : float

## How much variance is added to the first shot
@export var default_variance : float
## If burst fire, how much spread does each shot have? (Typically between 0.0 and 0.15)
@export var max_variance : float
## How much variance is added per shot
@export var variance_build : float
## How long does it take for the variance to reset in seconds
@export var variance_reset : float

## The maximum amount of ammo that can be held for the weapon, including what's in the magazine
@export var max_ammo : int
## How many shots can be fired before the weapon must be reloaded
@export var mag_size : int

## The maximum amount of recoil that is added vertically on each shot.
@export var body_dmg : Dictionary = {Globals.BODY_SEGS.HEAD : 0, \
									Globals.BODY_SEGS.TORSO : 0, \
									Globals.BODY_SEGS.LIMB : 0}
## The distance where the damage begins falling off, and the max distance the weapon can reach
@export var dmg_falloff := Vector2(10, 30)
## The strength of the kick given to rag dolls
## Position for lining up the weapon

@export var pos_offset : Vector3
## Rotation for lining up the weapon
@export var rot_offset : Vector3
