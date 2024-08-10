extends Node
class_name State

@export var enemy : CharacterBase

signal Transitioned
var active := false

func enter() -> void: pass
func exit() -> void: pass
func update() -> void: pass
func physics_update() -> void: pass
