extends Node


@onready var game = get_tree().current_scene


var level1_ := preload("res://Levels/Level1.tscn")
var level2_ := preload("res://Levels/Level2.tscn")


enum WEAPONS {SLAPPER, PISTOL, RIFLE, SHOTGUN}
var WEAPON_NAMES = ["Slapper", "Pistol", "Rifle", "Shotgun"]
enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}
const BODY_DMG := 	[25,				# Slapper
					[22, 12, 5],		# Pistol
					[25, 15, 8]]		# Rifle


func start_game() -> void:
	game.get_child(0).queue_free()
	game.add_child(level2_.instantiate())
