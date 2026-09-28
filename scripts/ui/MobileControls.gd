class_name OdysseyMobileControls
extends Control

signal interact_pressed
signal action_pressed(action: String)
signal camera_drag(delta: Vector2)
signal backpack_pressed

const JOYSTICK_RADIUS_RATIO: float = 0.105
const JOYSTICK_DEADZONE: float = 0.14
const CAMERA_SENSITIVITY: float = 0.006
const BUTTON_SIZE: float = 88.0
const BUTTON_GAP: float = 14.0
const CAMERA_START_X: float = 0.38
const CAMERA_DRAG_THRESHOLD: float = 2.0
const BACKPACK_SIZE: float = 74.0

var move_vector: Vector2 = Vector2.ZERO
var _move_touch: int = -1
var _camera_touch: int = -1
var _camera_last: Vector2 = Vector2.ZERO
var _mouse_camera_active: bool = false
var _buttons: Dictionary = {}

func _ready() -> void:
    set_process_input(true)
    mouse_filter = Control.MOUSE_FILTER_PASS
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
        button.flat = false
        button.add_theme_font_size_override("font_size", 13 if id != "backpack" else 12)
        button.pressed.connect(_on_gui_button_pressed.bind(id))
        add_child(button)
        _buttons[id] = button
    _style_action_buttons()

func _style_action_buttons() -> void:
    for id: String in _buttons.keys():
        var button: Button = _buttons[id] as Button
        var normal := StyleBoxFlat.new()
        normal.bg_color = Color(0.025, 0.04, 0.07, 0.86)
        normal.border_color = Color(0.95, 0.88, 0.68, 0.86)
        normal.set_border_width_all(3)
        normal.set_corner_radius_all(44)
        var hover := normal.duplicate() as StyleBoxFlat
        hover.bg_color = Color(0.12, 0.14, 0.18, 0.94)
        var pressed := hover.duplicate() as StyleBoxFlat
        pressed.bg_color = Color(0.24, 0.20, 0.12, 0.96)
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
    var margin: float = 30.0
    var bottom: float = size.y - margin
    var right: float = size.x - margin
    var rects := _button_rects()
    for id: String in _buttons.keys():
        var button: Button = _buttons[id] as Button
        var rect: Rect2 = rects[id] as Rect2
        button.position = rect.position
        button.size = rect.size
        button.text = "BAG" if id == "backpack" else id.to_upper()
        button.tooltip_text = id.capitalize()

func _joystick_center() -> Vector2:
    return Vector2(maxf(118.0, size.x * 0.15), size.y - maxf(122.0, size.y * 0.17))

func _button_rects() -> Dictionary:
    var margin: float = 30.0
    var bottom: float = size.y - margin
    var right: float = size.x - margin
    return {
        "jump": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE * 2.0 - BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE),
        "interact": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE),
        "sprint": Rect2(right - BUTTON_SIZE * 2.0 - BUTTON_GAP, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE),
        "backpack": Rect2(right - BACKPACK_SIZE, 28.0, BACKPACK_SIZE, BACKPACK_SIZE)
    }

func _button_at(point: Vector2) -> String:
    var rects: Dictionary = _button_rects()
    for id: String in rects.keys():
        var rect: Rect2 = rects[id] as Rect2
        if rect.has_point(point):
            return id
    return ""

func _is_camera_zone(point: Vector2) -> bool:
    return point.x >= size.x * CAMERA_START_X and _button_at(point) == ""

func _on_gui_button_pressed(button: String) -> void:
    _emit_button(button)

func _emit_button(button: String) -> void:
    if button == "interact":
        interact_pressed.emit()
    elif button == "backpack":
        backpack_pressed.emit()
    else:
        action_pressed.emit(button)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch: InputEventScreenTouch = event as InputEventScreenTouch
        if touch.pressed:
            # Real Button children own button taps. Only the joystick/camera are handled here.
            if _button_at(touch.position) != "":
                return
            var joystick_center: Vector2 = _joystick_center()
            var joystick_radius: float = maxf(74.0, minf(size.x, size.y) * 0.24)
            if touch.position.distance_to(joystick_center) <= joystick_radius and _move_touch == -1:
                _move_touch = touch.index
                move_vector = Vector2.ZERO
                queue_redraw()
                get_viewport().set_input_as_handled()
                return
            if _is_camera_zone(touch.position) and _camera_touch == -1:
                _camera_touch = touch.index
                _camera_last = touch.position
                get_viewport().set_input_as_handled()
        else:
            if touch.index == _move_touch:
                _move_touch = -1
                move_vector = Vector2.ZERO
                queue_redraw()
                get_viewport().set_input_as_handled()
            if touch.index == _camera_touch:
                _camera_touch = -1
                get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag:
        var drag: InputEventScreenDrag = event as InputEventScreenDrag
        if drag.index == _move_touch:
            var radius: float = maxf(74.0, minf(size.x, size.y) * JOYSTICK_RADIUS_RATIO)
            var offset: Vector2 = drag.position - _joystick_center()
            var stick_vector: Vector2 = Vector2.ZERO if offset.length() <= radius * JOYSTICK_DEADZONE else offset.limit_length(radius) / radius
            move_vector = Vector2(stick_vector.x, -stick_vector.y)
            queue_redraw()
            get_viewport().set_input_as_handled()
        elif drag.index == _camera_touch:
            var delta: Vector2 = drag.position - _camera_last
            _camera_last = drag.position
            if delta.length() >= CAMERA_DRAG_THRESHOLD:
                camera_drag.emit(delta * CAMERA_SENSITIVITY)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton:
        var mouse_button: InputEventMouseButton = event as InputEventMouseButton
        if mouse_button.button_index == MOUSE_BUTTON_LEFT:
            if mouse_button.pressed:
                if _button_at(mouse_button.position) != "":
                    # Let the real Button child receive the click.
                    return
                if _is_camera_zone(mouse_button.position):
                    _mouse_camera_active = true
                    get_viewport().set_input_as_handled()
            else:
                _mouse_camera_active = false
                get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and _mouse_camera_active:
        var motion: InputEventMouseMotion = event as InputEventMouseMotion
        if motion.relative.length() >= CAMERA_DRAG_THRESHOLD:
            camera_drag.emit(motion.relative * CAMERA_SENSITIVITY)
        get_viewport().set_input_as_handled()

func _draw() -> void:
    var center: Vector2 = _joystick_center()
    var radius: float = maxf(74.0, minf(size.x, size.y) * JOYSTICK_RADIUS_RATIO)
    var knob: Vector2 = center + move_vector * radius * 0.52
    draw_circle(center, radius, Color(0.025, 0.04, 0.07, 0.48))
    draw_arc(center, radius, 0.0, TAU, 64, Color(0.95, 0.88, 0.68, 0.78), 3.0)
    draw_circle(knob, radius * 0.34, Color(0.94, 0.88, 0.68, 0.84))
