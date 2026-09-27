class_name OdysseyGameBootstrap
extends Node3D

@onready var inventory: OdysseyInventory = $Player/Inventory
@onready var discovery: OdysseyDiscoverySystem = $Systems/Discovery
@onready var world: OdysseyWorldGenerator = $World
@onready var hud: OdysseyGameHUD = $UI/GameHUD
@onready var player: Odysseus = $Player

func _ready() -> void:
    inventory.add_material("wood", 4)
    inventory.add_material("rope", 2)
    inventory.add_material("stone", 3)
    discovery.discover("unknown_shore", "opening_coast")
    world.build_shore(inventory, discovery)
    hud.bind_player(player)
    hud.bind_inventory(inventory)
    hud.show_message("Washed ashore. Explore, gather, and make your own way.", 5.0)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        if not player.try_interact():
            hud.show_message("Nothing nearby to interact with.", 1.5)
