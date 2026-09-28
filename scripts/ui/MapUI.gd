class_name OdysseyMapUI
extends CanvasLayer

var discovery: OdysseyDiscoverySystem
var panel: Panel
var map_label: Label
var title_label: Label
var _open := false

func bind_discovery(value: OdysseyDiscoverySystem) -> void:
    discovery = value
    if discovery:
        discovery.discovered.connect(_refresh)
    _build()
    _refresh("")

func _build() -> void:
    if panel:
        return
    panel = Panel.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-360, -250)
    panel.size = Vector2(720, 500)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.035, 0.055, 0.07, 0.97)
    style.border_color = Color(0.88, 0.78, 0.55, 0.95)
    style.set_border_width_all(3)
    style.set_corner_radius_all(18)
    panel.add_theme_stylebox_override("panel", style)
    panel.visible = false
    add_child(panel)

    title_label = Label.new()
    title_label.position = Vector2(24, 18)
    title_label.size = Vector2(560, 40)
    title_label.text = "THE AEGEAN — DISCOVERY MAP"
    title_label.add_theme_font_size_override("font_size", 23)
    title_label.add_theme_color_override("font_color", Color(1, 0.92, 0.72, 1))
    panel.add_child(title_label)

    var close := Button.new()
    close.text = "CLOSE"
    close.position = Vector2(610, 18)
    close.size = Vector2(84, 40)
    close.pressed.connect(close_map)
    panel.add_child(close)

    map_label = Label.new()
    map_label.position = Vector2(28, 74)
    map_label.size = Vector2(650, 390)
    map_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    map_label.add_theme_font_size_override("font_size", 17)
    map_label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.86, 1))
    panel.add_child(map_label)

func _refresh(_id: String) -> void:
    if not map_label or not discovery:
        return
    var lines: Array[String] = [
        "DISCOVERED DESTINATIONS",
        "────────────────────────",
        discovery.map_text()
    ]
    map_label.text = "\n".join(lines)

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
    var controls := get_node_or_null("../MobileLayer/MobileControls") as OdysseyMobileControls
    if controls:
        controls.visible = true
