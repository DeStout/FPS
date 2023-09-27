@tool
extends PickUp


@export var health_type : Globals.HEALTHS : set = _set_model
@onready var health_model := get_child(0)
var health_ := preload("res://Props/PickUps/HealthPackBase.tscn")
var armor_ := preload("res://Props/PickUps/ArmorBase.tscn")

var health_amount := 50

var rotate_rate := 2.0


func _process(delta) -> void:
	$Model.rotate_y(rotate_rate * delta)


func _set_model(new_health_type) -> void:
	health_type = new_health_type
	match health_type:
		Globals.HEALTHS.HEALTH_PACK:
			health_model = health_.instantiate()
			health_model.position.y = 0.325
			health_model.rotation_degrees = Vector3(-33, -34.6, 36.5)
			$PickUpAudio.pitch_scale = 2.0
		Globals.HEALTHS.ARMOR:
			health_model = armor_.instantiate()
			health_model.position.y = 0.1
			health_model.rotation = Vector3.ZERO
			$PickUpAudio.pitch_scale = 1.75
	if $Model.get_child_count() > 0:
		$Model.get_child(0).replace_by(health_model)
