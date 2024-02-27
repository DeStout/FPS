extends CharacterBase


const TURN_SPEED := 6.0
const AIM_SPEED := 8.0

@export var level : CampaignLevel = null
@onready var nav_agent := $NavAgent
@export var target : CharacterBase = null
var target_vis := false
var target_vis_threshold := 0.45


func _process(delta: float) -> void:
	if target != null:
		_look(delta)


func _physics_process(delta):
	super(delta)
	target_vis = _is_target_vis()
	_find_target()


func set_animation(anim : String) -> void:
	state_machine.travel(anim)


func turn_to_target(delta) -> void:
	var next_path_pos := Vector3.ZERO
	if !nav_agent.is_navigation_finished():
		next_path_pos = nav_agent.get_next_path_position()
		next_path_pos.y = position.y
	if next_path_pos and transform.origin != next_path_pos:
		var new_transform := transform.looking_at(next_path_pos)
		transform = transform.interpolate_with(new_transform, TURN_SPEED * delta)


func move_to_target(delta) -> void:
	var input_dir = Vector2.UP
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, accel)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, deaccel)
		velocity.z = move_toward(velocity.z, 0, deaccel)
	move_and_slide()


func _find_target() -> void:
	if target:
		%TargetCast.target_position = \
				%TargetCast.to_local(target.global_position) + Vector3(0, 0.9, 0)


func _is_target_vis() -> bool:
	var temp_target_vis = target and %TargetCast.is_colliding()
	temp_target_vis = %TargetCast.get_collider() == target
	var target_cast_col = to_local(%TargetCast.get_collision_point()).normalized()
	temp_target_vis =  target_cast_col.dot(Vector3.FORWARD) > target_vis_threshold
	return temp_target_vis


func set_rand_nav_point() -> void:
	nav_agent.target_position = level.get_nav_point().global_position


func has_arrived() -> bool:
	return nav_agent.is_target_reached()


func _look(delta) -> void:
	if target and target_vis:
		var target_pos : Vector3 = $LookHelper.to_local(target.global_position + 
																Vector3(0, 1.5, 0))
		$LookHelper.basis = $LookHelper.basis.looking_at(target_pos)
		var temp_euler : Vector3 = $LookHelper.basis.get_euler() / (PI/2)
		var eulers := Vector2(-temp_euler.y, temp_euler.x)
		var torso : Vector2 = anim_tree["parameters/Run/TorsoRunBlend/blend_position"]
		torso = torso.lerp(eulers, AIM_SPEED * delta)
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].x = torso.x
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].y = torso.y
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].x = torso.x
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].y = torso.y
		$LookHelper.basis = Basis()
	else:
		var torso : Vector2 = anim_tree["parameters/Run/TorsoRunBlend/blend_position"]
		torso = torso.lerp(Vector2.ZERO, AIM_SPEED * delta)
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].x = torso.x
		anim_tree["parameters/Run/TorsoRunBlend/blend_position"].y = torso.y
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].x = torso.x
		anim_tree["parameters/IdleFall/TorsoIdleBlend/blend_position"].y = torso.y


func _shoot() -> void:
	super()


func _swing() -> void:
	super()
	_slap()


func take_damage(body_seg_type : int, damage : int, shooter : CharacterBase) -> void:
	super(body_seg_type, damage, shooter)


# Keep so he don't die
func _die() -> void:
	health = 100
