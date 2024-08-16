class_name Door
extends Node3D


@onready var starting_pos := global_position
@export var open_on_start := false
@export var open_dist := 2.4
@export var open_pos_z := true
@export var move_time := 2.5
@export var locked := false
@export var auto_close := true
@export var open_time := 10.0
var closed := true
var moving := false


func _ready() -> void:
	if open_on_start:
		position += basis.z * (open_dist * (int(open_pos_z) * 2 - 1))
		closed = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Use"):
		if $UseArea.overlaps_body(%Player):
			if !moving and !locked:
				_activate()


func _activate() -> void:
	$CloseTimer.stop()
	
	var tween = $Door.create_tween()
	moving = true
	$MoveSound.play(0.0)
	if closed:
		tween.tween_property(self, "position", position + (basis.z * \
							(open_dist * (int(open_pos_z) * 2 - 1))), move_time)
	else:
		tween.tween_property(self, "position", position - (basis.z * \
							(open_dist * (int(open_pos_z) * 2 - 1))), move_time)
	await tween.finished
	
	moving = false
	closed = !closed
	$MoveSound.stop()
	$FinishSound.play()
	
	if !closed and auto_close:
		$CloseTimer.start(open_time)
