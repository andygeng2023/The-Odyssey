class_name OdysseyBackpackUI
extends Control

const PANEL_MARGIN := 42.0
const PREVIEW_RATIO := 0.30
const TAB_HEIGHT := 52.0
const ROW_HEIGHT := 72.0

var inventory: OdysseyInventory
var tabs: Array[Button] = []
var item_list: VBoxContainer
var count_label: Label
var hint_label: Label
var close_button: Button
var _active_tab := "Foodstuff"
var _mobile_controls: OdysseyMobileControls
var preview_container: SubViewportContainer
var preview_viewport: SubViewport
var preview_camera: Camera3D
var preview_root: Node3D

const TAB_DEFINITIONS := [
    ["Foodstuff", "FOOD"],
    ["Materials", "MATERIALS"],
    ["Other", "OTHER"],
    ["Equipment", "EQUIPMENT"],
    ["Blueprints", "BLUEPRINTS"],
    ["Important", "IMPORTANT"]
]

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    mouse_filter = Control.MOUSE_FILTER_STOP
    visible = false
    set_process_input(true)
    _mobile_controls = get_node_or_null("../../MobileLayer/MobileControls") as OdysseyMobileControls
    if _mobile_controls:
        if not _mobile_controls.backpack_pressed.is_connected(toggle):
            _mobile_controls.backpack_pressed.connect(toggle)
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
    close_button.add_theme_font_size_override("font_size", 16)
    close_button.pressed.connect(close)
    add_child(close_button)

    count_label = Label.new()
    count_label.add_theme_font_size_override("font_size", 15)
    count_label.add_theme_color_override("font_color", Color(0.78, 0.72, 0.57, 1))
    add_child(count_label)

    hint_label = Label.new()
    hint_label.text = "Ordinary resources are effectively unlimited. Equipment uses carrying capacity."
    hint_label.add_theme_font_size_override("font_size", 14)
    hint_label.add_theme_color_override("font_color", Color(0.67, 0.70, 0.72, 1))
    add_child(hint_label)

    for definition in TAB_DEFINITIONS:
        var button := Button.new()
        button.text = definition[1]
        button.focus_mode = Control.FOCUS_NONE
        button.add_theme_font_size_override("font_size", 13)
        button.button_down.connect(_select_tab.bind(definition[0]))
        add_child(button)
        tabs.append(button)

    item_list = VBoxContainer.new()
    item_list.add_theme_constant_override("separation", 8)
    add_child(item_list)

func _process(_delta: float) -> void:
    if visible:
        _layout()
        _sync_3d_preview()

func _layout() -> void:
    var s := size
    var left := s.x * 0.04
    var top := s.y * 0.07
    var width := s.x * 0.92
    var height := s.y * 0.86
    close_button.position = Vector2(left + width - 152.0, top + 20.0)
    close_button.size = Vector2(132.0, 38.0)
    count_label.position = Vector2(left + width - 360.0, top + 30.0)
    count_label.size = Vector2(190.0, 24.0)
    hint_label.position = Vector2(left + 24.0, top + height - 42.0)
    hint_label.size = Vector2(width - 48.0, 26.0)

    var content_left := left + width * PREVIEW_RATIO + 22.0
    var content_top := top + 132.0
    var content_width := width * (1.0 - PREVIEW_RATIO) - 44.0
    var content_height := height - 190.0
    var tab_width := content_width / float(tabs.size())
    for i in tabs.size():
        tabs[i].position = Vector2(content_left + i * tab_width, top + 78.0)
        tabs[i].size = Vector2(tab_width - 5.0, TAB_HEIGHT)
    item_list.position = Vector2(content_left, content_top)
    item_list.size = Vector2(content_width, content_height)
    if preview_container:
        var preview_rect := Rect2(left + 22.0, top + 88.0, width * PREVIEW_RATIO - 10.0, height - 138.0)
        preview_container.position = preview_rect.position
        preview_container.size = preview_rect.size
        preview_viewport.size = Vector2i(maxi(1, int(preview_rect.size.x)), maxi(1, int(preview_rect.size.y)))
        _position_preview_camera()
    for child in item_list.get_children():
        if child is Control:
            child.custom_minimum_size = Vector2(content_width, ROW_HEIGHT)

