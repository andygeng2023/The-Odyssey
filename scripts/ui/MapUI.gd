class_name OdysseyMapUI
extends CanvasLayer

class MapArt extends Control:
    func _draw() -> void:
        draw_rect(Rect2(Vector2.ZERO, size), Color(0.64, 0.69, 0.60, 1))
        for y in range(0, int(size.y), 34):
            draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.36, 0.45, 0.38, 0.12), 1)
        for x in range(0, int(size.x), 42):
            draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.36, 0.45, 0.38, 0.10), 1)

        var coast := PackedVector2Array([
            Vector2(size.x * 0.10, size.y * 0.72),
            Vector2(size.x * 0.15, size.y * 0.54),
            Vector2(size.x * 0.26, size.y * 0.40),
            Vector2(size.x * 0.40, size.y * 0.30),
            Vector2(size.x * 0.56, size.y * 0.36),
            Vector2(size.x * 0.67, size.y * 0.49),
            Vector2(size.x * 0.78, size.y * 0.52),
            Vector2(size.x * 0.88, size.y * 0.68),
            Vector2(size.x * 0.76, size.y * 0.83),
            Vector2(size.x * 0.58, size.y * 0.86),
            Vector2(size.x * 0.40, size.y * 0.79),
            Vector2(size.x * 0.23, size.y * 0.88)
        ])
        draw_colored_polygon(coast, Color(0.42, 0.52, 0.31, 0.95))
        draw_polyline(coast, Color(0.24, 0.30, 0.22, 0.95), 4.0)

        for p in [
            Vector2(size.x * 0.34, size.y * 0.52),
            Vector2(size.x * 0.48, size.y * 0.42),
            Vector2(size.x * 0.61, size.y * 0.60),
            Vector2(size.x * 0.72, size.y * 0.43)
        ]:
            draw_circle(p, minf(size.x, size.y) * 0.055, Color(0.35, 0.46, 0.28, 0.34))

        draw_string(ThemeDB.fallback_font, Vector2(18, 28), "AEGEAN COAST", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.20, 0.25, 0.21, 0.86))
        var north := Vector2(size.x - 30, 32)
        draw_string(ThemeDB.fallback_font, north, "N", HORIZONTAL_ALIGNMENT_CENTER, 24, 18, Color(0.20, 0.25, 0.21, 0.9))
        draw_line(north + Vector2(0, 8), north + Vector2(0, 36), Color(0.20, 0.25, 0.21, 0.75), 2)

var discovery: OdysseyDiscoverySystem
var player: Odysseus
var panel: Panel
var map_art: Control
var title_label: Label
var destination_box: VBoxContainer
var close_button: Button
var hint_label: Label
var _open := false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    layer = 60

func bind_player(value: Odysseus) -> void:
    player = value

func bind_discovery(value: OdysseyDiscoverySystem) -> void:
    discovery = value
    if discovery and not discovery.discovered.is_connected(_refresh):
        discovery.discovered.connect(_refresh)
    _build()
    _refresh("")

func _build() -> void:
    if panel:
        return

    panel = Panel.new()
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.set_anchors_preset(Control.PRESET_FULL_RECT)
    panel.offset_left = 32.0
    panel.offset_top = 28.0
    panel.offset_right = -32.0
    panel.offset_bottom = -28.0
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.035, 0.050, 0.045, 0.985)
    style.border_color = Color(0.88, 0.72, 0.39, 0.98)
    style.set_border_width_all(3)
    style.set_corner_radius_all(20)
    panel.add_theme_stylebox_override("panel", style)
    panel.visible = false
    add_child(panel)

    title_label = Label.new()
    title_label.text = "THE AEGEAN  •  DISCOVERY MAP"
    title_label.add_theme_font_size_override("font_size", 26)
    title_label.add_theme_color_override("font_color", Color(0.96, 0.86, 0.63, 1))
    panel.add_child(title_label)

    hint_label = Label.new()
    hint_label.text = "Tap a discovered landmark to travel there. Discovery unlocks destinations; the map never reveals what you have not found."
    hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hint_label.add_theme_font_size_override("font_size", 13)
    hint_label.add_theme_color_override("font_color", Color(0.62, 0.69, 0.63, 1))
    panel.add_child(hint_label)

    map_art = MapArt.new()
    map_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(map_art)

    var right := Panel.new()
    right.mouse_filter = Control.MOUSE_FILTER_STOP
    var right_style := StyleBoxFlat.new()
    right_style.bg_color = Color(0.025, 0.038, 0.034, 0.98)
    right_style.border_color = Color(0.28, 0.35, 0.28, 1)
    right_style.set_border_width_all(1)
    right_style.set_corner_radius_all(14)
    right.add_theme_stylebox_override("panel", right_style)
    panel.add_child(right)

    var heading := Label.new()
    heading.text = "DISCOVERED DESTINATIONS"
    heading.add_theme_font_size_override("font_size", 16)
    heading.add_theme_color_override("font_color", Color(0.92, 0.82, 0.58, 1))
    right.add_child(heading)

    destination_box = VBoxContainer.new()
    destination_box.add_theme_constant_override("separation", 8)
    destination_box.mouse_filter = Control.MOUSE_FILTER_PASS
    right.add_child(destination_box)

    close_button = Button.new()
    close_button.text = "CLOSE"
    close_button.focus_mode = Control.FOCUS_NONE
    close_button.pressed.connect(close_map)
    _style_button(close_button, false)
    panel.add_child(close_button)

