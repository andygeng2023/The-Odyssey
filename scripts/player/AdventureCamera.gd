class_name OdysseyAdventureCamera
extends Node3D

@export var distance := 8.5
@export var height := 5.2
@export var sensitivity := 0.012
@export var min_pitch := -0.45
@export var max_pitch := 0.35
var yaw := 0.0
var pitch := -0.28

func _ready() -> void:
    var controls := get_node_or_null("../../UI/MobileControls") as OdysseyMobileControls
    if controls:
        controls.camera_drag.connect(_on_camera_drag)

func _process(_delta: float) -> void:
    position = Vector3(0, height, distance)
    rotation.x = pitch
    rotation.y = yaw

func _on_camera_drag(delta: Vector2) -> void:
    yaw -= delta.x * sensitivity
    pitch = clamp(pitch - delta.y * sensitivity, min_pitch, max_pitch)
