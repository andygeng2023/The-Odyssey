class_name OdysseyRelationshipSystem
extends Node

signal relationship_changed(character_id, value)
var values: Dictionary = {}
var traits: Dictionary = {}

func set_character(character_id: String, initial: int = 0, trait: String = "") -> void:
    values[character_id] = clampi(initial, -100, 100)
    if trait != "":
        traits[character_id] = trait

func change(character_id: String, amount: int) -> void:
    values[character_id] = clampi(int(values.get(character_id, 0)) + amount, -100, 100)
    relationship_changed.emit(character_id, values[character_id])

func get_value(character_id: String) -> int:
    return int(values.get(character_id, 0))
