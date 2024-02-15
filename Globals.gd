extends Node


@onready var game = get_tree().current_scene

var mouse_sensitivity := 0.002
var controller_sensitivity := 0.05
var invert_y_axis := false

var main_menu_ := preload("res://Menus/MainMenu.tscn")
var level1_ := preload("res://Levels/Level1.tscn")
var level2_ := preload("res://Levels/Level2.tscn")

var main_menu : Node3D = main_menu_.instantiate()
var level : Node3D = null

enum WEAPONS {SLAPPER, PISTOL, SMG, RIFLE, SHOTGUN}
var WEAPON_NAMES = ["Slapper", "Pistol", "SMG", "Rifle", "Shotgun"]
enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}
const BODY_DMG := 	[25,				# Slapper
					[22, 12, 5],		# Pistol
					[25, 15, 8]]		# Rifle


#func _ready() -> void:
	#game.add_child(main_menu)


func start_game() -> void:
	game.remove_child(main_menu)
	level = level2_.instantiate()
	game.add_child(level)


func switch_levels() -> void:
	level.queue_free()
	await level.tree_exited
	match level.name:
		"Level1":
			level = level2_.instantiate()
		"Level2":
			level = level1_.instantiate()
	game.add_child(level)


func quit_game() -> void:
	level.queue_free()
	level = null
	game.add_child(main_menu)


func invert_y_to_int() -> int:
	return (int(invert_y_axis) * 2) - 1
