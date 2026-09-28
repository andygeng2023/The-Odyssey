class_name OdysseyMapUI
extends CanvasLayer

class MapArt extends Control:
    func _draw() -> void:
        draw_rect(Rect2(Vector2.ZERO, size), Color(0.72,0.68,0.53,1))
        for y in range(0, int(size.y), 36):
            draw_line(Vector2(0,y), Vector2(size.x,y), Color(0.57,0.60,0.49,0.18), 1)
        for x in range(0, int(size.x), 42):
            draw_line(Vector2(x,0), Vector2(x,size.y), Color(0.57,0.60,0.49,0.14), 1)
        draw_rect(Rect2(Vector2.ZERO, size), Color(0.25,0.47,0.50,0.24))
        var coast := PackedVector2Array([Vector2(80,330),Vector2(100,260),Vector2(145,210),Vector2(215,170),Vector2(285,145),Vector2(360,170),Vector2(410,225),Vector2(470,245),Vector2(500,330),Vector2(455,405),Vector2(350,420),Vector2(250,390),Vector2(180,405),Vector2(105,380)])
        draw_colored_polygon(coast, Color(0.49,0.57,0.36,0.92))
        draw_polyline(coast, Color(0.30,0.35,0.24,0.95), 4)
        for p in [Vector2(180,280),Vector2(235,235),Vector2(300,260),Vector2(355,220),Vector2(400,290)]:
            draw_circle(p, 34, Color(0.40,0.49,0.30,0.42))
        for p in [Vector2(120,300),Vector2(445,330),Vector2(250,355)]:
            draw_circle(p, 6, Color(0.72,0.53,0.28,0.9))
            draw_circle(p, 2.5, Color(0.96,0.86,0.58,1))
        draw_string(ThemeDB.fallback_font, Vector2(24,38), "AEGEAN COAST", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(0.28,0.30,0.25,0.82))
        draw_string(ThemeDB.fallback_font, Vector2(375,58), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.24,0.27,0.24,0.9))
        draw_line(Vector2(390,82),Vector2(390,45),Color(0.24,0.27,0.24,0.8),2)

var discovery: OdysseyDiscoverySystem
var player: Odysseus
var panel: Panel
var map_art: Control
var title_label: Label
var destination_box: VBoxContainer
var _open := false

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
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-470, -300)
    panel.size = Vector2(940, 600)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.055, 0.075, 0.065, 0.98)
    style.border_color = Color(0.84, 0.70, 0.40, 0.98)
    style.set_border_width_all(3)
    style.set_corner_radius_all(22)
    panel.add_theme_stylebox_override("panel", style)
    panel.visible = false
    add_child(panel)

    title_label = Label.new()
    title_label.position = Vector2(30, 18)
    title_label.size = Vector2(600, 42)
    title_label.text = "THE AEGEAN  •  DISCOVERY MAP"
    title_label.add_theme_font_size_override("font_size", 25)
    title_label.add_theme_color_override("font_color", Color(0.96,0.86,0.63,1))
    panel.add_child(title_label)

    var subtitle := Label.new()
    subtitle.position = Vector2(32, 52)
    subtitle.size = Vector2(600, 24)
    subtitle.text = "Chart the coast. Discover landmarks. Return to places you have truly found."
    subtitle.add_theme_font_size_override("font_size", 13)
    subtitle.add_theme_color_override("font_color", Color(0.62,0.69,0.63,1))
    panel.add_child(subtitle)

    map_art = MapArt.new()
    map_art.position = Vector2(26, 92)
    map_art.size = Vector2(548, 470)
    map_art.mouse_filter = Control.MOUSE_FILTER_IGNORE

    panel.add_child(map_art)

    var right := Panel.new()
    right.position = Vector2(592, 92)
    right.size = Vector2(320, 470)
    var right_style := StyleBoxFlat.new()
    right_style.bg_color = Color(0.035,0.050,0.044,0.96)
    right_style.border_color = Color(0.28,0.35,0.28,1)
    right_style.set_border_width_all(1)
    right_style.set_corner_radius_all(14)
    right.add_theme_stylebox_override("panel", right_style)
    panel.add_child(right)

    var heading := Label.new()
    heading.position = Vector2(18,16)
    heading.size = Vector2(280,28)
    heading.text = "DISCOVERED DESTINATIONS"
    heading.add_theme_font_size_override("font_size",16)
    heading.add_theme_color_override("font_color",Color(0.92,0.82,0.58,1))
    right.add_child(heading)

    destination_box = VBoxContainer.new()
    destination_box.position = Vector2(14, 54)
    destination_box.size = Vector2(292, 390)
    destination_box.add_theme_constant_override("separation", 8)
    right.add_child(destination_box)

    var close := Button.new()
    close.text = "CLOSE"
    close.position = Vector2(810, 22)
    close.size = Vector2(100, 40)
    close.focus_mode = Control.FOCUS_NONE
    close.pressed.connect(close_map)
    _style_button(close, false)
    panel.add_child(close)

func _style_button(button: Button, selected: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.12,0.16,0.13,0.96) if not selected else Color(0.33,0.29,0.18,0.98)
    normal.border_color = Color(0.63,0.55,0.36,0.9)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(9)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", normal.duplicate())
    button.add_theme_color_override("font_color", Color(0.92,0.87,0.72,1))
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
        button.text = "✦  " + str(entry.title) + "\n    " + str(entry.region)
        button.custom_minimum_size = Vector2(0, 56)
        button.focus_mode = Control.FOCUS_NONE
        _style_button(button, false)
        button.pressed.connect(_fast_travel.bind(str(id)))
        destination_box.add_child(button)
    if not found:
        var empty := Label.new()
        empty.text = "No landmarks discovered yet.\nExplore the coast to reveal your map."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.add_theme_color_override("font_color",Color(0.62,0.67,0.61,1))
        destination_box.add_child(empty)

func _fast_travel(id: String) -> void:
    if player == null or discovery == null or not discovery.can_fast_travel_to(id):
        return
    var destination := discovery.fast_travel(id)
    if destination == Vector3.INF:
        return
    player.global_position = destination + Vector3.UP * 0.95
    player.velocity = Vector3.ZERO
    close_map()
    var hud := get_node_or_null("../GameHUD") as OdysseyGameHUD
    if hud:
        hud.show_message("Travelled to " + str(discovery.landmarks[id].title) + ".", 3.0)

func toggle() -> void:
    if _open:
        close_map()
    else:
        open_map()

func open_map() -> void:
    _open = true
    panel.visible = true
    _refresh("")
    var controls := get_node_or_null("../../MobileLayer/MobileControls") as OdysseyMobileControls
    if controls:
        controls.visible = false

func close_map() -> void:
    _open = false
    panel.visible = false
    var controls := get_node_or_null("../../MobileLayer/MobileControls") as OdysseyMobileControls
    if controls:
        controls.visible = true
