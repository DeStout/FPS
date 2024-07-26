extends CharacterBody3D


const ACCEL := 180
const DEACCEL := 120
const SPEED := 8
const FAST_SPEED := 14
var speed := SPEED


func _physics_process(delta: float) -> void:
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


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		$Camera3D.rotate_x(Globals.invert_y_to_int() * Globals.mouse_sensitivity * \
							event.relative.y)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, \
										-deg_to_rad(89), deg_to_rad(89))
		rotate_y(-Globals.mouse_sensitivity * event.relative.x)
		rotation.z = 0
