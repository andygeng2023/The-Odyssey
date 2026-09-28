class_name OdysseyGameHUD
extends CanvasLayer

var hud_label: Label
var message_label: Label
var message_timer := 0.0
var player: Odysseus
var inventory: OdysseyInventory
var survival: OdysseySurvivalSystem
var weather: OdysseyWeatherSystem
var underwater_overlay: ColorRect

func _ready() -> void:
    var panel := Panel.new()
    panel.position = Vector2(18, 18)
    panel.size = Vector2(440, 145)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.045, 0.065, 0.88)
    style.border_color = Color(0.92, 0.84, 0.62, 0.85)
    style.set_border_width_all(2)
    style.set_corner_radius_all(14)
    panel.add_theme_stylebox_override("panel", style)
    add_child(panel)

    hud_label = Label.new()
    hud_label.position = Vector2(18, 14)
    hud_label.size = Vector2(404, 72)
    hud_label.add_theme_font_size_override("font_size", 17)
    hud_label.add_theme_color_override("font_color", Color(1, 0.96, 0.82, 1))
    panel.add_child(hud_label)

    var instruction_label := Label.new()
    instruction_label.position = Vector2(18, 86)
    instruction_label.size = Vector2(404, 48)
    instruction_label.text = "MOVE  •  DRAG RIGHT TO LOOK\nJUMP  •  INTERACT  •  EXPLORE"
    instruction_label.add_theme_font_size_override("font_size", 14)
    instruction_label.add_theme_color_override("font_color", Color(0.90, 0.93, 0.96, 1))
    panel.add_child(instruction_label)

    var message_panel := Panel.new()
    message_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    message_panel.position = Vector2(-430, -112)
    message_panel.size = Vector2(860, 72)
    var message_style := StyleBoxFlat.new()
    message_style.bg_color = Color(0.02, 0.04, 0.06, 0.84)
    message_style.border_color = Color(0.82, 0.73, 0.48, 0.72)
    message_style.set_border_width_all(2)
    message_style.set_corner_radius_all(16)
    message_panel.add_theme_stylebox_override("panel", message_style)

    underwater_overlay = ColorRect.new()
    underwater_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    underwater_overlay.color = Color(0.02, 0.18, 0.30, 0.30)
    underwater_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    underwater_overlay.visible = false
    add_child(underwater_overlay)
    move_child(underwater_overlay, 0)
    add_child(message_panel)

    survival = get_node_or_null("../../Systems/Survival") as OdysseySurvivalSystem
    weather = get_node_or_null("../../Systems/Weather") as OdysseyWeatherSystem

    message_label = Label.new()
    message_label.set_anchors_preset(Control.PRESET_FULL_RECT)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    message_label.add_theme_font_size_override("font_size", 17)
    message_label.add_theme_color_override("font_color", Color(1, 0.96, 0.86, 1))
    message_panel.add_child(message_label)

func bind_player(value: Odysseus) -> void:
    player = value

func bind_inventory(value: OdysseyInventory) -> void:
    inventory = value

func _process(delta: float) -> void:
    message_timer = maxf(0.0, message_timer - delta)
    if message_timer <= 0.0 and message_label:
        message_label.text = ""
    if player and inventory and hud_label:
        underwater_overlay.visible = player.underwater
        hud_label.text = "THE ODYSSEY  •  THE SHORE\nWood %d   Stone %d   Rope %d   Stamina %d%%" % [
            int(inventory.bulk.get("wood", 0)),
            int(inventory.bulk.get("stone", 0)),
            int(inventory.bulk.get("rope", 0)),
            int(player.traversal.stamina)
        ]
        if survival:
            hud_label.text += "\nFood %d   Warmth %d   Oxygen %d" % [int(survival.hunger), int(survival.warmth), int(survival.oxygen)]
        if weather:
            hud_label.text += "   Weather " + weather.condition_name().capitalize()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("map"):
        var map_ui := get_node_or_null("../MapLayer/MapUI") as OdysseyMapUI
        if map_ui:
            map_ui.toggle()

func show_message(text: String, duration: float = 3.0) -> void:
    if message_label:
        message_label.text = text
    message_timer = duration
