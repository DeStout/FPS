extends CanvasLayer


var game_over = false

@onready var pause_menu := $PauseMenu

@onready var fade_in_out := $FadeInOut
@onready var match_timer := $MatchTimer
@onready var scoreboard := $Score
@onready var score_list := $Score/List
@onready var leader_list := $LeaderList

@onready var ui := $UI
@onready var reticle := $UI/Reticle
@onready var scope := $UI/Scope

@onready var weapon_info := $UI/Weapon
@onready var ammo_in_mag := $UI/Weapon/AmmoInMag
@onready var extra_ammo := $UI/Weapon/ExtraAmmo

@onready var health_mod := $UI/HealthMod
@onready var health_bar := $UI/HealthMod/HealthBar
@onready var armor_bar := $UI/HealthMod/ArmorBar

@onready var damage_up := $UI/Damage/Up
@onready var damage_down := $UI/Damage/Down
@onready var damage_left := $UI/Damage/Left
@onready var damage_right := $UI/Damage/Right

@export var open_time := 1.0
@export var close_time := 1.5

var default_reticle_pos := 50
var max_reticle_bloom := 150

var screenshot_path := "E:\\De\\My Documents\\Godot\\Exports" + \
										"\\MannequinShooter\\Images\\Screenshots\\"

func _ready() -> void:
	set_process(false)
	visible = false


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ScoreBoard"):
		show_health()
	
	if Input.is_action_just_pressed("Screenshot"):
		_take_screenshot()


func _process(delta: float) -> void:
	if !game_over and !Input.is_action_pressed("ScoreBoard"):
		_fade_health(delta)
	_fade_dmg(delta)


func _take_screenshot(): # Function for taking screenshots and saving them
	var date = Time.get_date_string_from_system().replace(".","_") 
	var time :String = Time.get_time_string_from_system().replace(":","")
	var screenshot_name = "screenshot_" + date + "_" + time + ".png"
	var full_path = screenshot_path + screenshot_name
	
	var image = get_viewport().get_texture().get_image()
	image.save_png(full_path)
	$ScreenshotSFX.play()


func setup_single_player() -> void:
	ui.visible = true
	fade_in_out.visible = true
	match_timer.visible = false
	scoreboard.visible = false
	scoreboard.locked = true


func setup_bot_sim() -> void:
	ui.visible = true
	fade_in_out.visible = true
	if Globals.game.bot_sim_settings.time > 0:
		match_timer.visible = true
	else:
		match_timer.visible = false
	scoreboard.visible = false
	scoreboard.locked = false


func reset_scoreboard() -> void:
	scoreboard.characters.clear()
	scoreboard.teams.clear()
	score_list.clear()
	leader_list.reset()


func set_game_over() -> void:
	game_over = true
	scoreboard.visible = true
	show_health()
	$MatchTimer.visible = false


func exit_game() -> void:
	game_over = false
	visible = false
	set_process(false)


func fade_in() -> void:
	visible = true
	HUD.show_health()
	fade_in_out.color.a = 1
	var tween = create_tween()
	tween.tween_property(fade_in_out, "color:a", 0.0, open_time)
	await tween.finished
	set_process(true)
	return


func fade_out() -> void:
	fade_in_out.visible = true
	fade_in_out.color.a = 0
	var tween = create_tween()
	tween.tween_property(fade_in_out, "color:a", 1.0, close_time)
	await tween.finished
	return


func show_weapon_info(show : bool) -> void:
	$UI/Weapon.visible = show


func update_weapon(mag_ammo, ammo_extra) -> void:
	ammo_in_mag.text = str(mag_ammo)
	extra_ammo.text = str(ammo_extra)


func show_health() -> void:
	health_mod.modulate.a = 1


func update_health(max_health, max_armor, health, armor) -> void:
	# Health Boxes
	var box_count := health_bar.get_child_count()
	var health_per_box : int = max_health / box_count
	var filled_boxes : int = health / health_per_box
	for box_num in range(0, box_count):
		var box : ColorRect = health_bar.get_child(box_count - box_num - 1)
		if box_num < filled_boxes:
			box.color.a = 1
		elif box_num == filled_boxes:
			box.color.a = fmod(health, health_per_box) / float(health_per_box)
		else:
			box.color.a = 0

	# Armor Boxes
	box_count = armor_bar.get_child_count()
	var armor_per_box : int = max_armor / box_count
	filled_boxes = armor / armor_per_box
	for box_num in range(0, box_count):
		var box : ColorRect = armor_bar.get_child(box_count - box_num - 1)
		if box_num < filled_boxes:
			box.color.a = 1
		elif box_num == filled_boxes:
			box.color.a = fmod(armor, armor_per_box) / float(armor_per_box)
		else:
			box.color.a = 0


func show_activate(show : bool) -> void:
	$Activate.visible = show


func show_locked() -> void:
	$Locked.visible = true
	$Locked/LockedTimer.start(2)


func _hide_locked() -> void:
	$Locked.visible = false


func show_reticle(show) -> void:
	reticle.visible = show


func bloom_reticle(bloom_perc : float) -> void:
	var bloom = bloom_perc * (max_reticle_bloom - default_reticle_pos)
	reticle.get_child(1).offset.x = -bloom - default_reticle_pos
	reticle.get_child(2).offset.x = bloom + default_reticle_pos


func zoom_crosshairs(show) -> void:
	scope.visible = show
	reticle.visible = !show


func show_damage(dmg_dir) -> void:
	if dmg_dir.y > 0:
		damage_up.modulate.a = dmg_dir.y
	else:
		damage_down.modulate.a = abs(dmg_dir.y)
	if dmg_dir.x > 0:
		damage_right.modulate.a = dmg_dir.x
	else:
		damage_left.modulate.a = abs(dmg_dir.x)


func _fade_health(delta) -> void:
	if health_mod.modulate.a > 0:
		health_mod.modulate.a -= delta


func _fade_dmg(delta) -> void:
	if damage_up.modulate.a > 0:
		damage_up.modulate.a -= delta
	if damage_left.modulate.a > 0:
		damage_left.modulate.a -= delta
	if damage_down.modulate.a > 0:
		damage_down.modulate.a -= delta
	if damage_right.modulate.a > 0:
		damage_right.modulate.a -= delta
