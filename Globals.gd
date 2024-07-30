extends Node


signal game_started
signal game_ended


@onready var game = get_tree().current_scene

var mouse_sensitivity := 0.002
var controller_sensitivity := 0.05
var invert_y_axis := false

var main_menu_ := preload("res://Menus/MainMenu.tscn")
var Square_ := preload("res://Maps/Multiplayer/Square.tscn")
var Bridge_ := preload("res://Maps/Multiplayer/Bridge.tscn")
var Temple_ := preload("res://Maps/Multiplayer/Temple.tscn")

@onready var main_menu : Control = game.get_node("MainMenu")
var map : Node3D = null
var match_settings : MatchSettings = MatchSettings.new()

enum WEAPONS {SLAPPER, PISTOL, SMG, RIFLE, SHOTGUN}
var WEAPON_NAMES = ["Slapper", "Pistol", "SMG", "Rifle", "Shotgun"]
enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}
const BODY_DMG := 	[25,				# Slapper
					[22, 12, 5],		# Pistol
					[25, 15, 8]]		# Rifle


# Called from PlayMenu.start_button()
func set_match_settings(new_match_settings : MatchSettings) -> void:
	match_settings = new_match_settings


# Called from PlayMenu.start_button()
func start_game() -> void:
	game.remove_child(main_menu)
	map = select_map().instantiate()
	game.add_child(map)
	game_started.emit(map)


func select_map() -> PackedScene:
	match match_settings.map:
		0:
			return Square_
		1:
			return Bridge_
		2:
			return Temple_
		_:
			return Temple_


# Called from Pause.quit_button()
func quit_game() -> void:
	if main_menu:
		map.queue_free()
		map = null
		await get_tree().process_frame
		game.add_child(main_menu)
		main_menu.update()
		# Signal to Debug.game_ended()
		game_ended.emit()
	else:
		get_tree().quit()


func invert_y_to_int() -> int:
	return (int(invert_y_axis) * 2) - 1


#func align_to_floor_normal(old_basis, floor_normal) -> Basis:
	#if floor_normal
	#var dot1 = 
	#var new_basis : Basis = Basis()
	#return new_basis
