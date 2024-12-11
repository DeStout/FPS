extends Weapon


var slappable := []
@export var damage := 25


func _ready() -> void:
	$FireTimer.wait_time = 0.5


func fire() -> void:
	super()


func can_reload() -> bool:
	return false


func get_anim(anim : String) -> String:
	if anim == "Shoot":
		return Globals.WEAPON_NAMES[weapon_type] + "Slap" + str(randi_range(1, 2))
	else:
		return super(anim)


func _add_slappable(body: Node3D) -> void:
	if body.is_in_group("players"):
		slappable.append(body)


func _remove_slappable(body: Node3D) -> void:
	if slappable.has(body):
		slappable.erase(body)
