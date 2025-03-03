class_name Event
extends Node


@export var event_script : Script = null
@export var player : CharacterBase = null
var event := Node.new()
@export var resources : Array[Node] = []


func _ready() -> void:
	event.set_script(event_script)
	event.resources = resources
	add_child(event)
	event.player = player


func trigger() -> void:
	event.trigger()
