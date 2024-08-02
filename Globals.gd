extends Node


signal game_started
signal game_ended


@onready var game = get_tree().current_scene

var mouse_sensitivity := 0.002
var controller_sensitivity := 0.05
var invert_y_axis := false

var main_menu_ := preload("res://Menus/MainMenu.tscn")
#var Square_ := preload("res://Maps/Multiplayer/Square.tscn")
#var Bridge_ := preload("res://Maps/Multiplayer/Bridge.tscn")
#var Temple_ := preload("res://Maps/Multiplayer/Temple.tscn")

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
func load_game() -> void:
	game.remove_child(main_menu)
	LoadingScreen.load(_select_map(), add_map)


func _select_map() -> String:
	var map_address := ""
	match match_settings.map:
		0:
			map_address = "res://Maps/Multiplayer/Square.tscn"
		1:
			map_address = "res://Maps/Multiplayer/Bridge.tscn"
		2:
			map_address = "res://Maps/Multiplayer/Temple.tscn"
	return map_address


# Called from LoadingScreen._load_complete()
func add_map(new_map) -> void:
	map = new_map.instantiate()
	game.add_child(map)


func start_match() -> void:
	# Signals to Debug.game_start()
	game_started.emit(map)
	map.open()


# Called from Pause.quit_button() and MultiplayerLevel.end_match()
func quit_game() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	map.queue_free()
	map = null
	match_settings = MatchSettings.new()
	await get_tree().process_frame
	
	if main_menu:
		game.add_child(main_menu)
		main_menu.update()
	else:
		get_tree().quit()
		
	# Signal to Debug.game_ended()
	game_ended.emit()


func invert_y_to_int() -> int:
	return (int(invert_y_axis) * 2) - 1