func _draw() -> void:
    var s := size
    draw_rect(Rect2(Vector2.ZERO, s), Color(0.008, 0.012, 0.018, 0.78))
    var left := s.x * 0.04
    var top := s.y * 0.07
    var width := s.x * 0.92
    var height := s.y * 0.86
    _draw_panel(Rect2(left, top, width, height), Color(0.055, 0.047, 0.035, 0.98), Color(0.76, 0.61, 0.32, 0.95), 2.0, 18.0)
    draw_string(ThemeDB.fallback_font, Vector2(left + 28.0, top + 43.0), "BACKPACK", HORIZONTAL_ALIGNMENT_LEFT, 300.0, 28, Color(0.96, 0.88, 0.67, 1))
    draw_string(ThemeDB.fallback_font, Vector2(left + 30.0, top + 67.0), "ODYSSEUS", HORIZONTAL_ALIGNMENT_LEFT, 300.0, 13, Color(0.60, 0.62, 0.60, 1))

    var preview := Rect2(left + 22.0, top + 88.0, width * PREVIEW_RATIO - 10.0, height - 138.0)
    _draw_panel(preview, Color(0.025, 0.034, 0.043, 1), Color(0.36, 0.31, 0.22, 1), 1.0, 14.0)
    draw_string(ThemeDB.fallback_font, preview.position + Vector2(20.0, 34.0), "EQUIPMENT", HORIZONTAL_ALIGNMENT_LEFT, 220.0, 17, Color(0.88, 0.80, 0.63, 1))

    var right := Rect2(left + width * PREVIEW_RATIO + 10.0, top + 88.0, width * (1.0 - PREVIEW_RATIO) - 32.0, height - 138.0)
    _draw_panel(right, Color(0.035, 0.037, 0.038, 0.96), Color(0.25, 0.25, 0.23, 1), 1.0, 14.0)

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
    env.background_color = Color(0.018, 0.024, 0.032, 1.0)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.76, 0.82, 1.0)
    env.ambient_light_energy = 1.15
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.environment = env
    preview_viewport.add_child(environment)

    preview_root = Node3D.new()
    preview_root.name = "OdysseusPreview"
    preview_viewport.add_child(preview_root)

    var source := get_tree().get_first_node_in_group("odyssey_player") as Node3D
    if source:
        for child in source.get_children():
            if child is MeshInstance3D:
                var visual := child.duplicate() as MeshInstance3D
                visual.process_mode = Node.PROCESS_MODE_DISABLED
                visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
                preview_root.add_child(visual)
    else:
        push_warning("Backpack preview could not find the live player model.")

    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-24.0, 150.0, 0.0)
    key.light_energy = 1.8
    key.shadow_enabled = false
    preview_viewport.add_child(key)

    var fill := DirectionalLight3D.new()
    fill.rotation_degrees = Vector3(-10.0, -35.0, 0.0)
    fill.light_energy = 0.65
    fill.shadow_enabled = false
    preview_viewport.add_child(fill)

    preview_camera = Camera3D.new()
    preview_camera.fov = 35.0
    preview_camera.near = 0.02
    preview_camera.far = 20.0
    preview_viewport.add_child(preview_camera)
    _position_preview_camera()

func _position_preview_camera() -> void:
    if not preview_camera or not preview_root or not preview_container:
        return
    var height := maxf(1.0, preview_container.size.y)
    var distance := clampf(height / 150.0, 2.4, 3.8)
    preview_camera.position = Vector3(0.0, 1.18, -distance)
    preview_camera.look_at(Vector3(0.0, 1.08, 0.0), Vector3.UP)
    preview_root.position = Vector3(0.0, 0.0, 0.0)
    preview_root.rotation = Vector3.ZERO

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
        toggle()
        get_viewport().set_input_as_handled()

func toggle() -> void:
    if visible:
        close()
    else:
        open()

func open() -> void:
    visible = true
    if _mobile_controls:
        _mobile_controls.visible = false
    _refresh()
    queue_redraw()

