class_name AlertState
extends State


var update_interval := 10


func enter():
	#print(enemy.name, ": Enter AlertState")
	pass


func exit():
	pass


func update(_delta):
	pass


func physics_update(delta):
	if get_tree().get_frame() % update_interval == 0:
		check_priorities()
	
	enemy.move_to_target(delta)


func check_priorities() -> void:
	if enemy.check_enemies_visible():
		enemy.set_closest_to_target()
	
	if !enemy.target:
		transition.emit(self, "GuardState")
