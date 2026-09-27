class_name OdysseyCraftingSystem
extends Node
signal crafted(item_id)
var recipes := {
	"rope_ladder": {"cost": {"wood": 4, "rope": 2}, "tags": ["climbable", "constructible"]},
	"raft": {"cost": {"wood": 12, "rope": 4}, "tags": ["transport", "watercraft"]},
	"campfire": {"cost": {"wood": 3, "stone": 2}, "tags": ["fire", "cooking", "warmth"]},
	"bridge": {"cost": {"wood": 8, "rope": 2}, "tags": ["traversal", "constructible"]},
	"storage": {"cost": {"wood": 6}, "tags": ["storage"]}
}
func craft(inventory: OdysseyInventory, item_id: String) -> Dictionary:
	if not recipes.has(item_id): return {"ok": false, "reason": "Unknown recipe"}
	var recipe: Dictionary = recipes[item_id]
	if not inventory.consume_materials(recipe.cost): return {"ok": false, "reason": "Missing materials"}
	crafted.emit(item_id)
	return {"ok": true, "item": item_id, "tags": recipe.tags}
