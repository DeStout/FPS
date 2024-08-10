extends CharacterBase


@onready var nav_agent := $NavAgent

var update_frame_interval := 5

@export var player : CharacterBase
var enemies_vis := []
var target_vis_threshold := 0.45
var target_dist := 2.5
var shoot_accuracy_threshold := 0.9
var shoot_speed_mod := 1.0/1.75
var shoot_speed_variance := Vector2(0.3, 1.0)

var move_speed_mod := 0.8
const TURN_SPEED := 6.0
const AIM_SPEED := 6.0
	
	
func _ready() -> void:
	super()


func _process(delta: float) -> void:
	super(delta)
	if get_tree().get_frame() % update_frame_interval == 0:
		_check_enemies_vis()


func _physics_process(delta):
	super(delta)

	var input_dir = Vector2.ZERO
	var next_path_pos := Vector3.ZERO
			
	if !nav_agent.is_navigation_finished():
		next_path_pos = nav_agent.get_next_path_position()
		next_path_pos.y = position.y
	
	if next_path_pos and transform.origin != next_path_pos:
		var new_transform : Transform3D
		input_dir = Vector2.UP
		new_transform = transform.looking_at(next_path_pos)
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_on_floor():
			state_machine.travel("Run")
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel * delta)
	else:
		state_machine.travel("IdleFall")
		velocity.x = move_toward(velocity.x, 0, deaccel * delta)
		velocity.z = move_toward(velocity.z, 0, deaccel * delta)
	velocity.x *= move_speed_mod
	velocity.z *= move_speed_mod
	move_and_slide()


func _check_enemies_vis() -> void:
	for enemy_i in range(%VisionCone.bodies_vis.size()):
		%TargetCast.target_position = %TargetCast.to_local(%VisionCone \
						.bodies_vis[enemy_i].global_position + (Vector3.UP*1.5))
		%TargetCast.force_raycast_update()


func _shoot() -> void:
	super()
	trigger_pulled = false
	var speed_variance = randf_range(shoot_speed_variance.x , shoot_speed_variance.y)
	var shoot_speed = weapon_held.stats.shots_per_second * shoot_speed_mod * speed_variance
	$ShootTimer.start(1.0 / shoot_speed)


func _swing() -> void:
	super()
	_slap()


func _jump() -> void:
	velocity.y = JUMP_VELOCITY


func take_damage(body_seg : Area3D, damage : int, shooter : CharacterBase) -> void:
	damage *= 2
	super(body_seg, damage, shooter)


func _unequip_weapon(old_weapon) -> void:
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
