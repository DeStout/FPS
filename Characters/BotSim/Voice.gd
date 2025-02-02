extends Node3D


enum VOICES {DE, REUBEN, AUTUMN}
var voice : VOICES

const HURT_SETTINGS = [[2, 7, 4],			# De
						[4, 10, 4],			#Reuben
						[-6, 7, 0]]			#Autumn]
const DEATH_SETTINGS = [[0, 5, 0],			# De
						[2, 7, 4],			#Reuben
						[-6, 7, 0]]			#Autumn]

var hurt_sfx := []
var death_sfx := []

func _ready() -> void:
	voice = randi() % VOICES.size()
	
	var new_voice : AudioStreamPlayer3D
	var voice_name : String
	match voice:
		VOICES.DE:
			voice_name = "De"
			new_voice = AudioStreamPlayer3D.new()
			new_voice.stream = preload("res://Characters/Audio/Hurt1.ogg")
			new_voice.volume_db = HURT_SETTINGS[VOICES.DE][0]
			new_voice.unit_size = HURT_SETTINGS[VOICES.DE][1]
			new_voice.max_db = HURT_SETTINGS[VOICES.DE][2]
			new_voice.bus = "SFX"
			add_child(new_voice)
			hurt_sfx.append(new_voice)
			new_voice = AudioStreamPlayer3D.new()
			new_voice.stream = preload("res://Characters/Audio/Hurt2.ogg")
			new_voice.volume_db = HURT_SETTINGS[VOICES.DE][0]
			new_voice.unit_size = HURT_SETTINGS[VOICES.DE][1]
			new_voice.max_db = HURT_SETTINGS[VOICES.DE][2]
			new_voice.bus = "SFX"
			add_child(new_voice)
			hurt_sfx.append(new_voice)
			new_voice = AudioStreamPlayer3D.new()
			new_voice.stream = preload("res://Characters/Audio/Death.ogg")
			new_voice.volume_db = DEATH_SETTINGS[VOICES.DE][0]
			new_voice.unit_size = DEATH_SETTINGS[VOICES.DE][1]
			new_voice.max_db = DEATH_SETTINGS[VOICES.DE][2]
			new_voice.bus = "SFX"
			#add_child(new_voice)
			death_sfx.append(new_voice)
		VOICES.REUBEN:
			voice_name = "Reuben"
			new_voice = AudioStreamPlayer3D.new()
			new_voice.stream = preload("res://Characters/Audio/Reuben_Ow.ogg")
			new_voice.volume_db = HURT_SETTINGS[VOICES.REUBEN][0]
			new_voice.unit_size = HURT_SETTINGS[VOICES.REUBEN][1]
			new_voice.max_db = HURT_SETTINGS[VOICES.REUBEN][2]
			new_voice.bus = "SFX"
			add_child(new_voice)
			hurt_sfx.append(new_voice)
			new_voice = AudioStreamPlayer3D.new()
			new_voice.stream = preload("res://Characters/Audio/Reuben_ImDying.ogg")
			new_voice.volume_db = DEATH_SETTINGS[VOICES.REUBEN][0]
			new_voice.unit_size = DEATH_SETTINGS[VOICES.REUBEN][1]
			new_voice.max_db = DEATH_SETTINGS[VOICES.REUBEN][2]
			new_voice.bus = "SFX"
			#add_child(new_voice)
			death_sfx.append(new_voice)
		VOICES.AUTUMN:
			voice_name = "Autumn"
			new_voice = AudioStreamPlayer3D.new()
			new_voice.stream = preload("res://Characters/Audio/Autumn_Ow.ogg")
			new_voice.volume_db = HURT_SETTINGS[VOICES.AUTUMN][0]
			new_voice.unit_size = HURT_SETTINGS[VOICES.AUTUMN][1]
			new_voice.max_db = HURT_SETTINGS[VOICES.AUTUMN][2]
			new_voice.bus = "SFX"
			add_child(new_voice)
			hurt_sfx.append(new_voice)
			new_voice = AudioStreamPlayer3D.new()
			new_voice.stream = preload("res://Characters/Audio/Autumn_Dying.ogg")
			new_voice.volume_db = DEATH_SETTINGS[VOICES.AUTUMN][0]
			new_voice.unit_size = DEATH_SETTINGS[VOICES.AUTUMN][1]
			new_voice.max_db = DEATH_SETTINGS[VOICES.AUTUMN][2]
			new_voice.bus = "SFX"
			#add_child(new_voice)
			death_sfx.append(new_voice)
	#print(owner.name, " is ", voice_name)


func get_hurt_sfx() -> AudioStreamPlayer3D:
	return hurt_sfx.pick_random()


func get_death_sfx() -> AudioStreamPlayer3D:
	return death_sfx.pick_random().duplicate()
