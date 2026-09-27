class_name OdysseyInventory
extends Node
signal changed
var bulk: Dictionary = {}
var equipment: Array[String] = []
var equipment_capacity: int = 6
var blueprints: Dictionary = {}
var important: Array[String] = []
func add_material(id: String, amount: int = 1) -> void:
	if amount <= 0: return
	bulk[id] = int(bulk.get(id, 0)) + amount
	changed.emit()
func remove_material(id: String, amount: int = 1) -> bool:
	if int(bulk.get(id, 0)) < amount: return false
	bulk[id] -= amount
	if bulk[id] <= 0: bulk.erase(id)
	changed.emit()
	return true
func has_materials(cost: Dictionary) -> bool:
	for id in cost:
		if int(bulk.get(id, 0)) < int(cost[id]): return false
	return true
func consume_materials(cost: Dictionary) -> bool:
	if not has_materials(cost): return false
	for id in cost: bulk[id] -= int(cost[id])
	changed.emit()
	return true
func equip(item_id: String) -> bool:
	if equipment.size() >= equipment_capacity: return false
	equipment.append(item_id)
	changed.emit()
	return true
