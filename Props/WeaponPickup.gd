@tool
extends PickUp


var pistol_ := preload("res://Props/PistolBase.tscn")
var rifle_ := preload("res://Props/RifleBase.tscn")

@export var weapon_type : Globals.WEAPONS : set = _set_model
@onready var weapon_model := get_child(0)
var weapon_info := []

var rotate_rate := 2.0


func _ready() -> void:
	rotation.y = randf() * 2 * PI


func _process(delta) -> void:
	$Model.rotate_y(rotate_rate * delta)


func _set_model(new_weapon_type) -> void:
	weapon_type = new_weapon_type
	match weapon_type:
		Globals.WEAPONS.SLAPPER:
			weapon_type = Globals.WEAPONS.PISTOL
		Globals.WEAPONS.PISTOL:
			weapon_model = pistol_.instantiate()
		Globals.WEAPONS.RIFLE:
			weapon_model = rifle_.instantiate()
	if $Model.get_child_count() > 0:
		$Model.get_child(0).replace_by(weapon_model)


func picked_up() -> void:
	super()
	if weapon_info.size() > 0:
		await $PickUpAudio.finished
		queue_free()


func set_up_drop(new_pos, new_weapon_info) -> void:
	weapon_type = new_weapon_info[0]
	weapon_info = new_weapon_info
	global_position = new_pos + Vector3(0, 0.25, 0)
	match weapon_info[0]:
		Globals.WEAPONS.PISTOL:
			name = "PistolPickUp"
		Globals.WEAPONS.RIFLE:
			name = "RiflePickUp"
	$Despawn.start()


func despawn() -> void:
	print(name, " despawned")
	queue_free()
