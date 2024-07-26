extends Node


signal game_started
signal game_ended


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
var game_settings : GameSettings = GameSettings.new()

enum WEAPONS {SLAPPER, PISTOL, SMG, RIFLE, SHOTGUN}
var WEAPON_NAMES = ["Slapper", "Pistol", "SMG", "Rifle", "Shotgun"]
enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}
const BODY_DMG := 	[25,				# Slapper
					[22, 12, 5],		# Pistol
					[25, 15, 8]]		# Rifle


# Called from SettingsMenu2D.accept_pressed()
func set_game_settings(new_game_settings : GameSettings) -> void:
	game_settings = new_game_settings


# Called from PlayMenu2D.start_pressed()
func start_game() -> void:
	game.remove_child(main_menu)
	level = select_level().instantiate()
	game.add_child(level)
	game_started.emit(level)


func select_level() -> PackedScene:
	match game_settings.level:
		0:
			return level1_
		1:
			return level2_
		2:
			return level3_
		_:
			return level3_


# Called from Pause.quit_button()
func quit_game() -> void:
	if main_menu:
		level.queue_free()
		level = null
		await get_tree().process_frame
		game.add_child(main_menu)
		game_ended.emit()
	else:
		get_tree().quit()


func invert_y_to_int() -> int:
	return (int(invert_y_axis) * 2) - 1
