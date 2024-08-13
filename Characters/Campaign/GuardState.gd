class_name GuardState
extends State


var update_interval := 10


func enter() -> void:
	print(enemy.name, ": Enter GuardState")
	# TODO: Set animations to standing idle
	pass


func exit() -> void:
	pass


func update(_delta) -> void:
	pass


func physics_update(delta) -> void:
	if get_tree().get_frame() % update_interval == 0:
		if enemy.check_enemies_visible():
			transition.emit(self, "AlertState")
			return
	enemy.guard(delta)


func alert() -> void:
	transition.emit(self, "AlertState")
