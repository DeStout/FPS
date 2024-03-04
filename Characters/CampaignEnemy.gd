extends CharacterBase


const TURN_SPEED := 4.0
const AIM_SPEED := 8.0

@export var level : CampaignLevel = null
@onready var nav_agent := $NavAgent
@export var target : CharacterBase = null
var target_vis := false
var target_vis_threshold := 0.45

@export var patrol_path : Path3D = null


func _ready() -> void:
	super()
	nav_agent.target_position = Vector3.ZERO
	$NameLabel.text = name


func _process(delta: float) -> void:
	if target != null:
		_look(delta)


func _physics_process(delta):
	super(delta)
	_find_target()


func set_animation(anim : String) -> void:
	state_machine.travel(anim)


func _find_target() -> void:
	if target:
		%TargetCast.target_position = \
				%TargetCast.to_local(target.global_position) + Vector3(0, 0.9, 0)


func is_target_vis() -> bool:
	var temp_target_vis = target and %TargetCast.is_colliding()
	temp_target_vis = %TargetCast.get_collider() == target
	var target_cast_col = to_local(%TargetCast.get_collision_point()).normalized()
	temp_target_vis =  target_cast_col.dot(Vector3.FORWARD) > target_vis_threshold
	if temp_target_vis:
		trigger_pulled = true
	return temp_target_vis


func set_rand_nav_point() -> void:
	nav_agent.target_position = level.get_nav_point().global_position


func set_target_as_nav_target() -> void:
	nav_agent.target_position = target.global_position


func has_arrived() -> bool:
	print("Nav Arrived: ", nav_agent.is_target_reached())
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


# Keep so he don't die
func _die() -> void:
	health = 100
