class_name OdysseyMobileControls
extends Control

signal interact_pressed
signal action_pressed(action: String)
signal camera_drag(delta: Vector2)

const JOYSTICK_RADIUS_RATIO: float = 0.12
const JOYSTICK_DEADZONE: float = 0.12
const CAMERA_SENSITIVITY: float = 0.0025
const BUTTON_SIZE: float = 92.0

var move_vector: Vector2 = Vector2.ZERO
var _move_touch: int = -1
var _camera_touch: int = -1
var _camera_last: Vector2 = Vector2.ZERO

func _ready() -> void:
    set_process_input(true)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _joystick_center() -> Vector2:
    return Vector2(maxf(112.0, size.x * 0.15), size.y - maxf(116.0, size.y * 0.17))

func _button_rects() -> Dictionary:
    var margin: float = 28.0
    var bottom: float = size.y - margin
    var right: float = size.x - margin
    return {
        "jump": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE * 2.05, BUTTON_SIZE, BUTTON_SIZE),
        "interact": Rect2(right - BUTTON_SIZE, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE),
        "action": Rect2(right - BUTTON_SIZE * 2.05, bottom - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE)
    }

func _button_at(point: Vector2) -> String:
    var rects: Dictionary = _button_rects()
    for id: String in rects.keys():
        var rect: Rect2 = rects[id] as Rect2
        if rect.has_point(point):
            return id
    return ""

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch: InputEventScreenTouch = event as InputEventScreenTouch
        if touch.pressed:
            var button: String = _button_at(touch.position)
            if button != "":
                if button == "interact":
                    interact_pressed.emit()
                else:
                    action_pressed.emit(button)
                get_viewport().set_input_as_handled()
                return

            var joystick_center: Vector2 = _joystick_center()
            if touch.position.distance_to(joystick_center) <= size.y * 0.28 and _move_touch == -1:
                _move_touch = touch.index
                move_vector = Vector2.ZERO
                queue_redraw()
                get_viewport().set_input_as_handled()
                return

            if touch.position.x > size.x * 0.42 and _camera_touch == -1:
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
            var radius: float = maxf(70.0, minf(size.x, size.y) * JOYSTICK_RADIUS_RATIO)
            var offset: Vector2 = drag.position - _joystick_center()
            if offset.length() < radius * JOYSTICK_DEADZONE:
                move_vector = Vector2.ZERO
            else:
                move_vector = offset.limit_length(radius) / radius
            queue_redraw()
            get_viewport().set_input_as_handled()
        elif drag.index == _camera_touch:
            var delta: Vector2 = drag.position - _camera_last
            _camera_last = drag.position
            if delta.length_squared() > 0.01:
                camera_drag.emit(delta * CAMERA_SENSITIVITY / 0.0025)
            get_viewport().set_input_as_handled()

func _draw() -> void:
    var center: Vector2 = _joystick_center()
    var radius: float = maxf(70.0, minf(size.x, size.y) * JOYSTICK_RADIUS_RATIO)
    var knob: Vector2 = center + move_vector * radius * 0.58
    draw_circle(center, radius, Color(0.03, 0.05, 0.08, 0.42))
    draw_arc(center, radius, 0.0, TAU, 48, Color(0.95, 0.90, 0.72, 0.55), 3.0)
    draw_circle(knob, radius * 0.38, Color(0.90, 0.86, 0.72, 0.72))

    var rects: Dictionary = _button_rects()
    for id: String in rects.keys():
        var rect: Rect2 = rects[id] as Rect2
        var button_center: Vector2 = rect.get_center()
        var button_radius: float = rect.size.x * 0.47
        draw_circle(button_center, button_radius, Color(0.03, 0.05, 0.08, 0.62))
        draw_arc(button_center, button_radius, 0.0, TAU, 40, Color(0.95, 0.90, 0.72, 0.75), 3.0)
        draw_string(ThemeDB.fallback_font, button_center + Vector2(-22.0, 7.0), id.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 44.0, 13, Color(1, 1, 1, 0.95))
