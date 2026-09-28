class_name OdysseyWorldObject
extends Node3D

@export var display_title: String = ""
@export var material_id: String = ""
@export var quantity: int = 1
@export var tags: Array[String] = []
@export var mass: float = 1.0
@export var flammable: bool = false
@export var breakable: bool = false
@export var movable: bool = false
@export var carryable: bool = false
@export var usable_as_weapon: bool = false
@export var durability: float = 100.0
@export var harvest_damage: float = 34.0

func display_name() -> String:
	return display_title if not display_title.is_empty() else name.replace("_", " ").capitalize()

func can(action: String) -> bool:
	return action in tags

func apply_damage(amount: float) -> bool:
	if not breakable:
		return false
	durability = maxf(0.0, durability - amount)
	if durability <= 0.0:
		queue_free()
		return true
	return false
