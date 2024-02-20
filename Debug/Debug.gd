extends Control


var debug_visible := false

var fps_visible := true

#var enemy_behavior_visible := true

#enum Mute{NONE, MUSIC, SFX, ALL}
#var mute_visible := false
#@onready var master_bus := AudioServer.get_bus_index("Master")
#@onready var sfx_bus := AudioServer.get_bus_index("SFX")
#@onready var music_bus := AudioServer.get_bus_index("Music")
#var mute_setting := Mute.MUSIC

#var player : CharacterBase
#var player_invincible := false
#var infinite_ammo := false

enum Level{LEVEL1, LEVEL2, LEVEL3}
var level := Level.LEVEL3
var level_visible := true


func _ready() -> void:
	#player = get_tree().current_scene.get_node("Players").player
	visible = debug_visible
	$FPS.visible = fps_visible

	#if player:
		#player.weapon_picked_up.connect(_new_player_weapon)

	#$Mute.visible = mute_visible
	#_set_mute()

	$Level.visible = level_visible
	$Level.text = "Level:"

	#$Behaviors.visible = enemy_behavior_visible


func _process(_delta) -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	$FPS.text = "FPS: " + str(fps)


func _input(event) -> void:
#	if event.is_action_pressed("Kill"):
#		player.container.remove_player(player)
#	if event.is_action_pressed("Mute"):
#		mute_setting = (mute_setting + 1) % 4
#		_set_mute()
	if event.is_action_pressed("SwitchLevel"):
		_switch_level()


#func _new_player_weapon(new_weapon) -> void:
	#new_weapon.finished_reloading.connect(_infinte_ammo)


#func _infinte_ammo() -> void:
	#if infinite_ammo:
		#print("Debug: Infinite Ammo")
		#player.weapon_held.extra_ammo = player.weapon_held.max_ammo - \
										#player.weapon_held.mag_size
		#player._update_UI()

#func _set_mute() -> void:
#	match mute_setting:
#		Mute.NONE:
#			AudioServer.set_bus_mute(master_bus, false)
#			AudioServer.set_bus_mute(sfx_bus, false)
#			AudioServer.set_bus_mute(music_bus, false)
#			$Mute.text = "Mute: None"
#		Mute.MUSIC:
#			AudioServer.set_bus_mute(master_bus, false)
#			AudioServer.set_bus_mute(sfx_bus, false)
#			AudioServer.set_bus_mute(music_bus, true)
#			$Mute.text = "Mute: Music"
#		Mute.SFX:
#			AudioServer.set_bus_mute(master_bus, false)
#			AudioServer.set_bus_mute(sfx_bus, true)
#			AudioServer.set_bus_mute(music_bus, false)
#			$Mute.text = "Mute: SFX"
#		Mute.ALL:
#			AudioServer.set_bus_mute(master_bus, true)
#			AudioServer.set_bus_mute(sfx_bus, false)
#			AudioServer.set_bus_mute(music_bus, false)
#			$Mute.text = "Mute: All"
#
#
#func add_enemy_behavior_label(enemy) -> Label:
#	var label = Label.new()
#	label.name = enemy.name
#	$Behaviors.add_child(label)
#	return label
#
#
func _switch_level() -> void:
	if level == Level.LEVEL1:
		level = Level.LEVEL2
		#get_tree().change_scene_to_file("res://Level2.tscn")
		$Level.text = "Level: Level2"
	elif level == Level.LEVEL2:
		level = Level.LEVEL3
		#get_tree().change_scene_to_file("res://Level1.tscn")
		$Level.text = "Level: Level3"
	elif level == Level.LEVEL3:
		level = Level.LEVEL1
		#get_tree().change_scene_to_file("res://Level1.tscn")
		$Level.text = "Level: Level1"

	#for child in $Behaviors.get_children():
		#child.queue_free()
