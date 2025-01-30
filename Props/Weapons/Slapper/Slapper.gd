extends Weapon


var slappable := []
@export var damage := 25


func fire() -> void:
	super()
	fire_time = 0.5


func can_reload() -> bool:
	return false


func get_anim(anim : String) -> String:
	if anim == "Shoot":
		return "SlapperSlap" + str(randi_range(1, 2))
	else:
		return super(anim)


func is_fire_anim(anim : String) -> bool:
	return anim.contains("Slap")


func _add_slappable(body: Node3D) -> void:
	if body.is_in_group("players"):
		slappable.append(body)


func _remove_slappable(body: Node3D) -> void:
	if slappable.has(body):
		slappable.erase(body)
