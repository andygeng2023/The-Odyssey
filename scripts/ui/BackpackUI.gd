class_name OdysseyBackpackUI
extends Control

const TAB_HEIGHT := 48.0
const CARD_HEIGHT := 86.0
const PREVIEW_RATIO := 0.31

var inventory: OdysseyInventory
var tabs: Array[Button] = []
var tabs_scroll: ScrollContainer
var tabs_box: HBoxContainer
var item_scroll: ScrollContainer
var item_grid: GridContainer
var count_label: Label
var detail_title: Label
var detail_text: Label
var carry_button: Button
var close_button: Button
var _active_tab := "Foodstuff"
var _selected_id := ""
var _selected_entry: Dictionary = {}
var _mobile_controls: OdysseyMobileControls

var preview_container: SubViewportContainer
var preview_viewport: SubViewport
var preview_camera: Camera3D
var preview_root: Node3D

const TAB_DEFINITIONS := [
    ["Foodstuff", "FOOD"],
    ["Materials", "MATERIALS"],
    ["Other", "OTHER"],
    ["Equipment", "EQUIP"],
    ["Blueprints", "PLANS"],
    ["Important", "QUEST"]
]

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    mouse_filter = Control.MOUSE_FILTER_STOP
    visible = false
    set_process_input(true)
    _mobile_controls = get_node_or_null("../../MobileLayer/MobileControls") as OdysseyMobileControls
    _build_ui()
    _build_3d_preview()
    queue_redraw()

func bind_inventory(value: OdysseyInventory) -> void:
    inventory = value
    if not inventory.changed.is_connected(_refresh):
        inventory.changed.connect(_refresh)
    _refresh()

func _build_ui() -> void:
    close_button = Button.new()
    close_button.text = "CLOSE  [B]"
    close_button.focus_mode = Control.FOCUS_NONE
    close_button.pressed.connect(close)
    _style_button(close_button, false)
    add_child(close_button)

    count_label = Label.new()
    count_label.add_theme_font_size_override("font_size", 15)
    count_label.add_theme_color_override("font_color", Color(0.87, 0.80, 0.62, 1))
    add_child(count_label)

    tabs_scroll = ScrollContainer.new()
    tabs_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    tabs_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    tabs_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
    add_child(tabs_scroll)

    tabs_box = HBoxContainer.new()
    tabs_box.add_theme_constant_override("separation", 7)
    tabs_scroll.add_child(tabs_box)

    for definition in TAB_DEFINITIONS:
        var button := Button.new()
        button.text = definition[1]
        button.custom_minimum_size = Vector2(94, TAB_HEIGHT)
        button.focus_mode = Control.FOCUS_NONE
        button.pressed.connect(_select_tab.bind(definition[0]))
        _style_button(button, definition[0] == _active_tab)
        tabs_box.add_child(button)
        tabs.append(button)

    item_scroll = ScrollContainer.new()
    item_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    item_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    item_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
    add_child(item_scroll)

    item_grid = GridContainer.new()
    item_grid.columns = 2
    item_grid.add_theme_constant_override("h_separation", 9)
    item_grid.add_theme_constant_override("v_separation", 9)
    item_scroll.add_child(item_grid)

    detail_title = Label.new()
    detail_title.text = "SELECT AN ITEM"
    detail_title.add_theme_font_size_override("font_size", 18)
    detail_title.add_theme_color_override("font_color", Color(0.94, 0.86, 0.66, 1))
    add_child(detail_title)

    detail_text = Label.new()
    detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_text.add_theme_font_size_override("font_size", 13)
    detail_text.add_theme_color_override("font_color", Color(0.68, 0.70, 0.68, 1))
    add_child(detail_text)

    carry_button = Button.new()
    carry_button.text = "CARRY"
    carry_button.focus_mode = Control.FOCUS_NONE
    carry_button.pressed.connect(_carry_selected)
    _style_button(carry_button, true)
    add_child(carry_button)

