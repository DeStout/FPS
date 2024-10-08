# Finite State Machine

## Creating State Machine

To create the State Machine, simply create a new State Machine Node.

> [!NOTE]
> To make a starting State for the State Machine, select the State Machine and change the Initial State property.

## Creating a State

To create a new State, create a script similiar to this...

```gdscript
extends State
class_name STATE_NAME # Your state's name

# Runs when the state is entered
func enter():
	pass

# Runs when the state is exited
func exit():
	pass

# Updates every _process() update (When state is active)
func update():
	pass

# Updates every _physics_process() update (When state is active)
func physics_update():
	pass
```

> [!WARNING]
> If you do not specify a class name for your state, you will be unable to create a node of the State.

To add the State to the State Machine, create a new Node of the State you just made, and add it as a child of the State Machine.

## Transitioning to other States

To transition to other States on the State Machine, make sure there are more than one State as a child of the State Machine.

To transition to another State, you can use the `Transitioned` signal (signal inside State script)...

```gdscript
# (CURRENT_STATE, NEXT_STATE_NAME)
Transitioned.emit(self, "EnemyIdle")
```

## Checking if State is Active

If you need to check if a state is active while inside of the state, for example, inside the EnemyIdle state you are checking the `_on_area_entered():` (you might already be getting an 'Cannot change state from a non-active state') you can use the `active` boolean included inside the State class to check if the state is currently active.

```gdscript
# Instead of doing this...
func area_entered(area):
	# Code here

# Do this...
func area_entered(area):
	if active:
		# Code here
```

> [!NOTE]
> This applies to any functions that could run at anytime (such as `area_entered`, `area_exited`, etc).

# Support

If you have any issues, create an [Issue](https://github.com/AlecSouthward/State-Machine/issues/new) or message me on Discord at `itsmealec`.
