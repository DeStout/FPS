extends CharacterBase


const TURN_SPEED := 6.0
const AIM_SPEED := 8.0

@onready var nav_agent := $NavAgent

@onready var player := get_parent().get_node("Player")
var player_vis := false
var player_vis_threshold := 0.45

var input_dir := Vector2.ZERO


func new_name(new_name_ : String) -> void:
	name = new_name_
	$NameLabel.text = name


func _process(delta: float) -> void:
	_look(delta)


func _physics_process(delta):
	super(delta)

	# Accel and move
	var accel = ACCEL
	var deaccel = DEACCEL
	if !is_on_floor():
		accel = AIR_ACCEL
		deaccel = AIR_DEACCEL
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel)
	else:
		state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel)
		velocity.z = move_toward(velocity.z, 0, deaccel)
	move_and_slide()


func get_rand_nav_point() -> Vector3:
	return Vector3(randf(), randf(), randf())


func _look(delta) -> void:
	var player_pos : Vector3 = $LookHelper.to_local(player.global_position + 
															Vector3(0, 1.5, 0))
	$LookHelper.basis = $LookHelper.basis.looking_at(player_pos)
	var euler : Vector3 = $LookHelper.basis.get_euler() / (PI/2)
	anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].y = euler.x
	anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].x = -euler.y
	anim_tree["parameters/Run/TorsoRunBlend/blend_position"].y = euler.x
	anim_tree["parameters/Run/TorsoRunBlend/blend_position"].x = -euler.y
	$LookHelper.basis = Basis()


func _shoot() -> void:
	super()


func _swing() -> void:
	super()
	_slap()


func take_damage(body_seg_type : int, damage : int, shooter : CharacterBase) -> void:
	super(body_seg_type, damage, shooter)


func _die() -> void:
	health = 100
	pass
	#super()
	#player_vis = false
	#$VisTimer.stop()


func respawn() -> void:
	super()


func _unequip_weapon(old_weapon) -> void:
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
