class_name OdysseyGameHUD
extends CanvasLayer

var hud_label: Label
var message_label: Label
var message_timer := 0.0
var player: Odysseus
var inventory: OdysseyInventory

func _ready() -> void:
    var panel := ColorRect.new()
    panel.position = Vector2(18, 18)
    panel.size = Vector2(430, 132)
    panel.color = Color(0.025, 0.045, 0.065, 0.72)
    add_child(panel)
    hud_label = Label.new()
    hud_label.position = Vector2(32, 28)
    hud_label.add_theme_font_size_override("font_size", 15)
    add_child(hud_label)
    message_label = Label.new()
    message_label.position = Vector2(32, 630)
    message_label.size = Vector2(1100, 60)
    message_label.add_theme_font_size_override("font_size", 18)
    add_child(message_label)

func bind_player(value: Odysseus) -> void:
    player = value

func bind_inventory(value: OdysseyInventory) -> void:
    inventory = value

func _process(delta: float) -> void:
    message_timer = maxf(0.0, message_timer - delta)
    if message_timer <= 0.0 and message_label:
        message_label.text = ""
    if player and inventory:
        hud_label.text = "THE ODYSSEY  •  THE SHORE\n\nWood %d   Stone %d   Rope %d   Stamina %d%%" % [
            int(inventory.bulk.get("wood", 0)),
            int(inventory.bulk.get("stone", 0)),
            int(inventory.bulk.get("rope", 0)),
            int(player.traversal.stamina)
        ]

func show_message(text: String, duration: float = 3.0) -> void:
    if message_label:
        message_label.text = text
    message_timer = duration
