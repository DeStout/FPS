class_name Event
extends Node


@export var event_script : Script = null
@export var player : CharacterBase = null
var event := Node.new()
@export var resources : Array[Node] = []


func _ready() -> void:
	event.set_script(event_script)
	add_child(event)
	event.player = player
	event.resources = resources


func trigger() -> void:
	event.trigger()
