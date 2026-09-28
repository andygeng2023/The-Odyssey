class_name OdysseyGatheringSystem
extends Node

signal gathered(resource_id, amount)

func gather(inventory: OdysseyInventory, resource_id: String, amount: int) -> bool:
	if inventory == null or amount <= 0:
		return false
	inventory.add_material(resource_id, amount)
	gathered.emit(resource_id, amount)
	return true

func gather_from_node(inventory: OdysseyInventory, node: OdysseyResourceNode) -> bool:
	if inventory == null or node == null:
		return false
	return node.harvest(null, inventory)
