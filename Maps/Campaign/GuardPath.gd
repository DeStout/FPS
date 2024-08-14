extends Path3D


@export var follower : CharacterBase
@onready var path_follow = $PathFollow
@export var speed := 5.5
@export var loop := true
var direction := 1


func _ready() -> void:
	if follower:
		speed = follower.GUARD_SPEED
	path_follow.loop = loop


func _physics_process(delta: float) -> void:
	path_follow.progress += (direction * ((speed * delta) / 2))
	if !loop and path_follow.progress_ratio <= 0 or path_follow.progress_ratio >= 1:
		direction *= -1
