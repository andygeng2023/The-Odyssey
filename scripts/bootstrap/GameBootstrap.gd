class_name OdysseyGameBootstrap
extends Node3D

@onready var inventory: OdysseyInventory = $Player/Inventory
@onready var discovery: OdysseyDiscoverySystem = $Systems/Discovery
@onready var world: OdysseyWorldGenerator = $World
@onready var hud: OdysseyGameHUD = $UI/GameHUD
@onready var player: Odysseus = $Player
@onready var relationships: OdysseyRelationshipSystem = $Systems/Relationships
@onready var features: OdysseyWorldFeatureRegistry = $Systems/Features
@onready var backpack: OdysseyBackpackUI = $UI/BackpackLayer/BackpackUI

func _ready() -> void:
    inventory.add_material("wood", 4)
    inventory.add_material("rope", 2)
    inventory.add_material("stone", 3)
    inventory.add_food("fruit", 3)
    inventory.add_other("shell", 2)
    inventory.add_other("flint", 1)
    inventory.add_blueprint("campfire", "Campfire Blueprint")
    inventory.add_blueprint("raft", "Raft Blueprint")
    inventory.add_important("storm_survivor")
    inventory.equip("climbing_kit")
    relationships.set_character("athena", 0, "guide")
    relationships.set_character("telemachus", 0, "family")
    relationships.set_character("calypso", 0, "island_keeper")
    discovery.discover("unknown_shore", "opening_coast")
    world.build_shore(inventory, discovery)
    hud.bind_player(player)
    hud.bind_inventory(inventory)
    backpack.bind_inventory(inventory)
    hud.show_message("The journey begins. Explore, gather, build, climb, sail and discover your way home.", 6.0)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        if not player.try_interact():
            hud.show_message("Nothing nearby.", 1.5)
