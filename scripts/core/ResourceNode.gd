class_name OdysseyResourceNode
extends OdysseyWorldObject

signal harvested(actor, material_id, amount)
@export var harvest_yield: Dictionary = {"wood": 3}
@export var harvest_uses := 3

func harvest(actor: Node, inventory: OdysseyInventory) -> bool:
	if harvest_uses <= 0 or inventory == null:
		return false
	for material_id in harvest_yield:
		var amount := int(harvest_yield[material_id])
		inventory.add_material(material_id, amount)
		harvested.emit(actor, material_id, amount)
	harvest_uses -= 1
	if harvest_uses <= 0:
		queue_free()
	return true
