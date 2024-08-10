class_name GuardState
extends State


# Parent Parameters
# signal Transitioned
# var active := false


# Runs when the state is entered
func enter():
	pass

# Runs when the state is exited
func exit():
	pass

# Updates every _process() update (When state is active)
func update():
	print("Guarding")

# Updates every _physics_process() update (When state is active)
func physics_update():
	pass
