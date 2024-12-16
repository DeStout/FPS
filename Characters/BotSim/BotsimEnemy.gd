class_name BotSimEnemy
extends BotSimCharacter


@onready var state_machine := $StateMachine
@onready var nav_agent := $NavAgent

var update_interval := 15
var update_offset := randi_range(0, update_interval-1)

@onready var aim_helper := $AimHelper
@onready var target_timer := $TargetTimer
var target_seek_time := 4.0
var target : CharacterBase = null
var enemies_vis : Array[bool] = []

@onready var shoot_timer := $ShootTimer
var shoot_speed_mod := 1.0/2.5
var shoot_speed_variance := Vector2(0.3, 1.0)

const TURN_SPEED := 6.0
const AIM_SPEED := 1.0
var move_speed_mod := 0.9
var bot_blocking := false


func _ready() -> void:
	super()
	
	state_machine.set_physics_process(false)
	await NavigationServer3D.map_changed
	state_machine.set_physics_process(true)


func set_processing(new_process) -> void:
	super(new_process)
	if new_process:
		state_machine.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		state_machine.process_mode = Node.PROCESS_MODE_DISABLED


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("EmoteWave"):
		anim_tree["parameters/Wave/request"] = \
									AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


func _process(delta: float) -> void:
	super(delta)


func _physics_process(delta):
	super(delta)
	for i in range(get_slide_collision_count()):
		if get_slide_collision(i).get_collider(0) is CharacterBase:
			bot_blocking = true


func set_enemies(new_enemies : Array[CharacterBase]) -> void:
	super(new_enemies)
	enemies_vis.resize(new_enemies.size())
	enemies_vis.fill(false)


func _fire() -> void:
	super()
	trigger_pulled = false
	var speed_variance := randf_range(shoot_speed_variance.x , shoot_speed_variance.y)
	var shoot_speed := 0.25 * speed_variance
	if weapon_held.weapon_type != Globals.WEAPONS.SLAPPER:
		shoot_speed = weapon_held.properties.shots_per_second * \
												shoot_speed_mod * speed_variance
	$ShootTimer.start(1.0 / shoot_speed)


func goal_reached() -> void:
	if state_machine.current_state.name == "SeekState":
		state_machine.current_state.set_goal()


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
		
	if is_inside_tree():
		var vis_enemies = enemies.filter(is_enemy_visible)
		target = vis_enemies[0]
		var dist = global_position.distance_squared_to(target.global_position)
		for enemy in vis_enemies:
			if enemy == target or !enemy.is_inside_tree():
				continue
			var temp_dist = global_position.distance_squared_to(enemy.global_position)
			if temp_dist < dist:
				target = enemy
				dist = temp_dist


func is_enemy_visible(enemy) -> bool:
	return enemies.has(enemy) and enemies_vis[enemies.find(enemy)]


func character_killed(deceased) -> void:
	if deceased == target:
		target = null


func get_closest_healths(healths_type : Globals.HEALTHS) -> PickUp:
	var healths_list = current_level.get_healths_pickups(healths_type)
	if !healths_list.size():
		return null
	elif healths_list.size() == 1:
		return healths_list[0]

	var healths_i := 0
	var temp_dist := global_position.distance_squared_to \
									(healths_list[healths_i].global_position)
	var healths_dist := temp_dist
	for i in range(1, healths_list.size()):
		temp_dist = global_position.distance_squared_to\
											(healths_list[i].global_position)
		if temp_dist < healths_dist:
			healths_dist = temp_dist
			healths_i = i
			
	return healths_list[healths_i]


func get_closest_weapon(weapon_type : Globals.WEAPONS) -> PickUp:
	var weapon_list = current_level.get_weapon_pickups(weapon_type)
	if !weapon_list.size():
		return null
	elif weapon_list.size() == 1:
		return weapon_list[0]

	var weapon_i := 0
	var temp_dist := global_position.distance_squared_to \
									(weapon_list[weapon_i].global_position)
	var weapon_dist := temp_dist
	for i in range(1, weapon_list.size()):
		temp_dist = global_position.distance_squared_to\
											(weapon_list[i].global_position)
		if temp_dist < weapon_dist:
			weapon_dist = temp_dist
			weapon_i = i
			
	return weapon_list[weapon_i]


func pickup_removed(pickup) -> void:
	if state_machine.current_state.name == "SeekState":
		state_machine.current_state.check_pickup(pickup)


func _swing() -> void:
	super()
	slap()


func take_damage(body_seg : Area3D, damage : int, shooter : CharacterBase) -> void:
	if state_machine.current_state.name == "SeekState" and \
									state_machine.current_state.active == true:
		target = shooter
		state_machine.current_state.alert()
	super(body_seg, damage, shooter)


func _unequip_weapon(old_weapon) -> void:
	if old_weapon == null:
		return
	old_weapon.visible = false


func _equip_weapon(new_weapon) -> void:
	new_weapon.visible = true
