extends CharacterBase


const TURN_SPEED := 4.0
const AIM_SPEED := 8.0

@export var level : CampaignLevel = null
@onready var nav_agent := $NavAgent
@export var target : CharacterBase = null
var target_vis := false
var target_vis_threshold := 0.15

@export var patrol_path : Path3D = null


func _ready() -> void:
	super()
	nav_agent.target_position = Vector3.ZERO
	$NameLabel.text = name


func _process(delta: float) -> void:
	super(delta)
	if target != null:
		_look(delta)
	if !trigger_pulled:
		_reset_aim()


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
	if %TargetCast.get_collider() == target:
		var target_cast_col = to_local(%TargetCast.get_collision_point()).normalized()
		if target_cast_col.dot(Vector3.FORWARD) > target_vis_threshold:
			return temp_target_vis
	return false


func set_rand_nav_point() -> void:
	nav_agent.target_position = level.get_nav_point().global_position


func set_target_as_nav_target() -> void:
	nav_agent.target_position = target.global_position


func set_nav_target(new_nav_target : Vector3) -> void:
	nav_agent.target_position = new_nav_target


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


func _reset_aim() -> void:
	$AimHelper.rotation.x = lerp_angle($AimHelper.rotation.x, 0, 0.5)


func _swing() -> void:
	super()
	_slap()


func _unequip_weapon(old_weapon) -> void:
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true


# Keep so he don't die
func _die() -> void:
	health = 100
