class_name OdysseyMobileControls
extends Control

signal interact_pressed
signal action_pressed(action: String)
signal camera_drag(delta: Vector2)

var move_vector: Vector2 = Vector2.ZERO
var _move_touch: int = -1
var _camera_touch: int = -1
var _move_center: Vector2 = Vector2.ZERO
var _camera_last: Vector2 = Vector2.ZERO
var _buttons: Dictionary = {
    "jump": Rect2(),
    "interact": Rect2(),
    "action": Rect2()
}

func _ready() -> void:
    set_process_input(true)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

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
                return
            if touch.position.x < size.x * 0.48 and _move_touch == -1:
                _move_touch = touch.index
                _move_center = touch.position
                move_vector = Vector2.ZERO
                queue_redraw()
            elif touch.position.x >= size.x * 0.45 and _camera_touch == -1:
                _camera_touch = touch.index
                _camera_last = touch.position
        else:
            if touch.index == _move_touch:
                _move_touch = -1
                move_vector = Vector2.ZERO
                queue_redraw()
            if touch.index == _camera_touch:
                _camera_touch = -1
    elif event is InputEventScreenDrag:
        var drag: InputEventScreenDrag = event as InputEventScreenDrag
        if drag.index == _move_touch:
            var radius: float = minf(size.x, size.y) * 0.13
            if radius > 0.0:
                move_vector = (drag.position - _move_center).limit_length(radius) / radius
            queue_redraw()
        elif drag.index == _camera_touch:
            var delta: Vector2 = drag.position - _camera_last
            _camera_last = drag.position
            camera_drag.emit(delta)

func _button_at(point: Vector2) -> String:
    for id in _buttons:
        if (_buttons[id] as Rect2).has_point(point):
            return id
    return ""

func _draw() -> void:
    var radius: float = minf(size.x, size.y) * 0.13
    var center: Vector2 = Vector2(size.x * 0.16, size.y * 0.78)
    if _move_touch != -1:
        center = _move_center
    var knob: Vector2 = center + move_vector * radius * 0.58
    draw_circle(center, radius, Color(0.05, 0.08, 0.12, 0.28))
    draw_circle(knob, radius * 0.42, Color(0.9, 0.88, 0.75, 0.62))

    _buttons["jump"] = Rect2(size.x - 190, size.y - 150, 64, 64)
    _buttons["interact"] = Rect2(size.x - 112, size.y - 184, 76, 76)
    _buttons["action"] = Rect2(size.x - 198, size.y - 82, 64, 64)
    for id in _buttons:
        var rect: Rect2 = _buttons[id] as Rect2
        draw_circle(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.48, Color(0.06, 0.10, 0.16, 0.48))
        draw_arc(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.48, 0.0, TAU, 32, Color(0.95, 0.9, 0.72, 0.65), 2.0)
        draw_string(ThemeDB.fallback_font, rect.get_center() + Vector2(-14, 7), id.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(1, 1, 1, 0.9))
