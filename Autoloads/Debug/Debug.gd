extends CanvasLayer


var debug_visible := true
var fps_visible := true

# Cheats
var invincible := false
var infinite_ammo := false
var bottomless_mag:= false

var bot_sim_level : BotSimLevel = null
var players_container = null
var player : CharacterBase = null
var player_pos : Transform3D

var debug_camera_ = preload("res://Autoloads/Debug/DebugCamera.tscn")
var debug_camera : CharacterBody3D = null
var cam_swap := false


func _ready() -> void:
	visible = debug_visible
	$FPS.visible = fps_visible
	
	Globals.game.bot_sim_started.connect(_bot_sim_started)
	Globals.game.bot_sim_ended.connect(_bot_sim_ended)
	
	await get_tree().physics_frame
	HUD.pause_menu.options.invincibility.toggled.connect(_set_invincible)
	HUD.pause_menu.options.infinite_ammo.toggled.connect(_set_infinite_ammo)
	HUD.pause_menu.options.bottomless_mag.toggled.connect(_set_bottomless_mag)
	HUD.pause_menu.options.show_hud.toggled.connect(_show_HUD)
	HUD.pause_menu.options.show_weapon_info.toggled.connect(_show_weapon_info)
	HUD.pause_menu.options.show_crosshair.toggled.connect(_show_crosshair)
	
	_set_invincible(HUD.pause_menu.options.invincibility.button_pressed)
	_set_infinite_ammo(HUD.pause_menu.options.infinite_ammo.button_pressed)
	_set_bottomless_mag(HUD.pause_menu.options.bottomless_mag.button_pressed)


func _process(_delta) -> void:
	$FPS.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	$Objects.text = "Objects: " + \
					str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	
	if player:
		if invincible:
			_invincible()
		if infinite_ammo:
			_infinite_ammo()
		if bottomless_mag:
			_bottomless_mag()
			
		if Input.is_action_just_pressed("Debug") and bot_sim_level:
			_swap_cameras()


func _set_invincible(is_invincible : bool) -> void:
	invincible = is_invincible

func _set_infinite_ammo(is_infinite : bool) -> void:
	infinite_ammo = is_infinite

func _set_bottomless_mag(is_bottomless : bool) -> void:
	bottomless_mag = is_bottomless

func _show_HUD(show_HUD : bool) -> void:
	HUD.visible = show_HUD

func _show_weapon_info(show_weapon_info : bool) -> void:
	HUD.weapon_info.visible = show_weapon_info

func _show_crosshair(show_crosshair : bool) -> void:
	HUD.reticle.visible = show_crosshair


func _bot_sim_started(new_level) -> void:
	bot_sim_level = new_level
	players_container = bot_sim_level.get_node("Players")
	player = players_container.player
	
	_show_HUD(HUD.pause_menu.options.show_hud.button_pressed)
	_show_weapon_info(HUD.pause_menu.options.show_weapon_info.button_pressed)
	_show_crosshair(HUD.pause_menu.options.show_crosshair.button_pressed)


func _bot_sim_ended() -> void:
	bot_sim_level = null
	players_container = null
	player = null
	debug_camera = null
	cam_swap = false


func _swap_cameras() -> void:
	cam_swap = !cam_swap
	if cam_swap:
		player_pos = player.transform
		players_container.remove_child(player)
		
		for bot in players_container.bots:
			bot.character_killed(player)
		
		if !debug_camera:
			debug_camera = debug_camera_.instantiate()
		debug_camera.transform = player_pos
		add_child(debug_camera)
		debug_camera.global_position.y += 1.7
	else:
		var temp_trans = debug_camera.global_transform
		remove_child(debug_camera)
		players_container.add_child(player)
		if bot_sim_level.nav_region:
			var nav_map := bot_sim_level.nav_region.get_navigation_map()
			var closest_point = NavigationServer3D.map_get_closest_point( \
														nav_map, temp_trans.origin)
			player.global_transform = temp_trans
			player.global_position = closest_point
			player.velocity = Vector3.ZERO
		else:
			player.transform = player_pos
			
		for bot in players_container.bots:
			bot.character_spawned(player, true)


func _invincible() -> void:
	player.health = player.MAX_HEALTH

func _infinite_ammo() -> void:
	if player.weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		player.weapon_held.extra_ammo = player.weapon_held.properties.max_ammo - \
										player.weapon_held.properties.mag_size
		HUD.update_weapon(player.weapon_held.ammo_in_mag, player.weapon_held.extra_ammo)

func _bottomless_mag() -> void:
	if player.weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		player.weapon_held.ammo_in_mag = player.weapon_held.properties.mag_size
		HUD.update_weapon(player.weapon_held.ammo_in_mag, player.weapon_held.extra_ammo)
