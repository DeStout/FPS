@tool
extends MeshInstance3D


var current_level : BotSimLevel

@export var process_in_editor := false :
	set = set_process_in_editor

var flash_threshold := 0.99
var flash_limits := Vector2(0.01, 0.3)
var flash_length := 0.05
var flash_time := 0.0

@onready var sfx_path := $SFXPath
@onready var sfx := $FlashSFX
var init_pitch := 1.0


func _ready() -> void:
	init_pitch = sfx.pitch_scale


func _process(delta : float) -> void:
	if Engine.is_editor_hint() and !process_in_editor:
		return
		
	if !visible:
		var flash = randf()
		if flash >= flash_threshold:
			visible = true
			if %Players.player.is_inside_tree():
				sfx.position = sfx_path.curve.get_closest_point( \
									to_local(%Players.player.global_position))
			sfx.pitch_scale = init_pitch + (init_pitch * randf_range(-0.1, 0.1))
			sfx.play()
			flash_length = randf_range(flash_limits.x, flash_limits.y)
	else:
		if flash_time >= flash_length:
			visible = false
			flash_time = 0.0
			return
		flash_time += delta


func set_process_in_editor(new_editor_process) -> void:
	process_in_editor = new_editor_process
	if !new_editor_process:
		sfx.pitch_scale = 1.0
		visible = true
