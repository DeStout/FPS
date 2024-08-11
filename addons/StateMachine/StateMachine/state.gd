extends Node
class_name State

@export var enemy : CharacterBase

signal transition
var active := false

func enter() -> void: pass
func exit() -> void: pass
func update(delta) -> void: pass
func physics_update(delta) -> void: pass
