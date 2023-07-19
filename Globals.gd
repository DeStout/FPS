extends Node


enum WEAPONS {SLAPPER, PISTOL, RIFLE}
const MAG_SIZES := [0, 12, 24]
var slapper_ := preload("res://Props/Slapper.tscn")
var pistol_ := preload("res://Props/Pistol.tscn")
var rifle_ := preload("res://Props/Rifle.tscn")

enum PICK_UPS {WEAPON, AMMO, HEALTH}
