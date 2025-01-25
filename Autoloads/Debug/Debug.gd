extends CanvasLayer


var debug_visible := true
var fps_visible := true

# Cheats
var invisible := false
var invincible := false
var infinite_ammo := false
var bottomless_mag:= false

var bot_sim_level : BotSimLevel = null
var players_container = null
var player : CharacterBase = null
var player_pos : Transform3D

var debug_camera_ = load("res://Autoloads/Debug/DebugCamera.tscn")
var debug_camera : CharacterBody3D = null
var cam_swap := false


func _ready() -> void:
	visible = debug_visible
	$FPS.visible = fps_visible
	
	Globals.game.bot_sim_started.connect(_bot_sim_started)
	Globals.game.bot_sim_ended.connect(_bot_sim_ended)
	
	await get_tree().physics_frame
	HUD.pause_menu.options.invisibility.toggled.connect(_set_invisible)
	HUD.pause_menu.options.invincibility.toggled.connect(_set_invincible)
	HUD.pause_menu.options.infinite_ammo.toggled.connect(_set_infinite_ammo)
	HUD.pause_menu.options.bottomless_mag.toggled.connect(_set_bottomless_mag)
	HUD.pause_menu.options.wireframe.toggled.connect(_set_wireframe)


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


func _set_invisible(is_invisible : bool) -> void:
	invisible = is_invisible
	player.set_collision_layer_value(1, invisible)
	player.set_collision_layer_value(2, !invisible)
	player.set_collision_mask_value(2, !invincible)

func _set_invincible(is_invincible : bool) -> void:
	invincible = is_invincible

func _set_infinite_ammo(is_infinite : bool) -> void:
	infinite_ammo = is_infinite

func _set_bottomless_mag(is_bottomless : bool) -> void:
	bottomless_mag = is_bottomless

func _set_wireframe(is_wireframe : bool) -> void:
	var vp_rid := get_viewport().get_viewport_rid()
	if is_wireframe:
		RenderingServer.viewport_set_debug_draw(vp_rid, \
									RenderingServer.VIEWPORT_DEBUG_DRAW_WIREFRAME)
	else:
		RenderingServer.viewport_set_debug_draw(vp_rid, \
									RenderingServer.VIEWPORT_DEBUG_DRAW_DISABLED)


func _bot_sim_started(new_level) -> void:
	bot_sim_level = new_level
	players_container = bot_sim_level.players
	player = players_container.player
	player.respawned.connect(_player_respawned)


func _bot_sim_ended() -> void:
	bot_sim_level = null
	players_container = null
	player = null
	cam_swap = false
	
	if debug_camera:
		cam_swap = false
		debug_camera.queue_free()
		debug_camera = null


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


func _player_respawned() -> void:
	pass


func _invincible() -> void:
	player.health = player.MAX_HEALTH

func _infinite_ammo() -> void:
	if player.weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		player.weapon_held.extra_ammo = player.weapon_held.properties.max_ammo - \
										player.weapon_held.properties.mag_size
		HUD.update_weapon(player.weapon_held.ammo_in_mag, player.weapon_held.extra_ammo)
		player.grenade_count = player.MAX_GRENADES

func _bottomless_mag() -> void:
	if player.weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		player.weapon_held.ammo_in_mag = player.weapon_held.properties.mag_size
		HUD.update_weapon(player.weapon_held.ammo_in_mag, player.weapon_held.extra_ammo)
