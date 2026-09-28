class_name OdysseyMobileControls
extends Control

signal interact_pressed
signal action_pressed(action: String)
signal camera_drag(delta: Vector2)
signal backpack_pressed

const JOYSTICK_DEADZONE: float = 0.14
const JOYSTICK_RADIUS: float = 92.0
const CAMERA_SENSITIVITY: float = 0.006
const BUTTON_SIZE: float = 88.0
const BUTTON_GAP: float = 14.0
const CAMERA_START_X: float = 0.34
const BACKPACK_SIZE: float = 74.0

var move_vector := Vector2.ZERO
var _touch_roles: Dictionary = {}
var _mouse_camera_active := false
var _camera_last := Vector2.ZERO
var _buttons: Dictionary = {}

func _ready() -> void:
    # This control owns the complete mobile input surface. The visible Button
    # nodes are visual only; handling the hit rectangles here makes touch and
    # mouse behavior deterministic across web and mobile.
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    process_mode = Node.PROCESS_MODE_ALWAYS
    set_process_input(true)
    _create_action_buttons()
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _create_action_buttons() -> void:
    for id in ["jump", "interact", "sprint", "backpack"]:
        var button := Button.new()
        button.name = id.capitalize() + "Button"
        button.focus_mode = Control.FOCUS_NONE
        button.mouse_filter = Control.MOUSE_FILTER_STOP
        button.z_index = 100
        button.button_down.connect(_on_button_pressed.bind(id))
        button.add_theme_font_size_override("font_size", 13 if id != "backpack" else 12)
        add_child(button)
        _buttons[id] = button
    _style_action_buttons()

func _style_action_buttons() -> void:
    for id: String in _buttons.keys():
        var button: Button = _buttons[id] as Button
        var normal := StyleBoxFlat.new()
        normal.bg_color = Color(0.025, 0.04, 0.07, 0.90)
        normal.border_color = Color(0.95, 0.88, 0.68, 0.90)
        normal.set_border_width_all(3)
        normal.set_corner_radius_all(44)
        var hover := normal.duplicate() as StyleBoxFlat
        hover.bg_color = Color(0.12, 0.14, 0.18, 0.96)
        var pressed := hover.duplicate() as StyleBoxFlat
        pressed.bg_color = Color(0.24, 0.20, 0.12, 0.98)
        button.add_theme_stylebox_override("normal", normal)
        button.add_theme_stylebox_override("hover", hover)
        button.add_theme_stylebox_override("pressed", pressed)
        button.add_theme_stylebox_override("focus", hover)
        button.add_theme_color_override("font_color", Color(1, 0.98, 0.90, 0.96))
        button.add_theme_color_override("font_hover_color", Color(1, 0.98, 0.90, 1))
        button.add_theme_color_override("font_pressed_color", Color(1, 0.98, 0.90, 1))

func _process(_delta: float) -> void:
    _layout_buttons()

func _layout_buttons() -> void:
    if _buttons.is_empty():
        return
    var margin := 30.0
    var bottom := size.y - margin
    var right := size.x - margin
    var rects := _button_rects()
    for id: String in _buttons.keys():
        var button: Button = _buttons[id] as Button
        var rect: Rect2 = rects[id] as Rect2
        button.position = rect.position
        button.size = rect.size
        button.text = "BAG" if id == "backpack" else id.to_upper()

func _joystick_center() -> Vector2:
    return Vector2(maxf(118.0, size.x * 0.15), size.y - maxf(122.0, size.y * 0.17))

func _button_rects() -> Dictionary:
    var margin := 30.0
    var bottom := size.y - margin
    var right := size.x - margin
    return {
        "jump": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE * 2.0 - BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE),
        "interact": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE),
        "sprint": Rect2(right - BUTTON_SIZE * 2.0 - BUTTON_GAP, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE),
        "backpack": Rect2(right - BACKPACK_SIZE, 28.0, BACKPACK_SIZE, BACKPACK_SIZE)
    }

