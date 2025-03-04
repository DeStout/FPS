class_name Door
extends Node3D


signal finished

@export var open_on_start := false
@export var open_dist := 2.4
@export var open_pos_z := true
@export var move_time := 2.5
@export var locked := false
@export var auto_close := true
@export var open_time := 10.0

@onready var starting_pos := global_position
var closed := true
var moving := false
var tween : Tween = null

var bodies := []


func _ready() -> void:
	if open_on_start:
		$Door.position += $Door.basis.z * (open_dist * (int(open_pos_z) * 2 - 1))
		closed = false


func _show_activate(body) -> void:
	if !bodies.has(body):
		bodies.append(body)
		
	if body is Player and !locked and closed:
		HUD.show_activate(true)


func _hide_activate(body) -> void:
	if bodies.has(body):
		bodies.erase(body)
		
	if body is Player:
		HUD.show_activate(false)


func _input(event: InputEvent) -> void:
	var has_player := false
	for body in bodies:
		if body is Player:
			has_player = true
			break
	if !has_player:
		return
		
	if Input.is_action_just_pressed("Use"):
		if !locked:
			$ActivateSound.play()
			activate()
			HUD.show_activate(false)
			return
		HUD.show_locked()
		$ErrorSound.play()


func activate() -> void:
	if tween:
		tween.kill()
	tween = $Door.create_tween()
	
	$CloseTimer.stop()
	$MoveSound.play(0.0)
	closed = !closed
	moving = true
	
	var open_pos = ($Door.global_basis.z * (open_dist * (int(open_pos_z) * 2 - 1)))
	var tween_to = starting_pos + open_pos
	if closed:
		tween_to = starting_pos
	var move_perc = $Door.global_position.distance_to(tween_to) / open_dist
	var time_to = move_time * move_perc
	
	tween.tween_property($Door, "global_position", tween_to, time_to)
	await tween.finished
	finished.emit()
	
	$MoveSound.stop()
	$FinishSound.play()
	moving = false
	if !closed and auto_close:
		$CloseTimer.start(open_time)
	if closed and $UseArea.overlaps_body(%Player):
		HUD.show_activate(true)


func open(open) -> void:
	if closed == open:
		activate()


func set_auto_close(new_auto) -> void:
	auto_close = new_auto
	if !auto_close:
		$CloseTimer.stop()
