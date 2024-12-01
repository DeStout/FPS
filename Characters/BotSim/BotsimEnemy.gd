extends BotSimCharacter


@onready var state_machine := $StateMachine
@onready var nav_agent := $NavAgent

var target : CharacterBase = null
var enemies_vis : Array[bool] = []
var alert := false

@export var starting_weapon : Globals.WEAPONS
var shoot_speed_mod := 1.0/2.5
var shoot_speed_variance := Vector2(0.3, 1.0)

const GUARD_SPEED := 3.0
const TURN_SPEED := 6.0
const AIM_SPEED := 1.0
var move_speed_mod := 0.8


func _ready() -> void:
	super()
	
	#enemies_vis.resize(enemies.size())
	#enemies_vis.fill(false)
	
	#weapons.append(starting_weapon)
	#_switch_weapon(_get_weapon(starting_weapon))
	
	state_machine.set_physics_process(false)
	await NavigationServer3D.map_changed
	state_machine.set_physics_process(true)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("EmoteWave"):
		anim_tree["parameters/Wave/request"] = \
									AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE



func _process(delta: float) -> void:
	super(delta)


func _physics_process(delta):
	super(delta)


func set_enemies(new_enemies : Array[CharacterBase]) -> void:
	super(new_enemies)
	enemies_vis.resize(new_enemies.size())
	enemies_vis.fill(false)


func aim(delta) -> void:
	if target and enemies_vis[enemies.find(target)]:
		var target_pos = target.global_position + Vector3(0, 1.2, 0)
		var new_trans : Transform3D = $AimHelper.global_transform.looking_at(target_pos)
		$AimHelper.global_transform = $AimHelper.global_transform.interpolate_with \
													(new_trans, AIM_SPEED * delta)
	else:
		$AimHelper.rotation = $AimHelper.rotation.lerp(Vector3.ZERO, AIM_SPEED * delta)
	$AimHelper.rotation.x = clamp($AimHelper.rotation.x, deg_to_rad(-90), rad_to_deg(90))
	$AimHelper.rotation.y = clamp($AimHelper.rotation.y, deg_to_rad(-80), rad_to_deg(80))
	$AimHelper.rotation.z = 0


func target_lost() -> void:
	target = null


func check_enemies_visible() -> bool:
	%TargetCast.target_position = Vector3.FORWARD
	enemies_vis.fill(false)
	var bodies = %VisionCone.get_bodies()
	for body in bodies:
		if enemies.has(body):
			%TargetCast.target_position = %TargetCast.to_local(\
										body.global_position + (Vector3.UP*1.5))
			%TargetCast.force_raycast_update()
			if %TargetCast.is_colliding() and %TargetCast.get_collider() == body:
				enemies_vis[enemies.find(body)] = true
	return enemies_vis.has(true)


func set_closest_to_target() -> void:
	if enemies.size() == 0:
		return
		
	target = enemies[0]
	var dist = global_position.distance_squared_to(target.global_position)
	for enemy in enemies:
		if enemy == target or !enemy.is_inside_tree():
			continue
		var temp_dist = global_position.distance_squared_to(enemy.global_position)
		if temp_dist < dist:
			target = enemy
			dist = temp_dist


func is_enemy_visible(enemy) -> bool:
	return enemies.has(enemy) and enemies_vis[enemies.find(enemy)]


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
	if state_machine.current_state.name == "GuardState" and \
									state_machine.current_state.active == true:
		target = shooter
		state_machine.current_state.alert()
	super(body_seg, damage*2.5, shooter)


func _die() -> void:
	super()
	
	if weapon_held.stats.weapon_type != Globals.WEAPONS.SLAPPER:
		var weapon_info := [weapon_held.stats.weapon_type,
								weapon_held.extra_ammo,
								weapon_held.ammo_in_mag]
		current_level.spawn_weapon_pick_up(global_position, weapon_info)
	
	#call_deferred("queue_free")


func _unequip_weapon(old_weapon) -> void:
	if old_weapon == null:
		return
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
