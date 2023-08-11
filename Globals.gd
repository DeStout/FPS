extends Node


var level1_ := preload("res://Levels/Level1.tscn")
var level2_ := preload("res://Levels/Level2.tscn")


enum WEAPONS {SLAPPER, PISTOL, RIFLE}
enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}
const BODY_DMG := [[50, 50, 50],		# Slapper
					[22, 12, 5],		# Pistol
					[25, 15, 8]]		# Rifle
