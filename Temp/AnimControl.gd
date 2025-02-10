extends CanvasLayer


@export var anim_tree : AnimationTree
var upper_anim := "parameters/UpperAnim/blend_position"
var lower_anim := "parameters/LowerAnim/blend_position"
var shoot_request := "parameters/ShootOneShot/request"

@onready var container := $AnimControl
@onready var cursor := $AnimControl/Cursor
@export var value_label : Label
@onready var cursor_offset = cursor.size / 2 * cursor.scale
var cursor_captured := false


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event is InputEventMouseMotion and cursor_captured:
			_set_cursor_pos(event)
			return
			
		elif event is InputEventMouseButton:
			if event.pressed and event.button_index == 1 and !cursor_captured:
				if _is_in_bounds(event.global_position):
					cursor_captured = true
					_set_cursor_pos(event)
			else:
				cursor_captured = false


func _is_in_bounds(click_pos : Vector2) -> bool:
	var bounds = Rect2(container.global_position, container.size)
	return bounds.has_point(click_pos)


func _set_cursor_pos(event : InputEventMouse) -> void:
	cursor.global_position = event.global_position - cursor_offset
	cursor.global_position = cursor.global_position.clamp(container.global_position, 
									container.global_position + container.size -
													(cursor.size * cursor.scale))
	_set_anim_vals(_calc_val())


func _calc_val() -> Vector2:
	var bounds := Rect2((-container.size / 2) + cursor_offset, 
							container.size - (cursor_offset * 2))
	#return (cursor.position + bounds.position) / (bounds.size.x / 2)
	var val = (cursor.position + bounds.position) / (bounds.size.x / 2)
	return snapped(val, Vector2(0.1, 0.1))


func _set_anim_vals(new_vals : Vector2) -> void:
	anim_tree[upper_anim] = new_vals
	anim_tree[lower_anim] = new_vals
	value_label.text = str(new_vals)


func play_shoot_anim() -> void:
	anim_tree[shoot_request] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
