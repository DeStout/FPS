class_name AlertState
extends State


var update_interval := 10
var interval_offset := randi_range(0, update_interval)


func enter() -> void:
	#print(enemy.name, ": Enter AlertState")
	if enemy.weapon_held != null:
		enemy.weapon_state_machine.travel("Alert")


func exit() -> void:
	pass


func update(_delta) -> void:
	pass


func physics_update(delta) -> void:
	if get_tree().get_frame() % update_interval == interval_offset:
		check_priorities()
	
	enemy.aim(delta)
	enemy.move_to_target(delta)


func check_priorities() -> void:
	if enemy.check_enemies_visible():
		enemy.set_closest_to_target()
	
	if !enemy.target:
		transition.emit(self, "GuardState")
