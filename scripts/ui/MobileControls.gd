class_name OdysseyMobileControls
extends Control

signal interact_pressed
signal action_pressed(action: String)
signal camera_drag(delta: Vector2)

const JOYSTICK_RADIUS_RATIO: float = 0.105
const JOYSTICK_DEADZONE: float = 0.14
const CAMERA_SENSITIVITY: float = 0.00115
const BUTTON_SIZE: float = 88.0
const BUTTON_GAP: float = 14.0
const CAMERA_START_X: float = 0.38
const CAMERA_DRAG_THRESHOLD: float = 3.0

var move_vector: Vector2 = Vector2.ZERO
var _move_touch: int = -1
var _camera_touch: int = -1
var _camera_last: Vector2 = Vector2.ZERO
var _mouse_camera_active: bool = false

func _ready() -> void:
    set_process_input(true)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _joystick_center() -> Vector2:
    return Vector2(maxf(118.0, size.x * 0.15), size.y - maxf(122.0, size.y * 0.17))

func _button_rects() -> Dictionary:
    var margin: float = 30.0
    var bottom: float = size.y - margin
    var right: float = size.x - margin
    return {
        "jump": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE * 2.0 - BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE),
        "interact": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE),
        "action": Rect2(right - BUTTON_SIZE * 2.0 - BUTTON_GAP, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE)
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

func _emit_button(button: String) -> void:
    if button == "interact":
        interact_pressed.emit()
    else:
        action_pressed.emit(button)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch: InputEventScreenTouch = event as InputEventScreenTouch
        if touch.pressed:
            var button: String = _button_at(touch.position)
            if button != "":
                _emit_button(button)
                get_viewport().set_input_as_handled()
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
            move_vector = Vector2.ZERO if offset.length() <= radius * JOYSTICK_DEADZONE else offset.limit_length(radius) / radius
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
                var button: String = _button_at(mouse_button.position)
                if button != "":
                    _emit_button(button)
                    get_viewport().set_input_as_handled()
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
    var rects: Dictionary = _button_rects()
    for id: String in rects.keys():
        var rect: Rect2 = rects[id] as Rect2
        var c: Vector2 = rect.get_center()
        var r: float = rect.size.x * 0.46
        draw_circle(c, r, Color(0.025, 0.04, 0.07, 0.68))
        draw_arc(c, r, 0.0, TAU, 56, Color(0.95, 0.88, 0.68, 0.82), 3.0)
        draw_string(ThemeDB.fallback_font, c + Vector2(-22.0, 6.0), id.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 44.0, 12, Color(1, 0.98, 0.90, 0.96))