func _button_at(point: Vector2) -> String:
    var rects := _button_rects()
    for id: String in rects.keys():
        var rect: Rect2 = rects[id] as Rect2
        if rect.has_point(point):
            return id
    return ""

func _camera_zone(point: Vector2) -> bool:
    return point.x >= size.x * CAMERA_START_X and _button_at(point) == ""

func _on_button_pressed(button: String) -> void:
    var player := get_tree().get_first_node_in_group("odyssey_player") as Odysseus
    if player:
        match button:
            "interact":
                player.try_interact()
            "jump":
                player.handle_mobile_action("jump")
            "sprint":
                player.handle_mobile_action("sprint")
    if button == "backpack":
        var backpack_ui := get_node_or_null("../../BackpackLayer/BackpackUI") as OdysseyBackpackUI
        if backpack_ui:
            backpack_ui.toggle()
    if button == "interact":
        interact_pressed.emit()
    elif button == "backpack":
        backpack_pressed.emit()
    else:
        action_pressed.emit(button)

func _on_gui_button_pressed(button: String) -> void:
    _on_button_pressed(button)

func _input(event: InputEvent) -> void:
    # Read the viewport-level input before any child Control can consume it.
    # This is the authoritative route for touch/click gameplay controls.
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed:
            var joystick := _joystick_center()
            if touch.position.distance_to(joystick) <= JOYSTICK_RADIUS and not _touch_roles.has(touch.index):
                _touch_roles[touch.index] = "move"
                move_vector = Vector2.ZERO
                queue_redraw()
                get_viewport().set_input_as_handled()
                return
            if _camera_zone(touch.position) and not _touch_roles.has(touch.index):
                _touch_roles[touch.index] = "camera"
                _camera_last = touch.position
                get_viewport().set_input_as_handled()
        else:
            if _touch_roles.has(touch.index):
                var role: String = str(_touch_roles[touch.index])
                _touch_roles.erase(touch.index)
                if role == "move":
                    move_vector = Vector2.ZERO
                    queue_redraw()
                get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if not _touch_roles.has(drag.index):
            return
        var role: String = str(_touch_roles[drag.index])
        if role == "move":
            var offset := drag.position - _joystick_center()
            var stick := Vector2.ZERO if offset.length() <= JOYSTICK_RADIUS * JOYSTICK_DEADZONE else offset.limit_length(JOYSTICK_RADIUS) / JOYSTICK_RADIUS
            move_vector = Vector2(stick.x, -stick.y)
            queue_redraw()
            get_viewport().set_input_as_handled()
        elif role == "camera":
            var delta := drag.position - _camera_last
            _camera_last = drag.position
            if delta.length_squared() > 1.0:
                camera_drag.emit(delta * CAMERA_SENSITIVITY)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            if _camera_zone(event.position):
                _mouse_camera_active = true
                _camera_last = event.position
                get_viewport().set_input_as_handled()
        else:
            _mouse_camera_active = false
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and _mouse_camera_active:
        var motion := event as InputEventMouseMotion
        if motion.relative.length_squared() > 1.0:
            camera_drag.emit(motion.relative * CAMERA_SENSITIVITY)
        get_viewport().set_input_as_handled()

func _draw() -> void:
    var center := _joystick_center()
    # move_vector uses gameplay coordinates (up = positive Y), while canvas
    # coordinates use down = positive Y. Flip only when drawing the knob.
    var visual_vector := Vector2(move_vector.x, -move_vector.y)
    var knob := center + visual_vector * JOYSTICK_RADIUS * 0.52
    draw_circle(center, JOYSTICK_RADIUS, Color(0.025, 0.04, 0.07, 0.50))
    draw_arc(center, JOYSTICK_RADIUS, 0.0, TAU, 64, Color(0.95, 0.88, 0.68, 0.78), 3.0)
    draw_circle(knob, JOYSTICK_RADIUS * 0.34, Color(0.94, 0.88, 0.68, 0.86))
