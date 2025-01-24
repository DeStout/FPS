extends Node3D


var slapper_ := load("res://Characters/Player/FirstPerson/FP_Slapper.tscn")
var pistol_ := load("res://Characters/Player/FirstPerson/FP_Pistol.tscn")
var smg_ := load("res://Characters/Player/FirstPerson/FP_SMG.tscn")
var rifle_ := load("res://Characters/Player/FirstPerson/FP_Rifle.tscn")
var shotgun_ := load("res://Characters/Player/FirstPerson/FP_Shotgun.tscn")
var sniper_ := load("res://Characters/Player/FirstPerson/FP_Sniper.tscn")

@export var player : CharacterBase = null
var current_weapon : FPWeapon
var animator : AnimationPlayer = null


func get_weapon(weapon_type : Globals.WEAPONS) -> Node3D:
	match weapon_type:
		Globals.WEAPONS.SLAPPER:
			return slapper_.instantiate()
		Globals.WEAPONS.PISTOL:
			return pistol_.instantiate()
		Globals.WEAPONS.SMG:
			return smg_.instantiate()
		Globals.WEAPONS.RIFLE:
			return rifle_.instantiate()
		Globals.WEAPONS.SHOTGUN:
			return shotgun_.instantiate()
		Globals.WEAPONS.SNIPER:
			return sniper_.instantiate()
		_:
			assert(false, "FirstPerson.get_weapon(): weapon_type not a weapon")
			return


func add_weapon(new_weapon : Weapon) -> void:
	current_weapon = get_weapon(new_weapon.weapon_type)
	current_weapon.show_mesh(false)
	current_weapon.first_person = self
	current_weapon.weapon = player.weapon_held
	player.weapon_held.fp_weapon = current_weapon
	
	add_child(current_weapon)
	animator = current_weapon.anim_player
	await get_tree().physics_frame
	
	animator.play_backwards(new_weapon.get_anim("Equip"))
	current_weapon.show_mesh(true)


func remove_weapon(old_weapon : Weapon) -> void:
	assert(current_weapon.weapon_type == old_weapon.weapon_type, \
							"FirstPerson.remove_weapon(): weapon_type mismatch")
	animator.play(old_weapon.get_anim("Equip"))
	await animator.animation_finished
	current_weapon.queue_free()
	return


func show_weapon(show : bool) -> void:
	current_weapon.show_mesh(show)


func reset_weapons() -> void:
	current_weapon.queue_free()
	current_weapon = get_weapon(Globals.WEAPONS.SLAPPER)
	add_child(current_weapon)
	animator = current_weapon.anim_player


func slap() -> void:
	player.slap()


func shell_loaded() -> void:
	player.shell_loaded()
