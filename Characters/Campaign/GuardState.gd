class_name GuardState
extends State


var update_interval := 10


# Runs when the state is entered
func enter() -> void:
	print(enemy.name, ": Guard State")

# Runs when the state is exited
func exit() -> void:
	pass

# Updates every _process() update (When state is active)
func update() -> void:
	if get_tree().get_frame() % update_interval == 0:
		pass

# Updates every _physics_process() update (When state is active)
func physics_update() -> void:
	if get_tree().get_frame() % update_interval == 0:
		if enemy.check_enemies_visible():
			Transitioned.emit(self, "AlertState")