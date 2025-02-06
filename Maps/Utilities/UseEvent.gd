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
				HUD.show_activate(false)
				activated = !activated
				trigger()


func _show_activate(body) -> void:
	if body is Player and !activated:
		HUD.show_activate(true)


func _hide_activate(body) -> void:
	if body is Player:
		HUD.show_activate(false)