func close() -> void:
    visible = false
    if _mobile_controls:
        _mobile_controls.visible = true
    queue_redraw()

func _select_tab(tab_name: String) -> void:
    if tab_name == _active_tab:
        return
    _active_tab = tab_name
    for i in tabs.size():
        var selected: bool = TAB_DEFINITIONS[i][0] == _active_tab
        tabs[i].disabled = selected
    _refresh()

func _refresh() -> void:
    if not item_list or not inventory:
        return
    for child in item_list.get_children():
        child.queue_free()
    var entries: Array[Dictionary] = inventory.get_category_entries(_active_tab)
    if entries.is_empty():
        var empty := Label.new()
        empty.text = "Nothing here yet. Explore, gather and discover."
        empty.add_theme_font_size_override("font_size", 18)
        empty.add_theme_color_override("font_color", Color(0.62, 0.64, 0.63, 1))
        empty.custom_minimum_size = Vector2(0, ROW_HEIGHT)
        item_list.add_child(empty)
    else:
        for entry in entries:
            item_list.add_child(_make_item_row(entry))
    if count_label:
        count_label.text = "CARRY  %d / %d" % [inventory.equipment.size(), inventory.equipment_capacity]
    for i in tabs.size():
        tabs[i].disabled = TAB_DEFINITIONS[i][0] == _active_tab
    queue_redraw()

func _make_item_row(entry: Dictionary) -> Control:
    var row := Panel.new()
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.075, 0.075, 0.068, 0.94)
    style.border_color = Color(0.23, 0.22, 0.19, 1)
    style.set_border_width_all(1)
    style.set_corner_radius_all(10)
    row.add_theme_stylebox_override("panel", style)
    row.custom_minimum_size = Vector2(0, ROW_HEIGHT)

    var name_label := Label.new()
    name_label.text = str(entry.get("name", "Item"))
    name_label.position = Vector2(18, 8)
    name_label.size = Vector2(0, 25)
    name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
    name_label.anchor_right = 0.55
    name_label.offset_right = -8.0
    name_label.add_theme_font_size_override("font_size", 17)
    name_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.75, 1))
    row.add_child(name_label)

    var description := Label.new()
    description.text = str(entry.get("description", ""))
    description.position = Vector2(18, 36)
    description.size = Vector2(0, 22)
    description.set_anchors_preset(Control.PRESET_TOP_WIDE)
    description.anchor_right = 0.74
    description.offset_right = -8.0
    description.add_theme_font_size_override("font_size", 12)
    description.add_theme_color_override("font_color", Color(0.59, 0.61, 0.60, 1))
    row.add_child(description)

    var amount := Label.new()
    amount.text = "× %d" % int(entry.get("amount", 0))
    amount.position = Vector2(0, 20)
    amount.size = Vector2(0, 28)
    amount.set_anchors_preset(Control.PRESET_TOP_WIDE)
    amount.anchor_left = 0.55
    amount.anchor_right = 0.73
    amount.offset_left = 4.0
    amount.offset_right = -8.0
    amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    amount.add_theme_font_size_override("font_size", 17)
    amount.add_theme_color_override("font_color", Color(0.84, 0.77, 0.59, 1))
    row.add_child(amount)

    if _active_tab == "Equipment":
        var carry := Button.new()
        carry.text = "CARRY"
        carry.position = Vector2(0, 16)
        carry.size = Vector2(0, 40)
        carry.set_anchors_preset(Control.PRESET_TOP_WIDE)
        carry.anchor_left = 0.75
        carry.anchor_right = 0.98
        carry.offset_left = 4.0
        carry.offset_right = -4.0
        carry.focus_mode = Control.FOCUS_NONE
        carry.disabled = inventory.equipment.has(str(entry.get("id", ""))) or inventory.equipment.size() >= inventory.equipment_capacity
        carry.pressed.connect(_equip_entry.bind(str(entry.get("id", ""))))
        row.add_child(carry)
    return row

func _equip_entry(item_id: String) -> void:
    if inventory.equip(item_id):
        _refresh()
