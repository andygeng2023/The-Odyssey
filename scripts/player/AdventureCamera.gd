class_name OdysseyAdventureCamera
extends Node3D

@export var distance: float = 8.5
@export var height: float = 5.2
@export var sensitivity: float = 1.0
@export var min_pitch: float = -0.45
@export var max_pitch: float = 0.35
var yaw: float = 0.0
var pitch: float = -0.28

func _ready() -> void:
    top_level = true
    var controls := get_node_or_null("../../UI/MobileControls") as OdysseyMobileControls
    if controls:
        controls.camera_drag.connect(_on_camera_drag)

func _process(_delta: float) -> void:
    var target := get_parent().global_position
    global_position = target + Vector3(0.0, height, 0.0)
    rotation.x = pitch
    rotation.y = yaw

func _on_camera_drag(delta: Vector2) -> void:
    yaw -= delta.x * sensitivity
    pitch = clamp(pitch - delta.y * sensitivity, min_pitch, max_pitch)
