class_name OdysseyGameHUD
extends CanvasLayer

class HUDArt extends Control:
    var player: Odysseus
    var inventory: OdysseyInventory
    var survival: OdysseySurvivalSystem
    var message := ""
    var message_time := 0.0

    func _ready() -> void:
        mouse_filter = Control.MOUSE_FILTER_IGNORE

    func _process(delta: float) -> void:
        message_time = maxf(0.0, message_time - delta)
        queue_redraw()

    func _draw() -> void:
        if not player:
            return
        var s := size
        var health := survival.health if survival else 5.0
        var max_health := survival.max_health if survival else 5.0
        var hearts := int(ceil(max_health))
        var filled := int(floor(health))
        var partial: float = health - floor(health)

        for i in hearts:
            var center := Vector2(34.0 + i * 30.0, 32.0)
            _draw_heart(center, 9.0, i < filled or (i == filled and partial > 0.01))

        var stamina := clampf(player.traversal.stamina / maxf(1.0, player.traversal.max_stamina), 0.0, 1.0)
        var stamina_active := player.climbing or player.swimming or stamina < 0.995
        if stamina_active:
            var ring_center := Vector2(s.x - 62.0, 52.0)
            draw_arc(ring_center, 27.0, -PI * 0.5, TAU - PI * 0.5, 64, Color(0.08, 0.10, 0.09, 0.55), 8.0, true)
            draw_arc(ring_center, 27.0, -PI * 0.5, -PI * 0.5 + TAU * stamina, 64, Color(0.76, 0.91, 0.56, 0.98), 8.0, true)
            draw_circle(ring_center, 9.0, Color(0.09, 0.12, 0.10, 0.88))
            var ring_text := "O₂" if player.underwater else ("↗" if player.climbing else "·")
            draw_string(ThemeDB.fallback_font, ring_center + Vector2(-7, 6), ring_text, HORIZONTAL_ALIGNMENT_CENTER, 16, 11, Color(0.95, 0.93, 0.82, 1))

        var wood := int(inventory.bulk.get("wood", 0)) if inventory else 0
        var stone := int(inventory.bulk.get("stone", 0)) if inventory else 0
        var rope := int(inventory.bulk.get("rope", 0)) if inventory else 0
        draw_string(ThemeDB.fallback_font, Vector2(28, s.y - 38), "◈ %d    ◆ %d    ≋ %d" % [wood, stone, rope], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.95, 0.89, 0.72, 0.92))

        if message_time > 0.0 and message != "":
            var text_size := ThemeDB.fallback_font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
            var center := Vector2(s.x * 0.5, s.y - 92.0)
            draw_circle(center, 22.0, Color(0.03, 0.05, 0.045, 0.72))
            draw_string(ThemeDB.fallback_font, center + Vector2(-text_size.x * 0.5, 6), message, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.98, 0.94, 0.82, 1))

    func _draw_heart(center: Vector2, radius: float, filled: bool) -> void:
        var c := Color(0.84, 0.24, 0.22, 0.98) if filled else Color(0.14, 0.11, 0.10, 0.60)
        draw_circle(center + Vector2(-radius * 0.42, -radius * 0.18), radius * 0.52, c)
        draw_circle(center + Vector2(radius * 0.42, -radius * 0.18), radius * 0.52, c)
        var points := PackedVector2Array([
            center + Vector2(-radius * 0.92, 0),
            center + Vector2(radius * 0.92, 0),
            center + Vector2(0, radius * 1.05)
        ])
        draw_colored_polygon(points, c)

var player: Odysseus
var inventory: OdysseyInventory
var survival: OdysseySurvivalSystem
var weather: OdysseyWeatherSystem
var underwater_overlay: ColorRect
var art: HUDArt

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 20
    art = HUDArt.new()
    art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(art)

    underwater_overlay = ColorRect.new()
    underwater_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    underwater_overlay.color = Color(0.02, 0.20, 0.30, 0.20)
    underwater_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    underwater_overlay.visible = false
    add_child(underwater_overlay)

    survival = get_node_or_null("../../Systems/Survival") as OdysseySurvivalSystem
    weather = get_node_or_null("../../Systems/Weather") as OdysseyWeatherSystem

func bind_player(value: Odysseus) -> void:
    player = value
    art.player = value

func bind_inventory(value: OdysseyInventory) -> void:
    inventory = value
    art.inventory = value

func _process(_delta: float) -> void:
    if not art or not player:
        return
    art.survival = survival
    underwater_overlay.visible = player.underwater

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("map"):
        var map_ui := get_node_or_null("../MapLayer/MapUI") as OdysseyMapUI
        if map_ui:
            map_ui.toggle()
            get_viewport().set_input_as_handled()

func show_message(text: String, duration: float = 3.0) -> void:
    if art:
        art.message = text
        art.message_time = duration
