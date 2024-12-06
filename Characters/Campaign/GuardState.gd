class_name GuardState
extends State


func enter() -> void:
	#print(enemy.name, ": Enter GuardState")
	if enemy.weapon_held != null:
		enemy.weapon_state_machine.travel("Guard")


func exit() -> void:
	pass


func update(_delta) -> void:
	pass


func physics_update(delta) -> void:
	if get_tree().get_frame() % enemy.update_interval == enemy.update_offset:
		if enemy.check_enemies_visible():
			transition.emit(self, "AlertState")
			return
	enemy.guard(delta)


func alert() -> void:
	transition.emit(self, "AlertState")
