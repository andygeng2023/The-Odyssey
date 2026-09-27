class_name OdysseyAdventureCamera
extends Node3D

@export var height: float = 4.8
@export var sensitivity: float = 0.72
@export var min_pitch: float = -0.55
@export var max_pitch: float = 0.30
@export var target_path: NodePath = NodePath("../Player")

var yaw: float = 0.0
var pitch: float = -0.20
var _target: Node3D

func _ready() -> void:
    _target = get_node_or_null(target_path) as Node3D
    if _target == null:
        push_warning("AdventureCamera target not found: " + str(target_path))
    var controls := get_node_or_null("../UI/MobileControls") as OdysseyMobileControls
    if controls:
        controls.camera_drag.connect(_on_camera_drag)
    _apply_camera_transform()

func _process(_delta: float) -> void:
    _apply_camera_transform()

func _apply_camera_transform() -> void:
    if not is_instance_valid(_target):
        return
    global_position = _target.global_position + Vector3.UP * height
    rotation = Vector3(pitch, yaw, 0.0)

func _on_camera_drag(delta: Vector2) -> void:
    yaw -= delta.x * sensitivity
    pitch = clampf(pitch - delta.y * sensitivity, min_pitch, max_pitch)
    _apply_camera_transform()
