extends Node


var level1_ := preload("res://Levels/Level1.tscn")
var level2_ := preload("res://Levels/Level2.tscn")


enum WEAPONS {SLAPPER, PISTOL, RIFLE}
const MAG_SIZES := [0, 12, 24]
var slapper_ := preload("res://Props/Slapper.tscn")
var pistol_ := preload("res://Props/Pistol.tscn")
var rifle_ := preload("res://Props/Rifle.tscn")

enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}
const BODY_DMG := [50, 25, 10]
