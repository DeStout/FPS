class_name AlertState
extends State


var update_interval := 10


# Runs when the state is entered
func enter():
	print(enemy.name, ": Alert State")

# Runs when the state is exited
func exit():
	pass

# Updates every _process() update (When state is active)
func update():
	pass

# Updates every _physics_process() update (When state is active)
func physics_update():
	if get_tree().get_frame() % update_interval == 0:
		if !enemy.check_enemies_visible():
			Transitioned.emit(self, "GuardState")
