class_name GuardState
extends State


var update_interval := 10
var interval_offset := randi_range(0, update_interval)


func enter() -> void:
	#print(enemy.name, ": Enter GuardState")
	if enemy.weapon_held != null:
		enemy.weapon_state_machine.travel("Guard")


func exit() -> void:
	pass


func update(_delta) -> void:
	pass


func physics_update(delta) -> void:
	if get_tree().get_frame() % update_interval == interval_offset:
		if enemy.check_enemies_visible():
			transition.emit(self, "AlertState")
			return
	enemy.guard(delta)


func alert() -> void:
	transition.emit(self, "AlertState")
