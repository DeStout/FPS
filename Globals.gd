extends Node


@onready var game = get_tree().current_scene

var mouse_sensitivity := 0.002
var controller_sensitivity := 0.05
var invert_y_axis := false

var main_menu_ := preload("res://Menus/MainMenu.tscn")
var level1_ := preload("res://Levels/Multiplayer/Level1.tscn")
var level2_ := preload("res://Levels/Multiplayer/Level2.tscn")
var level3_ := preload("res://Levels/Multiplayer/Level3.tscn")

@onready var main_menu : Node3D = game.get_node("MainMenu")
var level : Node3D = null

enum WEAPONS {SLAPPER, PISTOL, SMG, RIFLE, SHOTGUN}
var WEAPON_NAMES = ["Slapper", "Pistol", "SMG", "Rifle", "Shotgun"]
enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}
const BODY_DMG := 	[25,				# Slapper
					[22, 12, 5],		# Pistol
					[25, 15, 8]]		# Rifle


func start_game() -> void:
	game.remove_child(main_menu)
	level = level3_.instantiate()
	game.add_child(level)


func switch_levels() -> void:
	var free_level = level
	game.remove_child(level)
	free_level.queue_free()
	match level.name:
		"Level1":
			level = level2_.instantiate()
		"Level2":
			level = level3_.instantiate()
		"Level3":
			level = level1_.instantiate()
		_:
			assert(false, "Can't switch from this level")
	game.add_child(level)


func quit_game() -> void:
	if main_menu:
		level.queue_free()
		level = null
		game.add_child(main_menu)
	else:
		get_tree().quit()


func invert_y_to_int() -> int:
	return (int(invert_y_axis) * 2) - 1
