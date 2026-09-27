extends Node3D
@onready var inventory: OdysseyInventory = $Odysseus/Inventory
@onready var crafting: OdysseyCraftingSystem = $Systems/Crafting
@onready var discovery: OdysseyDiscoverySystem = $Systems/Discovery
func _ready() -> void:
	inventory.add_material("wood", 20)
	inventory.add_material("rope", 6)
	inventory.add_material("stone", 10)
	discovery.discover("unknown_shore", "opening_coast")
	print("The Odyssey engine foundation is running.")
	print(crafting.craft(inventory, "raft"))