func _style_button(button: Button, selected: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.20, 0.25, 0.28, 0.98) if not selected else Color(0.48, 0.37, 0.20, 1)
    normal.border_color = Color(0.83, 0.70, 0.42, 0.95)
    normal.set_border_width_all(2 if selected else 1)
    normal.set_corner_radius_all(9)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.30, 0.34, 0.35, 1)
    var pressed := hover.duplicate() as StyleBoxFlat
    pressed.bg_color = Color(0.55, 0.43, 0.22, 1)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("focus", hover)
    button.add_theme_color_override("font_color", Color(0.96, 0.91, 0.78, 1))
    button.add_theme_font_size_override("font_size", 13)

func _process(_delta: float) -> void:
    if visible:
        _layout()
        _sync_3d_preview()

func _layout() -> void:
    var s := size
    var left := s.x * 0.035
    var top := s.y * 0.055
    var width := s.x * 0.93
    var height := s.y * 0.89

    close_button.position = Vector2(left + width - 142, top + 18)
    close_button.size = Vector2(122, 38)
    count_label.position = Vector2(left + width - 340, top + 27)
    count_label.size = Vector2(180, 24)

    var content_top := top + 92
    var content_bottom := top + height - 26
    var content_height := content_bottom - content_top
    var preview_width := clampf(width * PREVIEW_RATIO, 230.0, 360.0)
    var right_left := left + preview_width + 18
    var right_width := width - preview_width - 18

    tabs_scroll.position = Vector2(right_left, content_top)
    tabs_scroll.size = Vector2(right_width, TAB_HEIGHT)
    tabs_box.size = Vector2(maxf(right_width, tabs_box.get_combined_minimum_size().x), TAB_HEIGHT)

    var detail_height := 92.0
    item_scroll.position = Vector2(right_left, content_top + TAB_HEIGHT + 10)
    item_scroll.size = Vector2(right_width, content_height - TAB_HEIGHT - detail_height - 24)

    var columns_width := maxf(120.0, (right_width - 9.0) / 2.0)
    for child in item_grid.get_children():
        if child is Control:
            child.custom_minimum_size = Vector2(columns_width, CARD_HEIGHT)

    detail_title.position = Vector2(right_left, content_bottom - detail_height)
    detail_title.size = Vector2(right_width - 122, 28)
    detail_text.position = Vector2(right_left, content_bottom - detail_height + 28)
    detail_text.size = Vector2(right_width - 122, 58)
    carry_button.position = Vector2(right_left + right_width - 108, content_bottom - 54)
    carry_button.size = Vector2(100, 40)

    if preview_container:
        var preview_rect := Rect2(left, content_top, preview_width - 8, content_height)
        preview_container.position = preview_rect.position
        preview_container.size = preview_rect.size
        preview_viewport.size = Vector2i(maxi(1, int(preview_rect.size.x)), maxi(1, int(preview_rect.size.y)))
        _position_preview_camera()

func _draw() -> void:
    var s := size
    draw_rect(Rect2(Vector2.ZERO, s), Color(0.018, 0.028, 0.032, 0.72))
    var left := s.x * 0.035
    var top := s.y * 0.055
    var width := s.x * 0.93
    var height := s.y * 0.89

    _draw_panel(Rect2(left, top, width, height), Color(0.15, 0.18, 0.18, 0.97), Color(0.86, 0.70, 0.39, 0.98), 3.0, 22.0)
    draw_string(ThemeDB.fallback_font, Vector2(left + 26, top + 44), "ADVENTURE POUCH", HORIZONTAL_ALIGNMENT_LEFT, 330, 28, Color(0.97, 0.89, 0.69, 1))
    draw_string(ThemeDB.fallback_font, Vector2(left + 28, top + 67), "ODYSSEUS  •  TRAVEL KIT", HORIZONTAL_ALIGNMENT_LEFT, 330, 12, Color(0.61, 0.68, 0.70, 1))

    var content_top := top + 92
    var content_height := height - 118
    var preview_width := clampf(width * PREVIEW_RATIO, 230.0, 360.0)
    var preview := Rect2(left, content_top, preview_width - 8, content_height)
    _draw_panel(preview, Color(0.20, 0.23, 0.21, 0.98), Color(0.37, 0.44, 0.45, 1), 1.0, 16.0)
    draw_string(ThemeDB.fallback_font, preview.position + Vector2(18, 30), "ODYSSEUS", HORIZONTAL_ALIGNMENT_LEFT, 200, 16, Color(0.89, 0.82, 0.65, 1))

    var right := Rect2(left + preview_width + 18, content_top, width - preview_width - 18, content_height)
    _draw_panel(right, Color(0.12, 0.15, 0.15, 0.94), Color(0.25, 0.31, 0.33, 1), 1.0, 16.0)

