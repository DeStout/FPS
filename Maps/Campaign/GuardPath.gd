extends Path3D


@export var follower : CharacterBase
var speed : float
@onready var path_follow = $PathFollow
@export var loop := true
var direction := 1


func _ready() -> void:
	path_follow.loop = loop
	speed = follower.GUARD_SPEED


func _physics_process(delta: float) -> void:
	path_follow.progress += (direction * ((speed * delta)))
	if !loop and path_follow.progress_ratio <= 0 or path_follow.progress_ratio >= 1:
		direction *= -1
