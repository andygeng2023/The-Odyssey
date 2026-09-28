class_name OdysseyAdventureCamera
extends Node3D

@export var height: float = 1.62
@export var sensitivity: float = 0.78
@export var min_pitch: float = -0.62
@export var max_pitch: float = 0.38
@export var follow_speed: float = 11.0
@export var target_path: NodePath = NodePath("../Player")

var yaw := 0.0
var pitch := -0.12
var _target: Node3D
var _follow_position := Vector3.ZERO

func _ready() -> void:
    _target = get_node_or_null(target_path) as Node3D
    if _target == null:
        push_warning("AdventureCamera target not found: " + str(target_path))
        return
    _follow_position = _target.global_position + Vector3.UP * height
    var arm := get_node_or_null("SpringArm3D") as SpringArm3D
    if arm:
        arm.add_excluded_object(_target.get_rid())
    var controls := get_node_or_null("../UI/MobileLayer/MobileControls") as OdysseyMobileControls
    if controls:
        controls.camera_drag.connect(_on_camera_drag)
    _apply_camera_transform(1.0)

func _process(delta: float) -> void:
    _apply_camera_transform(delta)

func _apply_camera_transform(delta: float) -> void:
    if not is_instance_valid(_target):
        return
    var desired := _target.global_position + Vector3.UP * height
    var blend := 1.0 - exp(-follow_speed * maxf(delta, 0.001))
    _follow_position = _follow_position.lerp(desired, blend)
    global_position = _follow_position
    rotation = Vector3(pitch, yaw, 0.0)

func _on_camera_drag(delta: Vector2) -> void:
    yaw -= delta.x * sensitivity
    pitch = clampf(pitch - delta.y * sensitivity, min_pitch, max_pitch)
    _apply_camera_transform(1.0)

func snap_to_target() -> void:
    if not is_instance_valid(_target):
        return
    _follow_position = _target.global_position + Vector3.UP * height
    _apply_camera_transform(1.0)
