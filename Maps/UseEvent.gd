extends Event


@export var activated := false
@export var togglable := false
@export var use_area : Area3D = null


func _ready() -> void:
	super()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Use"):
		if use_area.has_overlapping_bodies() and use_area.overlaps_body(player):
			if !activated or togglable:
				activated = !activated
				trigger()
