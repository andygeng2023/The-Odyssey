class_name OdysseyWaterVolume
extends Area3D

@export var surface_height := 0.0
@export var bounds := Vector3(50.0, 8.0, 27.5)

func _ready() -> void:
    add_to_group("water_volume")
    monitoring = true

func contains(point: Vector3) -> bool:
    return absf(point.x) <= bounds.x and absf(point.z + 27.5) <= bounds.z and point.y >= -bounds.y and point.y <= surface_height + 1.5

func is_underwater(point: Vector3) -> bool:
    return contains(point) and point.y < surface_height - 0.45
