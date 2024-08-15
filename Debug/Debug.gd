extends CanvasLayer



var debug_visible := true
var fps_visible := true

# Cheats
var invincible := false
var infinite_ammo := false
var bottomless_clip := false

var level : MultiplayerLevel = null
var players_container = null
var player : CharacterBase = null
var player_pos : Transform3D

var debug_camera_ = preload("res://Debug/DebugCamera.tscn")
var debug_camera : CharacterBody3D = null
var cam_swap := false


func _ready() -> void:
	visible = debug_visible
	$FPS.visible = fps_visible
	
	Globals.game_started.connect(game_started)
	Globals.game_ended.connect(game_ended)


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
			
		if Input.is_action_just_pressed("DebugCam"):
			_swap_cameras()


# Emitted from Globals.start_match()
func game_started(new_level) -> void:
	level = new_level
	players_container = level.get_node("Players")
	#players_container = player.get_parent()
	player = players_container.player

func game_ended() -> void:
	level = null
	players_container = null
	player = null
	debug_camera = null
	cam_swap = false


func _swap_cameras() -> void:
	cam_swap = !cam_swap
	if cam_swap:
		player_pos = player.transform
		if !players_container:
			players_container = player.get_parent()
		players_container.remove_child(player)
		#for bot in players_container.bots:
			#bot.character_killed(player)
		
		if !debug_camera:
			debug_camera = debug_camera_.instantiate()
			debug_camera.transform = player_pos
			add_child(debug_camera)
			debug_camera.global_position.y += 1.5
		else:
			add_child(debug_camera)
	else:
		remove_child(debug_camera)
		players_container.add_child(player)
		player.transform = player_pos
		#for bot in players_container.bots:
			#bot.character_spawned(player, true)


func _invincible() -> void:
	player.health = player.MAX_HEALTH
	player.update_health_UI()

func _infinite_ammo() -> void:
	player.weapon_held.extra_ammo = player.weapon_held.stats.max_ammo - \
									player.weapon_held.stats.mag_size
	player.update_UI()

func _bottomless_clip() -> void:
	player.weapon_held.ammo_in_mag = player.weapon_held.stats.mag_size
	player.update_UI()
