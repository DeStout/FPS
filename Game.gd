extends Node


signal bot_sim_started
signal bot_sim_ended

var loading_screen_ := preload("res://Menus/LoadingScreen.tscn")
var loading_screen : CanvasLayer = null

@onready var main_menu : Control = $MainMenu

var map : Node3D = null
var single_player_settings := 0
var bot_sim_settings : BotSimSettings = BotSimSettings.new()
var can_be_paused := false


func _add_loading_screen() -> CanvasLayer:
	var load_screen = loading_screen_.instantiate()
	add_child(load_screen)
	return load_screen


# Called from SinglePlayerMenu.start_button()
func load_single_player(map_selected) -> void:
	loading_screen = _add_loading_screen()
	if main_menu.is_inside_tree():
		remove_child(main_menu)
	single_player_settings = map_selected
	loading_screen.load(_select_single_player_map(), add_map, start_single_player)


func _select_single_player_map() -> String:
	var map_address := ""
	match single_player_settings:
		0:
			map_address = "res://Maps/Campaign/TestCampaign.tscn"
		1:
			map_address = "res://Maps/Campaign/Reuben/Reuben.tscn"
	return map_address


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
			map_address = "res://Maps/BotSim/Square.tscn"
		1:
			map_address = "res://Maps/BotSim/Bridge.tscn"
		2:
			map_address = "res://Maps/BotSim/Temple/Temple.tscn"
	return map_address


# Called from loading_screen._update_load()
func add_map(new_map) -> void:
	map = new_map.instantiate()
	add_child(map)


# Called from loading_screen._update_UI()
func start_single_player() -> void:
	map.open()
	can_be_paused = true


# Called from CampaignLevel.character_out_of_bounds()
func reset_single_player() -> void:
	if !map.is_queued_for_deletion():
		can_be_paused = false
		map.queue_free()
		HUD.exit_game()
		load_single_player(single_player_settings)


func quit_single_player() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globals.zoom_sensitibity = 1.0
	
	map.end_game()
	map.queue_free()
	can_be_paused = false
	HUD.exit_game()
	
	if main_menu:
		add_child(main_menu)
		main_menu.update()
	else:
		get_tree().quit()


# Called from loading_screen._update_UI()
func start_bot_sim() -> void:
	map.open()
	can_be_paused = true
	
	# Signal to Debug.bot_sim_start()
	bot_sim_started.emit(map)


# Called from Pause.quit_button() and MultiplayerLevel.end_match()
func quit_bot_sim() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globals.zoom_sensitibity = 1.0
	
	map.queue_free()
	bot_sim_settings = BotSimSettings.new()
	await get_tree().physics_frame
	map = null
	can_be_paused = false
	HUD.reset_scoreboard()
	HUD.exit_game()
	
	if main_menu:
		add_child(main_menu)
		main_menu.update()
	else:
		get_tree().quit()
		
	# Signal to Debug.bot_sim_ended()
	bot_sim_ended.emit()