func _process(_delta: float) -> void:
    if panel and panel.visible:
        _layout()

func _layout() -> void:
    var s := panel.size
    var margin := 24.0
    title_label.position = Vector2(margin, 18)
    title_label.size = Vector2(maxf(260.0, s.x - 190.0), 34)
    close_button.position = Vector2(s.x - 122.0, 18)
    close_button.size = Vector2(96.0, 38)

    hint_label.position = Vector2(margin, 54)
    hint_label.size = Vector2(maxf(280.0, s.x - 180.0), 38)

    var content_top := 102.0
    var content_bottom := s.y - 22.0
    var content_height := maxf(180.0, content_bottom - content_top)
    var map_width := clampf(s.x * 0.60, 300.0, 700.0)
    var gap := 14.0
    var right_width := s.x - margin * 2.0 - map_width - gap

    map_art.position = Vector2(margin, content_top)
    map_art.size = Vector2(map_width, content_height)

    var right := destination_box.get_parent() as Panel
    right.position = Vector2(margin + map_width + gap, content_top)
    right.size = Vector2(maxf(220.0, right_width), content_height)

    var heading := right.get_child(0) as Label
    heading.position = Vector2(16, 14)
    heading.size = Vector2(right.size.x - 32.0, 26)

    destination_box.position = Vector2(12, 52)
    destination_box.size = Vector2(right.size.x - 24.0, right.size.y - 66.0)

func _style_button(button: Button, selected: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.11, 0.15, 0.13, 0.98) if not selected else Color(0.30, 0.27, 0.17, 1)
    normal.border_color = Color(0.66, 0.56, 0.36, 0.92)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(9)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.19, 0.23, 0.18, 1)
    var pressed := hover.duplicate() as StyleBoxFlat
    pressed.bg_color = Color(0.35, 0.29, 0.17, 1)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_color_override("font_color", Color(0.93, 0.88, 0.74, 1))
    button.add_theme_font_size_override("font_size", 13)

func _refresh(_id: String) -> void:
    if not destination_box or not discovery:
        return
    for child in destination_box.get_children():
        child.queue_free()

    var found := false
    for id in discovery.landmarks.keys():
        if not discovery.is_discovered(str(id)):
            continue
        found = true
        var entry: Dictionary = discovery.landmarks[id]
        var button := Button.new()
        button.text = "✦  " + str(entry.title) + "  •  " + str(entry.region)
        button.custom_minimum_size = Vector2(0, 58)
        button.focus_mode = Control.FOCUS_NONE
        button.mouse_filter = Control.MOUSE_FILTER_STOP
        _style_button(button, false)
        button.pressed.connect(_fast_travel.bind(str(id)))
        destination_box.add_child(button)

    if not found:
        var empty := Label.new()
        empty.text = "No landmarks discovered yet.\nExplore the coast to reveal your map."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.add_theme_color_override("font_color", Color(0.62, 0.67, 0.61, 1))
        empty.add_theme_font_size_override("font_size", 15)
        destination_box.add_child(empty)

func _fast_travel(id: String) -> void:
    if player == null or discovery == null or not discovery.can_fast_travel_to(id):
        return
    var destination := discovery.fast_travel(id)
    if destination == Vector3.INF:
        return

    player.velocity = Vector3.ZERO
    player.global_position = Vector3(destination.x, destination.y + 1.05, destination.z)
    close_map()

    var hud := get_node_or_null("../../GameHUD") as OdysseyGameHUD
    if hud:
        hud.show_message("Travelled to " + str(discovery.landmarks[id].title) + ".", 3.0)

func _input(event: InputEvent) -> void:
    if not _open:
        return
    if event.is_action_pressed("map") or event.is_action_pressed("ui_cancel"):
        close_map()
        get_viewport().set_input_as_handled()

func toggle() -> void:
    if _open:
        close_map()
    else:
        open_map()

func open_map() -> void:
    _open = true
    _build()
    panel.visible = true
    _refresh("")
    var controls := get_node_or_null("../../MobileLayer/MobileControls") as OdysseyMobileControls
    if controls:
        controls.set_overlay_active(true)

func close_map() -> void:
    _open = false
    if panel:
        panel.visible = false
    var controls := get_node_or_null("../MobileLayer/MobileControls") as OdysseyMobileControls
    if controls:
        controls.set_overlay_active(false)
