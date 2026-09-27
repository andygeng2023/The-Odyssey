class_name OdysseyPrototypeInteractable
extends Node3D

@export var interaction_name := "Interact"
var action: Callable

func setup(label: String, callback: Callable) -> void:
	interaction_name = label
	action = callback

func interact(player: Node) -> void:
	if action.is_valid():
		action.call(player)
