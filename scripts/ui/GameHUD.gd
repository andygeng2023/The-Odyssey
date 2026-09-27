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
    panel.size = Vector2(450, 122)
    panel.color = Color(0.02, 0.04, 0.05, 0.78)
    add_child(panel)
    hud_label = Label.new()
    hud_label.position = Vector2(32, 30)
    hud_label.add_theme_font_size_override("font_size", 16)
    add_child(hud_label)
    message_label = Label.new()
    message_label.position = Vector2(32, 620)
    message_label.size = Vector2(1100, 60)
    message_label.add_theme_font_size_override("font_size", 18)
    add_child(message_label)

func bind_player(value: Odysseus) -> void:
    player = value

func bind_inventory(value: OdysseyInventory) -> void:
    inventory = value

func _process(delta: float) -> void:
    message_timer = maxf(0.0, message_timer - delta)
    if message_timer <= 0.0:
        message_label.text = ""
    if player and inventory:
        hud_label.text = "THE ODYSSEY — THE SHORE\nWASD / arrows: move    Shift: sprint    E: interact\nWood: %d    Stone: %d    Rope: %d\nStamina: %d / %d" % [
            int(inventory.bulk.get("wood", 0)),
            int(inventory.bulk.get("stone", 0)),
            int(inventory.bulk.get("rope", 0)),
            int(player.traversal.stamina),
            int(player.traversal.max_stamina)
        ]

func show_message(text: String, duration: float = 3.0) -> void:
    if message_label:
        message_label.text = text
    message_timer = duration
