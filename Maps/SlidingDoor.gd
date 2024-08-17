class_name Door
extends Node3D


@export var open_on_start := false
@export var open_dist := 2.4
@export var open_pos_z := true
@export var move_time := 2.5
@export var locked := false
@export var auto_close := true
@export var open_time := 10.0

@onready var starting_pos := global_position
var closed := true
var tween : Tween = null


func _ready() -> void:
	if open_on_start:
		$Door.position += $Door.basis.z * (open_dist * (int(open_pos_z) * 2 - 1))
		closed = false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Use"):
		if $UseArea.overlaps_body(%Player):
			if !locked:
				activate()


func activate() -> void:
	if tween:
		tween.kill()
	tween = $Door.create_tween()
		
	$CloseTimer.stop()
	$MoveSound.play(0.0)
	closed = !closed
	
	var open_pos = ($Door.global_basis.z * (open_dist * (int(open_pos_z) * 2 - 1)))
	var tween_to = starting_pos + open_pos
	if closed:
		tween_to = starting_pos
	var move_perc = $Door.global_position.distance_to(tween_to) / open_dist
	var time_to = move_time * move_perc
	
	tween.tween_property($Door, "global_position", tween_to, time_to)
	await tween.finished
	
	$MoveSound.stop()
	$FinishSound.play()
	
	if !closed and auto_close:
		$CloseTimer.start(open_time)
