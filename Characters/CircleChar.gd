extends CharacterBase

@export var speed := 0.5
@export var turn := 0.02


func _ready():
	super()
	state_machine.travel("Run")


func _physics_process(delta):
	var input_dir = Vector2(0, -speed)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	rotate_y(turn)

	move_and_slide()


func _die() -> void:
	$DeathSFX.get_children().pick_random().play()
	visible = false

	for body_seg in body_segs:
		body_seg.set_collision_layer_value(4, false)

	$Collision.disabled = true
	$Respawn.start()


func _respawn():
	visible = true

	for body_seg in body_segs:
		body_seg.set_collision_layer_value(4, true)

	$Collision.disabled = false
	health = 100
	print(name, " Respawn")
