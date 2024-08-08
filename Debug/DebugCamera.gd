extends CharacterBody3D


const ACCEL := 180
const DEACCEL := 120
const SPEED := 8
const FAST_SPEED := 14
var speed := SPEED


func _process(delta: float) -> void:
	_update_time_UI()


func _physics_process(delta: float) -> void:
	# Controller Look
	var look_dir = Input.get_vector("LookLeft", "LookRight", "LookUp", "LookDown")
	if look_dir:
		$AimHelper.rotate_x(-Globals.invert_y_to_int() * \
							Globals.controller_sensitivity * \
							Globals.zoom_sensitibity * -look_dir.y)
		$AimHelper.rotation.x = clamp($AimHelper.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(Globals.controller_sensitivity * Globals.zoom_sensitibity * \
																-look_dir.x)
		rotation.z = 0
	
	var input_dir = Input.get_vector("StrifeLeft", "StrifeRight", "Forward", "Backward")
	var input_dir_y = Input.get_axis("Crouch", "Jump")
	var direction = (transform.basis * Vector3(input_dir.x, input_dir_y, \
																input_dir.y))
	speed = SPEED
	if Input.is_action_pressed("Fast"):
		speed = FAST_SPEED
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * speed, ACCEL * delta)
		velocity.y = move_toward(velocity.y, direction.y * speed, ACCEL * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DEACCEL * delta)
		velocity.y = move_toward(velocity.y, 0, DEACCEL * delta)
		velocity.z = move_toward(velocity.z, 0, DEACCEL * delta)
	move_and_slide()
	
	
func _update_time_UI() -> void:
	if Globals.match_settings.time != 0:
		%MatchTimer.set_time($"..".level.get_match_time())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$AimHelper/Camera3D.rotate_x(Globals.invert_y_to_int() * \
									Globals.mouse_sensitivity * event.relative.y)
		$AimHelper/Camera3D.rotation.x = clamp($AimHelper/Camera3D.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(-Globals.mouse_sensitivity * event.relative.x)
		rotation.z = 0
