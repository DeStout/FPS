extends CanvasLayer


var debug_visible := true
var fps_visible := true

# Cheats
var invincible := false
var infinite_ammo := false
var bottomless_clip := false

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
	
	Globals.game.bot_sim_started.connect(bot_sim_started)
	Globals.game.bot_sim_ended.connect(bot_sim_ended)


func _process(_delta) -> void:
	$FPS.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	$Objects.text = "Objects: " + \
					str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	
	if player:
		if invincible:
			_invincible()
		if infinite_ammo:
			_infinite_ammo()
		if bottomless_clip:
			_bottomless_clip()
			
		if Input.is_action_just_pressed("Debug") and bot_sim_level:
			_swap_cameras()


func bot_sim_started(new_level) -> void:
	bot_sim_level = new_level
	players_container = bot_sim_level.get_node("Players")
	player = players_container.player


func bot_sim_ended() -> void:
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
	#player.update_health_UI()

func _infinite_ammo() -> void:
	player.weapon_held.extra_ammo = player.weapon_held.stats.max_ammo - \
									player.weapon_held.stats.mag_size
	HUD.update_weapon(player.weapon_held.ammo_in_mag, player.weapon_held.extra_ammo)

func _bottomless_clip() -> void:
	if player:
		player.weapon_held.ammo_in_mag = player.weapon_held.properties.mag_size
	HUD.update_weapon(player.weapon_held.ammo_in_mag, player.weapon_held.extra_ammo)
