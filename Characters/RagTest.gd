extends Skeleton3D


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(5).timeout
	physical_bones_start_simulation()