func _draw_panel(rect: Rect2, fill: Color, border: Color, border_width: float, radius: float) -> void:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(int(border_width))
    style.set_corner_radius_all(int(radius))
    draw_style_box(style, rect)

func _build_3d_preview() -> void:
    preview_container = SubViewportContainer.new()
    preview_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    preview_container.stretch = true
    add_child(preview_container)

    preview_viewport = SubViewport.new()
    preview_viewport.transparent_bg = false
    preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    preview_viewport.handle_input_locally = false
    preview_viewport.msaa_3d = Viewport.MSAA_2X
    preview_container.add_child(preview_viewport)

    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.025, 0.035, 0.045, 1)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.75, 0.79, 0.84, 1)
    env.ambient_light_energy = 1.2
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.environment = env
    preview_viewport.add_child(environment)

    preview_root = Node3D.new()
    preview_viewport.add_child(preview_root)

    var source := get_tree().get_first_node_in_group("odyssey_player") as Node3D
    if source:
        for child in source.get_children():
            if child is MeshInstance3D:
                var visual := child.duplicate() as MeshInstance3D
                visual.process_mode = Node.PROCESS_MODE_DISABLED
                visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
                preview_root.add_child(visual)

    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-24, 150, 0)
    key.light_energy = 1.8
    preview_viewport.add_child(key)

    var fill := DirectionalLight3D.new()
    fill.rotation_degrees = Vector3(-10, -35, 0)
    fill.light_energy = 0.65
    preview_viewport.add_child(fill)

    preview_camera = Camera3D.new()
    preview_camera.fov = 35
    preview_camera.near = 0.02
    preview_camera.far = 20
    preview_viewport.add_child(preview_camera)
    _position_preview_camera()

func _position_preview_camera() -> void:
    if not preview_camera or not preview_root or not preview_container:
        return
    var distance := clampf(preview_container.size.y / 150.0, 2.4, 3.8)
    preview_camera.position = Vector3(0, 1.18, -distance)
    preview_camera.look_at(Vector3(0, 1.05, 0), Vector3.UP)

func _sync_3d_preview() -> void:
    if not preview_root:
        return
    var source := get_tree().get_first_node_in_group("odyssey_player") as Node3D
    if not source:
        return
    for child in preview_root.get_children():
        if child is MeshInstance3D:
            var source_child := source.get_node_or_null(str(child.name)) as MeshInstance3D
            if source_child:
                child.visible = source_child.visible
                child.transform = source_child.transform
                child.mesh = source_child.mesh
                child.material_override = source_child.material_override

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("backpack"):
        if visible:
            close()
        else:
            open()
        get_viewport().set_input_as_handled()
    elif visible and event.is_action_pressed("ui_cancel"):
        close()
        get_viewport().set_input_as_handled()

func open() -> void:
    visible = true
    if _mobile_controls:
        _mobile_controls.set_overlay_active(true)
    _refresh()
    queue_redraw()

func close() -> void:
    visible = false
    if _mobile_controls:
        _mobile_controls.set_overlay_active(false)
    queue_redraw()

func toggle() -> void:
    if visible:
        close()
    else:
        open()

