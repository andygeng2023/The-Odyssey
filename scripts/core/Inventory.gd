class_name OdysseyInventory
extends Node

signal changed

var bulk: Dictionary = {}
var foodstuff: Dictionary = {}
var other_items: Dictionary = {}
var equipment: Array[String] = []
var equipment_capacity: int = 6
var blueprints: Dictionary = {}
var important: Array[String] = []

const ITEM_DEFINITIONS := {
    "wood": {"name": "Wood", "description": "Branches, timber and usable wood."},
    "stone": {"name": "Stone", "description": "Stone fragments and building material."},
    "rope": {"name": "Rope", "description": "Strong cord for traversal and construction."},
    "fiber": {"name": "Plant Fiber", "description": "Flexible fibers gathered from plants."},
    "herb": {"name": "Wild Herb", "description": "A useful plant gathered in the wild."},
    "fruit": {"name": "Wild Fruit", "description": "Simple food gathered from the coastline."},
    "dried_fish": {"name": "Dried Fish", "description": "Travel food that keeps well."},
    "shell": {"name": "Sea Shell", "description": "A small object found along the shore."},
    "flint": {"name": "Flint", "description": "Hard stone useful around campfires."},
    "raft_frame": {"name": "Raft Frame", "description": "A prepared frame for a small vessel."},
    "climbing_kit": {"name": "Climbing Kit", "description": "Practical equipment for difficult climbs."}
}

func add_material(id: String, amount: int = 1) -> void:
    if amount <= 0:
        return
    bulk[id] = int(bulk.get(id, 0)) + amount
    changed.emit()

func remove_material(id: String, amount: int = 1) -> bool:
    if int(bulk.get(id, 0)) < amount:
        return false
    bulk[id] -= amount
    if bulk[id] <= 0:
        bulk.erase(id)
    changed.emit()
    return true

func add_food(id: String, amount: int = 1) -> void:
    if amount <= 0:
        return
    foodstuff[id] = int(foodstuff.get(id, 0)) + amount
    changed.emit()

func add_other(id: String, amount: int = 1) -> void:
    if amount <= 0:
        return
    other_items[id] = int(other_items.get(id, 0)) + amount
    changed.emit()

func add_blueprint(id: String, name: String = "Blueprint") -> void:
    blueprints[id] = name
    changed.emit()

func add_important(id: String) -> void:
    if not important.has(id):
        important.append(id)
        changed.emit()

func has_materials(cost: Dictionary) -> bool:
    for id in cost:
        if int(bulk.get(id, 0)) < int(cost[id]):
            return false
    return true

func consume_materials(cost: Dictionary) -> bool:
    if not has_materials(cost):
        return false
    for id in cost:
        bulk[id] -= int(cost[id])
        if bulk[id] <= 0:
            bulk.erase(id)
    changed.emit()
    return true

func equip(item_id: String) -> bool:
    if equipment.has(item_id) or equipment.size() >= equipment_capacity:
        return false
    equipment.append(item_id)
    changed.emit()
    return true

func unequip(item_id: String) -> bool:
    var index := equipment.find(item_id)
    if index < 0:
        return false
    equipment.remove_at(index)
    changed.emit()
    return true

func get_category_entries(category: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    match category:
        "Foodstuff":
            for id in foodstuff:
                result.append(_entry(id, int(foodstuff[id])))
        "Materials":
            for id in bulk:
                result.append(_entry(id, int(bulk[id])))
        "Other":
            for id in other_items:
                result.append(_entry(id, int(other_items[id])))
        "Equipment":
            for id in equipment:
                result.append(_entry(id, 1))
    return result

func _entry(id: String, amount: int) -> Dictionary:
    var definition: Dictionary = ITEM_DEFINITIONS.get(id, {"name": id.replace("_", " ").capitalize(), "description": "A useful item."})
    return {"id": id, "name": definition.get("name", id), "description": definition.get("description", ""), "amount": amount}
