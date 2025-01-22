extends Node3D


var slapper_ := load("res://Characters/Player/FirstPerson/FP_SlapperAnims.blend")
var pistol_ := load("res://Characters/Player/FirstPerson/FP_PistolAnims.blend")
var smg_ := load("res://Characters/Player/FirstPerson/FP_SMGAnims.blend")
var rifle_ := load("res://Characters/Player/FirstPerson/FP_RifleAnims.blend")
var shotgun_ := load("res://Characters/Player/FirstPerson/FP_ShotgunAnims.blend")
var sniper_ := load("res://Characters/Player/FirstPerson/FP_SniperAnims.blend")

@export var player : CharacterBase = null


func _slap() -> void:
	player.slap()


func _shell_loaded() -> void:
	player.shell_loaded()
