extends Node


signal bot_sim_started
signal bot_sim_ended


@onready var game = get_tree().current_scene

var mouse_sensitivity := 0.002
var controller_sensitivity := 0.05
var zoom_sensitibity := 1.0
var invert_y_axis := false

var main_menu_ := preload("res://Menus/MainMenu.tscn")

@onready var main_menu : Control = game.get_node("MainMenu")
var map : Node3D = null
var bot_sim_settings : BotSimSettings = BotSimSettings.new()

enum WEAPONS {SLAPPER, PISTOL, SMG, RIFLE, SHOTGUN, SNIPER}
var WEAPON_NAMES = ["Slapper", "Pistol", "SMG", "Rifle", "Shotgun", "Sniper"]
enum PICK_UPS {WEAPON, AMMO, HEALTH}
enum HEALTHS {HEALTH_PACK, ARMOR}

enum BODY_SEGS {HEAD, TORSO, LIMB}


# Called from BotSimMenu.start_button()
func set_bot_sim_settings(new_bot_sim_settings : BotSimSettings) -> void:
	bot_sim_settings = new_bot_sim_settings


# Called from SinglePlayerMenu.start_button()
func load_single_player() -> void:
	game.remove_child.call_deferred(main_menu)
	LoadingScreen.load("res://Maps/Campaign/TestCampaign.tscn", add_map, start_single_player)


# Called from BotSimMenu.start_button()
func load_bot_sim_game() -> void:
	game.remove_child(main_menu)
	LoadingScreen.load(_select_bot_sim_map(), add_map, start_bot_sim)


func _select_bot_sim_map() -> String:
	var map_address := ""
	match bot_sim_settings.map:
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


func start_single_player() -> void:
	map.open()


# Called from CampaignLevel.character_out_of_bounds()
func reset_single_player() -> void:
	game.remove_child.call_deferred(map)
	load_single_player()


func quit_single_player() -> void:
	map.end_game()
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	game.remove_child.call_deferred(map)
	await map.tree_exited
	map.queue_free()
	map = null
	
	if main_menu:
		game.add_child(main_menu)
		main_menu.update()
	else:
		get_tree().quit()


func start_bot_sim() -> void:
	# Signals to Debug.bot_sim_start()
	bot_sim_started.emit(map)
	map.open()


# Called from Pause.quit_button() and MultiplayerLevel.end_match()
func quit_bot_sim() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	map.queue_free()
	bot_sim_settings = BotSimSettings.new()
	await get_tree().process_frame
	map = null
	
	if main_menu:
		game.add_child(main_menu)
		main_menu.update()
	else:
		get_tree().quit()
		
	# Signal to Debug.bot_sim_ended()
	bot_sim_ended.emit()


func invert_y_to_int() -> int:
	return (int(invert_y_axis) * 2) - 1
