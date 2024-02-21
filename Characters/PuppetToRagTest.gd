extends Node3D


var rag_doll_ = preload("res://Characters/RagDoll.tscn")
@onready var skeleton = $Skeleton3D


func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval(randf_range(2.5, 3.5))
	tween.tween_callback(_spawn_rag)


func _spawn_rag() -> void:
	var rag_doll = rag_doll_.instantiate()
	get_parent().add_child(rag_doll)
	rag_doll.match_pose_transform(skeleton, transform)
	visible = false
	queue_free()
