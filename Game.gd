extends Node


signal bot_sim_started
signal bot_sim_ended

var loading_screen_ := preload("res://Menus/LoadingScreen.tscn")
var loading_screen : CanvasLayer = null

@onready var main_menu : Control = $MainMenu

var map : Node3D = null
var bot_sim_settings : BotSimSettings = BotSimSettings.new()


func _add_loading_screen() -> CanvasLayer:
	var load_screen = loading_screen_.instantiate()
	add_child(load_screen)
	return load_screen


# Called from SinglePlayerMenu.start_button()
func load_single_player() -> void:
	loading_screen = _add_loading_screen()
	remove_child(main_menu)
	loading_screen.load("res://Maps/Campaign/TestCampaign.tscn", add_map, start_single_player)


# Called from BotSimMenu.start_button()
func load_bot_sim_game() -> void:
	loading_screen = _add_loading_screen()
	remove_child(main_menu)
	loading_screen.load(_select_bot_sim_map(), add_map, start_bot_sim)


# Called from BotSimMenu.start_button()
func set_bot_sim_settings(new_bot_sim_settings : BotSimSettings) -> void:
	bot_sim_settings = new_bot_sim_settings


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


# Called from loading_screen._update_load()
func add_map(new_map) -> void:
	map = new_map.instantiate()
	add_child(map)


# Called from loading_screen._update_UI()
func start_single_player() -> void:
	map.open()


# Called from CampaignLevel.character_out_of_bounds()
func reset_single_player() -> void:
	remove_child(map)
	load_single_player()


func quit_single_player() -> void:
	map.end_game()
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	map.queue_free()
	await get_tree().physics_frame
	
	if main_menu:
		add_child(main_menu)
		main_menu.update()
	else:
		get_tree().quit()


# Called from loading_screen._update_UI()
func start_bot_sim() -> void:
	# Signals to Debug.bot_sim_start()
	#bot_sim_started.emit(map)
	map.open()


# Called from Pause.quit_button() and MultiplayerLevel.end_match()
func quit_bot_sim() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	map.queue_free()
	bot_sim_settings = BotSimSettings.new()
	await get_tree().physics_frame
	map = null
	
	if main_menu:
		add_child(main_menu)
		main_menu.update()
	else:
		get_tree().quit()
		
	# Signal to Debug.bot_sim_ended()
	bot_sim_ended.emit()