func _select_tab(tab_name: String) -> void:
    _active_tab = tab_name
    _selected_id = ""
    _selected_entry = {}
    for i in tabs.size():
        _style_button(tabs[i], TAB_DEFINITIONS[i][0] == _active_tab)
    _refresh()

func _refresh() -> void:
    if not item_grid or not inventory:
        return
    for child in item_grid.get_children():
        child.queue_free()

    var entries: Array[Dictionary] = inventory.get_category_entries(_active_tab)
    if entries.is_empty():
        var empty := Label.new()
        empty.text = "Nothing here yet.\nExplore, gather and discover."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        empty.add_theme_font_size_override("font_size", 17)
        empty.add_theme_color_override("font_color", Color(0.62, 0.66, 0.67, 1))
        item_grid.add_child(empty)
    else:
        for entry in entries:
            item_grid.add_child(_make_item_button(entry))

    if count_label:
        count_label.text = "CARRY  %d / %d" % [inventory.equipment.size(), inventory.equipment_capacity]

    if _selected_id == "":
        detail_title.text = "SELECT AN ITEM"
        detail_text.text = "Choose an item to inspect it. Equipment can be carried from here."
        carry_button.visible = false
    else:
        detail_title.text = str(_selected_entry.get("name", "ITEM"))
        detail_text.text = str(_selected_entry.get("description", ""))
        carry_button.visible = _active_tab == "Equipment"
        carry_button.disabled = inventory.equipment.has(_selected_id) or inventory.equipment.size() >= inventory.equipment_capacity

    queue_redraw()

func _make_item_button(entry: Dictionary) -> Button:
    var button := Button.new()
    button.text = _item_icon(str(entry.get("id", ""))) + "  " + str(entry.get("name", "Item")) + "\n× " + str(entry.get("amount", 0))
    button.tooltip_text = str(entry.get("description", ""))
    button.alignment = HORIZONTAL_ALIGNMENT_LEFT
    button.focus_mode = Control.FOCUS_NONE
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.set_meta("item_id", str(entry.get("id", "")))
    button.pressed.connect(_select_entry.bind(entry))
    _style_item_button(button, str(entry.get("id", "")) == _selected_id)
    return button

func _item_icon(id: String) -> String:
    match id:
        "wood":
            return "✦"
        "stone":
            return "◆"
        "rope":
            return "≋"
        "fiber":
            return "❧"
        "herb":
            return "✿"
        "fruit":
            return "●"
        "shell":
            return "◈"
        "flint":
            return "◇"
        _:
            return "•"

func _style_item_button(button: Button, selected: bool) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.23, 0.27, 0.25, 0.92) if not selected else Color(0.62, 0.48, 0.23, 1)
    normal.border_color = Color(0.36, 0.43, 0.44, 1) if not selected else Color(0.86, 0.70, 0.39, 1)
    normal.set_border_width_all(2 if selected else 1)
    normal.set_corner_radius_all(11)
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.34, 0.38, 0.34, 1)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    button.add_theme_color_override("font_color", Color(0.94, 0.88, 0.73, 1))
    button.add_theme_font_size_override("font_size", 16)

func _select_entry(entry: Dictionary) -> void:
    _selected_entry = entry
    _selected_id = str(entry.get("id", ""))
    for child in item_grid.get_children():
        if child is Button:
            var is_selected := str(child.get_meta("item_id", "")) == _selected_id
            _style_item_button(child, is_selected)
    queue_redraw()
    _refresh_detail_only()

func _refresh_detail_only() -> void:
    if _selected_id == "":
        return
    detail_title.text = str(_selected_entry.get("name", "ITEM"))
    detail_text.text = str(_selected_entry.get("description", ""))
    carry_button.visible = _active_tab == "Equipment"
    carry_button.disabled = inventory.equipment.has(_selected_id) or inventory.equipment.size() >= inventory.equipment_capacity

func _carry_selected() -> void:
    if inventory and _active_tab == "Equipment" and _selected_id != "":
        if inventory.equip(_selected_id):
            _refresh()
