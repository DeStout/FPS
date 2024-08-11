class_name AlertState
extends State


var update_interval := 10

func enter():
	print(enemy.name, ": Enter AlertState")
	enemy.action = Callable()


func exit():
	enemy.action = Callable()


func update(_delta):
	pass


func physics_update(delta):
	if get_tree().get_frame() % update_interval == 0:
		check_priorities()
	
	if enemy.action:
		enemy.action.call(delta)


func check_priorities() -> void:
	if enemy.check_enemies_visible():
		enemy.set_closest_to_target()
	
	if enemy.target:
		enemy.action = Callable(enemy.move_to_nav_target)
	else:
		transition.emit(self, "GuardState")
